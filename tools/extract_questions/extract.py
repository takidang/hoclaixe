"""Extract the official 600-question bank into structured JSON.

Sources (place in data/question-bank/raw/, see docs/data/sources.md):
  - "600 câu hỏi dùng cho sát hạch GPLX cơ giới đường bộ" (Cục CSGT, 2025) — questions, options, images;
    the correct option is the UNDERLINED one (CV 2262/CSGT-P5, part I.1 note).
  - "Hướng dẫn sử dụng bộ câu hỏi ... (CV 2262/CSGT-P5 ngày 07/5/2025)" — chapters, A1/A pool (Phụ lục 1),
    B1 pool (Phụ lục 2), 60 critical questions (Phụ lục 3); the A1/A and B1 critical
    subsets are listed in group 6 of Phụ lục 1 and 2.

Usage:
  python tools/extract_questions/extract.py [--raw data/question-bank/raw] [--out data/question-bank]
"""
import argparse
import glob
import json
import os
import re
from collections import defaultdict

import pymupdf

SOURCE_VERSION = 'CSGT-600-2025 (CV 2262/CSGT-P5 ngày 07/05/2025)'

CHAPTERS = {
    1: 'Quy định chung và quy tắc giao thông đường bộ',
    2: 'Văn hóa giao thông, đạo đức người lái xe, kỹ năng phòng cháy, chữa cháy và cứu hộ, cứu nạn',
    3: 'Kỹ thuật lái xe',
    4: 'Cấu tạo và sửa chữa',
    5: 'Báo hiệu đường bộ',
    6: 'Giải thế sa hình và kỹ năng xử lý tình huống giao thông',
}
ROMAN = {'I': 1, 'II': 2, 'III': 3, 'IV': 4, 'V': 5, 'VI': 6}

# CV 2262 part I.2: hạng B and above use all 600 questions.
FULL_CLASSES = ['B', 'C1', 'C', 'D1', 'D2', 'D', 'BE', 'C1E', 'CE', 'D1E', 'D2E', 'DE']

OPTION_MARK = re.compile(r'^([1-4])\.$')
# "Câu 1. …", "Câu 507: …" and "Câu 512.Theo …" all occur in the source
QUESTION_START = re.compile(r'^Câu\s*(\d{1,3})\s*[\.:]\s*(.*)$')
VOWELS = set('aăâeêioôơuưyáàảãạắằẳẵặấầẩẫậéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ')
COLUMN_GAP = 40  # pt; a gap this wide before an option mark means a second column
UNDERLINE_TOL = 3.5  # pt between text-line bottom and underline top


def find_one(raw, pattern):
    files = glob.glob(os.path.join(raw, pattern))
    if len(files) != 1:
        raise SystemExit(f'Expected exactly one file matching {pattern!r} in {raw}, found {files}')
    return files[0]


# ---------------------------------------------------------------- guide (CV 2262)

def parse_guide(path):
    """Return {'A1_A': set, 'A1_A_critical': set, 'B1': set, 'B1_critical': set, 'critical': set}."""
    text = '\n'.join(page.get_text() for page in pymupdf.open(path))
    parts = re.split(r'PHỤ LỤC\s+(\d)', text)
    appendix = {int(parts[i]): parts[i + 1] for i in range(1, len(parts) - 1, 2)}

    def numbers(block):
        return [int(x) for x in re.findall(r'^\s*(\d{1,3})\s*$', block, flags=re.M)]

    def pool_and_critical(block):
        main, _, crit = re.split(r'(\n\s*6\.\s*Nhóm)', block, maxsplit=1)
        return set(numbers(main)), set(numbers(crit))

    a1a, a1a_crit = pool_and_critical(appendix[1])
    b1, b1_crit = pool_and_critical(appendix[2])
    critical = set(numbers(appendix[3]))
    return {'A1_A': a1a, 'A1_A_critical': a1a_crit, 'B1': b1, 'B1_critical': b1_crit, 'critical': critical}


# ---------------------------------------------------------------- question PDF

def fix_broken_words(text, fixes):
    """Re-join syllables that Word split across lines, e.g. 'đường b ộ' -> 'đường bộ'.

    A lowercase token with no vowel is never a Vietnamese syllable, so it is glued to the next token
    when that token starts with a vowel. Every fix is recorded for human review.
    """
    tokens = text.split(' ')
    out = []
    i = 0
    while i < len(tokens):
        tok = tokens[i]
        nxt = tokens[i + 1] if i + 1 < len(tokens) else ''
        if (tok and tok.isalpha() and tok.islower() and not (set(tok) & VOWELS)
                and nxt and nxt[0].lower() in VOWELS):
            fixes.append(f'{tok} {nxt} -> {tok}{nxt}')
            out.append(tok + nxt)
            i += 2
            continue
        out.append(tok)
        i += 1
    return ' '.join(out)


def clean(text):
    return re.sub(r'\s+', ' ', text).strip()


def page_lines(page):
    """Yield text lines as dicts: words [(x0, x1, text)], bbox, bold flag.

    Words are built from character boxes so that their x positions are exact and stay tied to
    the right line (the 'words' extraction numbers blocks differently on pages with images).
    """
    for block in page.get_text('rawdict')['blocks']:
        for line in block.get('lines', []):
            words, cur = [], None
            bold = False
            for span in line['spans']:
                for ch in span['chars']:
                    c = ch['c']
                    if c.isspace():
                        cur = None
                        continue
                    if span['flags'] & 16:
                        bold = True
                    if cur is None:
                        cur = [ch['bbox'][0], ch['bbox'][2], c]
                        words.append(cur)
                    else:
                        cur[1] = ch['bbox'][2]
                        cur[2] += c
            if words:
                yield {'words': [tuple(w) for w in words], 'bbox': line['bbox'], 'bold': bold}


def split_segments(words):
    """Split a line into option segments. Returns list of (option_no or None, x0, x1, text)."""
    segs = []
    cur = None
    prev_x1 = None
    for x0, x1, w in words:
        m = OPTION_MARK.match(w)
        starts_option = m and (prev_x1 is None or x0 - prev_x1 > COLUMN_GAP)
        if starts_option:
            cur = [int(m.group(1)), x0, x1, []]
            segs.append(cur)
        else:
            if cur is None:
                cur = [None, x0, x1, []]
                segs.append(cur)
            cur[3].append(w)
            cur[2] = x1
        prev_x1 = x1
    return [(n, a, b, ' '.join(ws)) for n, a, b, ws in segs]


def parse_questions(path, images_dir, rel_images):
    doc = pymupdf.open(path)
    questions = {}
    order = []
    chapter = None
    cur = None
    last_opt = None  # option number that continuation lines attach to
    in_chapter_title = False
    issues = defaultdict(list)
    os.makedirs(images_dir, exist_ok=True)

    for pno, page in enumerate(doc):
        lines = list(page_lines(page))
        if not any(l['words'][0][2] == 'Câu' for l in lines) and chapter is None:
            continue  # cover / editorial pages
        underlines = [d['rect'] for d in page.get_drawings()
                      if d['rect'].height < 2.5 and d['rect'].width > 3]
        page_q_starts = []

        for line in lines:
            ws = line['words']
            texts = [w for _, _, w in ws]
            y0, y1 = line['bbox'][1], line['bbox'][3]
            if len(ws) == 1 and re.fullmatch(r'\d+', texts[0]) and y1 < 60:
                continue  # page number in header
            if texts[0] == 'CHƯƠNG' and len(texts) > 1:
                chapter = ROMAN[texts[1].rstrip('.')]
                last_opt = None
                in_chapter_title = True
                continue
            if in_chapter_title and not QUESTION_START.match(' '.join(texts)):
                continue  # 2nd line of a chapter title, e.g. "NĂNG PHÒNG CHÁY, CHỮA CHÁY VÀ CỨU HỘ, CỨU NẠN"
            in_chapter_title = False
            if chapter is None:
                continue
            m_q = QUESTION_START.match(' '.join(texts))
            if m_q and line['bold']:
                n = int(m_q.group(1))
                cur = {'number': n, 'chapter': chapter, 'content': m_q.group(2),
                       'options': {}, 'underlined': set(), 'images': [], 'page': pno + 1}
                questions[n] = cur
                order.append(n)
                page_q_starts.append((y0, n))
                last_opt = None
                continue
            if cur is None:
                continue

            if all(re.fullmatch(r'\d{1,2}', t) for t in texts):
                issues['figure_labels_dropped'].append(cur['number'])
                continue  # numbers printed inside a figure (e.g. "1 2" under two signs)

            segs = split_segments(ws)
            has_marks = any(s[0] for s in segs)
            if not has_marks:
                text = segs[0][3] if len(segs) == 1 else ' '.join(s[3] for s in segs)
                if last_opt is None:
                    cur['content'] += ' ' + text
                else:
                    cur['options'][last_opt] += ' ' + text
                line_segments = [(last_opt, line['bbox'][0], line['bbox'][2])]
            else:
                line_segments = []
                for n, a, b, text in segs:
                    if n is None:  # text before first mark on a marked line — treat as continuation
                        target = last_opt
                        if target is None:
                            cur['content'] += ' ' + text
                        else:
                            cur['options'][target] += ' ' + text
                        continue
                    if n in cur['options']:
                        issues['duplicate_option_mark'].append(cur['number'])
                    cur['options'][n] = text
                    line_segments.append((n, a, b))
                    last_opt = n
                if len(line_segments) > 1:
                    issues['two_column_options'].append(cur['number'])

            for u in underlines:
                if abs(u.y0 - y1) > UNDERLINE_TOL:
                    continue
                for n, a, b in line_segments:
                    if n is not None and u.x0 < b and u.x1 > a:
                        cur['underlined'].add(n)

        # Images sit between a question's text and its options: attach each image to the nearest
        # question starting above it on this page, otherwise to the last question of an earlier page.
        for img in sorted(page.get_images(full=True), key=lambda im: page.get_image_bbox(im).y0):
            bbox = page.get_image_bbox(img)
            above = [(y, n) for y, n in page_q_starts if y <= bbox.y0]
            earlier = [n for n in order if questions[n]['page'] < pno + 1]
            if above:
                qn = max(above)[1]
            elif earlier:
                qn = earlier[-1]
                issues['image_continues_from_previous_page'].append(qn)
            else:
                continue
            info = doc.extract_image(img[0])
            questions[qn]['images'].append((info['ext'], info['image']))

    for n, q in questions.items():
        imgs = q['images']
        if len(imgs) > 1:
            issues['multiple_images'].append(n)
        names = []
        for idx, (ext, data) in enumerate(imgs, 1):
            name = f'q{n:04d}' + (f'_{idx}' if len(imgs) > 1 else '') + '.' + ext
            with open(os.path.join(images_dir, name), 'wb') as fh:
                fh.write(data)
            names.append(f'{rel_images}/{name}')
        q['images'] = names

    return questions, issues


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--raw', default='data/question-bank/raw')
    ap.add_argument('--out', default='data/question-bank')
    args = ap.parse_args()

    q_pdf = find_one(args.raw, '*600 câu hỏi*.pdf')
    guide_pdf = find_one(args.raw, '*Hướng dẫn sử dụng bộ câu hỏi*.pdf')
    images_dir = os.path.join(args.out, 'images')
    for f in glob.glob(os.path.join(images_dir, 'q*.*')):
        os.remove(f)

    guide = parse_guide(guide_pdf)
    questions, issues = parse_questions(q_pdf, images_dir, 'images')

    word_fixes = []
    result = []
    for n in sorted(questions):
        q = questions[n]
        fixes = []
        content = fix_broken_words(clean(q['content']), fixes)
        options = [fix_broken_words(clean(q['options'][k]), fixes) for k in sorted(q['options'])]
        if fixes:
            word_fixes.append({'number': n, 'fixes': fixes})
        if sorted(q['options']) != list(range(1, len(q['options']) + 1)):
            issues['option_numbering_gap'].append(n)
        classes = list(FULL_CLASSES)
        if n in guide['B1']:
            classes.insert(0, 'B1')
        if n in guide['A1_A']:
            classes[:0] = ['A1', 'A']
        # Critical status depends on the license class: Phụ lục 1/2 name only 20/30 of the 60
        # critical questions (Phụ lục 3) as critical for A1, A / B1 — the others are ordinary there.
        critical_for = []
        if n in guide['A1_A_critical']:
            critical_for += ['A1', 'A']
        if n in guide['B1_critical']:
            critical_for.append('B1')
        if n in guide['critical']:
            critical_for += FULL_CLASSES
        result.append({
            'id': f'Q{n:04d}',
            'number': n,
            'chapter': q['chapter'],
            'content': content,
            'images': q['images'],
            'options': options,
            'correctIndex': (min(q['underlined']) - 1) if len(q['underlined']) == 1 else None,
            'criticalFor': critical_for,
            'licenseClasses': classes,
            'sourceVersion': SOURCE_VERSION,
            'sourcePage': q['page'],
        })

    os.makedirs(args.out, exist_ok=True)
    with open(os.path.join(args.out, 'questions.json'), 'w', encoding='utf-8') as fh:
        json.dump({'sourceVersion': SOURCE_VERSION, 'chapters': CHAPTERS, 'questions': result},
                  fh, ensure_ascii=False, indent=1)
    with open(os.path.join(args.out, 'extract-report.json'), 'w', encoding='utf-8') as fh:
        json.dump({'issues': {k: sorted(set(v)) for k, v in issues.items()},
                   'wordFixes': word_fixes,
                   'guide': {k: sorted(v) for k, v in guide.items()}},
                  fh, ensure_ascii=False, indent=1)
    print(f'Wrote {len(result)} questions, {sum(len(q["images"]) for q in result)} images, '
          f'{len(word_fixes)} questions with word fixes.')
    for k, v in issues.items():
        print(f'  {k}: {len(set(v))}')


if __name__ == '__main__':
    main()

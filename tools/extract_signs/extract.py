"""Extract the traffic-sign catalog from QCVN 41:2024/BGTVT (Phụ lục B–F).

Each appendix section ("B.4  Biển số P.104 "Cấm xe máy"") gives sign codes, names, the meaning text,
and one or more sign images. Images are matched to codes by the bold labels printed under them
("a) Biển số P.103a") or, for a single image, by the figure caption ("Hình B.4 - Biển số P.104").

Source file (not committed): data/question-bank/raw/51-bgtvt-kem.pdf — see docs/data/sources.md.
Usage: python tools/extract_signs/extract.py [--pdf …] [--out data/sign-catalog]
"""
import argparse
import glob
import json
import os
import re
from collections import defaultdict

import pymupdf

SOURCE = {'doc': 'QCVN 41:2024/BGTVT', 'issuedWith': 'Thông tư 51/2024/TT-BGTVT', 'effectiveDate': '2025-01-01'}
GROUPS = {  # appendix letter -> (group key, display name)
    'B': ('cam', 'Biển báo cấm'),
    'C': ('nguy_hiem', 'Biển báo nguy hiểm và cảnh báo'),
    'D': ('hieu_lenh', 'Biển hiệu lệnh'),
    'E': ('chi_dan', 'Biển chỉ dẫn'),
    'F': ('phu', 'Biển phụ'),
}
CODE = r'(?:DP|IE|[PWRIS])\.\d{3}'
SECTION_START = re.compile(r'^([B-F])\.(\d+[a-z]?)\b\s*(.*)$')
LABEL = re.compile(r'([a-zđ])\)\s*Biển\s*số\s*(' + CODE + r'[a-z]?)')
CAPTION = re.compile(r'^Hình\s+([B-F])\.(\d+[a-z]?)\s*[-–]\s*(.*)$')
APPENDIX_HEAD = re.compile(r'^Phụ\s*lục\s+([A-ZĐ])$')


def clean(s):
    return re.sub(r'[\x00-\x08]', ' ', s)


VOWELS = set('aăâeêioôơuưyáàảãạắằẳẵặấầẩẫậéèẻẽẹếềểễệíìỉĩịóòỏõọốồổỗộớờởỡợúùủũụứừửữựýỳỷỹỵ')


def fix_broken_words(text, fixes, where):
    """Re-join syllables split by PDF spacing ('tr ừ' -> 'trừ'): a lowercase token without a vowel is
    never a Vietnamese syllable. Every fix is recorded for review."""
    toks, out, i = text.split(' '), [], 0
    while i < len(toks):
        t, n = toks[i], toks[i + 1] if i + 1 < len(toks) else ''
        after_code = bool(out) and re.fullmatch(CODE + r'[a-z]?,?', out[-1])  # 'R.302 b ở' = code suffix
        if (t.isalpha() and t.islower() and not (set(t) & VOWELS) and n and n[0].lower() in VOWELS
                and not after_code):
            fixes.append(f'{where}: {t} {n} -> {t}{n}')
            out.append(t + n)
            i += 2
            continue
        out.append(t)
        i += 1
    return ' '.join(out)


def norm(s):
    return re.sub(r'\s+', ' ', s).strip()


def expand_codes(text):
    """'P.106 (a,b)' -> P.106a, P.106b; 'P.103b và P.103c' -> both; 'W.201(c,d)'; plain codes."""
    codes = []
    for m in re.finditer(r'(' + CODE + r')([a-z]?)\s*(\(([a-z](?:\s*,\s*[a-z])*)\))?', text):
        base, suffix, _, group = m.groups()
        if group:
            codes += [base + x.strip() for x in group.split(',')]
        else:
            codes.append(base + suffix)
    out = []
    for c in codes:
        if c not in out:
            out.append(c)
    return out


def name_pairs(heading):
    """Pair codes with quoted names in a heading. Returns ({code: name}, ok_flag)."""
    names = re.findall(r'["“]([^"”]+)["”]', heading)
    parts = re.split(r'["“][^"”]+["”]', heading)
    mapping, ok = {}, True
    # codes that precede each quoted name
    i = 0
    while i < len(names):
        codes = expand_codes(parts[i]) if i < len(parts) else []
        # 'P.103b và P.103c "A" và "B"': following names have no codes of their own -> one name per code
        follow = 1
        while i + follow < len(names) and not expand_codes(parts[i + follow]):
            follow += 1
        if len(codes) > 1 and follow == len(codes):
            mapping.update({c: norm(n) for c, n in zip(codes, names[i:i + follow])})
            i += follow
            continue
        if codes:
            mapping.update({c: norm(names[i]) for c in codes})
        i += 1
    all_codes = expand_codes(heading)
    # "Biển số P.103b và P.103c "A" và "B"": names follow codes one by one
    leftover = [c for c in all_codes if c not in mapping]
    if leftover:
        ok = False
        for c in leftover:
            mapping[c] = norm(names[-1]) if names else ''
    multi_named = [c for c in all_codes if list(mapping.values()).count(mapping[c]) > 1]
    if len(names) > 1 and len(multi_named) == len(all_codes) and len(names) == len(all_codes):
        mapping = dict(zip(all_codes, map(norm, names)))
    return mapping, ok


def line_items(page):
    """Text lines (with char x positions) and images of a page, in reading order."""
    items = []
    for b in page.get_text('rawdict')['blocks']:
        if b['type'] == 1:
            items.append({'kind': 'img', 'y': b['bbox'][1], 'bbox': b['bbox'], 'xref': None})
            continue
        for line in b.get('lines', []):
            chars = [(clean(ch['c']), ch['bbox'][0], ch['bbox'][2]) for s in line['spans'] for ch in s['chars']]
            text = ''.join(c for c, _, _ in chars)
            if not text.strip():
                continue
            bold = any(s['flags'] & 16 for s in line['spans'] if clean(''.join(ch['c'] for ch in s['chars'])).strip())
            items.append({'kind': 'text', 'y': line['bbox'][1], 'bbox': line['bbox'], 'text': text,
                          'chars': chars, 'bold': bold})
    # attach xrefs to image blocks by matching bboxes
    infos = page.get_image_info(xrefs=True)
    for it in items:
        if it['kind'] == 'img':
            for inf in infos:
                if all(abs(a - b) < 1.5 for a, b in zip(inf['bbox'], it['bbox'])):
                    it['xref'] = inf['xref']
                    break
    return sorted(items, key=lambda it: (round(it['y']), it['bbox'][0]))


def label_positions(item):
    """For a bold label line, return [(code, x_center, y)] for each 'a) Biển số X' occurrence."""
    text = item['text']
    out = []
    for m in LABEL.finditer(text):
        a, b = m.start(2), m.end(2) - 1
        xs = [item['chars'][a][1], item['chars'][b][2]]
        out.append((m.group(2), sum(xs) / 2, item['y']))
    return out


def ink_runs(values, threshold, min_gap):
    """Index ranges where values > threshold, merging runs separated by gaps shorter than min_gap."""
    runs, start, last = [], None, None
    for i, v in enumerate(values):
        if v > threshold:
            if start is None:
                start = i
            elif i - last > min_gap:
                runs.append((start, last))
                start = i
            last = i
    if start is not None:
        runs.append((start, last))
    return runs


def split_composite(page, bbox, n, zoom=3):
    """Split a picture of several signs into n boxes (page coords) along blank rows/columns.

    Returns boxes in reading order, or None when the blank-space layout does not give exactly n signs.
    """
    clip = pymupdf.Rect(bbox)
    pix = page.get_pixmap(matrix=pymupdf.Matrix(zoom, zoom), clip=clip, colorspace=pymupdf.csGRAY)
    w, h, buf = pix.width, pix.height, pix.samples

    def dark(x, y):
        return buf[y * w + x] < 200

    rows = ink_runs([sum(dark(x, y) for x in range(0, w, 2)) for y in range(h)], 0, 6)
    boxes = []
    for y0, y1 in rows:
        cols = ink_runs([sum(dark(x, y) for y in range(y0, y1 + 1, 2)) for x in range(w)], 0, 6)
        for x0, x1 in cols:
            if (x1 - x0) > 8 and (y1 - y0) > 8:
                boxes.append(pymupdf.Rect(clip.x0 + (x0 - 2) / zoom, clip.y0 + (y0 - 2) / zoom,
                                          clip.x0 + (x1 + 3) / zoom, clip.y0 + (y1 + 3) / zoom) & clip)
    return boxes if len(boxes) == n else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pdf', default=None)
    ap.add_argument('--out', default='data/sign-catalog')
    args = ap.parse_args()
    pdf = args.pdf or glob.glob('data/question-bank/raw/51-bgtvt-kem.pdf')[0]
    doc = pymupdf.open(pdf)
    img_dir = os.path.join(args.out, 'images')
    os.makedirs(img_dir, exist_ok=True)
    for f in glob.glob(os.path.join(img_dir, '*.*')):
        os.remove(f)

    sections = []
    cur = None
    appendix = None
    pending_imgs = []  # images of the current section waiting for labels/caption
    issues = defaultdict(list)

    def flush_images(labels, caption_codes):
        """Assign pending images to codes using label x positions, else caption codes."""
        nonlocal pending_imgs
        if not pending_imgs or cur is None:
            pending_imgs = []
            return
        if labels:
            for img in pending_imgs:
                x0, y0, x1, y1 = img['bbox']
                inside = [lc for lc in labels if x0 - 5 <= lc[1] <= x1 + 5]
                if len(inside) >= 2:
                    # one picture holding several signs: split along blank space, match labels in reading order
                    inside.sort(key=lambda lc: (round(lc[2]), lc[1]))
                    boxes = split_composite(doc[img['page'] - 1], img['bbox'], len(inside))
                    if boxes is None:
                        issues['composite_image_not_split'].append(cur['section'])
                        cur['images'].append({'codes': [lc[0] for lc in inside], 'xref': img['xref'],
                                              'page': img['page']})
                        continue
                    for (code, _, _), box in zip(inside, boxes):
                        cur['images'].append({'codes': [code], 'xref': None, 'page': img['page'],
                                              'crop': tuple(box)})
                    issues['composite_image_split'].append(cur['section'])
                    continue
                cx = (x0 + x1) / 2
                code = min(labels, key=lambda lc: abs(lc[1] - cx))[0]
                cur['images'].append({'codes': [code], 'xref': img['xref'], 'page': img['page']})
        else:
            codes = caption_codes or cur['codes']
            for img in pending_imgs:
                cur['images'].append({'codes': list(codes), 'xref': img['xref'], 'page': img['page']})
        pending_imgs = []

    # Only parse the sign appendices: from "Phụ lục B" up to the next appendix after F (cheap text scan first).
    starts = {}
    for pno in range(doc.page_count):
        m = re.search(r'Phụ\s*lục\s+([A-ZĐ])\s*\n', clean(doc[pno].get_text()))
        if m and m.group(1) not in starts and pno > 60:
            starts[m.group(1)] = pno
    first = starts['B']
    last = min(p for k, p in starts.items() if p > starts['F']) if any(p > starts['F'] for p in starts.values()) \
        else doc.page_count

    labels_buf = []
    for pno in range(first, last):
        page = doc[pno]
        for it in line_items(page):
            if it['kind'] == 'text':
                t = norm(it['text'])
                m_app = APPENDIX_HEAD.match(t)
                if m_app and it['bold']:
                    flush_images(labels_buf, None)
                    labels_buf = []
                    appendix = m_app.group(1)
                    cur = None
                    continue
                if appendix not in GROUPS:
                    continue
                if re.fullmatch(r'\d{1,3}', t):
                    continue  # page number
                m_sec = SECTION_START.match(t)
                if m_sec and it['bold'] and m_sec.group(1) == appendix:
                    flush_images(labels_buf, None)
                    labels_buf = []
                    cur = {'section': f'{m_sec.group(1)}.{m_sec.group(2)}', 'appendix': appendix,
                           'heading': m_sec.group(3), 'heading_open': True, 'body': [],
                           'images': [], 'page': pno + 1, 'codes': []}
                    sections.append(cur)
                    continue
                if cur is None:
                    continue
                if it['bold'] and LABEL.search(t):
                    labels_buf += label_positions(it)
                    continue
                m_cap = CAPTION.match(t)
                if m_cap and it['bold']:
                    if not cur['codes']:
                        cur['codes'] = expand_codes(cur['heading'])
                    flush_images(labels_buf, expand_codes(m_cap.group(3)))
                    labels_buf = []
                    cur['heading_open'] = False
                    continue
                if it['bold'] and cur['heading_open'] and not cur['body']:
                    cur['heading'] += ' ' + t
                    continue
                cur['heading_open'] = False
                if not cur['codes']:
                    cur['codes'] = expand_codes(cur['heading'])
                cur['body'].append(t)
            else:
                if cur is not None and appendix in GROUPS:
                    if not cur['codes']:
                        cur['codes'] = expand_codes(cur['heading'])
                    pending_imgs.append({'bbox': it['bbox'], 'xref': it['xref'], 'page': pno + 1})
    flush_images(labels_buf, None)

    # ---- build catalog
    signs = {}
    saved = {}
    word_fixes = []
    for sec in sections:
        heading = norm(sec['heading'])
        names, ok = name_pairs(heading)
        if not ok:
            issues['heading_name_mapping_guessed'].append(sec['section'])
        codes = sec['codes'] or expand_codes(heading)
        if not codes:
            issues['section_without_codes'].append(sec['section'])
            continue
        body = []
        for line in sec['body']:
            if body and not re.match(r'^([a-zđ]\)|-\s|\d+\)|[•+])', line):
                body[-1] += ' ' + line
            else:
                body.append(line)
        meaning = '\n'.join(fix_broken_words(norm(b), word_fixes, sec['section']) for b in body)
        group, group_name = GROUPS[sec['appendix']]
        if not sec['images']:
            issues['section_without_images'].append(sec['section'])
        for code in codes:
            imgs = []
            for img in sec['images']:
                if code not in img['codes']:
                    continue
                if img.get('crop'):
                    key = ('crop', img['page'], img['crop'])
                    if key not in saved:
                        name = f"{code.replace('.', '')}.png"
                        pix = doc[img['page'] - 1].get_pixmap(matrix=pymupdf.Matrix(3, 3),
                                                              clip=pymupdf.Rect(*img['crop']))
                        pix.save(os.path.join(img_dir, name))
                        saved[key] = name
                elif img['xref']:
                    key = img['xref']
                    if key not in saved:
                        info = doc.extract_image(key)
                        name = f"{'_'.join(img['codes']).replace('.', '')}.{info['ext']}"
                        if name in saved.values():
                            name = f"{'_'.join(img['codes']).replace('.', '')}_{key}.{info['ext']}"
                        with open(os.path.join(img_dir, name), 'wb') as fh:
                            fh.write(info['image'])
                        saved[key] = name
                else:
                    continue
                imgs.append(f'images/{saved[key]}')
            if not imgs:
                issues['code_without_image'].append(code)
            if code in signs:
                issues['code_in_several_sections'].append(code)
                signs[code]['images'] += [i for i in imgs if i not in signs[code]['images']]
                continue
            signs[code] = {
                'code': code,
                'name': names.get(code, ''),
                'group': group,
                'groupName': group_name,
                'section': sec['section'],
                'heading': heading,
                'meaning': meaning,
                'images': imgs,
                'source': dict(SOURCE, appendix=sec['appendix'], section=sec['section'], page=sec['page']),
            }
            if not signs[code]['name']:
                issues['code_without_name'].append(code)

    def sort_key(c):
        m = re.match(r'([A-Z]+)\.(\d+)([a-z]?)', c)
        return (list(GROUPS).index({'P': 'B', 'DP': 'B', 'W': 'C', 'R': 'D', 'I': 'E', 'IE': 'E', 'S': 'F'}
                                   .get(m.group(1), 'F')), m.group(1), int(m.group(2)), m.group(3))

    result = [signs[c] for c in sorted(signs, key=sort_key)]
    with open(os.path.join(args.out, 'signs.json'), 'w', encoding='utf-8') as fh:
        json.dump({'source': SOURCE, 'groups': {key: name for key, name in GROUPS.values()},
                   'signs': result}, fh, ensure_ascii=False, indent=1)
    with open(os.path.join(args.out, 'extract-report.json'), 'w', encoding='utf-8') as fh:
        json.dump({'sections': len(sections), 'issues': {k: sorted(set(v)) for k, v in issues.items()},
                   'wordFixes': word_fixes},
                  fh, ensure_ascii=False, indent=1)
    print(f'{len(sections)} sections -> {len(result)} sign codes, {len(saved)} images')
    for k, v in issues.items():
        print(f'  {k}: {len(set(v))} {sorted(set(v))[:12]}')


if __name__ == '__main__':
    main()

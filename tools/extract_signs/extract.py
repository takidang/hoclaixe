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
import shutil
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
# label under a picture: "a) Biển số P.103a" — the "a)" prefix is missing in some sections (e.g. DP.127a)
LABEL = re.compile(r'(?:([a-zđ])\)\s*)?Biển\s*số\s*(' + CODE + r'[a-z]?)')
QUOTE = re.compile(r'["“”]')
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


HIGHWAY_GROUP = ('cao_toc', 'Biển chỉ dẫn trên đường cao tốc')
HW_HEAD = re.compile(r'^(47\.\d+(?:\.\d+)?)\.\s*(.*)$')
HW_CAPTION = re.compile(r'^Hình\s+\d+[a-z’\']*\s*[-–]\s*(.*)$')


def highway_signs(doc, img_dir, issues):
    """Highway guide signs (IE.4xx) from Điều 47 of the main text (not in the appendices).

    Each '47.x.y. Biển số IE.… <name>' block gives code, name and text; figures (raster or vector) are cropped from
    the page region above their caption 'Hình N - Biển số …', split by sub-labels 'a) Biển số IE.…' when present.
    """
    start = next(i for i in range(30, 80) if re.search(r'(?m)^\s*47\.1\.', clean(doc[i].get_text())))
    blocks, cur = [], None          # text blocks per subsection
    figures = []                    # (page, rect, codes, caption, subsection id)
    pending_top = None
    sub_labels = []
    for pno in range(start, start + 25):
        page = doc[pno]
        lines = []
        for b in page.get_text('dict')['blocks']:
            for ln in b.get('lines', []):
                t = norm(clean(''.join(s['text'] for s in ln['spans'])))
                if t:
                    lines.append((ln['bbox'], t, any(s['flags'] & 16 for s in ln['spans'])))
        lines.sort(key=lambda x: (round(x[0][1]), x[0][0]))
        last_text_bottom = 50
        stop = False
        for bbox, t, bold in lines:
            if re.match(r'^Điều\s*48\b|^48\.\d', t):
                stop = True
                break
            if re.fullmatch(r'\d{1,3}', t) and (bbox[1] > 770 or bbox[1] < 50):
                continue
            m_cap = HW_CAPTION.match(t)
            if bold and m_cap:
                top = pending_top if pending_top is not None else last_text_bottom
                rect = pymupdf.Rect(40, top + 2, page.rect.width - 40, bbox[1] - 2)
                codes = expand_codes(m_cap.group(1))
                figures.append({'page': pno, 'rect': rect, 'codes': codes, 'caption': m_cap.group(1),
                                'labels': sub_labels, 'section': cur['id'] if cur else None})
                sub_labels, pending_top = [], None
                last_text_bottom = bbox[3]
                continue
            if bold and LABEL.search(t) and not QUOTE.search(t) and not HW_HEAD.match(t):
                if pending_top is None:
                    pending_top = last_text_bottom
                sub_labels.append((expand_codes(t), bbox))
                continue
            m_head = HW_HEAD.match(t)
            if bold and m_head:
                cur = {'id': m_head.group(1), 'title': m_head.group(2), 'text': [m_head.group(2)], 'page': pno + 1}
                blocks.append(cur)
                pending_top = None
                last_text_bottom = bbox[3]
                continue
            if cur is not None:
                if bold and len(cur['text']) == 1 and not cur['title'].endswith(('.', ')')):
                    cur['title'] += ' ' + t
                cur['text'].append(t)
            # only paragraph lines / table titles mark where a figure can start; short bold lines such as
            # "Biển có ba dịch vụ" or numbers are drawn inside the figure itself
            is_paragraph = (not bold and bbox[2] - bbox[0] > 250) or t.startswith('Bảng')
            if pending_top is None and is_paragraph:
                last_text_bottom = bbox[3]
        if stop:
            break

    # ---- build entries
    entries = {}
    for blk in blocks:
        text = norm(' '.join(blk['text']))
        sentences = re.split(r'(?<=[.;])\s+(?=[A-ZĐÂĂÊÔƠƯ])', text)
        for code in [c for c in expand_codes(text) if c.startswith(('IE.', 'I.4'))]:
            if code in entries:
                continue
            own = [s for s in sentences if code in expand_codes(s)]
            first = own[0] if own else text
            m = re.search(re.escape(code) + r'\s*(?:\([a-z,]+\))?\s*["“]([^"”]+)["”]', first) or \
                re.search(re.escape(code) + r'\s+([^,;(]+?)(?:\s*\(Hình|\s*,|\s*;|\.$|$)', first)
            name = norm(m.group(1)) if m else ''
            if name.startswith(('Biển', 'biển')) or not name:
                name = blk['title'] if not blk['title'].startswith('Biển') else name
            name = (name[:1].upper() + name[1:]).rstrip(' .') if name else ''
            entries[code] = {'code': code, 'name': name, 'group': HIGHWAY_GROUP[0], 'groupName': HIGHWAY_GROUP[1],
                             'section': f'Điều {blk["id"]}', 'heading': blk['title'],
                             'summary': ' '.join(own) if own else text, 'meaning': text, 'images': [],
                             'source': dict(SOURCE, appendix=None, section=f'Điều {blk["id"]}', page=blk['page'])}
    # ---- figures
    for k, fig in enumerate(figures):
        page = doc[fig['page']]
        parts = []
        rows = []   # labels on the same line -> pictures side by side
        for codes, lb in fig['labels']:
            if rows and abs(rows[-1][0][1][1] - lb[1]) < 6:
                rows[-1].append((codes, lb))
            else:
                rows.append([(codes, lb)])
        top = fig['rect'].y0
        for row in rows:
            bottom = max(lb[3] for _, lb in row) + 2
            row.sort(key=lambda r: r[1][0])
            centers = [(lb[0] + lb[2]) / 2 for _, lb in row]
            cuts = [fig['rect'].x0] + [(a + b) / 2 for a, b in zip(centers, centers[1:])] + [fig['rect'].x1]
            for (codes, _), left, right in zip(row, cuts, cuts[1:]):
                parts.append((codes, pymupdf.Rect(left, top, right, bottom)))
            top = bottom
        if not parts:
            parts.append((fig['codes'], fig['rect']))
        for codes, rect in parts:
            if rect.height < 15:
                issues['highway_figure_too_small'].append(','.join(codes))
                continue
            targets = [c for c in codes if c in entries]
            # caption with a base code ("IE.450") covers its variants mentioned in the text
            for c in codes:
                targets += [e for e in entries if e != c and e[:-1] == c and not entries[e]['images']]
            if not targets and len(parts) == 1:
                targets = [c for c in fig['codes'] if c in entries]
            if not targets:
                issues['highway_figure_unmatched'].append(fig['caption'][:60])
                continue
            name = f"{'_'.join(sorted(set(targets))).replace('.', '')}_{k}.png"
            page.get_pixmap(matrix=pymupdf.Matrix(2, 2), clip=rect).save(os.path.join(img_dir, name))
            for c in set(targets):
                entries[c]['images'].append(f'images/{name}')
    for c, e in entries.items():
        if not e['images']:
            issues['code_without_image'].append(c)
        if not e['name']:
            issues['code_without_name'].append(c)
    return entries


MARKING_GROUP = ('vach_ke', 'Vạch kẻ đường')
MK_HEAD = re.compile(r'^(?:[a-zđ]\.\s*)?Vạch\s+(\d+\.\d+[a-z]?)\s*:\s*(.*)$')
MK_CAPTION = re.compile(r'^Hình\s+G\.\d+[a-z]?\s*[-–]\s*(.*)$')
MK_SUBGROUP = re.compile(r'^(G\.?\d+(?:\.\d+)?)\.\s*(.*)$')


def road_markings(doc, img_dir, issues):
    """Road markings from Phụ lục G: 'a. Vạch 1.1: <tên>', 'Ý nghĩa sử dụng: …', 'Minh họa:' + figure, 'Quy cách: …'."""
    starts = [i for i in range(150, doc.page_count)
              if re.search(r'Phụ\s*lục\s+G\s*\n', clean(doc[i].get_text()))]
    end = next(i for i in range(starts[0] + 1, doc.page_count)
               if re.search(r'Phụ\s*lục\s+[H-Z]\s*\n', clean(doc[i].get_text())))
    entries, cur, subgroup = {}, None, ''
    fig_top = None
    for pno in range(starts[0], end):
        page = doc[pno]
        lines = []
        for b in page.get_text('dict')['blocks']:
            for ln in b.get('lines', []):
                t = norm(clean(''.join(s['text'] for s in ln['spans'])))
                if t:
                    lines.append((ln['bbox'], t, any(s['flags'] & 16 for s in ln['spans'])))
        lines.sort(key=lambda x: (round(x[0][1]), x[0][0]))
        carry = None
        last_para_bottom = 50
        if fig_top is not None:
            carry = (pno - 1, fig_top)   # figure drawn at the bottom of the previous page
            fig_top = 50
        for bbox, t, bold in lines:
            if re.fullmatch(r'\d{1,3}', t) and bbox[1] > 770:
                continue
            m_head = MK_HEAD.match(t) if bold else None
            if m_head:
                code = f'Vạch {m_head.group(1)}'
                cur = {'code': code, 'name': m_head.group(2), 'open': True, 'text': [], 'page': pno + 1,
                       'images': [], 'subgroup': subgroup}
                entries.setdefault(code, cur)
                cur = entries[code]
                fig_top = None
                continue
            m_sub = MK_SUBGROUP.match(t) if bold else None
            if m_sub and not MK_CAPTION.match(t):
                subgroup = m_sub.group(2) or subgroup
                continue
            m_cap = MK_CAPTION.match(t) if bold else None
            if m_cap:
                explicit = fig_top is not None   # figure announced by "Minh họa:" for the current marking
                if fig_top is None:
                    fig_top = last_para_bottom   # no "Minh họa:" line: figure starts after the last paragraph
                # the caption names the marking ("Hình G.2 - Vạch 1.2", "… sử dụng vạch 3.1 …") -> attach there
                named = [f'Vạch {c}' for c in re.findall(r'[Vv]ạch\s+(\d+\.\d+[a-z]?)', m_cap.group(1))]
                named = [c for c in named if c in entries]
                target = entries[named[0]] if named else (cur if explicit else None)
                if not named:
                    issues['marking_figure_caption_without_code'].append(m_cap.group(1)[:60])
                if target is not None:
                    cur_fig = target
                    src, rect = page, pymupdf.Rect(40, fig_top + 2, page.rect.width - 40, bbox[1] - 2)
                    if rect.height < 15 and carry:
                        src = doc[carry[0]]
                        rect = pymupdf.Rect(40, carry[1] + 2, src.rect.width - 40, src.rect.height - 40)
                    if rect.height >= 15:
                        name = f"{cur_fig['code'].replace('Vạch ', 'V').replace('.', '_')}_{pno}_{int(bbox[1])}.png"
                        src.get_pixmap(matrix=pymupdf.Matrix(2, 2), clip=rect).save(os.path.join(img_dir, name))
                        cur_fig['images'].append(f'images/{name}')
                    carry = None
                fig_top = None
                last_para_bottom = bbox[3]
                continue
            if not bold and bbox[2] - bbox[0] > 250 or m_head or (bold and MK_SUBGROUP.match(t)):
                last_para_bottom = bbox[3]
            if cur is None:
                continue
            if bold and cur['open'] and not cur['text']:
                cur['name'] += ' ' + t      # heading wrapped
                continue
            cur['open'] = False
            if t.startswith('Minh họa'):
                fig_top = bbox[3]
                continue
            if fig_top is None:
                cur['text'].append(t)
    result = {}
    for code, e in entries.items():
        body = []
        for line in e['text']:
            if body and not re.match(r'^(Ý\s*nghĩa|Quy\s*cách|-\s|\*|[a-zđ]\)|\d+\))', line):
                body[-1] += ' ' + line
            else:
                body.append(line)
        body = [fix_broken_words(norm(b), [], code) for b in body]
        meaning = '\n'.join(body)
        own = [b for b in body if re.match(r'^Ý\s*nghĩa', b)]
        summary = norm(re.sub(r'^Ý\s*nghĩa\s*sử\s*dụng\s*:\s*', '', own[0])) if own else (body[0] if body else '')
        summary = summary[:1].upper() + summary[1:]
        if not own:
            issues['marking_summary_fallback'].append(code)
        if not e['images']:
            issues['code_without_image'].append(code)
        result[code] = {'code': code, 'name': fix_broken_words(norm(e['name']), [], code).rstrip(' .'), 'group': MARKING_GROUP[0],
                        'groupName': MARKING_GROUP[1], 'section': e['subgroup'], 'heading': norm(e['name']),
                        'summary': summary, 'meaning': meaning, 'images': e['images'],
                        'source': dict(SOURCE, appendix='G', section=e['subgroup'], page=e['page'])}
    return result


def crop_images(doc, img_dir, code, crops):
    """Render page regions ({'page': 1-based, 'rect': [x0, y0, x1, y1]} in PDF points) to PNG files."""
    paths = []
    for k, crop in enumerate(crops):
        page = doc[crop['page'] - 1]
        name = f"{code.replace('Vạch ', 'V').replace('.', '_' if code.startswith('Vạch') else '')}_fix{k}.png"
        page.get_pixmap(matrix=pymupdf.Matrix(2, 2), clip=pymupdf.Rect(crop['rect'])).save(os.path.join(img_dir, name))
        paths.append(f'images/{name}')
    return paths


def apply_overrides(signs, doc, img_dir, path, issues):
    """Hand corrections checked against the PDF (data/sign-catalog/overrides.json): drop codes that are not
    signs of their own, fix names, crop missing figures, add codes the automatic pass missed."""
    if not os.path.exists(path):
        return
    with open(path, encoding='utf-8') as fh:
        fix = json.load(fh)
    for d in fix.get('drop', []):
        if signs.pop(d['code'], None) is None:
            issues['override_drop_unknown'].append(d['code'])
    for s in fix.get('set', []):
        e = signs.get(s['code'])
        if e is None:
            issues['override_set_unknown'].append(s['code'])
            continue
        if 'name' in s:
            e['name'] = s['name']
        for field in ('summary', 'meaning'):  # re-joined text when a heading wrapped mid-sentence
            if field in s:
                e[field] = s[field]
        if 'images' in s:
            e['images'] = crop_images(doc, img_dir, s['code'], s['images'])
        if 'drawn' in s:  # team-drawn illustration where QCVN has no figure; the app shows imageNote under it
            e['images'] = []
            for src in s['drawn']:
                name = os.path.basename(src)
                shutil.copyfile(os.path.join(os.path.dirname(path), src), os.path.join(img_dir, name))
                e['images'].append(f'images/{name}')
            e['imageNote'] = s['imageNote']
            e.pop('noImageReason', None)
        if 'noImageReason' in s:
            e['images'] = []
            e['noImageReason'] = s['noImageReason']
        e['source'] = dict(e['source'], correctedFromPage=s['page'])
    for a in fix.get('add', []):
        if a['code'] in signs:
            issues['override_add_exists'].append(a['code'])
            continue
        signs[a['code']] = {
            'code': a['code'], 'name': a['name'], 'group': HIGHWAY_GROUP[0], 'groupName': HIGHWAY_GROUP[1],
            'section': a['section'], 'heading': a['heading'], 'summary': a['summary'], 'meaning': a['summary'],
            'images': crop_images(doc, img_dir, a['code'], a['images']),
            'source': dict(SOURCE, appendix=None, section=a['section'], page=a['page'], addedByHand=True),
        }
    # issues raised before the fixes no longer apply to corrected codes
    fixed = {x['code'] for x in fix.get('drop', []) + fix.get('set', []) + fix.get('add', [])}
    for key in ('code_without_image', 'code_without_name'):
        issues[key] = [c for c in issues[key] if c not in fixed]


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
                # a label belongs to a picture when it sits right under it (pictures can be stacked vertically)
                inside = [lc for lc in labels if x0 - 5 <= lc[1] <= x1 + 5 and -3 <= lc[2] - y1 <= 30]
                if not inside:
                    below = [lc for lc in labels if lc[2] >= y1 - 3]
                    if below:
                        cx = (x0 + x1) / 2
                        best = min(below, key=lambda lc: abs(lc[1] - cx) + abs(lc[2] - y1))
                        cur['images'].append({'codes': [best[0]], 'xref': img['xref'], 'page': img['page']})
                        continue
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
                cur['images'].append({'codes': [inside[0][0]], 'xref': img['xref'], 'page': img['page']})
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
                is_label = (it['bold'] and LABEL.search(t) and not QUOTE.search(t)
                            and not CAPTION.match(t))   # "Hình B.10 - Biển số P.110" is a caption, not a label
                if it['bold'] and cur['heading_open'] and not cur['body'] and not is_label:
                    cur['heading'] += ' ' + t   # heading wrapped onto the next bold line
                    continue
                if is_label:
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
        codes = list(sec['codes'] or expand_codes(heading))
        # variants that only appear in picture labels (heading "DP.127", labels "DP.127a/b/c")
        for img in sec['images']:
            for c in img['codes']:
                if c not in codes:
                    codes.append(c)
                    issues['code_from_label_only'].append(c)
        codes = [c for c in codes if not any(o != c and o[:-1] == c for o in codes)]  # drop base if variants
        if not codes:
            issues['section_without_codes'].append(sec['section'])
            continue
        body = []
        for line in sec['body']:
            if body and not re.match(r'^([a-zđ]\)|-\s|\d+\)|[•+])', line):
                body[-1] += ' ' + line
            else:
                body.append(line)
        paragraphs = [fix_broken_words(norm(b), word_fixes, sec['section']) for b in body]
        meaning = '\n'.join(paragraphs)
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
            # short description = the official paragraphs that name this exact code (verbatim, no rewriting)
            own = [p for p in paragraphs if code in expand_codes(p)]
            if not own:
                own = paragraphs if len(codes) == 1 else paragraphs[:1]
                issues['summary_fallback'].append(code)
            summary = '\n'.join(re.sub(r'^([a-zđ]\)|-)\s*', '', p) for p in own)
            signs[code] = {
                'code': code,
                'name': names.get(code) or names.get(code[:-1], '') if code[-1].islower() else names.get(code, ''),
                'summary': summary,
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

    # highway guide signs (Điều 47) — only codes not already described in the appendices
    for code, entry in highway_signs(doc, img_dir, issues).items():
        if code not in signs:
            signs[code] = entry
    signs.update(road_markings(doc, img_dir, issues))
    apply_overrides(signs, doc, img_dir, os.path.join(args.out, 'overrides.json'), issues)
    # images of dropped codes or replaced by hand crops are not used any more
    used = {os.path.basename(i) for e in signs.values() for i in e['images']}
    for f in glob.glob(os.path.join(img_dir, '*.*')):
        if os.path.basename(f) not in used:
            os.remove(f)
            saved = {k: v for k, v in saved.items() if v != os.path.basename(f)}

    order =['cam', 'nguy_hiem', 'hieu_lenh', 'chi_dan', 'phu', HIGHWAY_GROUP[0], MARKING_GROUP[0]]

    def sort_key(c):
        m = re.match(r'([A-Z]+)\.(\d+)([a-z]?)', c)
        if not m:   # 'Vạch 1.10a'
            n = re.match(r'Vạch (\d+)\.(\d+)([a-z]?)', c)
            return (order.index(signs[c]['group']), 'V', int(n.group(1)) * 1000 + int(n.group(2)), n.group(3))
        return (order.index(signs[c]['group']), m.group(1), int(m.group(2)), m.group(3))

    result = [signs[c] for c in sorted(signs, key=sort_key)]
    group_names = {key: name for key, name in GROUPS.values()}
    group_names[HIGHWAY_GROUP[0]] = HIGHWAY_GROUP[1]
    group_names[MARKING_GROUP[0]] = MARKING_GROUP[1]
    with open(os.path.join(args.out, 'signs.json'), 'w', encoding='utf-8') as fh:
        json.dump({'source': SOURCE, 'groups': group_names,
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

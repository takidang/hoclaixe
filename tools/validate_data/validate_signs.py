"""Validate data/sign-catalog/signs.json and generate a human review list.

Errors (exit 1): duplicate code, empty/invalid group, missing image file, orphan image file.
Warnings: sign without image or name, codes named in the main text of QCVN 41:2024 but absent from the catalog.

Usage: python tools/validate_data/validate_signs.py [--dir data/sign-catalog] [--pdf data/question-bank/raw/51-bgtvt-kem.pdf]
"""
import argparse
import json
import os
import random
import re
import sys

GROUP_KEYS = {'cam', 'nguy_hiem', 'hieu_lenh', 'chi_dan', 'phu'}
CODE = re.compile(r'(?:DP|IE|[PWRIS])\.\d{3}[a-z]?')
REVIEW_SAMPLE_SIZE = 30
REVIEW_SEED = 2026


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dir', default='data/sign-catalog')
    ap.add_argument('--pdf', default='data/question-bank/raw/51-bgtvt-kem.pdf')
    args = ap.parse_args()

    cat = json.load(open(os.path.join(args.dir, 'signs.json'), encoding='utf-8'))
    report = json.load(open(os.path.join(args.dir, 'extract-report.json'), encoding='utf-8'))
    signs = cat['signs']
    errors, warnings = [], []

    codes = [s['code'] for s in signs]
    if len(codes) != len(set(codes)):
        errors.append('duplicate codes')
    for s in signs:
        if not CODE.fullmatch(s['code']):
            errors.append(f'{s["code"]}: invalid code')
        if s['group'] not in GROUP_KEYS:
            errors.append(f'{s["code"]}: group {s["group"]}')
        if not s['meaning'].strip():
            warnings.append(f'{s["code"]}: empty meaning')
        if not s['name']:
            warnings.append(f'{s["code"]}: no name')
        if not s['images']:
            warnings.append(f'{s["code"]}: no image')
        for img in s['images']:
            if not os.path.isfile(os.path.join(args.dir, img)):
                errors.append(f'{s["code"]}: missing image {img}')
    referenced = {os.path.basename(i) for s in signs for i in s['images']}
    for f in sorted(set(os.listdir(os.path.join(args.dir, 'images'))) - referenced - {'.gitkeep'}):
        errors.append(f'orphan image {f}')

    # coverage against codes listed in the main text (Chương 4–8 lists "Biển số X: Tên")
    missing_from_catalog = []
    if os.path.isfile(args.pdf):
        import pymupdf
        doc = pymupdf.open(args.pdf)
        main_text = re.sub(r'[\x00-\x08]', ' ', ''.join(doc[i].get_text() for i in range(0, 77)))
        listed = set()
        for m in re.finditer(r'Biển\s*số\s*((?:DP|IE|[PWRIS])\.\d{3})\s*(?:\(([a-z,\s]+)\))?([a-z]?)', main_text):
            base, group, suffix = m.groups()
            if group:
                listed |= {base + x.strip() for x in group.split(',') if x.strip()}
            else:
                listed.add(base + suffix)
        missing_from_catalog = sorted(listed - set(codes))
        for c in missing_from_catalog:
            warnings.append(f'{c}: listed in QCVN main text but not in catalog')

    # review list
    flagged = {}

    def flag(code, reason):
        flagged.setdefault(code, []).append(reason)

    by_section = {}
    for s in signs:
        by_section.setdefault(s['section'], []).append(s['code'])
    for key, label in [('composite_image_not_split', 'hình gộp nhiều biển — kiểm tra hiển thị'),
                       ('composite_image_split', 'hình đã cắt từ hình gộp — kiểm tra đúng biển'),
                       ('heading_name_mapping_guessed', 'tên biển ghép tự động — kiểm tra tên')]:
        for sec in report['issues'].get(key, []):
            for c in by_section.get(sec, []):
                flag(c, label)
    for s in signs:
        if not s['images']:
            flag(s['code'], 'không có hình')
        if not s['name']:
            flag(s['code'], 'không có tên')
    for wf in report.get('wordFixes', []):
        sec = wf.split(':')[0]
        for c in by_section.get(sec, []):
            flag(c, 'đã nối chữ: ' + wf.split(': ', 1)[1])
    rest = [c for c in codes if c not in flagged]
    for c in random.Random(REVIEW_SEED).sample(rest, min(REVIEW_SAMPLE_SIZE, len(rest))):
        flag(c, f'mẫu ngẫu nhiên (seed {REVIEW_SEED})')

    by_code = {s['code']: s for s in signs}
    lines = ['# Danh sách soát danh mục biển báo (tự sinh — chạy lại validate_signs.py)', '',
             'So với QCVN 41:2024 (file `51-bgtvt-kem.pdf`, trang ghi bên dưới): **mã, tên, hình, ý nghĩa**. Khớp → [x].', '',
             f'Tổng: {len(flagged)} biển. Lỗi: {len(errors)}. Cảnh báo: {len(warnings)}.', '',
             '| Khớp | Mã | Tên (app) | Mục | Trang | Lý do soát | Ghi chú |', '|---|---|---|---|---|---|---|']
    for c in sorted(flagged, key=codes.index):
        s = by_code[c]
        lines.append(f'| [ ] | {c} | {s["name"] or "—"} | {s["section"]} | {s["source"]["page"]} | '
                     f'{"; ".join(flagged[c])} | |')
    if missing_from_catalog:
        lines += ['', '## Mã có trong phần thân QCVN nhưng chưa có trong danh mục', '',
                  ', '.join(missing_from_catalog)]
    with open(os.path.join(args.dir, 'review.md'), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(lines) + '\n')

    print(f'{len(signs)} signs | images {len(referenced)} | review items {len(flagged)} | '
          f'missing vs main text {len(missing_from_catalog)}')
    for w in warnings[:40]:
        print('WARN ', w)
    if len(warnings) > 40:
        print(f'WARN  … {len(warnings) - 40} more')
    for e in errors:
        print('ERROR', e)
    print('RESULT:', 'FAIL' if errors else 'PASS')
    sys.exit(1 if errors else 0)


if __name__ == '__main__':
    main()

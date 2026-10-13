"""Validate data/question-bank against the official structure and generate a human review list.

Checks (fail = exit code 1):
  - 600 questions, ids Q0001..Q0600, chapter sizes per CV 2262/CSGT-P5 part I.1
  - every question: 2–4 non-empty options, exactly one correct answer, chapter, license classes
  - 60 critical questions for B and above; A1/A pool 250 (20 critical); B1 pool 300 (30 critical)
  - every referenced image exists and no image file is orphaned
  - every complete exam structure can be generated from its pool

Writes data/question-bank/review.md for manual checking against the PDF.

Usage: python tools/validate_data/validate_questions.py [--dir data/question-bank]
"""
import argparse
import json
import os
import random
import re
import sys

CHAPTER_SIZES = {1: 180, 2: 25, 3: 58, 4: 37, 5: 185, 6: 115}
REVIEW_SAMPLE_SIZE = 50
REVIEW_SEED = 2026
NEEDS_FIGURE = re.compile(r'biển nào|biển này|các biển|(trong|theo) hình|hình (dưới|bên)|theo hướng mũi tên|vạch (dưới|này)',
                          re.I)
FIGURE_HINT =re.compile(r'hình|biển|sa hình|dưới đây|mũi tên|xe nào|hướng nào', re.I)


def has_caps_run(text, length=3):
    """True when `length` consecutive words are ALL CAPS (2+ letters) — e.g. a chapter title glued to a question."""
    run = 0
    for word in re.findall(r'\w+', text):
        run = run + 1 if len(word) >= 2 and word.isalpha() and word.isupper() else 0
        if run >= length:
            return True
    return False


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dir', default='data/question-bank')
    args = ap.parse_args()

    bank = json.load(open(os.path.join(args.dir, 'questions.json'), encoding='utf-8'))
    report = json.load(open(os.path.join(args.dir, 'extract-report.json'), encoding='utf-8'))
    structures = json.load(open(os.path.join(args.dir, 'exam-structures.json'), encoding='utf-8'))['structures']
    qs = bank['questions']
    by_no = {q['number']: q for q in qs}
    errors, warnings = [], []

    # --- bank-level counts
    if len(qs) != 600 or sorted(by_no) != list(range(1, 601)):
        errors.append(f'expected questions 1..600, got {len(qs)}')
    if len({q['id'] for q in qs}) != len(qs):
        errors.append('duplicate ids')
    for ch, size in CHAPTER_SIZES.items():
        got = sum(1 for q in qs if q['chapter'] == ch)
        if got != size:
            errors.append(f'chapter {ch}: expected {size}, got {got}')

    # --- per-question checks
    for q in qs:
        n = q['number']
        if q['id'] != f'Q{n:04d}':
            errors.append(f'{n}: id {q["id"]}')
        # chapter titles are all caps; 3+ consecutive all-caps words inside a question means a title leaked in
        for text in [q['content']] + q['options']:
            if has_caps_run(text):
                errors.append(f'{n}: all-caps run (chapter title leaked?): {text[-60:]}')
        # ch.V/VI questions that refer to a picture cannot be answered without one (bug found 08/10: 26 questions)
        if q['chapter'] in (5, 6) and not q['images'] and NEEDS_FIGURE.search(q['content']):
            errors.append(f'{n}: refers to a picture but has no image: {q["content"][:60]}')
        if not q['content'].strip():
            errors.append(f'{n}: empty content')
        if not 2 <= len(q['options']) <= 4:
            errors.append(f'{n}: {len(q["options"])} options')
        if any(not o.strip() for o in q['options']):
            errors.append(f'{n}: empty option')
        if len(set(q['options'])) != len(q['options']):
            warnings.append(f'{n}: duplicate option text')
        ci = q['correctIndex']
        if not isinstance(ci, int) or not 0 <= ci < len(q['options']):
            errors.append(f'{n}: correctIndex {ci}')
        if not q['licenseClasses']:
            errors.append(f'{n}: no license classes')
        for img in q['images']:
            if not os.path.isfile(os.path.join(args.dir, img)):
                errors.append(f'{n}: missing image {img}')

    # --- pools and critical questions (CV 2262 part I.2 and appendices)
    def pool(cls):
        return {q['number'] for q in qs if cls in q['licenseClasses']}

    def critical_for(cls):
        return {q['number'] for q in qs if cls in q['criticalFor']}

    critical = critical_for('B')
    for name, got, want in [('critical (B and above)', len(critical), 60),
                            ('A1 pool', len(pool('A1')), 250), ('A pool', len(pool('A')), 250),
                            ('B1 pool', len(pool('B1')), 300), ('B pool', len(pool('B')), 600),
                            ('A1 critical', len(critical_for('A1')), 20),
                            ('B1 critical', len(critical_for('B1')), 30)]:
        if got != want:
            errors.append(f'{name}: expected {want}, got {got}')
    if pool('A1') != pool('A') or critical_for('A1') != critical_for('A'):
        errors.append('A1 and A pools or critical sets differ')
    for cls in ('A1', 'B1', 'B'):
        if not critical_for(cls) <= pool(cls):
            errors.append(f'{cls}: critical questions outside its pool')
        if not critical_for(cls) <= critical:
            errors.append(f'{cls}: critical questions outside the 60 of Phụ lục 3')
    for q in qs:
        if not set(q['criticalFor']) <= set(q['licenseClasses']):
            errors.append(f'{q["number"]}: criticalFor outside licenseClasses')

    # --- images on disk
    referenced = {os.path.basename(i) for q in qs for i in q['images']}
    on_disk = set(os.listdir(os.path.join(args.dir, 'images')))
    for orphan in sorted(on_disk - referenced - {'.gitkeep'}):
        errors.append(f'orphan image {orphan}')

    # --- exam structures can be generated
    for s in structures:
        if s.get('status') == 'incomplete':
            continue
        total = sum(g['count'] for g in s['distribution'])
        if total != s['questionCount']:
            errors.append(f'{s["id"]}: distribution sums to {total}, questionCount {s["questionCount"]}')
        if not 0 < s['passScore'] <= s['questionCount']:
            errors.append(f'{s["id"]}: passScore {s["passScore"]}')
        p = pool(s['pool'])
        crit = critical_for(s['licenseClass'])
        for g in s['distribution']:
            if g['group'] == 'critical':
                avail = len(crit)
            else:
                avail = sum(1 for n in p - crit if by_no[n]['chapter'] in g['chapters'])
            if avail < g['count']:
                errors.append(f'{s["id"]}: group {g} needs {g["count"]}, pool has {avail}')

    # --- review list
    flagged = {}

    def flag(n, reason):
        flagged.setdefault(n, []).append(reason)

    labels = {
        'two_column_options': 'đáp án xếp 2 cột — kiểm tra thứ tự và đáp án đúng',
        'image_continues_from_previous_page': 'hình nằm ở trang sau câu hỏi — kiểm tra hình đúng câu',
        'multiple_images': 'nhiều hình — kiểm tra thứ tự hình',
        'figure_labels_dropped': 'đã bỏ số ghi trong hình khỏi nội dung — kiểm tra nội dung đủ',
        'duplicate_option_mark': 'số thứ tự đáp án lặp',
        'option_numbering_gap': 'số thứ tự đáp án bị thiếu',
    }
    for key, nums in report['issues'].items():
        for n in nums:
            flag(n, labels.get(key, key))
    for wf in report['wordFixes']:
        flag(wf['number'], 'đã nối chữ bị ngắt dòng: ' + '; '.join(wf['fixes']))
    for q in qs:
        if not q['images'] and q['chapter'] in (5, 6) and FIGURE_HINT.search(q['content']):
            flag(q['number'], 'chương V/VI nhắc tới hình nhưng không có hình')
        if q['criticalFor']:
            flag(q['number'], 'câu điểm liệt (' + ', '.join(c for c in ('A1', 'B1', 'B') if c in q['criticalFor'])
                 + ') — soát 100%')
    rest = [q['number'] for q in qs if q['number'] not in flagged]
    for n in random.Random(REVIEW_SEED).sample(rest, REVIEW_SAMPLE_SIZE):
        flag(n, f'mẫu ngẫu nhiên (seed {REVIEW_SEED})')

    lines = [
        '# Danh sách soát bộ câu hỏi (tự sinh — đừng sửa tay, chạy lại validate_questions.py)',
        '',
        'Cách soát: mở PDF "600 câu hỏi…" tới trang ghi bên dưới, so **nội dung, các đáp án, hình** và',
        '**đáp án đúng (phần gạch chân)** với cột "Đáp án đúng (app)". Khớp → đánh [x]. Sai → ghi chú và báo lại.',
        '',
        f'Tổng: {len(flagged)} câu. Lỗi tự động: {len(errors)}. Cảnh báo: {len(warnings)}.',
        '',
        '| Khớp | Câu | Trang PDF | Lý do soát | Đáp án đúng (app) | Ghi chú |',
        '|---|---|---|---|---|---|',
    ]
    for n in sorted(flagged):
        q = by_no[n]
        ans = q['options'][q['correctIndex']] if isinstance(q['correctIndex'], int) else '—'
        ans = ans.replace('|', '/')
        if len(ans) > 70:
            ans = ans[:67] + '…'
        lines.append(f'| [ ] | {n} | {q["sourcePage"]} | {"; ".join(flagged[n])} | '
                     f'{q["correctIndex"] + 1 if isinstance(q["correctIndex"], int) else "?"}. {ans} | |')
    with open(os.path.join(args.dir, 'review.md'), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(lines) + '\n')

    print(f'{len(qs)} questions | critical B+ {len(critical)} A1/A {len(critical_for("A1"))} B1 {len(critical_for("B1"))} | A1/A {len(pool("A1"))} | B1 {len(pool("B1"))} '
          f'| images {len(referenced)} | review items {len(flagged)}')
    for w in warnings:
        print('WARN ', w)
    for e in errors:
        print('ERROR', e)
    print('RESULT:', 'FAIL' if errors else 'PASS')
    sys.exit(1 if errors else 0)


if __name__ == '__main__':
    main()

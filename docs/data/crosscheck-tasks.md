# Việc cần làm: sửa 26 câu thiếu hình + thêm script đối chiếu bộ câu hỏi

> Ghi chú từ phiên đối chiếu dữ liệu ngày 2026-10-08. Làm theo giao thức trong CLAUDE.md (xin duyệt trước khi ghi file, không commit khi chưa được yêu cầu).

## 1. Kết quả đối chiếu (đã chạy)

So `data/question-bank/questions.json` với 2 bản trích xuất độc lập của cùng bộ 600 câu:
`rinaheart/tdytools-gplx` (data/questions.json) và `hdung25/600cauhoi` (data/questions.json). Cả hai không có LICENSE → chỉ dùng để **đối chiếu**, không chép dữ liệu.

| Hạng mục | Kết quả |
|---|---|
| Đáp án đúng | Khớp 600/600 (chỗ lệch duy nhất là lỗi của nguồn ngoài) |
| Điểm liệt hạng B | Khớp 60/60 |
| Nội dung câu hỏi / đáp án | Không có lỗi phía mình; các chỗ lệch đều do nguồn ngoài (vd. 180, 485 dính tiêu đề chương — lỗi mình đã sửa) |
| **Hình ảnh** | **26 câu thiếu hình** — 2 nguồn ngoài đều có |

## 2. Lỗi: 26 câu thiếu hình

Câu: 312, 314, 315, 320, 323, 326, 333, 338, 339, 345, 348, 351, 353, 357, 368, 371, 383, 390, 402, 404, 405, 416, 427, 436, 471, 472.
Nhiều câu dạng "Biển nào…?" → không có hình là không làm được (lỗi nghiêm trọng).

**Nguyên nhân** — `tools/extract_questions/extract.py` (~dòng 239–240): PDF đặt **cùng một hình (cùng xref)** cho 2–3 câu trên một trang.
`page.get_images()` trả mỗi xref một lần và `page.get_image_bbox()` chỉ cho vị trí đầu tiên → câu sau mất hình.

**Sửa** — duyệt mọi vị trí đặt hình:
```python
placements = [(r, img) for img in page.get_images(full=True)
              for r in page.get_image_rects(img[0])]
for bbox, img in sorted(placements, key=lambda p: p[0].y0):
    above = [(y, n) for y, n in page_q_starts if y <= bbox.y0]
    ...  # phần còn lại của thân vòng lặp giữ nguyên; bỏ dòng `bbox = page.get_image_bbox(img)`
```
Sau đó: chạy lại `python tools/extract_questions/extract.py` → `python tools/validate_data/validate_questions.py`.

**Kết quả mong đợi** (để kiểm tra; hình câu sau trùng nội dung hình câu trước):
```json
{
 "312": [
  "images/q0311.jpeg"
 ],
 "314": [
  "images/q0313.jpeg"
 ],
 "315": [
  "images/q0313.jpeg"
 ],
 "320": [
  "images/q0319.jpeg"
 ],
 "323": [
  "images/q0322.jpeg"
 ],
 "326": [
  "images/q0325.jpeg"
 ],
 "333": [
  "images/q0332.jpeg"
 ],
 "338": [
  "images/q0336.jpeg"
 ],
 "339": [
  "images/q0336.jpeg"
 ],
 "345": [
  "images/q0344.jpeg"
 ],
 "348": [
  "images/q0347.jpeg"
 ],
 "351": [
  "images/q0350.jpeg"
 ],
 "353": [
  "images/q0352.jpeg"
 ],
 "357": [
  "images/q0356.png"
 ],
 "368": [
  "images/q0367.jpeg"
 ],
 "371": [
  "images/q0370.jpeg"
 ],
 "383": [
  "images/q0381.jpeg"
 ],
 "390": [
  "images/q0389.jpeg"
 ],
 "402": [
  "images/q0401.jpeg"
 ],
 "404": [
  "images/q0403.jpeg"
 ],
 "405": [
  "images/q0403.jpeg"
 ],
 "416": [
  "images/q0415.png"
 ],
 "427": [
  "images/q0426.jpeg"
 ],
 "436": [
  "images/q0435.jpeg"
 ],
 "471": [
  "images/q0470.jpeg"
 ],
 "472": [
  "images/q0470.jpeg"
 ]
}```
Số file hình tăng thêm 26 (hoặc trùng nội dung với file đã có). Nên thêm vào `validate_questions.py` một kiểm tra:
câu có nội dung chứa "hình", "biển nào", "sa hình"… mà `images` rỗng → báo lỗi.

## 3. Thêm script đối chiếu `tools/validate_data/crosscheck_questions.py`

Chuẩn bị nguồn so sánh (không commit, để ngoài repo hoặc thêm vào .gitignore):
```powershell
gh repo clone rinaheart/tdytools-gplx ..\xcheck\rinaheart -- --depth 1
gh repo clone hdung25/600cauhoi ..\xcheck\hdung25 -- --depth 1
python tools/validate_data/crosscheck_questions.py data/question-bank/questions.json ..\xcheck\rinaheart\data\questions.json ..\xcheck\hdung25\data\questions.json > data/question-bank/crosscheck-report.md
```
Đọc báo cáo: dòng **"others agree"** = 2 nguồn ngoài cùng khác mình → ưu tiên soát với PDF. Dòng "ours" = có nguồn đồng ý với mình → thường nguồn kia sai.
Ghi nguồn so sánh vào `docs/data/sources.md` (mục công cụ kiểm tra, ngày truy cập 2026-10-08).

Nội dung script (đã chạy thử, Python 3, không cần thư viện ngoài):
```python
"""Cross-check questions.json against two independent extractions of the same 600-question PDF.
Usage: python crosscheck_questions.py ours.json rinaheart_questions.json hdung25_questions.json > report.md
Only disagreements are printed; majority (2 of 3) is shown as the likely-correct value."""
import json, re, sys, unicodedata, difflib

def norm(s):
    s = unicodedata.normalize('NFC', s or '')
    s = re.sub(r'[“”"„]', '"', s); s = re.sub(r"[‘’']", "'", s); s = re.sub(r'[–—]', '-', s)
    s = re.sub(r'^\s*\d+\s*[.)-]\s*', '', s)          # leading option number "1." / "1)"
    return re.sub(r'\s+', ' ', s).strip().rstrip('.').lower()

def load_ours(p):
    q = json.load(open(p, encoding='utf-8'))['questions']
    return {x['number']: dict(c=x['content'], o=x['options'], a=x['correctIndex'], img=bool(x['images']),
                              crit='B' in x.get('criticalFor', [])) for x in q}
def load_rina(p):
    return {x['questionNumber']: dict(c=x['content'], o=[o['text'] for o in x['options']],
            a=next(i for i, o in enumerate(x['options']) if o['isCorrect']), img=bool(x.get('image')),
            crit=x['isCritical']) for x in json.load(open(p, encoding='utf-8'))}
def load_hd(p):
    return {x['id']: dict(c=x['question'], o=[o['text'] for o in x['options']], a=x['answer'] - 1,
            img=bool(x.get('image')), crit=bool(x.get('critical'))) for x in json.load(open(p, encoding='utf-8'))}

def diff(a, b):
    sm = difflib.SequenceMatcher(None, a, b)
    return '; '.join(f'«{a[i1:i2]}»→«{b[j1:j2]}»' for t, i1, i2, j1, j2 in sm.get_opcodes() if t != 'equal')[:300]

O, R, H = load_ours(sys.argv[1]), load_rina(sys.argv[2]), load_hd(sys.argv[3])
rows, stats = [], dict(content=0, option=0, answer=0, image=0, critical=0)
for n in sorted(O):
    o, r, h = O[n], R.get(n), H.get(n)
    others = [x for x in (r, h) if x]
    def check(field, val):
        ov = val(o); vs = [val(x) for x in others]
        if all(v == ov for v in vs): return
        maj = 'ours' if vs.count(ov) >= 1 else ('others agree' if len(set(map(str, vs))) == 1 else 'all differ')
        return ov, vs, maj
    if (c := check('content', lambda x: norm(x['c']))):
        stats['content'] += 1; rows.append((n, 'content', c[2], diff(c[0], c[1][0])))
    if (c := check('opts', lambda x: [norm(t) for t in x['o']])):
        stats['option'] += 1
        for i, t in enumerate(c[0]):
            alt = c[1][0][i] if i < len(c[1][0]) else '(missing)'
            if t != alt: rows.append((n, f'option {i+1}', c[2], diff(t, alt)))
        if len(c[0]) != len(c[1][0]): rows.append((n, 'option count', c[2], f'{len(c[0])} vs {[len(v) for v in c[1]]}'))
    if (c := check('ans', lambda x: x['a'])):
        stats['answer'] += 1; rows.append((n, 'ANSWER', c[2], f'ours={c[0]+1} others={[v+1 for v in c[1]]}'))
    if (c := check('img', lambda x: x['img'])):
        stats['image'] += 1; rows.append((n, 'image', c[2], f'ours={c[0]} others={c[1]}'))
    if (c := check('crit', lambda x: x['crit'])):
        stats['critical'] += 1; rows.append((n, 'CRITICAL(B)', c[2], f'ours={c[0]} others={c[1]}'))

print(f'# Cross-check questions ({len(O)} câu)\n\nNguồn so sánh: rinaheart/tdytools-gplx, hdung25/600cauhoi.\n'
      f'"ours" = ít nhất 1 nguồn khác đồng ý với mình (thường bên kia sai); "others agree" = 2 nguồn kia cùng khác mình → **ưu tiên soát**.\n')
print('Số câu lệch:', stats, '\n\n| Câu | Trường | Đa số | Khác biệt (mình → nguồn 1) |\n|---|---|---|---|')
for n, f, m, d in sorted(rows, key=lambda r: (r[2] != 'others agree', r[0])):
    print(f'| {n} | {f} | {m} | {d.replace("|", "/")} |')
```

## 4. Danh mục biển báo — ghi nhận, chưa làm

- Không có nguồn ngoài đáng tin để đối chiếu: các app GPLX trên GitHub (vd. `duminoi/GPLXB2` 145 biển) dùng quy chuẩn cũ (còn W.211a/b, "Cấm xe xúc vật kéo"), ảnh lấy từ web có bản quyền → **không dùng**.
- Cải thiện có nguồn chính thức: biến thể đang dùng chung tên mục (W.201a, W.201b đều "Chỗ ngoặt nguy hiểm"),
  trong khi `summary` (nguyên văn QCVN) đã có tên riêng: "Biển số W.201a chỗ ngoặt nguy hiểm vòng bên trái" → sửa `tools/extract_signs/extract.py` lấy tên biến thể từ các dòng "Biển số X.xxxa …".
- Hình biển ~85 px: thử render vùng hình bằng `page.get_pixmap(clip=bbox, dpi=300)` nếu hình trong PDF là vector; hoặc tìm bản Word của Thông tư 51/2024/TT-BGTVT (vbpl.vn / thuvienphapluat.vn).

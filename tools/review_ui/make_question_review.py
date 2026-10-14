"""Build an offline HTML page to review the extracted question bank against the official PDF.

For every question the page shows the crop of the PDF page (left) next to the app data (right), so a reviewer
only compares by eye and clicks "Sai" on mismatches, then exports the result as JSON. No AI involved.

It also re-detects the underlined (correct) option with an independent method — rasterising the page and
looking for a solid dark line under each option — and puts every disagreement with questions.json first.

Usage:
  python tools/review_ui/make_question_review.py [--only-review] [--zoom 1.4]
Output: data/question-bank/review.html — one self-contained file (all images embedded), can be sent as is.
"""
import argparse
import base64
import html
import json
import os
import re
import sys

import pymupdf

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'extract_questions'))
from extract import QUESTION_START, find_one, page_lines, split_segments  # noqa: E402

BANK = 'data/question-bank'
BAND_PT = (-3.0, 0.5)       # band around the line bottom (pt) where the underline stroke sits
UNDERLINE_COVERAGE = 0.6    # longest continuous dark run, as a share of the option's width


def locate_questions(doc):
    """Return {number: [(page_index, y_top)]} start positions of every 'Câu N.' line."""
    starts = {}
    for pno in range(4, doc.page_count):
        for line in page_lines(doc[pno]):
            m = QUESTION_START.match(' '.join(w[2] for w in line['words']))
            if m and line['bold']:
                starts.setdefault(int(m.group(1)), (pno, line['bbox'][1]))
    return starts


def question_regions(doc, starts, n):
    """Page regions (page_index, Rect) from the start of question n to the start of question n+1."""
    pno, y0 = starts[n]
    nxt = starts.get(n + 1)
    regions = []
    page = doc[pno]
    if nxt and nxt[0] == pno:
        regions.append((pno, pymupdf.Rect(0, y0 - 4, page.rect.width, nxt[1] - 2)))
    else:
        regions.append((pno, pymupdf.Rect(0, y0 - 4, page.rect.width, page.rect.height - 40)))
        if nxt and nxt[0] == pno + 1 and nxt[1] > 70:
            regions.append((pno + 1, pymupdf.Rect(0, 50, page.rect.width, nxt[1] - 2)))
    return regions


def raster_underlined(doc, regions):
    """Independent answer detection: option numbers whose text has a solid dark band right under it."""
    found = set()
    current = None
    for pno, rect in regions:
        page = doc[pno]
        zoom = 3
        pix = page.get_pixmap(matrix=pymupdf.Matrix(zoom, zoom), clip=rect, colorspace=pymupdf.csGRAY)
        w, h, buf = pix.width, pix.height, pix.samples
        for line in page_lines(page):
            x0, y0, x1, y1 = line['bbox']
            if y0 < rect.y0 or y1 > rect.y1 + 2:
                continue
            segs = split_segments(line['words'])
            if QUESTION_START.match(' '.join(wd[2] for wd in line['words'])):
                current = None
                continue
            for opt, a, b, _ in segs:
                if opt is not None:
                    current = opt
                target = opt if opt is not None else current
                if target is None:
                    continue
                py0 = int((y1 + BAND_PT[0] - rect.y0) * zoom)
                py1 = int((y1 + BAND_PT[1] - rect.y0) * zoom)
                px0, px1 = int((a - rect.x0) * zoom), int((b - rect.x0) * zoom)
                if py1 >= h or px1 <= px0:
                    continue
                # an underline is one continuous dark row; glyph descenders and dots are short pieces
                longest = 0
                for y in range(max(py0, 0), min(py1, h)):
                    run = 0
                    for x in range(max(px0, 0), min(px1, w)):
                        run = run + 1 if buf[y * w + x] < 140 else 0
                        longest = max(longest, run)
                if longest / max(1, px1 - px0) >= UNDERLINE_COVERAGE:
                    found.add(target)
    return found


def embed_image(rel_path):
    """App image as a data URI, so review.html is one self-contained file that can be sent on its own."""
    path = os.path.join(BANK, rel_path)
    ext = os.path.splitext(path)[1].lstrip('.').lower().replace('jpg', 'jpeg')
    with open(path, 'rb') as fh:
        return f'data:image/{ext};base64,' + base64.b64encode(fh.read()).decode()


def crop_b64(doc, regions, zoom):
    out = []
    for pno, rect in regions:
        pix = doc[pno].get_pixmap(matrix=pymupdf.Matrix(zoom, zoom), clip=rect)
        out.append('data:image/jpeg;base64,' + base64.b64encode(pix.tobytes('jpeg', jpg_quality=55)).decode())
    return out


def review_numbers():
    path = os.path.join(BANK, 'review.md')
    if not os.path.isfile(path):
        return set()
    return {int(m) for m in re.findall(r'^\| \[.\] \| (\d+) \|', open(path, encoding='utf-8').read(), re.M)}


PAGE = """<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Soát bộ câu hỏi</title>
<style>
:root{--bg:#f6f7f9;--card:#fff;--fg:#1d2330;--muted:#667;--ok:#1a7f37;--bad:#c62828;--warn:#b26a00;--line:#dde1e7}
@media (prefers-color-scheme:dark){:root{--bg:#14171c;--card:#1d2128;--fg:#e8eaee;--muted:#9aa3b2;--line:#323844}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.45 system-ui,sans-serif}
header{position:sticky;top:0;z-index:2;background:var(--card);border-bottom:1px solid var(--line);padding:10px 16px;display:flex;gap:12px;flex-wrap:wrap;align-items:center}
header b{font-size:16px} select,button{font:inherit;padding:6px 10px;border-radius:6px;border:1px solid var(--line);background:var(--card);color:var(--fg);cursor:pointer}
.stat{color:var(--muted)} main{max-width:1200px;margin:0 auto;padding:12px 16px}
.q{display:grid;grid-template-columns:minmax(0,1.1fr) minmax(0,1fr);gap:16px;background:var(--card);border:1px solid var(--line);border-radius:10px;padding:12px;margin:12px 0}
.q.bad{border:2px solid var(--bad)} .q.flag{border-left:6px solid var(--warn)}
.q img.pdf{width:100%;background:#fff;border-radius:6px;display:block;margin-bottom:6px}
.meta{color:var(--muted);font-size:13px} .alert{color:var(--bad);font-weight:600}
ol{padding-left:22px;margin:8px 0} li{margin:4px 0} li.ok{color:var(--ok);font-weight:600} li.ok::after{content:"  ✅ đáp án đúng"}
.app img{max-width:100%;max-height:220px;background:#fff;border-radius:6px}
.actions{display:flex;gap:8px;align-items:center;margin-top:8px} .actions textarea{flex:1;min-height:34px;font:inherit;border-radius:6px;border:1px solid var(--line);background:var(--bg);color:var(--fg)}
button.wrong{border-color:var(--bad)} .q.marked button.wrong{background:var(--bad);color:#fff}
@media (max-width:760px){.q{grid-template-columns:1fr}}
</style></head><body>
<header><b>Soát bộ câu hỏi (__COUNT__ câu)</b>
<select id="filter"><option value="all">Tất cả</option><option value="mismatch">Lệch đáp án (máy dò lại)</option>
<option value="review">Trong review.md</option><option value="marked">Đã bấm Sai</option></select>
<span class="stat" id="stat"></span><button id="export">Xuất kết quả (JSON)</button></header>
<main id="list">__CARDS__</main>
<script>
const KEY='hoclaixe-review-questions';
let state={};try{state=JSON.parse(localStorage.getItem(KEY)||'{}')}catch(e){}
function save(){try{localStorage.setItem(KEY,JSON.stringify(state))}catch(e){}stat()}
function stat(){const m=Object.values(state).filter(s=>s.wrong).length;document.getElementById('stat').textContent=m+' câu đánh dấu Sai'}
document.querySelectorAll('.q').forEach(c=>{const n=c.dataset.n,s=state[n]||{};
 const t=c.querySelector('textarea');if(s.wrong)c.classList.add('marked');t.value=s.note||'';
 c.querySelector('button.wrong').onclick=()=>{const cur=state[n]||{};cur.wrong=!cur.wrong;state[n]=cur;c.classList.toggle('marked',cur.wrong);save()};
 t.oninput=()=>{const cur=state[n]||{};cur.note=t.value;state[n]=cur;save()}});
document.getElementById('filter').onchange=e=>{const v=e.target.value;document.querySelectorAll('.q').forEach(c=>{
 const show=v==='all'||(v==='mismatch'&&c.dataset.mismatch==='1')||(v==='review'&&c.dataset.review==='1')||(v==='marked'&&c.classList.contains('marked'));
 c.style.display=show?'':'none'})};
document.getElementById('export').onclick=()=>{const out=Object.entries(state).filter(([n,s])=>s.wrong||s.note).map(([n,s])=>({number:+n,wrong:!!s.wrong,note:s.note||''}));
 const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify({reviewed:new Date().toISOString(),items:out},null,1)],{type:'application/json'}));
 a.download='review-result-questions.json';a.click()};
stat();
</script></body></html>"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--only-review', action='store_true', help='only questions listed in review.md')
    ap.add_argument('--zoom', type=float, default=1.15)
    args = ap.parse_args()

    bank = json.load(open(os.path.join(BANK, 'questions.json'), encoding='utf-8'))['questions']
    doc = pymupdf.open(find_one(os.path.join(BANK, 'raw'), '*600 câu hỏi*.pdf'))
    starts = locate_questions(doc)
    in_review = review_numbers()

    cards, mismatches = [], []
    for q in bank:
        n = q['number']
        if args.only_review and n not in in_review:
            continue
        regions = question_regions(doc, starts, n)
        raster = raster_underlined(doc, regions)
        app_ans = q['correctIndex'] + 1
        mismatch = raster != {app_ans}
        if mismatch:
            mismatches.append((n, sorted(raster), app_ans))
        crops = ''.join(f'<img class="pdf" src="{src}" alt="PDF câu {n}">' for src in crop_b64(doc, regions, args.zoom))
        opts = ''.join(f'<li class="{"ok" if i == q["correctIndex"] else ""}">{html.escape(o)}</li>'
                       for i, o in enumerate(q['options']))
        imgs = ''.join(f'<img src="{embed_image(p)}" alt="hình câu {n}">' for p in q['images'])
        crit = ', '.join(c for c in ('A1', 'B1', 'B') if c in q['criticalFor'])
        alert = (f'<div class="alert">⚠ Máy dò lại gạch chân: {sorted(raster) or "không thấy"} — app ghi {app_ans}</div>'
                 if mismatch else '')
        cards.append((0 if mismatch else 1, n, f'''
<section class="q{' bad' if mismatch else ''}{' flag' if n in in_review else ''}" data-n="{n}" data-mismatch="{int(mismatch)}" data-review="{int(n in in_review)}">
 <div>{crops}<div class="meta">PDF trang {q['sourcePage']}</div></div>
 <div class="app"><div class="meta">Câu {n} · Chương {q['chapter']} · Hạng: {' '.join(q['licenseClasses'][:3])}… {('· Điểm liệt: ' + crit) if crit else ''}</div>
  {alert}<p><b>{html.escape(q['content'])}</b></p>{imgs}<ol>{opts}</ol>
  <div class="actions"><button class="wrong">Sai</button><textarea placeholder="Ghi chú nếu sai…"></textarea></div></div>
</section>'''))
    cards.sort()
    page = PAGE.replace('__COUNT__', str(len(cards))).replace('__CARDS__', ''.join(c[2] for c in cards))
    out = os.path.join(BANK, 'review.html')
    with open(out, 'w', encoding='utf-8') as fh:
        fh.write(page)
    print(f'{len(cards)} questions -> {out} ({os.path.getsize(out) / 1e6:.1f} MB)')
    print(f'independent underline check disagrees on {len(mismatches)} questions:', mismatches[:30])


if __name__ == '__main__':
    main()

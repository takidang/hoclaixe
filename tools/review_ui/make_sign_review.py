"""Build an offline HTML page to review the sign catalog against QCVN 41:2024 — one tab per sign group.

Each card shows, from the official PDF, the section heading (name of the sign) and the figure with the
"Biển số …" label for that code (left), next to the app data: image, code, name, meaning (right).
The reviewer clicks "Khớp" or "Sai" (+ note) and exports the result; progress per group is counted.
No AI involved. The output is one self-contained file (all images embedded) that can be sent as is.

Usage: python tools/review_ui/make_sign_review.py [--pdf data/question-bank/raw/51-bgtvt-kem.pdf]
Output: data/sign-catalog/review.html
"""
import argparse
import base64
import html
import json
import os
import re

import pymupdf

CATALOG = 'data/sign-catalog'
FIGURE_HEIGHT = 135   # pt of page shown above the label line (sign pictures are ~85 pt high)


def clean(s):
    return re.sub(r'\s+', ' ', re.sub(r'[\x00-\x08]', ' ', s)).strip()


def lines_of(page):
    out = []
    for b in page.get_text('dict')['blocks']:
        for line in b.get('lines', []):
            t = clean(''.join(s['text'] for s in line['spans']))
            if t:
                out.append((pymupdf.Rect(line['bbox']), t, any(s['flags'] & 16 for s in line['spans'])))
    return out


def jpeg(page, rect, zoom=1.6):
    pix = page.get_pixmap(matrix=pymupdf.Matrix(zoom, zoom), clip=rect)
    return 'data:image/jpeg;base64,' + base64.b64encode(pix.tobytes('jpeg', jpg_quality=60)).decode()


def embed(path):
    ext = os.path.splitext(path)[1].lstrip('.').lower().replace('jpg', 'jpeg')
    with open(path, 'rb') as fh:
        return f'data:image/{ext};base64,' + base64.b64encode(fh.read()).decode()


def find_crops(doc, sign):
    """Heading crop (section title) and figure crop (picture + label naming this code)."""
    code = re.escape(sign['code'])
    code_re = re.compile(r'Biển\s*số\s*' + code + r'(?![a-z0-9])|' + code + r'(?![a-z0-9])')
    start = sign['source']['page'] - 1
    heading = figure = None
    for pno in range(start, min(start + 4, doc.page_count)):
        page = doc[pno]
        ls = lines_of(page)
        if heading is None:
            for i, (r, t, bold) in enumerate(ls):
                if bold and t.startswith(sign['section']) and re.match(re.escape(sign['section']) + r'\b', t):
                    bottom = r.y1
                    for r2, t2, b2 in ls[i + 1:i + 4]:   # heading may wrap to 2–3 bold lines
                        if b2 and r2.y0 - bottom < 6:
                            bottom = r2.y1
                        else:
                            break
                    heading = (pno, pymupdf.Rect(50, r.y0 - 3, page.rect.width - 40, bottom + 3))
                    break
        for r, t, bold in ls:
            # bold label "a) Biển số P.103a" or caption "Hình B.4 - Biển số P.104" under the picture
            if bold and code_re.search(t) and (re.match(r'^[a-zđ]\)', t) or t.startswith('Hình')):
                top = max(40, r.y0 - FIGURE_HEIGHT)
                figure = (pno, pymupdf.Rect(40, top, page.rect.width - 40, r.y1 + 3))
                break
        if figure:
            break
    return heading, figure


def review_codes():
    path = os.path.join(CATALOG, 'review.md')
    if not os.path.isfile(path):
        return set()
    return set(re.findall(r'^\| \[.\] \| ((?:DP|IE|[PWRIS])\.\d{3}[a-z]?) \|', open(path, encoding='utf-8').read(), re.M))


PAGE = """<!doctype html><html lang="vi"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>Soát biển báo</title>
<style>
:root{--bg:#f6f7f9;--card:#fff;--fg:#1d2330;--muted:#667;--ok:#1a7f37;--bad:#c62828;--warn:#b26a00;--line:#dde1e7;--acc:#0b5cad}
@media (prefers-color-scheme:dark){:root{--bg:#14171c;--card:#1d2128;--fg:#e8eaee;--muted:#9aa3b2;--line:#323844;--acc:#6aa7ff}}
body{margin:0;background:var(--bg);color:var(--fg);font:15px/1.45 system-ui,sans-serif}
header{position:sticky;top:0;z-index:2;background:var(--card);border-bottom:1px solid var(--line);padding:10px 16px}
.top{display:flex;gap:10px;flex-wrap:wrap;align-items:center}
.tabs{display:flex;gap:6px;flex-wrap:wrap;margin-top:8px}
.tabs button{border-radius:999px} .tabs button.on{background:var(--acc);color:#fff;border-color:var(--acc)}
select,button{font:inherit;padding:6px 12px;border-radius:6px;border:1px solid var(--line);background:var(--card);color:var(--fg);cursor:pointer}
.stat{color:var(--muted);font-size:14px} main{max-width:1200px;margin:0 auto;padding:12px 16px}
.s{display:grid;grid-template-columns:minmax(0,1.1fr) minmax(0,1fr);gap:16px;background:var(--card);border:1px solid var(--line);border-radius:10px;padding:12px;margin:12px 0}
.s.flag{border-left:6px solid var(--warn)} .s.ok{border-left:6px solid var(--ok)} .s.bad{border-left:6px solid var(--bad)}
.pdf img{width:100%;background:#fff;border-radius:6px;display:block;margin-bottom:6px}
.meta{color:var(--muted);font-size:13px} .reason{color:var(--warn);font-size:13px}
.app .imgs img{height:110px;background:#fff;border-radius:6px;margin-right:8px;padding:4px}
.code{font-weight:700;color:var(--acc)} h3{margin:4px 0 6px;font-size:17px}
.meaning{white-space:pre-line;font-size:14px;max-height:180px;overflow:auto;border-top:1px solid var(--line);padding-top:6px}
.actions{display:flex;gap:8px;align-items:center;margin-top:8px} .actions textarea{flex:1;min-height:34px;font:inherit;border-radius:6px;border:1px solid var(--line);background:var(--bg);color:var(--fg)}
.s.ok button.okb{background:var(--ok);color:#fff} .s.bad button.badb{background:var(--bad);color:#fff}
@media (max-width:760px){.s{grid-template-columns:1fr}}
</style></head><body>
<header><div class="top"><b>Soát danh mục biển báo — QCVN 41:2024</b>
<select id="filter"><option value="all">Tất cả</option><option value="review">Trong review.md</option>
<option value="todo">Chưa xem</option><option value="bad">Đã đánh Sai</option></select>
<span class="stat" id="stat"></span><button id="export">Xuất kết quả (JSON)</button></div>
<div class="tabs" id="tabs">__TABS__</div></header>
<main id="list">__CARDS__</main>
<script>
const KEY='hoclaixe-review-signs';
let st={};try{st=JSON.parse(localStorage.getItem(KEY)||'{}')}catch(e){}
let group='__FIRST__';
const cards=[...document.querySelectorAll('.s')];
function save(){try{localStorage.setItem(KEY,JSON.stringify(st))}catch(e){}paint()}
function paint(){cards.forEach(c=>{const s=st[c.dataset.code]||{};c.classList.toggle('ok',s.status==='ok');c.classList.toggle('bad',s.status==='bad')});
 const f=document.getElementById('filter').value;
 cards.forEach(c=>{const s=(st[c.dataset.code]||{}).status;let show=c.dataset.group===group;
  if(f==='review')show=show&&c.dataset.review==='1';if(f==='todo')show=show&&!s;if(f==='bad')show=show&&s==='bad';c.style.display=show?'':'none'});
 document.querySelectorAll('#tabs button').forEach(b=>{const g=b.dataset.group,inG=cards.filter(c=>c.dataset.group===g);
  const seen=inG.filter(c=>(st[c.dataset.code]||{}).status).length;b.textContent=b.dataset.name+' ('+seen+'/'+inG.length+')';b.classList.toggle('on',g===group)});
 const all=Object.values(st);document.getElementById('stat').textContent=all.filter(s=>s.status).length+'/'+cards.length+' đã xem · '+all.filter(s=>s.status==='bad').length+' sai'}
cards.forEach(c=>{const code=c.dataset.code,t=c.querySelector('textarea');t.value=(st[code]||{}).note||'';
 const set=v=>{const s=st[code]||{};s.status=s.status===v?undefined:v;st[code]=s;save()};
 c.querySelector('.okb').onclick=()=>set('ok');c.querySelector('.badb').onclick=()=>set('bad');
 t.oninput=()=>{const s=st[code]||{};s.note=t.value;st[code]=s;save()}});
document.querySelectorAll('#tabs button').forEach(b=>b.onclick=()=>{group=b.dataset.group;paint();window.scrollTo(0,0)});
document.getElementById('filter').onchange=paint;
document.getElementById('export').onclick=()=>{const groups={};cards.forEach(c=>{const g=c.dataset.group,s=(st[c.dataset.code]||{}).status;
  groups[g]=groups[g]||{total:0,ok:0,bad:0,unseen:0};groups[g].total++;groups[g][s||'unseen']++});
 const items=Object.entries(st).filter(([k,s])=>s.status==='bad'||s.note).map(([k,s])=>({code:k,status:s.status||'unseen',note:s.note||''}));
 const a=document.createElement('a');a.href=URL.createObjectURL(new Blob([JSON.stringify({reviewed:new Date().toISOString(),groups,items},null,1)],{type:'application/json'}));
 a.download='review-result-signs.json';a.click()};
paint();
</script></body></html>"""


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--pdf', default='data/question-bank/raw/51-bgtvt-kem.pdf')
    args = ap.parse_args()
    cat = json.load(open(os.path.join(CATALOG, 'signs.json'), encoding='utf-8'))
    doc = pymupdf.open(args.pdf)
    in_review = review_codes()
    reasons = {}
    for m in re.finditer(r'^\| \[.\] \| (\S+) \|[^|]*\|[^|]*\|[^|]*\| ([^|]*)\|', open(os.path.join(CATALOG, 'review.md'), encoding='utf-8').read(), re.M):
        reasons[m.group(1)] = m.group(2).strip()

    groups = list(cat['groups'].items())
    cards, missing = [], []
    for s in cat['signs']:
        heading, figure = find_crops(doc, s)
        left = ''
        if heading:
            left += f'<img src="{jpeg(doc[heading[0]], heading[1])}" alt="đề mục {s["section"]}">'
        if figure:
            left += f'<img src="{jpeg(doc[figure[0]], figure[1])}" alt="hình {s["code"]} trong PDF">'
        else:
            missing.append(s['code'])
            left += '<p class="reason">Không tìm thấy nhãn hình của mã này trong PDF — mở PDF trang ' \
                    f'{s["source"]["page"]}–{s["source"]["page"] + 3} để xem.</p>'
        imgs = ''.join(f'<img src="{embed(os.path.join(CATALOG, p))}" alt="{s["code"]}">' for p in s['images']) \
            or '<span class="reason">(app không có hình)</span>'
        why = f'<div class="reason">Lý do soát: {html.escape(reasons[s["code"]])}</div>' if s['code'] in reasons else ''
        cards.append(f'''
<section class="s{' flag' if s['code'] in in_review else ''}" data-code="{s['code']}" data-group="{s['group']}" data-review="{int(s['code'] in in_review)}">
 <div class="pdf">{left}<div class="meta">PDF trang {s['source']['page']} · mục {s['section']}</div></div>
 <div class="app"><div class="imgs">{imgs}</div>
  <h3><span class="code">{s['code']}</span> · {html.escape(s['name'] or '(chưa có tên)')}</h3>{why}
  <div class="meaning">{html.escape(s['meaning'])}</div>
  <div class="actions"><button class="okb">Khớp</button><button class="badb">Sai</button><textarea placeholder="Ghi chú nếu sai…"></textarea></div></div>
</section>''')
    tabs = ''.join(f'<button data-group="{k}" data-name="{html.escape(v)}">{html.escape(v)}</button>' for k, v in groups)
    page = PAGE.replace('__TABS__', tabs).replace('__CARDS__', ''.join(cards)).replace('__FIRST__', groups[0][0])
    out = os.path.join(CATALOG, 'review.html')
    with open(out, 'w', encoding='utf-8') as fh:
        fh.write(page)
    print(f'{len(cards)} signs -> {out} ({os.path.getsize(out) / 1e6:.1f} MB); no PDF figure found for {len(missing)}: {missing[:20]}')


if __name__ == '__main__':
    main()

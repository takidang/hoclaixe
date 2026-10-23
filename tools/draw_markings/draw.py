"""Draw illustrations for road markings that have no figure in QCVN 41:2024 (vạch 3.2, 3.3, 3.4).

Drawn by the team from the specification text (QCVN 41:2024 Phụ lục G, p. 168) — NOT official figures; the app
shows that caption under them (`imageNote` in overrides.json). Solid line for 3.2, dashes L1:L2 = 1:1 for 3.3,
L1:L2 = 3:1 for 3.4, white on a grey road surface.
Usage: python tools/draw_markings/draw.py  ->  data/sign-catalog/drawn/*.png
"""
import os

import pymupdf

OUT = os.path.join('data', 'sign-catalog', 'drawn')
W, H = 600, 220
ROAD = (0.29, 0.31, 0.34)      # asphalt
EDGE = (0.55, 0.57, 0.60)      # shoulders
WHITE = (1, 1, 1)
LINE_Y, LINE_H = H / 2 - 6, 12

# code -> list of (dash length, gap) or None for a solid line
MARKINGS = {
    'V3_2': None,          # vạch liền nét
    'V3_3': (48, 48),      # đứt nét, L1:L2 = 1:1
    'V3_4': (90, 30),      # đứt nét, L1:L2 = 3:1
}


def draw(name, pattern):
    doc = pymupdf.open()
    page = doc.new_page(width=W, height=H)
    page.draw_rect(page.rect, color=None, fill=EDGE)
    page.draw_rect(pymupdf.Rect(0, 14, W, H - 14), color=None, fill=ROAD)
    if pattern is None:
        page.draw_rect(pymupdf.Rect(24, LINE_Y, W - 24, LINE_Y + LINE_H), color=None, fill=WHITE)
    else:
        dash, gap = pattern
        x = 24
        while x < W - 24:
            page.draw_rect(pymupdf.Rect(x, LINE_Y, min(x + dash, W - 24), LINE_Y + LINE_H), color=None, fill=WHITE)
            x += dash + gap
    page.get_pixmap(dpi=96).save(os.path.join(OUT, f'{name}.png'))


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for name, pattern in MARKINGS.items():
        draw(name, pattern)
    print('drawn:', ', '.join(MARKINGS))

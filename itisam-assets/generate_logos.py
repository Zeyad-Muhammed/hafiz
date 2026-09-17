# -*- coding: utf-8 -*-
"""Itisam logo v3 - stamped smooth strokes, transparent bg."""
import os
from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "output")
os.makedirs(OUT, exist_ok=True)

SS = 4
BASE = 1000
W = BASE * SS

DEEP  = (26, 60, 52, 255)
GOLD  = (186, 152, 104, 255)
CREAM = (245, 241, 232, 255)
BEIGE = (237, 230, 214, 255)
BLACK = (22, 22, 22, 255)
WHITE = (255, 255, 255, 255)

def cubic(p0, p1, p2, p3, n=120):
    pts = []
    for i in range(n + 1):
        t = i / n
        mt = 1 - t
        x = mt**3*p0[0] + 3*mt*mt*t*p1[0] + 3*mt*t*t*p2[0] + t**3*p3[0]
        y = mt**3*p0[1] + 3*mt*mt*t*p1[1] + 3*mt*t*t*p2[1] + t**3*p3[1]
        pts.append((x * SS, y * SS))
    return pts

def chain(*segs):
    out = []
    for s in segs:
        out += s[1:] if out else s
    return out

def smooth_stroke(d, pts, width_final, color):
    w = int(width_final * SS)
    r = w / 2
    d.line(pts, fill=color, width=w)  # base, no joint spikes (default miter but dense pts => ok)
    for (x, y) in pts[::3]:
        d.ellipse([x - r, y - r, x + r, y + r], fill=color)
    for (x, y) in (pts[0], pts[-1]):
        d.ellipse([x - r, y - r, x + r, y + r], fill=color)

def dome_path():
    return chain(
        cubic((408, 658), (308, 596), (282, 452), (352, 298)),
        cubic((352, 298), (404, 196), (462, 148), (500, 108)),
        cubic((500, 108), (538, 148), (596, 196), (648, 298)),
        cubic((648, 298), (718, 452), (692, 596), (592, 658)),
    )

def draw_logo(main_color, diamond_color, size=BASE):
    img = Image.new("RGBA", (W, W), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    smooth_stroke(d, dome_path(), 92, main_color)
    # outer book wings (lower, longer)
    smooth_stroke(d, cubic((498, 712), (398, 706), (298, 678), (208, 612)), 56, main_color)
    smooth_stroke(d, cubic((502, 712), (602, 706), (702, 678), (792, 612)), 56, main_color)
    # inner page lines (higher, shorter, thinner -> visible separation)
    smooth_stroke(d, cubic((498, 662), (414, 656), (334, 634), (262, 588)), 24, main_color)
    smooth_stroke(d, cubic((502, 662), (586, 656), (666, 634), (738, 588)), 24, main_color)
    cx, cy, r = 500 * SS, 512 * SS, 36 * SS
    d.polygon([(cx, cy - r), (cx + r*0.75, cy), (cx, cy + r), (cx - r*0.75, cy)], fill=diamond_color)
    cr = 10 * SS
    d.ellipse([cx - cr, 648*SS - cr, cx + cr, 648*SS + cr], fill=diamond_color)
    return img.resize((size, size), Image.LANCZOS)

def rounded_bg(size, radius, color):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(img).rounded_rectangle([0, 0, size-1, size-1], radius=radius, fill=color)
    return img

versions = [
    ("itisam-logo-deep-transparent", DEEP, GOLD),
    ("itisam-logo-white-transparent", WHITE, GOLD),
    ("itisam-logo-black-transparent", BLACK, GOLD),
    ("itisam-logo-beige-transparent", BEIGE, GOLD),
    ("itisam-logo-gold-transparent", GOLD, DEEP),
]
for name, main, dia in versions:
    draw_logo(main, dia).save(os.path.join(OUT, name + ".png"))
    print("saved", name)

deep_w = draw_logo(WHITE, GOLD, 720)
beige_d = draw_logo(DEEP, GOLD, 720)
for iname, bg, fg in [("itisam-appicon-dark", DEEP[:3] + (255,), deep_w),
                      ("itisam-appicon-light", CREAM, beige_d)]:
    bg_img = rounded_bg(1024, 230, bg)
    bg_img.alpha_composite(fg, (152, 152))
    bg_img.save(os.path.join(OUT, iname + "-1024.png"))
    print("saved", iname)

src = draw_logo(DEEP, GOLD, 256)
for s in (16, 32, 48, 180):
    src.resize((s, s), Image.LANCZOS).save(os.path.join(OUT, f"itisam-favicon-{s}.png"))
print("favicons done")

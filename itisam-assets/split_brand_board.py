# -*- coding: utf-8 -*-
"""Split the Itisam brand-board into standalone images + transparent logos.
Usage:
  1) Save the original brand board (highest resolution you have) as:
       itisam-assets/brand-board.png  (or .jpg)
  2) Run: python split_brand_board.py
Output -> itisam-assets/output/slices/*.png

Boxes are relative (x0,y0,x1,y1) so any resolution works.
make_transparent(): turns near-solid backgrounds (white / beige / dark-green)
into alpha, with edge feathering, for logo-only crops.
Requires: Pillow
"""
import os
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
SRC_CANDIDATES = [os.path.join(HERE, "brand-board.png"),
                  os.path.join(HERE, "brand-board.jpg"),
                  os.path.join(HERE, "brand-board.jpeg")]
DST = os.path.join(HERE, "output", "slices")
os.makedirs(DST, exist_ok=True)

# Layout boxes measured on the brand board (fractions of W/H)
SLICES = {
    "01-appicon-light-big":   (0.025, 0.020, 0.290, 0.395),
    "02-appicon-dark-big":    (0.300, 0.020, 0.555, 0.395),
    "03-mini-light":          (0.568, 0.045, 0.638, 0.190),
    "04-mini-dark":           (0.648, 0.045, 0.718, 0.190),
    "05-mini-green":          (0.568, 0.205, 0.638, 0.350),
    "06-mini-outline":        (0.648, 0.205, 0.718, 0.350),
    "07-phone-mockup":        (0.735, 0.000, 1.000, 0.395),
    "08-lockup-arabic":       (0.005, 0.415, 0.245, 0.625),
    "09-lockup-compact":      (0.255, 0.415, 0.485, 0.625),
    "10-lockup-english":      (0.495, 0.415, 0.720, 0.690),
    "11-construction-grid":   (0.735, 0.410, 1.000, 0.655),
    "12-color-variations":    (0.005, 0.705, 0.285, 0.870),
    "13-brand-colors":        (0.475, 0.705, 0.730, 0.870),
    "14-favicons":            (0.815, 0.705, 1.000, 0.870),
    "15-footer-bar":          (0.000, 0.915, 1.000, 1.000),
}

def find_source():
    for p in SRC_CANDIDATES:
        if os.path.exists(p):
            return p
    return None

def make_transparent(img, bg="light", tol=38, feather=1.2):
    """bg: light (white/beige) | dark (deep green) | black"""
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    if bg == "dark":
        ref = (26, 60, 52)
    elif bg == "black":
        ref = (18, 18, 18)
    else:
        # light backgrounds: use luminance distance to near-white
        ref = None
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    op = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if ref is None:
                dist = ((r - 245) ** 2 + (g - 241) ** 2 + (b - 232) ** 2) ** 0.5
                keep = dist > tol
            else:
                dist = ((r - ref[0]) ** 2 + (g - ref[1]) ** 2 + (b - ref[2]) ** 2) ** 0.5
                keep = dist > tol
            op[x, y] = (r, g, b, 255 if keep else 0)
    if feather:
        alpha = out.split()[3].filter(ImageFilter.GaussianBlur(feather))
        out.putalpha(alpha)
    return out

def main():
    src = find_source()
    if not src:
        print(">> Put the brand board file at:")
        print("   ", SRC_CANDIDATES[0])
        print(">> then re-run. Nothing sliced (source missing).")
        return
    board = Image.open(src).convert("RGB")
    W, H = board.size
    print(f"source: {src} ({W}x{H})")
    for name, (x0, y0, x1, y1) in SLICES.items():
        crop = board.crop((int(x0*W), int(y0*H), int(x1*W), int(y1*H)))
        crop.save(os.path.join(DST, name + ".png"))
        print("sliced", name, crop.size)
    # transparent logo extractions (from the two big icons + mini set)
    b = Image.open(src).convert("RGBA")
    W, H = b.size
    jobs = [
        ("logo-from-light-transparent", (0.025, 0.020, 0.290, 0.395), "light"),
        ("logo-from-dark-transparent",  (0.300, 0.020, 0.555, 0.395), "dark"),
    ]
    for name, (x0, y0, x1, y1), bg in jobs:
        crop = b.crop((int(x0*W), int(y0*H), int(x1*W), int(y1*H)))
        t = make_transparent(crop, bg=bg)
        # tight auto-crop to content
        bbox = t.split()[3].getbbox()
        if bbox:
            t = t.crop(bbox)
        t.save(os.path.join(DST, name + ".png"))
        print("transparent", name, t.size)

if __name__ == "__main__":
    main()

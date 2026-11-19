from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1]
store = root / "store" / "play"
store.mkdir(parents=True, exist_ok=True)
logo = Image.open(root / "assets" / "logo.png").convert("RGBA")

cream = (255, 246, 234, 255)


def fit_on_canvas(src: Image.Image, size: int, pad_ratio: float = 0.12, bg=cream) -> Image.Image:
    canvas = Image.new("RGBA", (size, size), bg)
    max_side = int(size * (1 - 2 * pad_ratio))
    ratio = min(max_side / src.width, max_side / src.height)
    nw = max(1, int(src.width * ratio))
    nh = max(1, int(src.height * ratio))
    resized = src.resize((nw, nh), Image.Resampling.LANCZOS)
    x = (size - nw) // 2
    y = (size - nh) // 2
    canvas.alpha_composite(resized, (x, y))
    return canvas


fg = logo.copy()
pixels = fg.load()
assert pixels is not None
for y in range(fg.height):
    for x in range(fg.width):
        r, g, b, a = pixels[x, y]
        if r < 28 and g < 28 and b < 28:
            pixels[x, y] = (0, 0, 0, 0)

icon_src = root / "assets" / "play_icon_source.png"
adaptive_fg = root / "assets" / "play_adaptive_fg.png"
fit_on_canvas(logo, 1024, 0.14, cream).save(icon_src)
fit_on_canvas(fg, 1024, 0.18, (0, 0, 0, 0)).save(adaptive_fg)
fit_on_canvas(logo, 512, 0.12, cream).convert("RGB").save(store / "icon_512.png", quality=95)

feat = Image.new("RGBA", (1024, 500), cream)
draw = ImageDraw.Draw(feat)
for i in range(160):
    alpha = int(40 * (i / 160))
    draw.rectangle([0, 500 - 160 + i, 1024, 500 - 159 + i], fill=(216, 58, 69, alpha))

lw = 360
ratio = lw / logo.width
lh = int(logo.height * ratio)
logo_big = logo.resize((lw, lh), Image.Resampling.LANCZOS)
feat.alpha_composite(logo_big, (72, (500 - lh) // 2))

try:
    font_big = ImageFont.truetype(r"C:\Windows\Fonts\segoeuib.ttf", 42)
    font_sm = ImageFont.truetype(r"C:\Windows\Fonts\segoeui.ttf", 26)
except OSError:
    font_big = ImageFont.load_default()
    font_sm = font_big

draw = ImageDraw.Draw(feat)
draw.text((470, 175), "HAPPY LA LA LAND", fill=(40, 40, 40, 255), font=font_big)
draw.text((470, 240), "Kids playground booking", fill=(216, 58, 69, 255), font=font_sm)
draw.text((470, 285), "Mawlamyine", fill=(90, 90, 90, 255), font=font_sm)
feat.convert("RGB").save(store / "feature_graphic.png", quality=95)

print("ok", icon_src.name, adaptive_fg.name, "icon_512.png", "feature_graphic.png")

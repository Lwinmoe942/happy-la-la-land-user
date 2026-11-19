from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT_PHONE = ROOT / "store" / "play" / "phone"
OUT_TABLET = ROOT / "store" / "play" / "tablet"
OUT_PHONE.mkdir(parents=True, exist_ok=True)
OUT_TABLET.mkdir(parents=True, exist_ok=True)

ASSETS = Path(r"C:\Users\user\.cursor\projects\d-HAPPY-LA-LA-LAND\assets")
SOURCES = [
    (
        "01_home",
        ASSETS
        / "c__Users_user_AppData_Roaming_Cursor_User_workspaceStorage_853887575bc7d6c26a4f75f409966859_images_photo_1_2026-11-19_20-58-06-3112e2ab-5adf-4b1d-89e9-be4b0bc0e6f5.jpg",
    ),
    (
        "02_main",
        ASSETS
        / "c__Users_user_AppData_Roaming_Cursor_User_workspaceStorage_853887575bc7d6c26a4f75f409966859_images_photo_2_2026-11-19_20-58-06-001d190a-89c4-4edf-88d4-398f2f200aa8.jpg",
    ),
    (
        "03_booking",
        ASSETS
        / "c__Users_user_AppData_Roaming_Cursor_User_workspaceStorage_853887575bc7d6c26a4f75f409966859_images_photo_3_2026-11-19_20-58-06-441bbfcd-9013-4fac-852e-ad780d80eb61.jpg",
    ),
    (
        "04_account",
        ASSETS
        / "c__Users_user_AppData_Roaming_Cursor_User_workspaceStorage_853887575bc7d6c26a4f75f409966859_images_photo_4_2026-11-19_20-58-06-f85e5e8b-be1c-454f-b52a-8f256a128f9d.jpg",
    ),
]

CREAM = (255, 246, 234)


def scale_to_width(src: Image.Image, width: int) -> Image.Image:
    height = max(1, int(src.height * (width / src.width)))
    # Play Store max edge is 3840px.
    if height > 3840:
        ratio = 3840 / height
        width = max(1, int(width * ratio))
        height = 3840
    return src.convert("RGB").resize((width, height), Image.Resampling.LANCZOS)


def tablet_frame(src: Image.Image, size: tuple[int, int] = (1600, 2560)) -> Image.Image:
    canvas = Image.new("RGB", size, CREAM)
    # Keep the phone UI large and centered on a tablet canvas.
    max_w = int(size[0] * 0.72)
    max_h = int(size[1] * 0.92)
    ratio = min(max_w / src.width, max_h / src.height)
    nw = max(1, int(src.width * ratio))
    nh = max(1, int(src.height * ratio))
    resized = src.convert("RGB").resize((nw, nh), Image.Resampling.LANCZOS)
    # Soft device shadow
    shadow = Image.new("RGBA", (nw + 24, nh + 24), (0, 0, 0, 0))
    for i in range(12):
        alpha = 18 - i
        Image.Image.paste(
            shadow,
            Image.new("RGBA", (nw + i * 2, nh + i * 2), (0, 0, 0, max(alpha, 0))),
            (12 - i, 12 - i),
        )
    shadow.paste(resized, (12, 12))
    x = (size[0] - shadow.width) // 2
    y = (size[1] - shadow.height) // 2
    canvas.paste(shadow, (x, y), shadow)
    return canvas


def main() -> None:
    for name, path in SOURCES:
        if not path.exists():
            raise FileNotFoundError(path)
        src = Image.open(path)
        phone = scale_to_width(src, 1080)
        phone.save(OUT_PHONE / f"{name}.png", optimize=True)
        tablet_frame(src).save(OUT_TABLET / f"{name}.png", optimize=True)
        print(f"ok {name} src={src.size} phone={phone.size}")
    print(OUT_PHONE)
    print(OUT_TABLET)


if __name__ == "__main__":
    main()

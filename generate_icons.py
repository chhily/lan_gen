import subprocess
import os

ICON_PNG = "icons/icon.png"

# macOS iconset
MAC_ICONSET = "icons/MyApp.iconset"
MAC_ICNS = "icons/MyApp.icns"

# Windows ICO output
WIN_ICO = "icons/app_icon.ico"

def make_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)

def generate_mac_icons():
    sizes = [
        (16, 1), (16, 2),
        (32, 1), (32, 2),
        (128, 1), (128, 2),
        (256, 1), (256, 2),
        (512, 1), (512, 2)
    ]
    make_dir(MAC_ICONSET)
    for size, scale in sizes:
        out_file = f"{MAC_ICONSET}/app_icon_{size * scale}.png"
        subprocess.run([
            "magick", "convert", ICON_PNG, "-resize", f"{size * scale}x{size * scale}", out_file
        ])

    # Optional: generate Contents.json
    contents_json = {
        "images": [
            {"size": f"{size}x{size}", "idiom": "mac", "filename": f"app_icon_{size * scale}.png", "scale": f"{scale}x"}
            for size, scale in sizes
        ],
        "info": {"version": 1, "author": "xcode"}
    }

    import json
    with open(f"{MAC_ICONSET}/Contents.json", "w") as f:
        json.dump(contents_json, f, indent=2)

    # Create ICNS
    subprocess.run(["iconutil", "-c", "icns", MAC_ICONSET, "-o", MAC_ICNS])
    print(f"[macOS] Generated {MAC_ICNS}")

def generate_windows_icon():
    sizes = [16, 32, 48, 64, 128, 256]
    cmd = ["magick", "convert", ICON_PNG]
    for s in sizes:
        cmd += ["-resize", f"{s}x{s}"]
    cmd += [WIN_ICO]
    subprocess.run(cmd)
    print(f"[Windows] Generated {WIN_ICO}")

if __name__ == "__main__":
    generate_mac_icons()
    generate_windows_icon()
    print("✅ Done generating all icons")

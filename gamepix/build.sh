#!/usr/bin/env bash
# Build the GamePix package: Godot 4.7.2 "GamePix" Web preset + SDK shell, zip with index.html at root.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-$HOME/.local/bin/godot}"
OUT="$ROOT/Exports/GamePix"
rm -rf "$OUT" && mkdir -p "$OUT"
cd "$ROOT/Godot"
"$GODOT" --headless --import
"$GODOT" --headless --export-release GamePix "$OUT/index.html"
python3 -c "from PIL import Image;Image.open('$ROOT/gamepix/cover-1360x850.png').convert('RGB').save('$OUT/background.jpg',quality=88)"
rm -f "$ROOT/Exports/lgs-gamepix.zip"
(cd "$OUT" && python3 -m zipfile -c "$ROOT/Exports/lgs-gamepix.zip" *)
echo "$ROOT/Exports/lgs-gamepix.zip"

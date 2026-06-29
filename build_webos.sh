#!/usr/bin/env bash
set -e

export PATH="$HOME/.npm-global/bin:$PATH"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   KFLIX TV — webOS IPK Builder       ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Step 1: Build Flutter web ─────────────────────────────────────────────────
echo "▶ Step 1/4 — Building Flutter web app..."
flutter build web --release
echo "✓ Web build complete"
echo ""

# ── Step 2: Copy web files into webOS app folder ──────────────────────────────
echo "▶ Step 2/4 — Copying web files to webos/app/..."
cp -r build/web/. webos/app/
echo "✓ Files copied"
echo ""

# ── Step 3: Copy icons ────────────────────────────────────────────────────────
echo "▶ Step 3/4 — Preparing icons..."
cp webos/app/icons/Icon-192.png webos/app/icon80.png
cp webos/app/icons/Icon-512.png webos/app/icon130.png
echo "✓ Icons ready"
echo ""

# ── Step 4: Package as IPK ────────────────────────────────────────────────────
echo "▶ Step 4/4 — Packaging as IPK..."
mkdir -p webos/output
ares-package webos/app/ --outdir webos/output/ --no-minify || true

IPK_FILE=$(ls webos/output/*.ipk 2>/dev/null | head -1)
if [ -f "$IPK_FILE" ]; then
  SIZE=$(du -h "$IPK_FILE" | cut -f1)
  echo ""
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  ✅  IPK built successfully!                             ║"
  echo "║                                                          ║"
  echo "║  File : $IPK_FILE"
  echo "║  Size : $SIZE"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""
  echo "📺  Install on LG TV:"
  echo "    ares-install --device <TV_NAME> $IPK_FILE"
  echo "    ares-launch  --device <TV_NAME> com.kflix.tv"
else
  echo "✗ IPK not found — packaging may have failed."
  exit 1
fi

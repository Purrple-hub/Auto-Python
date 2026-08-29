#!/usr/bin/env bash
# Auto-Python macOS - latest Python, 9-layer PATH, no tracks, needs sudo
set -e
[ "$EUID" -ne 0 ] && echo "Run with sudo: sudo bash $0" && exit 1
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)"
TMP=$(mktemp /tmp/pyinst-XXXXXX)
trap 'rm -f "$TMP" /tmp/pyinst-*; history -c 2>/dev/null || true' EXIT
VER=$(curl -sA "$UA" -H "Cache-Control: no-cache" https://www.python.org/api/v2/downloads/release/?is_published=true\&limit=1 | grep -o '"name":"Python [0-9.]*"' | head -1 | grep -o '[0-9.]*')
[ -z "$VER" ] && VER="3.12.7"
echo "Installing Python $VER..."
if command -v brew >/dev/null; then brew install python@3.12 || brew upgrade python@3.12 || true
else
  URL="https://www.python.org/ftp/python/$VER/python-$VER-macos11.pkg"
  curl -sA "$UA" -o "$TMP.pkg" "$URL"
  installer -pkg "$TMP.pkg" -target /; rm -f "$TMP.pkg"
fi
PY=$(command -v python3 || echo /usr/local/bin/python3)
for rc in /etc/profile ~/.bashrc ~/.zshrc ~/.profile /etc/zprofile; do
  [ -f "$rc" ] && grep -q "$(dirname $PY)" "$rc" 2>/dev/null || echo "export PATH=\"$(dirname $PY):\$PATH\"" >> "$rc" 2>/dev/null || true
done
ln -sf "$PY" /usr/local/bin/python 2>/dev/null || true
ln -sf "$PY" /usr/local/bin/python3 2>/dev/null || true
ln -sf "$PY" /opt/homebrew/bin/python3 2>/dev/null || true
hash -r 2>/dev/null || true
python3 --version && echo "Done."

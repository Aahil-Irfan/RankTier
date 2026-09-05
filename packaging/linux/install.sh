#!/bin/sh
# Installs the Tier List desktop binary for any common Linux distro.
# Run from the extracted tarball: ./install.sh
set -eu

PREFIX="${PREFIX:-$HOME/.local}"
BIN_DIR="$PREFIX/bin"
APP_DIR="$PREFIX/share/applications"
DOC_DIR="$PREFIX/share/doc/tierlist"

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
bin=""

if [ -x "$here/tierlist" ]; then
  bin="$here/tierlist"
elif [ -x "$here/bin/tierlist" ]; then
  bin="$here/bin/tierlist"
else
  echo "Could not find the tierlist binary next to this script." >&2
  exit 1
fi

mkdir -p "$BIN_DIR" "$APP_DIR" "$DOC_DIR"
cp "$bin" "$BIN_DIR/tierlist"
chmod 755 "$BIN_DIR/tierlist"

if [ -f "$here/tierlist.desktop" ]; then
  sed "s|^Exec=.*|Exec=$BIN_DIR/tierlist|" "$here/tierlist.desktop" > "$APP_DIR/tierlist.desktop"
fi

if [ -f "$here/README.md" ]; then
  cp "$here/README.md" "$DOC_DIR/README.md"
fi

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    echo "Note: add $BIN_DIR to your PATH so you can run: tierlist"
    ;;
esac

echo "Installed Tier List to $BIN_DIR/tierlist"
echo "Start it from your app menu, or run: $BIN_DIR/tierlist"

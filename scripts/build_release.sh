#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BIN="$ROOT/build/bin"
mkdir -p "$BIN"

export PATH="/opt/homebrew/bin:$PATH"
cd "$ROOT/desktop"

build() {
  os=$1
  arch=$2
  out=$3
  echo "Building $out"
  CGO_ENABLED=0 GOOS="$os" GOARCH="$arch" go build -trimpath -ldflags="-s -w" -o "$BIN/$out"
}

build windows amd64 TierList-windows-amd64.exe
build windows arm64 TierList-windows-arm64.exe
build linux amd64 tierlist-linux-amd64
build linux arm64 tierlist-linux-arm64

python3 "$ROOT/scripts/package_release.py"
echo "Release files are in website/downloads/"

# Desktop helper

A small Go program that embeds the web tier list, serves it on `127.0.0.1`, and opens your browser.

```bash
go run .
./tierlist --port 8765 --no-open
./tierlist --version
```

Cross-compile from the repo root with `../scripts/build_release.sh`, or:

```bash
GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o TierList.exe
GOOS=linux   GOARCH=amd64 go build -ldflags="-s -w" -o tierlist
```

The binary has no extra runtime dependencies beyond a browser.

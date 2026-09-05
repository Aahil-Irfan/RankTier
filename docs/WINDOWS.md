# Windows

## Download

From the website **Downloads** page, get:

- [TierList-1.0.0-windows-amd64.exe](../website/downloads/TierList-1.0.0-windows-amd64.exe) for most PCs
- [TierList-1.0.0-windows-arm64.exe](../website/downloads/TierList-1.0.0-windows-arm64.exe) for Windows on ARM

A `.zip` with the exe and this README is also provided.

## Run

1. Double-click `TierList.exe`.
2. If SmartScreen appears, open **More info** and choose **Run anyway**. The file is unsigned.
3. A browser tab opens on `http://127.0.0.1:<port>/`.
4. Leave the black console window open while you use the app. Close it (or Ctrl+C) to stop.

No installer and no administrator account are required.

## Build from source

```bash
cd desktop
GOOS=windows GOARCH=amd64 go build -ldflags="-s -w" -o TierList.exe
```

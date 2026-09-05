# Building a release

From the repo root:

```bash
./scripts/build_release.sh
```

Needs:

- Go 1.22+
- Python 3
- `zip`, `tar`, `ar`

Outputs land in `website/downloads/` and are listed on the Downloads page.

Cross-compiled binaries:

- Windows amd64 / arm64 `.exe`
- Linux amd64 / arm64

Packaging:

- Debian `.deb` (amd64, arm64)
- Simple RPM payloads (x86_64, aarch64)
- Arch `PKGBUILD`
- Tarballs with `install.sh`
- For Apple Xcode zip (iPhone, iPad, and Mac)
- Static website zip

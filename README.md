# Tier List

A tiermaker-style **S–F ranking board**. Upload images, drag them into a tier, and they stay locked there until you move them.

| Platform | What you get |
| --- | --- |
| **Website** | Use the app in a browser and download every build |
| **Windows** | `TierList.exe` |
| **Linux** | `.deb`, `.rpm`, Arch `PKGBUILD`, tarballs, `install.sh` |
| **For Apple** | One SwiftUI project for iPhone, iPad, and Mac |

## Quick start

Serve the website (app + downloads):

```bash
cd website
python3 -m http.server 8765
```

Then open [http://127.0.0.1:8765/](http://127.0.0.1:8765/).

Or run the desktop helper from source:

```bash
cd desktop
go run .
```

## Repository layout

```
TierListApp/          SwiftUI app for iPhone, iPad, and Mac
desktop/              Go desktop wrapper (embeds the web app)
website/              Public site, in-browser app, download folder
packaging/            Linux installers and package metadata
docs/                 Markdown install guides
scripts/build_release.sh
```

## Docs

- [Install on Windows](docs/WINDOWS.md)
- [Install on Linux](docs/LINUX.md)
- [Build for Apple](docs/SWIFT.md)
- [Build all release files](docs/BUILD.md)

## License

MIT. See [LICENSE](LICENSE).

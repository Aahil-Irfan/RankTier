# RankTier

Live site: [https://ranktier.netlify.app](https://ranktier.netlify.app)

A free **S–F ranking board**. Upload images, drag them into a tier, and they stay locked there until you move them.

| Platform | What you get |
| --- | --- |
| **Website** | Use RankTier in the browser at [ranktier.netlify.app](https://ranktier.netlify.app) |
| **Windows** | Windows `.exe` from the [downloads page](https://ranktier.netlify.app/downloads/) |
| **Linux** | `.deb`, `.rpm`, Arch `PKGBUILD`, tarballs, `install.sh` |
| **For Apple** | One SwiftUI project for iPhone, iPad, and Mac |

## Quick start

Open the live site:

**[https://ranktier.netlify.app](https://ranktier.netlify.app)**

Or serve the site locally:

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
website/              Public RankTier site, in-browser app, download folder
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

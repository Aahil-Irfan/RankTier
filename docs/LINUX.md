# Linux

Pick the file that matches your distro. All of them wrap the same `tierlist` binary.

## Debian / Ubuntu and derivatives

```bash
sudo apt install ./tierlist_1.0.0_amd64.deb
tierlist
```

Use `tierlist_1.0.0_arm64.deb` on ARM64 machines.

Works on Debian, Ubuntu, Linux Mint, Pop!_OS, elementary OS, Zorin, and Raspberry Pi OS (64-bit).

## Fedora / RHEL family / openSUSE

```bash
sudo dnf install ./tierlist-1.0.0-1.x86_64.rpm
tierlist
```

On older hosts: `sudo rpm -i ./tierlist-1.0.0-1.x86_64.rpm`.

## Arch Linux

Download `PKGBUILD` and the matching `tierlist-1.0.0-linux-*.tar.gz`, then:

```bash
makepkg -si
```

## Any other distro

```bash
tar -xzf tierlist-1.0.0-linux-amd64.tar.gz
cd tierlist-1.0.0-linux-amd64
./install.sh
```

`install.sh` copies the binary to `~/.local/bin` (override with `PREFIX=/usr/local`) and installs a `.desktop` launcher.

You can also run `./tierlist` from the extracted folder with no install.

### Alpine

The release binary is glibc. Install compatibility first:

```bash
sudo apk add gcompat
./tierlist
```

Or use the website app instead of the desktop helper.

### NixOS

Copy `tierlist` into a profile or wrap it with `buildFHSEnv` / `autoPatchelfHook` if dynamic linker paths differ. The tarball + `install.sh` is the supported path.

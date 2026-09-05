#!/usr/bin/env python3
"""Create tarballs, zips, .deb, and simple .rpm files from compiled binaries."""

from __future__ import annotations

import gzip
import hashlib
import io
import os
import shutil
import stat
import struct
import tarfile
import time
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BIN = ROOT / "build" / "bin"
OUT = ROOT / "website" / "downloads"
VERSION = "1.0.0"


def write_file(path: Path, data: bytes, mode: int = 0o644) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data)
    path.chmod(mode)


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def add_text_to_tar(tar: tarfile.TarFile, name: str, text: str, mode: int = 0o644) -> None:
    data = text.encode("utf-8")
    info = tarfile.TarInfo(name=name)
    info.size = len(data)
    info.mode = mode
    info.mtime = int(time.time())
    info.uid = 0
    info.gid = 0
    tar.addfile(info, io.BytesIO(data))


def add_bytes_to_tar(tar: tarfile.TarFile, name: str, data: bytes, mode: int = 0o755) -> None:
    info = tarfile.TarInfo(name=name)
    info.size = len(data)
    info.mode = mode
    info.mtime = int(time.time())
    info.uid = 0
    info.gid = 0
    tar.addfile(info, io.BytesIO(data))


def unix_readme() -> str:
    return f"""# Tier List {VERSION}

1. Run `./tierlist` or `./install.sh`
2. A browser window opens on a local address
3. Add images and drag them into S–F tiers
4. Press Ctrl+C in the terminal to quit

See docs at the project website or the repo README.
"""


def windows_readme() -> str:
    return f"""Tier List {VERSION} for Windows

Double-click TierList.exe. If SmartScreen appears, choose More info -> Run anyway.
Keep the console window open while you rank images. Close it to quit.
"""


def make_posix_tarball(archive: Path, prefix: str, binary: Path, extra: dict[str, tuple[bytes, int]]) -> None:
    archive.parent.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive, "w:gz") as tar:
        add_bytes_to_tar(tar, f"{prefix}/tierlist", binary.read_bytes(), 0o755)
        add_text_to_tar(tar, f"{prefix}/README.md", unix_readme())
        for name, (data, mode) in extra.items():
            add_bytes_to_tar(tar, f"{prefix}/{name}", data, mode)


def make_windows_zip(archive: Path, exe: Path) -> None:
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.write(exe, "TierList.exe")
        zf.writestr("README.txt", windows_readme())


def tar_gz_bytes(members: list[tuple[str, bytes, int]]) -> bytes:
    raw = io.BytesIO()
    with tarfile.open(fileobj=raw, mode="w:gz") as tar:
        for name, data, mode in members:
            info = tarfile.TarInfo(name=name)
            info.size = len(data)
            info.mode = mode
            info.mtime = int(time.time())
            info.uid = 0
            info.gid = 0
            info.uname = "root"
            info.gname = "root"
            tar.addfile(info, io.BytesIO(data))
    return raw.getvalue()


def make_ar(archive: Path, files: list[tuple[str, bytes]]) -> None:
    parts = [b"!<arch>\n"]
    for name, data in files:
        if len(data) % 2 == 1:
            payload = data + b"\n"
            odd = True
        else:
            payload = data
            odd = False
        header = f"{name:<16}{0:<12}{0:<6}{0:<6}{0o644:<8}{len(data):<10}`\n"
        parts.append(header.encode("ascii"))
        parts.append(payload if not odd else data + b"\n")
    archive.write_bytes(b"".join(parts))


def make_deb(out: Path, arch: str, binary: Path, desktop: bytes, license_text: bytes) -> None:
    control = f"""Package: tierlist
Version: {VERSION}
Section: graphics
Priority: optional
Architecture: {arch}
Maintainer: Aahil <aahil@localhost>
Description: S-F tier list app for ranking images
 Upload images and drag them into S, A, B, C, D, and F tiers.
""".encode()
    copyright_text = license_text
    data_members = [
        ("usr/bin/tierlist", binary.read_bytes(), 0o755),
        ("usr/share/applications/tierlist.desktop", desktop, 0o644),
        ("usr/share/doc/tierlist/copyright", copyright_text, 0o644),
        ("usr/share/doc/tierlist/README.md", unix_readme().encode(), 0o644),
    ]
    control_tar = tar_gz_bytes([("./control", control, 0o644)])
    data_tar = tar_gz_bytes([(f"./{name}", data, mode) for name, data, mode in data_members])
    make_ar(out, [
        ("debian-binary", b"2.0\n"),
        ("control.tar.gz", control_tar),
        ("data.tar.gz", data_tar),
    ])


def cpio_newc(entries: list[tuple[str, bytes, int]]) -> bytes:
    buf = io.BytesIO()
    ino = 1
    for name, data, mode in entries:
        name_b = name.encode("ascii") + b"\0"
        namesize = len(name_b)
        mode_full = (stat.S_IFREG | mode)
        header = (
            b"070701"
            + f"{ino:08x}".encode()
            + f"{mode_full:08x}".encode()
            + b"00000000"
            + b"00000000"
            + b"00000001"
            + f"{len(data):08x}".encode()
            + b"00000000" * 2
            + b"00000000"
            + f"{namesize:08x}".encode()
            + b"00000000"
        )
        buf.write(header)
        buf.write(name_b)
        pad = (4 - ((len(header) + namesize) % 4)) % 4
        buf.write(b"\0" * pad)
        buf.write(data)
        pad = (4 - (len(data) % 4)) % 4
        buf.write(b"\0" * pad)
        ino += 1
    trailer = b"TRAILER!!!\0"
    header = (
        b"070701"
        + b"00000000" * 5
        + b"00000001"
        + b"00000000" * 3
        + f"{len(trailer):08x}".encode()
        + b"00000000"
    )
    buf.write(header)
    buf.write(trailer)
    pad = (4 - ((len(header) + len(trailer)) % 4)) % 4
    buf.write(b"\0" * pad)
    return buf.getvalue()


def rpm_header(records: list[tuple[int, int, bytes]]) -> bytes:
    # tag, type, value  — types: 6=STRING, 4=INT32, 8=STRING_ARRAY, 7=BIN
    store = bytearray()
    index = bytearray()
    for tag, typ, value in records:
        offset = len(store)
        count = 1
        if typ == 4:
            store.extend(value)
        elif typ == 7:
            store.extend(value)
            count = len(value)
        elif typ == 8:
            parts = value.split(b"\0")
            if parts and parts[-1] == b"":
                parts = parts[:-1]
            store.extend(value if value.endswith(b"\0") else value + b"\0")
            count = max(1, len(parts))
        else:
            store.extend(value if value.endswith(b"\0") else value + b"\0")
        index.extend(struct.pack("!iiii", tag, typ, offset, count))
    while len(store) % 8:
        store.append(0)
    header = struct.pack("!3sBiii", b"\x8e\xad\xe8", 1, 0, len(records), len(store))
    return header + bytes(index) + bytes(store)


def make_rpm(out: Path, arch: str, binary: Path, desktop: bytes) -> None:
    files = [
        ("usr/bin/tierlist", binary.read_bytes(), 0o755),
        ("usr/share/applications/tierlist.desktop", desktop, 0o644),
        ("usr/share/doc/tierlist/README.md", unix_readme().encode(), 0o644),
    ]
    payload = gzip.compress(cpio_newc([(name, data, mode) for name, data, mode in files]), mtime=0)
    name = b"tierlist\0"
    version = VERSION.encode() + b"\0"
    release = b"1\0"
    summary = b"S-F tier list app for ranking images\0"
    # RPMTAG values
    records = [
        (1000, 6, name),            # NAME
        (1001, 6, version),         # VERSION
        (1002, 6, release),         # RELEASE
        (1004, 6, summary),         # SUMMARY
        (1022, 6, arch.encode() + b"\0"),  # ARCH
        (1044, 6, b"MIT\0"),        # LICENSE
        (1124, 6, b"cpio\0"),       # PAYLOADFORMAT
        (1125, 6, b"gzip\0"),       # PAYLOADCOMPRESSOR
        (1007, 4, struct.pack("!i", os.path.getsize(binary) + len(desktop) + 64)),  # SIZE
        (1009, 7, hashlib.md5(payload).digest()),  # SIGMD5-ish not used here
    ]
    # 1009 is SIGMD5 in signature header, RPMTAG_PAYLOADDIGEST is 5093
    records = [r for r in records if r[0] != 1009]
    header = rpm_header(records)
    lead = struct.pack(
        "!4sBBhh66shh16s",
        b"\xed\xab\xee\xdb",
        3,
        0,
        0,
        1,
        f"tierlist-{VERSION}-1".encode("ascii").ljust(66, b"\0"),
        1,
        5,
        b"\0" * 16,
    )
    # Empty-ish signature region:  header with no entries still needs magic
    sig = rpm_header([])
    pad = b"\0" * ((8 - (len(sig) % 8)) % 8)
    out.write_bytes(lead + sig + pad + header + payload)


def zip_dir(archive: Path, source: Path, ignore_names: set[str]) -> None:
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for path in source.rglob("*"):
            if path.name in ignore_names or any(p in ignore_names for p in path.parts):
                continue
            if path.is_file():
                zf.write(path, path.relative_to(source))


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    desktop = (ROOT / "packaging" / "linux" / "tierlist.desktop").read_bytes()
    install_sh = (ROOT / "packaging" / "linux" / "install.sh").read_bytes()
    pkgbuild = (ROOT / "packaging" / "linux" / "PKGBUILD").read_bytes()
    license_text = (ROOT / "LICENSE").read_bytes()

    extras = {
        "install.sh": (install_sh, 0o755),
        "tierlist.desktop": (desktop, 0o644),
    }

    mapping = {
        "linux-amd64": ("tierlist-linux-amd64", "amd64", "x86_64"),
        "linux-arm64": ("tierlist-linux-arm64", "arm64", "aarch64"),
    }

    for key, (bin_name, deb_arch, rpm_arch) in mapping.items():
        binary = BIN / bin_name
        prefix = f"tierlist-{VERSION}-{key}"
        make_posix_tarball(OUT / f"{prefix}.tar.gz", prefix, binary, extras)
        if deb_arch:
            make_deb(OUT / f"tierlist_{VERSION}_{deb_arch}.deb", deb_arch, binary, desktop, license_text)
        if rpm_arch:
            make_rpm(OUT / f"tierlist-{VERSION}-1.{rpm_arch}.rpm", rpm_arch, binary, desktop)

    make_windows_zip(OUT / f"TierList-{VERSION}-windows-amd64.zip", BIN / "TierList-windows-amd64.exe")
    shutil.copy2(BIN / "TierList-windows-amd64.exe", OUT / f"TierList-{VERSION}-windows-amd64.exe")
    shutil.copy2(BIN / "TierList-windows-arm64.exe", OUT / f"TierList-{VERSION}-windows-arm64.exe")

    shutil.copy2(ROOT / "packaging" / "linux" / "install.sh", OUT / "install.sh")
    shutil.copy2(ROOT / "packaging" / "linux" / "PKGBUILD", OUT / "PKGBUILD")

    swift_zip = OUT / f"TierList-For-Apple-{VERSION}.zip"
    with zipfile.ZipFile(swift_zip, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.write(ROOT / "docs" / "SWIFT.md", "README.md")
        for path in (ROOT / "TierListApp").rglob("*"):
            if path.is_file():
                zf.write(path, Path("TierListApp") / path.relative_to(ROOT / "TierListApp"))
        proj = ROOT / "TierListApp.xcodeproj"
        for path in proj.rglob("*"):
            if path.is_file():
                zf.write(path, Path("TierListApp.xcodeproj") / path.relative_to(proj))

    web_zip = OUT / f"tierlist-web-{VERSION}.zip"
    with zipfile.ZipFile(web_zip, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for rel in [
            "index.html",
            "styles.css",
            "README.md",
            "app/index.html",
            "docs/index.html",
            "docs/windows.html",
            "docs/linux.html",
            "docs/swift.html",
        ]:
            zf.write(ROOT / "website" / rel, rel)

    sums = []
    for path in sorted(OUT.iterdir()):
        if path.name in {"index.html", "SHA256SUMS.txt"} or path.is_dir():
            continue
        sums.append(f"{sha256(path)}  {path.name}")
    (OUT / "SHA256SUMS.txt").write_text("\n".join(sums) + "\n")
    print(f"Wrote {len(sums)} artifacts to {OUT}")


if __name__ == "__main__":
    main()

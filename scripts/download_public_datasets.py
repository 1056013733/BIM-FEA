#!/usr/bin/env python3
"""
Download public benchmark sources listed in data/datasets_manifest.json.

This script is intentionally conservative:
- it records a local checksum manifest
- it skips existing files unless --force is used
- it supports direct-file URLs best
- for website-only sources such as PEER SPD, it stores the landing page HTML
  so the provenance is preserved locally
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
import urllib.parse
import urllib.request
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "data/datasets_manifest.json"
DOWNLOADS_DIR = ROOT / "data/raw"
CHECKSUMS_PATH = DOWNLOADS_DIR / "checksums.json"


def sha256_of_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def safe_name(dataset_id: str, url: str, dataset_type: str) -> str:
    if dataset_type == "website":
        return f"{dataset_id}.html"
    suffix = Path(urllib.parse.urlparse(url).path).suffix
    if suffix:
        return f"{dataset_id}{suffix}"
    return f"{dataset_id}.bin"


def load_manifest() -> dict:
    with MANIFEST_PATH.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def load_checksums() -> dict:
    if not CHECKSUMS_PATH.exists():
        return {}
    with CHECKSUMS_PATH.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def save_checksums(data: dict) -> None:
    DOWNLOADS_DIR.mkdir(parents=True, exist_ok=True)
    with CHECKSUMS_PATH.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False)


def download(url: str, target: Path) -> None:
    with urllib.request.urlopen(url) as response:
        target.write_bytes(response.read())


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--force", action="store_true", help="re-download even if file exists")
    args = parser.parse_args(argv)

    manifest = load_manifest()
    checksums = load_checksums()
    DOWNLOADS_DIR.mkdir(parents=True, exist_ok=True)

    for dataset in manifest["datasets"]:
        target = DOWNLOADS_DIR / safe_name(dataset["id"], dataset["url"], dataset["type"])
        if target.exists() and not args.force:
            print(f"skip existing: {target.name}")
        else:
            print(f"downloading: {dataset['title']}")
            try:
                download(dataset["url"], target)
            except Exception as exc:
                print(f"failed: {dataset['url']} -> {exc}", file=sys.stderr)
                continue

        checksums[dataset["id"]] = {
            "title": dataset["title"],
            "source_url": dataset["url"],
            "local_file": str(target),
            "sha256": sha256_of_file(target),
        }

    save_checksums(checksums)
    print(f"wrote checksum manifest: {CHECKSUMS_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

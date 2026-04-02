#!/usr/bin/env python3
"""
Normalize raw benchmark spreadsheets into simple CSV tables that can be cited,
plotted, and mapped into ANSYS input templates.

Expected outputs:
- data/processed/specimens.csv
- data/processed/response_points.csv

The script is generic on purpose. You may need to adjust source-specific column
names after inspecting each dataset.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
DOWNLOADS_DIR = ROOT / "data/raw"
NORMALIZED_DIR = ROOT / "data/processed"


SPECIMEN_ALIASES = {
    "specimen": "specimen_id",
    "Specimen": "specimen_id",
    "ID": "specimen_id",
    "fc": "fc",
    "Fy": "fy",
    "Pexp": "peak_load",
    "Mexp": "peak_moment",
    "L": "member_length",
}


RESPONSE_ALIASES = {
    "force": "force",
    "Force": "force",
    "load": "force",
    "Load": "force",
    "displacement": "displacement",
    "Displacement": "displacement",
    "drift": "drift",
    "Drift": "drift",
}


def rename_columns(df: pd.DataFrame, aliases: dict[str, str]) -> pd.DataFrame:
    renamed = {}
    for col in df.columns:
        renamed[col] = aliases.get(col, col)
    return df.rename(columns=renamed)


def collect_tables(source_path: Path) -> list[pd.DataFrame]:
    suffix = source_path.suffix.lower()
    if suffix == ".csv":
        return [pd.read_csv(source_path)]
    if suffix in {".xls", ".xlsx"}:
        workbook = pd.ExcelFile(source_path)
        return [pd.read_excel(source_path, sheet_name=name) for name in workbook.sheet_names]
    return []


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--glob", default="*.xlsx", help="raw file glob under data/raw/")
    args = parser.parse_args()

    NORMALIZED_DIR.mkdir(parents=True, exist_ok=True)

    specimen_frames: list[pd.DataFrame] = []
    response_frames: list[pd.DataFrame] = []

    for path in sorted(DOWNLOADS_DIR.glob(args.glob)):
        for frame in collect_tables(path):
            frame = frame.dropna(axis=0, how="all").dropna(axis=1, how="all")
            frame = rename_columns(frame, SPECIMEN_ALIASES | RESPONSE_ALIASES)
            lower_cols = {str(c).lower() for c in frame.columns}

            if {"specimen_id", "peak_load"} & set(frame.columns):
                frame["source_file"] = path.name
                specimen_frames.append(frame.copy())

            if "force" in lower_cols and ("displacement" in lower_cols or "drift" in lower_cols):
                frame["source_file"] = path.name
                response_frames.append(frame.copy())

    if specimen_frames:
        pd.concat(specimen_frames, ignore_index=True).to_csv(
            NORMALIZED_DIR / "specimens.csv", index=False
        )
    if response_frames:
        pd.concat(response_frames, ignore_index=True).to_csv(
            NORMALIZED_DIR / "response_points.csv", index=False
        )

    print(f"normalized outputs written to: {NORMALIZED_DIR}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

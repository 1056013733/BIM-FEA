#!/usr/bin/env python3
"""
Generate a lightweight APDL macro from normalized specimen metadata.

This script is not a full solver workflow. It is a reproducible bridge between
public benchmark metadata and an ANSYS starter model.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd


ROOT = Path(__file__).resolve().parents[1]
NORMALIZED_DIR = ROOT / "data/processed"
GENERATED_DIR = ROOT / "simulations/runs"
TEMPLATE_PATH = ROOT / "templates" / "beam_column_template.mac"


def fill_template(template: str, row: pd.Series) -> str:
    values = {
        "SPECIMEN_ID": str(row.get("specimen_id", "UNKNOWN")),
        "MEMBER_LENGTH": str(row.get("member_length", 3000)),
        "FC": str(row.get("fc", 40)),
        "FY": str(row.get("fy", 400)),
        "PEAK_LOAD": str(row.get("peak_load", 0)),
    }
    for key, value in values.items():
        template = template.replace(f"{{{{{key}}}}}", value)
    return template


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--specimen-id", required=True, help="specimen_id value in data/processed/specimens.csv")
    args = parser.parse_args()

    specimens_path = NORMALIZED_DIR / "specimens.csv"
    if not specimens_path.exists():
        raise FileNotFoundError(f"missing normalized table: {specimens_path}")

    df = pd.read_csv(specimens_path)
    matches = df.loc[df["specimen_id"].astype(str) == str(args.specimen_id)]
    if matches.empty:
        raise ValueError(f"specimen not found: {args.specimen_id}")

    row = matches.iloc[0]
    template = TEMPLATE_PATH.read_text(encoding="utf-8")
    content = fill_template(template, row)

    GENERATED_DIR.mkdir(parents=True, exist_ok=True)
    out_path = GENERATED_DIR / f"{args.specimen_id}.mac"
    out_path.write_text(content, encoding="utf-8")
    print(f"generated: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

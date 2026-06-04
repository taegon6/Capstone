from __future__ import annotations

import argparse
import json
import urllib.request
from datetime import datetime
from pathlib import Path


HOMEHAR_BASE = "https://huggingface.co/datasets/gadgadgad/HomeHAR/resolve/main"
DEFAULT_FILES = {
    "empty": "data3/empty_1.csv",
    "watch": "data3/watch_1.csv",
    "work": "data3/work_1.csv",
    "smoke": "data3/smoke_1.csv",
}


def download_head_rows(label: str, remote_path: str, rows: int, out_dir: Path) -> dict:
    out_dir.mkdir(parents=True, exist_ok=True)
    url = f"{HOMEHAR_BASE}/{remote_path}"
    out_path = out_dir / f"homehar_{label}_{rows}rows.csv"

    kept = 0
    header = None
    with urllib.request.urlopen(url, timeout=60) as response, out_path.open(
        "w", encoding="utf-8", newline="\n"
    ) as out:
        for raw in response:
            line = raw.decode("utf-8", errors="ignore").rstrip("\r\n")
            if not line:
                continue
            if header is None:
                header = line
                out.write(header + "\n")
                continue
            out.write(line + "\n")
            kept += 1
            if kept >= rows:
                break

    return {
        "label": label,
        "remote_path": remote_path,
        "url": url,
        "local_path": str(out_path),
        "rows": kept,
    }


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Download a small HomeHAR public ESP32 CSI subset.")
    parser.add_argument("--rows", type=int, default=800, help="Rows per class to keep")
    parser.add_argument("--output-dir", default="data/public/homehar_subset", help="Output directory")
    parser.add_argument(
        "--labels",
        nargs="*",
        default=list(DEFAULT_FILES.keys()),
        choices=list(DEFAULT_FILES.keys()),
        help="Class labels to download",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    out_dir = Path(args.output_dir)
    records = []
    for label in args.labels:
        print(f"Downloading {label} from HomeHAR...")
        records.append(download_head_rows(label, DEFAULT_FILES[label], args.rows, out_dir))

    meta = {
        "downloaded_at": datetime.now().isoformat(timespec="seconds"),
        "source": "gadgadgad/HomeHAR",
        "source_url": "https://huggingface.co/datasets/gadgadgad/HomeHAR",
        "license": "CC BY 4.0",
        "rows_per_label": args.rows,
        "records": records,
    }
    meta_path = out_dir / "metadata.json"
    meta_path.write_text(json.dumps(meta, indent=2, ensure_ascii=False), encoding="utf-8")
    print(f"Saved metadata: {meta_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


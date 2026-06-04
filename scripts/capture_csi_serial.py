from __future__ import annotations

import argparse
import json
import re
import sys
import time
from datetime import datetime
from pathlib import Path

import serial


CSI_RE = re.compile(r"^CSI_DATA,.*\[[^\]]+\]$")
CSI_LEN_RE = re.compile(r"^CSI_DATA,[^,]*,[^,]*,[^,]*,[^,]*,(?P<len>\d+),\[")


def timestamp_for_filename() -> str:
    return datetime.now().strftime("%Y%m%d_%H%M%S")


def safe_print(text: str) -> None:
    print(text.encode("ascii", errors="replace").decode("ascii"), flush=True)


def capture(args: argparse.Namespace) -> tuple[Path, Path, dict]:
    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    stem = f"{timestamp_for_filename()}_{args.label}_{args.port}"
    log_path = out_dir / f"{stem}.log"
    meta_path = out_dir / f"{stem}.json"

    csi_count = 0
    status_count = 0
    other_count = 0
    first_csi_at = None
    csi_len_histogram: dict[str, int] = {}
    started_at = datetime.now().isoformat(timespec="seconds")
    deadline = time.time() + args.seconds

    safe_print(f"CSI_CAPTURE_START port={args.port} baud={args.baud} seconds={args.seconds} label={args.label}")
    safe_print(f"writing={log_path}")

    with serial.Serial(args.port, baudrate=args.baud, timeout=args.timeout) as ser, log_path.open(
        "w", encoding="utf-8", newline="\n"
    ) as out:
        ser.setDTR(False)
        ser.setRTS(False)
        time.sleep(0.2)

        while time.time() < deadline:
            raw = ser.readline()
            if not raw:
                continue
            line = raw.decode("utf-8", errors="ignore").strip()
            if not line:
                continue

            if line.startswith("CSI_DATA"):
                csi_count += 1
                len_match = CSI_LEN_RE.search(line)
                if len_match:
                    csi_len = len_match.group("len")
                    csi_len_histogram[csi_len] = csi_len_histogram.get(csi_len, 0) + 1
                if first_csi_at is None:
                    first_csi_at = datetime.now().isoformat(timespec="seconds")
            elif line.startswith("CSI_STATUS"):
                status_count += 1
            else:
                other_count += 1

            out.write(line + "\n")

            if args.echo and (line.startswith("CSI_STATUS") or csi_count <= args.echo_first_csi):
                safe_print(line)

    finished_at = datetime.now().isoformat(timespec="seconds")
    meta = {
        "label": args.label,
        "port": args.port,
        "baud": args.baud,
        "seconds": args.seconds,
        "started_at": started_at,
        "finished_at": finished_at,
        "first_csi_at": first_csi_at,
        "log_path": str(log_path),
        "csi_count": csi_count,
        "csi_len_histogram": csi_len_histogram,
        "status_count": status_count,
        "other_count": other_count,
        "valid_for_analysis": csi_count >= args.min_csi,
    }
    meta_path.write_text(json.dumps(meta, indent=2, ensure_ascii=False), encoding="utf-8")

    safe_print(
        "CSI_CAPTURE_DONE "
        f"csi_count={csi_count} status_count={status_count} "
        f"valid_for_analysis={meta['valid_for_analysis']} log={log_path}"
    )
    return log_path, meta_path, meta


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Capture ESP32 CSI serial logs to a timestamped file.")
    parser.add_argument("--port", default="COM11", help="Serial port, e.g. COM11")
    parser.add_argument("--baud", type=int, default=921600, help="Serial baudrate")
    parser.add_argument("--seconds", type=float, default=30.0, help="Capture duration")
    parser.add_argument("--label", default="sample", help="Experiment label")
    parser.add_argument("--output-dir", default="data/csi_logs", help="Output directory")
    parser.add_argument("--timeout", type=float, default=0.5, help="Serial read timeout")
    parser.add_argument("--min-csi", type=int, default=10, help="Minimum CSI rows required")
    parser.add_argument("--echo", action="store_true", help="Print status and first CSI rows while capturing")
    parser.add_argument("--echo-first-csi", type=int, default=3, help="How many CSI rows to echo")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        _, _, meta = capture(args)
    except serial.SerialException as exc:
        safe_print(f"CSI_CAPTURE_ERROR serial={exc}")
        return 2
    except KeyboardInterrupt:
        safe_print("CSI_CAPTURE_INTERRUPTED")
        return 130
    return 0 if meta["valid_for_analysis"] else 1


if __name__ == "__main__":
    raise SystemExit(main())

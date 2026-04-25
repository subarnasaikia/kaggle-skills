"""Reusable submission helper. Wraps kaggle CLI with pre-flight checks.

Usage:
    python3 shared/utils/submit.py <slug> <file> "<message>"
    python3 shared/utils/submit.py <slug> <file> "<message>" --yes   # skip confirm
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path


def preflight(competition: str, path: Path) -> None:
    """Check file exists, is non-empty, and CSV header matches sample_submission."""
    if not path.exists():
        sys.exit(f"submission file not found: {path}")
    if path.stat().st_size == 0:
        sys.exit(f"submission file empty: {path}")
    if path.suffix == ".csv":
        sample = Path(f"competitions/{competition}/data/sample_submission.csv")
        if sample.exists():
            with path.open() as f, sample.open() as g:
                if f.readline().strip() != g.readline().strip():
                    sys.exit("csv header differs from sample_submission.csv")


def archive(competition: str, path: Path, message: str) -> Path:
    """Copy the submission file to competitions/<slug>/submissions/ with a timestamp prefix."""
    archive_dir = Path(f"competitions/{competition}/submissions")
    archive_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d_%H%M")
    slug = "".join(c if c.isalnum() else "_" for c in message)[:40]
    dest = archive_dir / f"{ts}_{slug}{path.suffix}"
    dest.write_bytes(path.read_bytes())
    return dest


def log(competition: str, file: Path, message: str, score: str = "pending") -> None:
    """Append a row to competitions/<slug>/submissions/LOG.md."""
    log_path = Path(f"competitions/{competition}/submissions/LOG.md")
    ts = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    row = f"| {ts} | {file.name} | {message} | {score} | |\n"
    log_path.parent.mkdir(parents=True, exist_ok=True)
    if not log_path.exists():
        log_path.write_text(
            f"# Submission Log — {competition}\n\n"
            "| Date | File | Message | Public Score | Notes |\n"
            "|------|------|---------|--------------|-------|\n"
        )
    with log_path.open("a") as f:
        f.write(row)


def submit(competition: str, path: Path, message: str) -> int:
    """Run kaggle competitions submit (CLI >=2.0.0 positional slug form)."""
    return subprocess.run(
        ["kaggle", "competitions", "submit", competition, "-f", str(path), "-m", message]
    ).returncode


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Pre-flight validate + submit a file to a Kaggle competition."
    )
    ap.add_argument("competition", help="Competition slug (e.g. titanic)")
    ap.add_argument("file", type=Path, help="Path to the submission file")
    ap.add_argument("message", help="Submission message")
    ap.add_argument("--yes", action="store_true", help="Skip interactive confirmation prompt")
    args = ap.parse_args()

    preflight(args.competition, args.file)
    archived = archive(args.competition, args.file, args.message)
    print(f"pre-flight ok — archived to {archived}")

    if not args.yes:
        reply = input(f"submit {args.file} to {args.competition}? [y/N] ").strip().lower()
        if reply != "y":
            sys.exit("aborted")

    rc = submit(args.competition, args.file, args.message)
    log(args.competition, args.file, args.message, "pending" if rc == 0 else "failed")
    sys.exit(rc)


if __name__ == "__main__":
    main()

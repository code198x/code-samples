"""Inventory every Pattern Library listing and resolve its maintained source.

A successful structural audit proves paths, excerpt boundaries and source hashes.
It does not certify behaviour or replace an itemised human contract review.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INCLUDE = re.compile(
    r'^\s*(?:!?source|\.?include)\s+["\']([^"\']+)["\']', re.IGNORECASE | re.MULTILINE
)


def digest(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inspect(samples: Path, website: Path) -> dict:
    samples, website = samples.resolve(), website.resolve()
    directory = website / "src/content/patterns"
    pages = sorted(directory.rglob("*.mdx"))
    if not pages:
        raise ValueError("No Pattern Library pages found")
    entries = []
    failures = []
    reached: set[Path] = set()
    for page in pages:
        text = page.read_text()
        refs = re.findall(r"<CodeFromFile\b([^>]*?)/>", text, re.DOTALL)
        includes = []
        sources: dict[str, str] = {}

        def visit(
            path: Path, stack: tuple[Path, ...] = (), records: dict[str, str] = sources
        ) -> None:
            path = path.resolve()
            if not path.is_relative_to(samples.resolve()):
                raise ValueError(f"Source outside samples: {path.name}")
            if not path.is_file():
                raise ValueError(f"Missing source: {path.relative_to(samples)}")
            if path in stack:
                raise ValueError(f"Recursive include: {path.relative_to(samples)}")
            if str(path.relative_to(samples)) in records:
                return
            records[str(path.relative_to(samples))] = digest(path)
            reached.add(path)
            if path.suffix.lower() in {".asm", ".inc"}:
                for name in INCLUDE.findall(path.read_text()):
                    visit(path.parent / name, (*stack, path))

        for attributes in refs:
            values = dict(re.findall(r'(\w+)="([^"]*)"', attributes))
            if "src" not in values:
                failures.append(
                    f"{page.relative_to(directory)}: non-literal source needs review"
                )
                continue
            try:
                path = samples / values["src"]
                visit(path)
                source = path.read_text()
                positions = {}
                for bound in ["from", "to"]:
                    if bound in values:
                        anchor = values[bound]
                        if anchor not in source:
                            raise ValueError(
                                f"{bound} excerpt anchor is missing: {anchor}"
                            )
                        positions[bound] = source.index(anchor)
                if len(positions) == 2 and positions["from"] >= positions["to"]:
                    raise ValueError("Excerpt ends before it starts")
                includes.append(values)
            except (OSError, ValueError) as error:
                failures.append(f"{page.relative_to(directory)}: {error}")
        blocks = re.findall(r"```([^\n]*)\n(.*?)```", text, re.DOTALL)
        status = re.search(r"\*\*Code status: (.*?)\*\*", text)
        entries.append(
            {
                "entry": str(page.relative_to(directory).with_suffix("")),
                "page_sha256": digest(page),
                "declared_status": status.group(1)
                if status
                else "no standalone code status",
                "source_includes": includes,
                "source_closure": sources,
                "inline_blocks": [
                    {
                        "language": lang,
                        "sha256": hashlib.sha256(code.encode()).hexdigest(),
                        "lines": len(code.splitlines()),
                    }
                    for lang, code in blocks
                ],
                "review": "not established by this structural check",
            }
        )
    standalone = []
    for path in sorted(samples.glob("*/patterns/**/*")):
        if not path.is_file() or path.suffix not in {
            ".inc",
            ".asm",
            ".bas",
            ".fth",
            ".py",
        }:
            continue
        if any(part in {"verification", "build", "__pycache__"} for part in path.parts):
            continue
        if path.resolve() not in reached:
            standalone.append(
                {"path": str(path.relative_to(samples)), "sha256": digest(path)}
            )
    return {
        "status": "failed" if failures else "source-bindings-resolved",
        "entries": entries,
        "standalone_sources": standalone,
        "failures": failures,
        "limits": __doc__,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--website", type=Path, required=True)
    parser.add_argument("--samples", type=Path, default=ROOT)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.unlink(missing_ok=True)
    report = inspect(args.samples.resolve(), args.website.resolve())
    args.output.write_text(json.dumps(report, indent=2) + "\n")
    print(
        json.dumps(
            {
                "entries": len(report["entries"]),
                "standalone_sources": len(report["standalone_sources"]),
                "status": report["status"],
                "failures": report["failures"],
            },
            indent=2,
        )
    )
    if report["failures"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()

"""Validate an author-supplied vocabulary and emit bounded counted-word tables."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def compile_tables(data: dict) -> str:
    if not isinstance(data, dict) or set(data) != {"verbs", "nouns"}:
        raise ValueError("Vocabulary needs exactly verbs and nouns arrays")
    result = ["; Generated from vocabulary.json; edit the JSON, not these bytes."]
    for section in ["verbs", "nouns"]:
        entries = data.get(section)
        if (
            not isinstance(entries, list)
            or len(entries) > 32
            or (section == "verbs" and not entries)
        ):
            raise ValueError(
                f"{section}: supply {'1..32' if section == 'verbs' else '0..32'} aliases"
            )
        words = set()
        policies = {}
        result.append("verb_vocab:" if section == "verbs" else "noun_vocab:")
        for entry in entries:
            if not isinstance(entry, dict):
                raise TypeError("Each alias is an object")
            required = (
                {"word", "id", "noun_policy"} if section == "verbs" else {"word", "id"}
            )
            if set(entry) != required:
                raise ValueError("Missing or unknown alias fields")
            word = entry.get("word")
            identity = entry.get("id")
            policy = entry.get("noun_policy", 0)
            if not isinstance(word, str) or not re.fullmatch("[A-Z0-9]{1,12}", word):
                raise ValueError("Aliases need 1..12 uppercase letters/digits")
            if word in words:
                raise ValueError("Duplicate alias: " + word)
            words.add(word)
            if type(identity) is not int or not 1 <= identity <= 255:
                raise ValueError("IDs must be integers1..255")
            if (
                type(policy) is not int
                or policy not in (0, 1, 2)
                or section == "nouns"
                and policy != 0
            ):
                raise ValueError("Invalid noun policy")
            if identity in policies and policies[identity] != policy:
                raise ValueError("Aliases of one ID need the same noun policy")
            policies[identity] = policy
            result.append(f'    defb {len(word)},{identity},{policy},"{word}"')
        result.append("    defb 0")
    return "\n".join(result) + "\n"


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--source", type=Path, default=Path("vocabulary.json"))
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    rendered = compile_tables(json.loads(args.source.read_text()))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    temporary = args.output.with_suffix(".tmp")
    temporary.write_text(rendered)
    temporary.replace(args.output)


if __name__ == "__main__":
    main()

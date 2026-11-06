"""For every commit that modified existing verification records in code-samples,
group the modified records by pattern, then ask two questions per group:

1. Did the commit change any of the pattern's real inputs? Inputs are the
   paths a record pins under "sources", minus scripts/ and toolchain pins, or,
   when a record pins none, any file in the pattern folder outside
   verification/. A group with no input change was forced by scripts or tools.
2. Did the observations change? A leaf counts as identity when its key names a
   digest, version, tool, firmware or commit, or its value is a 40/64-hex string
   for a key that is not a capture. Changed captures (a modified image, audio
   or memory file in verification/, or a digest of one) and any other changed
   leaf count as observation changes.
"""

import json
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(sys.argv[1])
IDENTITY = re.compile(
    r"sha256|sha1|digest|hash|version|revision|commit|emulator|assembler|"
    r"firmware|producer|lock|toolchain|tool|archive|url|tag|server|identity",
    re.I,
)
CAPTURE = re.compile(r"\.(png|wav|bin|dat|z|a26|gb|cv|prg|tap|sna|adf|ppm)\b|capture|image|frame|screenshot|memory", re.I)
HEX = re.compile(r"^[0-9a-f]{40}$|^[0-9a-f]{64}$")


def git(*args):
    return subprocess.run(["git", "-C", str(REPO), *args], capture_output=True, text=True).stdout


def load(rev, path):
    out = subprocess.run(["git", "-C", str(REPO), "show", f"{rev}:{path}"], capture_output=True, text=True)
    if out.returncode:
        return None
    try:
        return json.loads(out.stdout)
    except json.JSONDecodeError:
        return None


def flat(o, p=""):
    if isinstance(o, dict):
        for k, v in o.items():
            yield from flat(v, f"{p}/{k}")
    elif isinstance(o, list):
        for i, v in enumerate(o):
            yield from flat(v, f"{p}[{i}]")
    else:
        yield p, o


def classify(old, new):
    a, b = dict(flat(old)), dict(flat(new))
    obs, cap, ident = [], [], []
    for k in set(a) | set(b):
        if a.get(k) == b.get(k):
            continue
        va, vb = a.get(k), b.get(k)
        hexy = any(isinstance(v, str) and HEX.match(v) for v in (va, vb))
        if CAPTURE.search(k) and hexy:
            cap.append(k)
        elif IDENTITY.search(k) or hexy:
            ident.append(k)
        else:
            obs.append(k)
    return obs, cap, ident


def pattern_dir(path):
    return path.split("/verification/")[0]


def is_input(path):
    return not (path.startswith("scripts/") or "toolchain" in path)


rows = []
commits = git("log", "--format=%H %ad", "--date=short", "--diff-filter=M", "--", "*/verification/*.json").split("\n")
for line in filter(None, commits):
    sha, date = line.split()
    changed = [l.split("\t") for l in git("diff-tree", "--no-commit-id", "-r", "--name-status", f"{sha}^", sha).split("\n") if l]
    changed_paths = {p[-1] for p in changed}
    groups = defaultdict(list)
    for status, *paths in changed:
        path = paths[-1]
        if "/verification/" in path:
            groups[pattern_dir(path)].append((status, path))
    for pdir, files in groups.items():
        modified_json = [p for s, p in files if s == "M" and p.endswith(".json")]
        if not modified_json:
            continue
        sources = set()
        for p in modified_json:
            new = load(sha, p) or {}
            src = new.get("sources") if isinstance(new, dict) else None
            if isinstance(src, dict):
                sources |= set(src)
        if sources:
            input_changed = any(s in changed_paths for s in sources if is_input(s))
        else:
            input_changed = any(p.startswith(pdir + "/") and "/verification/" not in p for p in changed_paths)
        obs, cap, ident = set(), set(), set()
        for p in modified_json:
            o, c, i = classify(load(f"{sha}^", p) or {}, load(sha, p) or {})
            obs |= {f"{Path(p).name}:{k}" for k in o}
            cap |= {f"{Path(p).name}:{k}" for k in c}
            ident |= set(i)
        binary_caps = [p for s, p in files if s == "M" and not p.endswith(".json")]
        subject = git("log", "-1", "--format=%s", sha).strip()
        rows.append(
            dict(
                sha=sha[:8], date=date, pattern=pdir, input_changed=input_changed,
                obs=sorted(obs), caps=sorted(cap) + binary_caps, ident=len(ident),
                subject=subject,
            )
        )

forced = [r for r in rows if not r["input_changed"]]
sourced = [r for r in rows if r["input_changed"]]


def summary(name, rs):
    changed = [r for r in rs if r["obs"] or r["caps"]]
    print(f"{name}: {len(rs)} re-records across {len({r['sha'] for r in rs})} commits; "
          f"{len(changed)} changed an observation or capture")
    return changed


print(f"{len(rows)} pattern re-records in {len({r['sha'] for r in rows})} commits\n")
f_changed = summary("Forced by scripts/tools only (no input change)", forced)
s_changed = summary("With an input change", sourced)
print("\nForced re-records that changed something:")
for r in f_changed:
    print(f"  {r['date']} {r['sha']} {r['pattern']}: obs={r['obs'][:3]} caps={r['caps'][:2]}  [{r['subject'][:70]}]")
json.dump(rows, open(Path(sys.argv[2]), "w"), indent=1)

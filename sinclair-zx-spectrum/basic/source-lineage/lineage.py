"""Let an audit accept evidence recorded on an earlier text of a listing.

`lineage.json` links each listing's earlier SHA-256 to its current one, with
the proof that the change kept the program: `space-only` links remove stored
spaces and nothing else, `renamed-variable` links rename a variable. An audit
calls `accepts(recorded, source)` wherever it compares an evidence record's
source hash with the listing on disk. The recorded hash is accepted when it
is the current hash, or when the current hash links back to it. Any other
difference still fails.

`build.py` writes lineage.json and re-verifies it.
"""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASIC = HERE.parent
_links = None
_noted = set()


def _load():
    global _links
    if _links is None:
        data = json.loads((HERE / 'lineage.json').read_text())
        _links = {}
        for link in data['links']:
            _links.setdefault(link['path'], {})[link['to']] = link
    return _links


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def chain(source):
    """The links from the listing's current text back to its earliest recorded text."""
    path = Path(source).resolve().relative_to(BASIC.parent.parent).as_posix()
    by_to = _load().get(path, {})
    out, current = [], sha(source)
    while current in by_to:
        link = by_to[current]
        out.append(link)
        current = link['from']
    return out


def earlier_texts(source):
    """The listing's earlier texts along its links, read from git and checked
    against the recorded hashes, for evidence that hashed a derived form."""
    import subprocess
    out = []
    for link in chain(source):
        data = subprocess.run(['git', '-C', str(BASIC), 'show', f'{link["from_commit"]}:{link["path"]}'],
                              check=True, capture_output=True).stdout
        if hashlib.sha256(data).hexdigest() != link['from']:
            raise AssertionError(f'{link["path"]} at {link["from_commit"][:8]} does not match lineage.json')
        out.append(data.decode())
    return out


def accepts(recorded, source):
    """True when `recorded` is the listing's current hash or links back to it."""
    if recorded == sha(source):
        return True
    crossed = []
    for link in chain(source):
        if link['kind'] == 'renamed-variable':
            crossed.append(link)
        if link['from'] == recorded:
            for rename in crossed:
                key = (rename['path'], rename['commit'])
                if key not in _noted:
                    _noted.add(key)
                    names = ', '.join(f'{a} -> {b}' for a, b in rename['renames'].items())
                    print(f'NOTE {rename["path"]}: evidence predates a variable rename '
                          f'({names}, {rename["commit"][:8]})')
            return True
    return False

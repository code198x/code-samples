"""Independent set/lifetime oracle for the native BASIC pool callers."""

from __future__ import annotations

FIELDS = (
    ["C", "M", "S", "R", "O", "E"]
    + [f"F{i}" for i in range(1, 9)]
    + [f"L{i}" for i in range(1, 9)]
)


def case_rows(cap):
    rows = []
    for i in range(16):
        row = dict.fromkeys(FIELDS, 0)
        row.update(C=cap, M=1 + i % 3, S=[0, cap - 1, cap, 255][i % 4])
        mask = [0, 1, 3, 15, 255][i % 5]
        for j in range(1, 9):
            row[f"F{j}"] = int(bool(mask & 1 << j - 1))
            row[f"L{j}"] = [0, 1, 2, 255][(i + j) % 4]
        if i == 12:
            row["C"] = 0
        if i == 13:
            row["F1"] = 2
        if i == 14:
            row["C"] = 9
        rows.append(row)
    return rows


def call(d: dict[str, int]) -> dict[str, int]:
    d = d.copy()
    d.update(R=255, O=0, E=0)
    cap = d["C"]
    if cap not in range(1, 9) or any(
        d[f"F{i}"] not in [0, 1] for i in range(1, cap + 1)
    ):
        d["E"] = 1
        return d
    live = {i - 1 for i in range(1, cap + 1) if d[f"F{i}"]}
    if d["M"] == 1:
        free = sorted(set(range(cap)) - live)
        if free:
            slot = free[0]
            d.update(R=slot, O=1)
            d[f"F{slot + 1}"] = 1
    elif d["M"] == 2:
        if d["S"] in live:
            d[f"F{d['S'] + 1}"] = 0
            d.update(R=d["S"], O=1)
    else:
        if any(not 1 <= d[f"L{i + 1}"] <= 255 for i in live):
            d["E"] = 1
            return d
        expired = []
        for slot in sorted(live):
            d[f"L{slot + 1}"] -= 1
            if d[f"L{slot + 1}"] == 0:
                d[f"F{slot + 1}"] = 0
                expired.append(slot)
        if expired:
            d.update(R=expired[-1], O=len(expired))
    return d


def packet(variant: str) -> list[int]:
    cap = 4 if variant == "custom" else 8
    d = dict.fromkeys(FIELDS, 0)
    d["C"] = cap
    out = []

    def emit():
        out.extend(d[k] for k in FIELDS)

    emit()
    for row in case_rows(cap):
        d = call(row)
        emit()
    d = dict.fromkeys(FIELDS, 0)
    d["C"] = cap
    for _ in range(cap):
        d["M"] = 1
        d = call(d)
        if d["O"]:
            d[f"L{d['R'] + 1}"] = 2
        emit()
    d["M"] = 1
    d = call(d)
    emit()
    d.update(M=2, S=255 if variant == "wrong" else 1)
    d = call(d)
    emit()
    d["M"] = 1
    d = call(d)
    if d["O"]:
        d[f"L{d['R'] + 1}"] = 2
    emit()
    d["M"] = 3
    d = call(d)
    emit()
    d = call(d)
    emit()
    assert len(out) < 997 and all(0 <= v < 256 for v in out)
    return out


if __name__ == "__main__":
    assert packet("demo") == packet("repaired")
    assert packet("demo") != packet("wrong")
    for cap in [4, 8]:
        for mask in range(256):
            d = dict.fromkeys(FIELDS, 0)
            d.update(C=cap, M=1)
            for i in range(8):
                d[f"F{i + 1}"] = int(bool(mask & (1 << i)))
            out = call(d)
            free = [i for i in range(cap) if not mask & (1 << i)]
            assert out["O"] == bool(free)
            assert out["R"] == (free[0] if free else 255)
    print(
        "Both capacities, all256 occupancy masks, deterministic variants and repair pass independent host invariants."
    )

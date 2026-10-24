"""Independent contracts expressed with integers, sets and lists."""

from __future__ import annotations

import random

TOPICS = {
    "ladder-controller": {
        "title": "Enter and Leave a Ladder",
        "category": "physics",
        "fields": [
            "MODE",
            "POSITION",
            "GRAVITY",
            "JUMPED",
            "VALID",
            "ON_LADDER",
            "UP",
            "DOWN",
            "JUMP",
            "MINIMUM",
            "MAXIMUM",
        ],
        "trace": [
            {"POSITION": 10, "MAXIMUM": 20, "ON_LADDER": 1, "UP": 1},
            {},
            {"JUMP": 1},
        ],
        "custom_trace": [
            {"POSITION": 19, "MAXIMUM": 20, "ON_LADDER": 1, "DOWN": 1},
            {},
            {"ON_LADDER": 0},
        ],
    },
    "inventory-transfer": {
        "title": "Transfer Inventory Stacks Atomically",
        "category": "framework",
        "fields": [
            "MOVED",
            "VALID",
            "SOURCE_KIND",
            "SOURCE_COUNT",
            "DEST_KIND",
            "DEST_COUNT",
            "CAPACITY",
            "AMOUNT",
        ],
        "trace": [
            {
                "SOURCE_KIND": 3,
                "SOURCE_COUNT": 7,
                "DEST_KIND": 3,
                "DEST_COUNT": 8,
                "CAPACITY": 10,
                "AMOUNT": 5,
            },
            {"DEST_KIND": 0, "DEST_COUNT": 0, "AMOUNT": 5},
        ],
        "custom_trace": [
            {"SOURCE_KIND": 2, "SOURCE_COUNT": 4, "CAPACITY": 4, "AMOUNT": 255},
            {},
        ],
    },
    "aimed-projectile": {
        "title": "Aim a Projectile with Bounded Integer Speed",
        "category": "physics",
        "fields": [
            "VELOCITY_X",
            "VELOCITY_Y",
            "VALID",
            "ORIGIN_X",
            "ORIGIN_Y",
            "TARGET_X",
            "TARGET_Y",
            "SPEED",
        ],
        "trace": [
            {
                "ORIGIN_X": 100,
                "ORIGIN_Y": 100,
                "TARGET_X": 80,
                "TARGET_Y": 90,
                "SPEED": 6,
            }
        ],
        "custom_trace": [
            {
                "ORIGIN_X": 0,
                "ORIGIN_Y": 0,
                "TARGET_X": 255,
                "TARGET_Y": 128,
                "SPEED": 15,
            }
        ],
    },
    "attack-hit-window": {
        "title": "Limit Hits to an Attack Window",
        "category": "framework",
        "fields": [
            "HIT",
            "VALID",
            "SEEN",
            "FRAME",
            "START_FRAME",
            "END_FRAME",
            "TARGET",
            "CONTACT",
            "NEW_ATTACK",
        ],
        "trace": [
            {
                "START_FRAME": 2,
                "END_FRAME": 5,
                "FRAME": 2,
                "TARGET": 1,
                "CONTACT": 1,
                "NEW_ATTACK": 1,
            },
            {"NEW_ATTACK": 0, "FRAME": 3},
            {},
        ],
        "custom_trace": [
            {
                "START_FRAME": 1,
                "END_FRAME": 3,
                "FRAME": 1,
                "TARGET": 7,
                "CONTACT": 1,
                "NEW_ATTACK": 1,
            },
            {"NEW_ATTACK": 0, "TARGET": 0},
            {"FRAME": 3},
        ],
    },
    "interaction-focus": {
        "title": "Keep a Stable Interaction Focus",
        "category": "framework",
        "fields": [
            "SELECTED",
            "VALID",
            "CURRENT",
            "ACTIVE",
            "RANGE",
            "MARGIN",
            "D0",
            "D1",
            "D2",
            "D3",
        ],
        "trace": [
            {"CURRENT": 1, "ACTIVE": 3, "RANGE": 20, "MARGIN": 2, "D0": 9, "D1": 10},
            {"CURRENT": 1, "D0": 8},
            {"CURRENT": 1, "D0": 8},
        ],
        "custom_trace": [
            {
                "CURRENT": 3,
                "ACTIVE": 15,
                "RANGE": 10,
                "MARGIN": 0,
                "D0": 10,
                "D1": 10,
                "D2": 10,
                "D3": 10,
            }
        ],
    },
    "menu-page-window": {
        "title": "Keep a Menu Selection Visible",
        "category": "input",
        "fields": [
            "TOP",
            "ROW",
            "VISIBLE",
            "VALID",
            "SELECTED",
            "ITEM_COUNT",
            "PAGE_ROWS",
        ],
        "trace": [
            {"ITEM_COUNT": 20, "PAGE_ROWS": 4, "SELECTED": 5},
            {"SELECTED": 6},
            {"SELECTED": 3},
        ],
        "custom_trace": [
            {"ITEM_COUNT": 255, "PAGE_ROWS": 8, "SELECTED": 254, "TOP": 255}
        ],
    },
    "typewriter-text": {
        "title": "Reveal Counted Text Over Time",
        "category": "rendering",
        "fields": [
            "REVEALED",
            "TICKS",
            "DONE",
            "ADDED",
            "VALID",
            "LENGTH",
            "INTERVAL",
            "SKIP",
        ],
        "trace": [{"LENGTH": 4, "INTERVAL": 2}, {}, {}, {}],
        "custom_trace": [{"LENGTH": 3, "INTERVAL": 1}, {"SKIP": 1}, {"SKIP": 0}, {}],
    },
    "music-command-stream": {
        "title": "Sequence Counted Notes and Rests",
        "category": "audio",
        "fields": [
            "NOTE",
            "EVENT",
            "FINISHED",
            "VALID",
            "INDEX",
            "REMAINING",
            "COUNT",
            "N0",
            "N1",
            "N2",
            "N3",
            "N4",
            "N5",
            "N6",
            "N7",
            "U0",
            "U1",
            "U2",
            "U3",
            "U4",
            "U5",
            "U6",
            "U7",
        ],
        "trace": [
            {"COUNT": 3, "N0": 40, "U0": 2, "N1": 0, "U1": 1, "N2": 44, "U2": 1},
            {},
            {},
        ],
        "custom_trace": [{"COUNT": 2, "N0": 72, "U0": 1, "N1": 255, "U1": 0}, {}, {}],
    },
    "save-record-validation": {
        "title": "Validate a Save Before Replacing Live State",
        "category": "framework",
        "fields": [
            "ACCEPTED",
            "VALID",
            "MODE",
            "L0",
            "L1",
            "L2",
            "L3",
            "C0",
            "C1",
            "C2",
            "C3",
            "C4",
            "C5",
            "C6",
            "C7",
        ],
        "trace": [
            {
                "MODE": 1,
                "L0": 2,
                "L1": 3,
                "L2": 4,
                "L3": 5,
                "C0": 198,
                "C1": 1,
                "C2": 4,
                "C3": 7,
                "C4": 20,
                "C5": 3,
                "C6": 2,
                "C7": 209,
            },
            {"C5": 255},
        ],
        "custom_trace": [
            {
                "MODE": 0,
                "L0": 9,
                "C0": 198,
                "C1": 1,
                "C2": 4,
                "C3": 15,
                "C4": 31,
                "C5": 9,
                "C6": 15,
                "C7": 213,
            },
            {"MODE": 1},
        ],
    },
    "object-command-buffer": {
        "title": "Defer Object Changes Until After Traversal",
        "category": "framework",
        "fields": [
            "APPLIED",
            "REJECTED",
            "FULL",
            "VALID",
            "MODE",
            "SLOT",
            "GENERATION",
            "ACTIVE",
            "COUNT",
            "G0",
            "G1",
            "G2",
            "G3",
            "O0",
            "O1",
            "O2",
            "O3",
            "S0",
            "S1",
            "S2",
            "S3",
            "H0",
            "H1",
            "H2",
            "H3",
        ],
        "trace": [
            {"MODE": 1, "SLOT": 1},
            {"MODE": 3},
            {"MODE": 2, "SLOT": 1, "GENERATION": 0},
            {"MODE": 3},
        ],
        "custom_trace": [
            {"MODE": 1, "SLOT": 2},
            {"MODE": 2, "GENERATION": 1},
            {"MODE": 3},
        ],
    },
}


def step(
    topic: str, row: list[int], custom: bool = False, wrong: bool = False
) -> list[int]:
    fields = TOPICS[topic]["fields"]
    d = dict(zip(fields, row, strict=True))
    if wrong:
        key, value = {
            "ladder-controller": ("ON_LADDER", 0),
            "inventory-transfer": ("AMOUNT", 0),
            "aimed-projectile": ("TARGET_X", d.get("ORIGIN_X", 0)),
            "attack-hit-window": ("SEEN", 0),
            "interaction-focus": ("CURRENT", 255),
            "menu-page-window": ("TOP", 0),
            "typewriter-text": ("TICKS", 0),
            "music-command-stream": ("REMAINING", 0),
            "save-record-validation": ("C7", 0),
            "object-command-buffer": ("COUNT", 0),
        }[topic]
        d[key] = value
    if topic == "ladder-controller":
        ok = d["MODE"] <= 1 and d["MINIMUM"] <= d["POSITION"] <= d["MAXIMUM"]
        d.update(GRAVITY=0, JUMPED=0, VALID=int(ok))
        if ok:
            if not d["ON_LADDER"]:
                d["MODE"] = 0
            elif d["MODE"] or d["UP"] or d["DOWN"]:
                d["MODE"] = 1
                if d["JUMP"]:
                    d.update(MODE=0, JUMPED=1)
                else:
                    d["POSITION"] = min(
                        d["MAXIMUM"],
                        max(
                            d["MINIMUM"],
                            d["POSITION"] + (int(bool(d["DOWN"])) - int(bool(d["UP"]))),
                        ),
                    )
            d["GRAVITY"] = int(d["MODE"] == 0)
    elif topic == "inventory-transfer":
        ok = all(
            d[p + "_COUNT"] <= d["CAPACITY"]
            and bool(d[p + "_COUNT"]) == bool(d[p + "_KIND"])
            for p in ["SOURCE", "DEST"]
        )
        d.update(MOVED=0, VALID=int(ok))
        if (
            ok
            and d["SOURCE_COUNT"]
            and (not d["DEST_COUNT"] or d["DEST_KIND"] == d["SOURCE_KIND"])
        ):
            amount = min(
                d["AMOUNT"], d["SOURCE_COUNT"], d["CAPACITY"] - d["DEST_COUNT"]
            )
            if amount:
                d["DEST_KIND"] = d["SOURCE_KIND"]
                d["DEST_COUNT"] += amount
                d["SOURCE_COUNT"] -= amount
                d["MOVED"] = amount
                if not d["SOURCE_COUNT"]:
                    d["SOURCE_KIND"] = 0
    elif topic == "aimed-projectile":
        dx = d["TARGET_X"] - d["ORIGIN_X"]
        dy = d["TARGET_Y"] - d["ORIGIN_Y"]
        scale = max(abs(dx), abs(dy))
        ok = d["SPEED"] <= 15
        d.update(VELOCITY_X=0, VELOCITY_Y=0, VALID=int(ok))
        if ok and scale:
            for key, delta in [("VELOCITY_X", dx), ("VELOCITY_Y", dy)]:
                d[key] = (
                    (1 if delta >= 0 else -1) * (abs(delta) * d["SPEED"] // scale)
                ) % 256
    elif topic == "attack-hit-window":
        ok = d["START_FRAME"] < d["END_FRAME"] and d["TARGET"] < 8
        d.update(HIT=0, VALID=int(ok))
        if ok:
            seen = {i for i in range(8) if d["SEEN"] & (1 << i)}
            if d["NEW_ATTACK"]:
                seen.clear()
            if (
                d["START_FRAME"] <= d["FRAME"] < d["END_FRAME"]
                and d["CONTACT"]
                and d["TARGET"] not in seen
            ):
                seen.add(d["TARGET"])
                d["HIT"] = 1
            d["SEEN"] = sum(1 << i for i in seen)
    elif topic == "interaction-focus":
        ok = (d["CURRENT"] in [0, 1, 2, 3, 255]) and d["ACTIVE"] < 16
        d.update(SELECTED=255, VALID=int(ok))
        if ok:
            candidates = [
                (d[f"D{i}"], i)
                for i in range(4)
                if d["ACTIVE"] & (1 << i) and d[f"D{i}"] <= d["RANGE"]
            ]
            if candidates:
                distance, slot = min(candidates)
                d["SELECTED"] = slot
                if any(
                    i == d["CURRENT"] and dist <= distance + d["MARGIN"]
                    for dist, i in candidates
                ):
                    d["SELECTED"] = d["CURRENT"]
    elif topic == "menu-page-window":
        ok = bool(
            d["ITEM_COUNT"] and d["PAGE_ROWS"] and d["SELECTED"] < d["ITEM_COUNT"]
        )
        d.update(ROW=0, VISIBLE=0, VALID=int(ok))
        if ok:
            top = min(d["TOP"], max(0, d["ITEM_COUNT"] - d["PAGE_ROWS"]))
            selected = d["SELECTED"]
            top = min(top, selected)
            top = max(top, selected - d["PAGE_ROWS"] + 1)
            d.update(
                TOP=top,
                ROW=selected - top,
                VISIBLE=min(d["PAGE_ROWS"], d["ITEM_COUNT"] - top),
            )
    elif topic == "typewriter-text":
        ok = bool(
            d["INTERVAL"]
            and d["TICKS"] < d["INTERVAL"]
            and d["REVEALED"] <= d["LENGTH"]
        )
        d.update(DONE=0, ADDED=0, VALID=int(ok))
        if ok:
            previous = d["REVEALED"]
            if d["SKIP"]:
                d.update(REVEALED=d["LENGTH"], TICKS=0)
            elif d["REVEALED"] < d["LENGTH"]:
                elapsed = d["TICKS"] + 1
                d["REVEALED"] += elapsed // d["INTERVAL"]
                d["TICKS"] = elapsed % d["INTERVAL"]
            d.update(
                DONE=int(d["REVEALED"] == d["LENGTH"]), ADDED=d["REVEALED"] - previous
            )
    elif topic == "music-command-stream":
        ok = d["COUNT"] <= 8 and d["INDEX"] <= d["COUNT"]
        d.update(EVENT=0, VALID=int(ok))
        if ok and not d["FINISHED"]:
            d["REMAINING"] = max(0, d["REMAINING"] - 1)
            if not d["REMAINING"]:
                if d["INDEX"] == d["COUNT"]:
                    d.update(FINISHED=1, NOTE=0, EVENT=2)
                else:
                    note = d[f"N{d['INDEX']}"]
                    duration = d[f"U{d['INDEX']}"]
                    if note == 255:
                        d.update(INDEX=d["INDEX"] + 1, FINISHED=1, NOTE=0, EVENT=2)
                    elif note > 95 or duration == 0:
                        d["VALID"] = 0
                    else:
                        d.update(
                            NOTE=note, REMAINING=duration, INDEX=d["INDEX"] + 1, EVENT=1
                        )
    elif topic == "save-record-validation":
        ok = d["MODE"] <= 1
        d.update(ACCEPTED=0, VALID=int(ok))
        payload = [d[f"C{i}"] for i in range(8)]
        checksum = 0
        for value in payload[:7]:
            checksum ^= value
        if (
            ok
            and payload[:3] == [198, 1, 4]
            and all(
                value <= limit
                for value, limit in zip(payload[3:7], [15, 31, 9, 15], strict=True)
            )
            and checksum == payload[7]
        ):
            d["ACCEPTED"] = 1
            if d["MODE"] == 1:
                d.update({f"L{i}": payload[i + 3] for i in range(4)})
    elif topic == "object-command-buffer":
        ok = d["ACTIVE"] < 16 and d["COUNT"] <= 4 and d["MODE"] <= 3
        d.update(APPLIED=0, REJECTED=0, FULL=0, VALID=0)
        if ok:
            mode = d["MODE"]
            if mode == 0:
                d.update(COUNT=0, VALID=1)
            elif mode in [1, 2]:
                if d["SLOT"] < 4:
                    d["VALID"] = 1
                    if d["COUNT"] == 4:
                        d["FULL"] = 1
                    else:
                        i = d["COUNT"]
                        d.update(
                            {
                                f"O{i}": mode,
                                f"S{i}": d["SLOT"],
                                f"H{i}": d["GENERATION"],
                            }
                        )
                        d["COUNT"] += 1
            else:
                commands = [
                    (d[f"O{i}"], d[f"S{i}"], d[f"H{i}"]) for i in range(d["COUNT"])
                ]
                if all(op in [1, 2] and slot < 4 for op, slot, gen in commands):
                    d["VALID"] = 1
                    active = {i for i in range(4) if d["ACTIVE"] & (1 << i)}
                    for op, slot, gen in commands:
                        applied = False
                        if op == 1 and slot not in active:
                            active.add(slot)
                            d[f"G{slot}"] = (d[f"G{slot}"] + 1) % 256
                            applied = True
                        elif op == 2 and slot in active and d[f"G{slot}"] == gen:
                            active.remove(slot)
                            applied = True
                        d["APPLIED" if applied else "REJECTED"] += 1
                    d.update(ACTIVE=sum(1 << i for i in active), COUNT=0)
    else:
        raise ValueError(topic)
    assert all(0 <= v < 256 for v in d.values()), (topic, d)
    return [d[k] for k in fields]


def cases(topic: str, custom: bool = False) -> list[list[int]]:
    fields = TOPICS[topic]["fields"]
    count = min(64, max(16, 1000 // len(fields)))
    rng = random.Random(1986 + list(TOPICS).index(topic))
    rows = []
    for i in range(count):
        d = {k: rng.randrange(256) for k in fields}
        if topic == "ladder-controller":
            d.update(
                MODE=i % 3,
                POSITION=[0, 1, 10, 20, 21, 255][i % 6],
                MINIMUM=0,
                MAXIMUM=20,
                ON_LADDER=i // 3 % 2,
                UP=i // 2 % 2,
                DOWN=i % 2,
                JUMP=i // 6 % 2,
            )
        elif topic == "inventory-transfer":
            d.update(
                SOURCE_KIND=[0, 1, 2][i % 3],
                SOURCE_COUNT=[0, 1, 4, 10, 11, 255][i // 3 % 6],
                DEST_KIND=[0, 1, 2][i // 9 % 3],
                DEST_COUNT=[0, 1, 9, 10, 11][i % 5],
                CAPACITY=10,
                AMOUNT=[0, 1, 5, 255][i // 4 % 4],
            )
            if i < 16:
                d.update(
                    SOURCE_KIND=2,
                    SOURCE_COUNT=7,
                    DEST_KIND=2 if i % 2 else 0,
                    DEST_COUNT=8 if i % 2 else 0,
                    AMOUNT=i,
                )
        elif topic == "aimed-projectile":
            axes = [0, 1, 127, 128, 254, 255]
            d.update(
                ORIGIN_X=axes[i % 6],
                ORIGIN_Y=axes[i // 6 % 6],
                TARGET_X=axes[5 - i % 6],
                TARGET_Y=axes[i % 6],
                SPEED=[0, 1, 7, 15, 16, 255][i // 6 % 6],
            )
            if i < 16:
                d.update(
                    ORIGIN_X=128,
                    ORIGIN_Y=128,
                    TARGET_X=[0, 127, 128, 129, 255][i % 5],
                    TARGET_Y=[0, 127, 128, 129, 255][i // 5],
                    SPEED=15,
                )
        elif topic == "attack-hit-window":
            d.update(
                START_FRAME=2,
                END_FRAME=5,
                FRAME=[0, 1, 2, 3, 4, 5, 255][i % 7],
                TARGET=i // 7 % 10,
                CONTACT=i % 2,
                NEW_ATTACK=i // 2 % 2,
                SEEN=[0, 1, 2, 128, 255][i // 4 % 5],
            )
        elif topic == "interaction-focus":
            d.update(
                CURRENT=[0, 1, 2, 3, 4, 255][i % 6],
                ACTIVE=[0, 1, 3, 15, 16, 255][i // 6 % 6],
                RANGE=[0, 10, 255][i % 3],
                MARGIN=[0, 1, 2, 255][i // 3 % 4],
                D0=9,
                D1=10,
                D2=10,
                D3=255,
            )
        elif topic == "menu-page-window":
            d.update(
                ITEM_COUNT=[0, 1, 4, 20, 254, 255][i % 6],
                PAGE_ROWS=[0, 1, 4, 8, 254, 255][i // 6 % 6],
                TOP=[0, 1, 3, 254, 255][i // 2 % 5],
                SELECTED=[0, 1, 3, 19, 253, 254, 255][i // 3 % 7],
            )
        elif topic == "typewriter-text":
            d.update(
                LENGTH=[0, 1, 4, 255][i % 4],
                REVEALED=[0, 1, 3, 254, 255][i // 4 % 5],
                TICKS=[0, 1, 2, 254, 255][i // 3 % 5],
                INTERVAL=[0, 1, 2, 255][i // 5 % 4],
                SKIP=i % 2,
            )
        elif topic == "music-command-stream":
            d.update(
                COUNT=[0, 1, 8, 9][i % 4],
                INDEX=i // 4 % 10,
                REMAINING=[0, 1, 2, 255][i // 3 % 4],
                FINISHED=0,
            )
            for j in range(8):
                d[f"N{j}"] = [0, 1, 95, 96, 255][(i + j) % 5]
                d[f"U{j}"] = [0, 1, 2, 255][(i + j) // 5 % 4]
            if i < 16:
                d.update(COUNT=8, INDEX=i % 8, REMAINING=0)
                d[f"N{i % 8}"] = [0, 95, 96, 255][i // 4]
                d[f"U{i % 8}"] = i % 4
        elif topic == "save-record-validation":
            d.update(
                MODE=i % 3,
                C0=198,
                C1=1,
                C2=4,
                C3=i % 17,
                C4=i % 33,
                C5=i % 11,
                C6=i % 17,
            )
            d["C7"] = 0
            for j in range(7):
                d["C7"] ^= d[f"C{j}"]
            if i >= 16:
                k = i % 8
                d[f"C{k}"] ^= 1
        elif topic == "object-command-buffer":
            d.update(
                MODE=i % 5,
                SLOT=i // 5 % 6,
                GENERATION=i % 3,
                ACTIVE=[0, 1, 3, 15, 16][i // 5 % 5],
                COUNT=i % 6,
            )
            for j in range(4):
                d[f"O{j}"] = 1 + j % 2
                d[f"S{j}"] = j
                d[f"H{j}"] = i % 3
                d[f"G{j}"] = i % 3
            if i < 12:
                d.update(MODE=3, COUNT=4, ACTIVE=i % 4)
            if i in [12, 13]:
                d.update(
                    MODE=3,
                    COUNT=4,
                    ACTIVE=0,
                    O3=3 if i == 12 else 1,
                    S3=4 if i == 13 else 3,
                )
        rows.append([d[k] for k in fields])
    return rows


def trace(topic: str, custom: bool = False) -> list[dict[str, int]]:
    return TOPICS[topic]["custom_trace" if custom else "trace"]


def packet(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    fields = TOPICS[topic]["fields"]
    out = [165, list(TOPICS).index(topic), int(custom)] + [0] * len(fields)
    for row in cases(topic, custom):
        out += step(topic, row, custom)
    state = [0] * len(fields)
    for change in trace(topic, custom):
        for field, value in change.items():
            state[fields.index(field)] = value
        state = step(topic, state, custom, wrong)
        out += state
    return out + [239]


def preview(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    n = len(TOPICS[topic]["fields"])
    return (packet(topic, custom, wrong)[-1 - n : -1] + [0] * 8)[:8]

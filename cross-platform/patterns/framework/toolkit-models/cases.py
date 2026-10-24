"""Independent mathematical and container contracts for native toolkit routines."""

from __future__ import annotations

import random

TOPICS = {
    "signed-byte-order": {
        "title": "Compare Signed Byte Values",
        "category": "framework",
        "fields": ["ORDER", "LEFT", "RIGHT"],
        "trace": [{"LEFT": 255, "RIGHT": 0}],
        "custom_trace": [{"LEFT": 128, "RIGHT": 127}],
    },
    "saturating-word-add": {
        "title": "Add Words with Saturation",
        "category": "framework",
        "fields": [
            "SUM_LO",
            "SUM_HI",
            "CLAMPED",
            "LEFT_LO",
            "LEFT_HI",
            "RIGHT_LO",
            "RIGHT_HI",
        ],
        "trace": [{"LEFT_LO": 250, "LEFT_HI": 254, "RIGHT_LO": 10, "RIGHT_HI": 1}],
        "custom_trace": [{"LEFT_LO": 255, "LEFT_HI": 0, "RIGHT_LO": 1, "RIGHT_HI": 0}],
    },
    "hexadecimal-format": {
        "title": "Format a Byte as Hexadecimal",
        "category": "framework",
        "fields": ["HIGH_CHAR", "LOW_CHAR", "VALUE", "LOWERCASE"],
        "trace": [{"VALUE": 171}],
        "custom_trace": [{"VALUE": 254, "LOWERCASE": 1}],
    },
    "hexadecimal-parser": {
        "title": "Parse Two Hexadecimal Digits",
        "category": "framework",
        "fields": ["VALUE", "VALID", "FIRST", "SECOND"],
        "trace": [{"FIRST": 65, "SECOND": 98}],
        "custom_trace": [{"FIRST": 102, "SECOND": 70}],
    },
    "bounded-bit-writer": {
        "title": "Write Packed Bits with Bounds",
        "category": "framework",
        "fields": ["VALID", "CURSOR", "COUNT", "VALUE", "B0", "B1", "B2", "B3"],
        "trace": [{"COUNT": 5, "VALUE": 21, "CURSOR": 6, "B0": 255, "B1": 255}],
        "custom_trace": [{"COUNT": 8, "VALUE": 165, "CURSOR": 24}],
    },
    "bitset-slot-allocation": {
        "title": "Allocate Slots with a Bitset",
        "category": "framework",
        "fields": ["SLOT", "RESULT", "VALID", "USED", "MODE", "REQUEST"],
        "trace": [{"USED": 3}, {}, {"MODE": 1, "REQUEST": 1}],
        "custom_trace": [{"USED": 254}, {}, {"MODE": 1, "REQUEST": 7}],
    },
    "priority-event-queue": {
        "title": "Keep a Stable Priority Event Queue",
        "category": "framework",
        "fields": [
            "EVENT",
            "PRIORITY",
            "RESULT",
            "VALID",
            "COUNT",
            "MODE",
            "NEW_EVENT",
            "NEW_PRIORITY",
            "E0",
            "E1",
            "E2",
            "E3",
            "P0",
            "P1",
            "P2",
            "P3",
        ],
        "trace": [
            {"NEW_EVENT": 11, "NEW_PRIORITY": 2},
            {"NEW_EVENT": 22, "NEW_PRIORITY": 8},
            {"NEW_EVENT": 33, "NEW_PRIORITY": 8},
            {"MODE": 1},
        ],
        "custom_trace": [
            {"NEW_EVENT": 7, "NEW_PRIORITY": 0},
            {"NEW_EVENT": 9, "NEW_PRIORITY": 255},
            {"MODE": 1},
        ],
    },
    "high-score-insertion": {
        "title": "Insert into a High-score Table",
        "category": "framework",
        "fields": [
            "RANK",
            "INSERTED",
            "VALID",
            "SCORE",
            "TAG",
            "COUNT",
            "S0",
            "S1",
            "S2",
            "S3",
            "I0",
            "I1",
            "I2",
            "I3",
        ],
        "trace": [
            {"SCORE": 20, "TAG": 1},
            {"SCORE": 40, "TAG": 2},
            {"SCORE": 40, "TAG": 3},
        ],
        "custom_trace": [{"SCORE": 255, "TAG": 4}, {"SCORE": 0, "TAG": 5}],
    },
    "dictionary-lookup": {
        "title": "Look Up a Bounded Byte Dictionary",
        "category": "framework",
        "fields": [
            "VALUE",
            "FOUND",
            "VALID",
            "KEY",
            "COUNT",
            "K0",
            "K1",
            "K2",
            "K3",
            "K4",
            "K5",
            "K6",
            "K7",
            "Q0",
            "Q1",
            "Q2",
            "Q3",
            "Q4",
            "Q5",
            "Q6",
            "Q7",
        ],
        "trace": [
            {
                "COUNT": 3,
                "K0": 10,
                "K1": 20,
                "K2": 20,
                "Q0": 4,
                "Q1": 7,
                "Q2": 9,
                "KEY": 20,
            }
        ],
        "custom_trace": [{"COUNT": 1, "K0": 255, "Q0": 0, "KEY": 255}],
    },
    "bounded-text-wrap": {
        "title": "Choose a Bounded Text Line",
        "category": "framework",
        "fields": [
            "LENGTH",
            "NEXT",
            "VALID",
            "START",
            "WIDTH",
            "COUNT",
            "C0",
            "C1",
            "C2",
            "C3",
            "C4",
            "C5",
            "C6",
            "C7",
            "C8",
            "C9",
            "C10",
            "C11",
            "C12",
            "C13",
            "C14",
            "C15",
        ],
        "trace": [
            {
                "COUNT": 11,
                "WIDTH": 7,
                "C0": 72,
                "C1": 69,
                "C2": 76,
                "C3": 76,
                "C4": 79,
                "C5": 32,
                "C6": 87,
                "C7": 79,
                "C8": 82,
                "C9": 76,
                "C10": 68,
            }
        ],
        "custom_trace": [
            {
                "COUNT": 8,
                "WIDTH": 3,
                "C0": 65,
                "C1": 66,
                "C2": 67,
                "C3": 68,
                "C4": 69,
                "C5": 70,
                "C6": 71,
                "C7": 72,
            }
        ],
    },
    "rectangle-clipping": {
        "title": "Clip a Rectangle to a Viewport",
        "category": "physics",
        "fields": [
            "OUT_LEFT",
            "OUT_TOP",
            "OUT_RIGHT",
            "OUT_BOTTOM",
            "VISIBLE",
            "VALID",
            "LEFT",
            "TOP",
            "RIGHT",
            "BOTTOM",
            "VIEW_LEFT",
            "VIEW_TOP",
            "VIEW_RIGHT",
            "VIEW_BOTTOM",
        ],
        "trace": [
            {
                "LEFT": 2,
                "TOP": 3,
                "RIGHT": 12,
                "BOTTOM": 15,
                "VIEW_LEFT": 5,
                "VIEW_TOP": 0,
                "VIEW_RIGHT": 10,
                "VIEW_BOTTOM": 10,
            }
        ],
        "custom_trace": [
            {
                "LEFT": 0,
                "TOP": 0,
                "RIGHT": 255,
                "BOTTOM": 255,
                "VIEW_LEFT": 10,
                "VIEW_TOP": 20,
                "VIEW_RIGHT": 30,
                "VIEW_BOTTOM": 40,
            }
        ],
    },
    "swept-axis-collision": {
        "title": "Sweep an Interval Along One Axis",
        "category": "physics",
        "fields": [
            "POSITION",
            "HIT",
            "VALID",
            "OLD_POSITION",
            "TARGET",
            "SIZE",
            "WALL_START",
            "WALL_END",
        ],
        "trace": [
            {
                "OLD_POSITION": 2,
                "TARGET": 20,
                "SIZE": 3,
                "WALL_START": 10,
                "WALL_END": 12,
            }
        ],
        "custom_trace": [
            {
                "OLD_POSITION": 20,
                "TARGET": 2,
                "SIZE": 2,
                "WALL_START": 10,
                "WALL_END": 12,
            }
        ],
    },
    "nearest-target": {
        "title": "Select the Nearest Active Target",
        "category": "ai",
        "fields": [
            "SLOT",
            "DISTANCE_LO",
            "DISTANCE_HI",
            "FOUND",
            "ACTIVE",
            "ORIGIN_X",
            "ORIGIN_Y",
            "PX0",
            "PX1",
            "PX2",
            "PX3",
            "PY0",
            "PY1",
            "PY2",
            "PY3",
        ],
        "trace": [{"ACTIVE": 3, "PX0": 100, "PY0": 100, "PX1": 2, "PY1": 3}],
        "custom_trace": [
            {
                "ACTIVE": 9,
                "ORIGIN_X": 255,
                "ORIGIN_Y": 255,
                "PX0": 0,
                "PY0": 0,
                "PX3": 254,
                "PY3": 255,
            }
        ],
    },
    "eight-way-direction": {
        "title": "Choose an Eight-way Direction",
        "category": "physics",
        "fields": ["DIRECTION", "DX", "DY", "FROM_X", "FROM_Y", "TO_X", "TO_Y"],
        "trace": [{"TO_X": 10, "TO_Y": 3}],
        "custom_trace": [{"FROM_X": 100, "FROM_Y": 100, "TO_X": 90, "TO_Y": 90}],
    },
    "bitmap-mirror": {
        "title": "Mirror an Eight-bit Bitmap Row",
        "category": "rendering",
        "fields": ["MIRRORED", "ROW"],
        "trace": [{"ROW": 192}],
        "custom_trace": [{"ROW": 129}],
    },
    "bitmap-transpose": {
        "title": "Transpose an Eight-by-eight Bitmap",
        "category": "rendering",
        "fields": [
            "R0",
            "R1",
            "R2",
            "R3",
            "R4",
            "R5",
            "R6",
            "R7",
            "C0",
            "C1",
            "C2",
            "C3",
            "C4",
            "C5",
            "C6",
            "C7",
        ],
        "trace": [{"C0": 255, "C1": 128, "C2": 128, "C3": 128}],
        "custom_trace": [
            {
                "C0": 128,
                "C1": 64,
                "C2": 32,
                "C3": 16,
                "C4": 8,
                "C5": 4,
                "C6": 2,
                "C7": 1,
            }
        ],
    },
    "packed-colour-step": {
        "title": "Step Towards a Packed Colour",
        "category": "rendering",
        "fields": ["COLOUR", "TARGET"],
        "trace": [{"TARGET": 255}, {}, {}, {}],
        "custom_trace": [{"COLOUR": 255, "TARGET": 0}, {}, {}, {}],
    },
    "bounded-delta-decoder": {
        "title": "Decode Bounded Byte Deltas",
        "category": "framework",
        "fields": [
            "WRITTEN",
            "VALID",
            "COUNT",
            "BASE",
            "Q0",
            "Q1",
            "Q2",
            "Q3",
            "Q4",
            "Q5",
            "Q6",
            "Q7",
            "R0",
            "R1",
            "R2",
            "R3",
            "R4",
            "R5",
            "R6",
            "R7",
        ],
        "trace": [{"COUNT": 4, "BASE": 10, "Q0": 1, "Q1": 255, "Q2": 2, "Q3": 254}],
        "custom_trace": [{"COUNT": 3, "BASE": 255, "Q0": 1, "Q1": 128, "Q2": 127}],
    },
    "input-debounce": {
        "title": "Debounce a Sampled Input Byte",
        "category": "input",
        "fields": ["STABLE", "CHANGED", "CANDIDATE", "RUN", "RAW", "THRESHOLD"],
        "trace": [{"RAW": 1, "THRESHOLD": 3}, {}, {"RAW": 0}, {"RAW": 1}, {}, {}],
        "custom_trace": [{"RAW": 128, "THRESHOLD": 1}, {}, {"RAW": 0}],
    },
    "round-robin-service": {
        "title": "Select Ready Work with Round-robin Fairness",
        "category": "framework",
        "fields": ["SLOT", "FOUND", "NEXT", "READY"],
        "trace": [{"READY": 37}, {}, {}, {}],
        "custom_trace": [{"NEXT": 7, "READY": 129}, {}, {}, {}],
    },
}


def step(
    topic: str, row: list[int], custom: bool = False, wrong: bool = False
) -> list[int]:
    fields = TOPICS[topic]["fields"]
    d = dict(zip(fields, row, strict=True))
    if wrong:
        mutations = {
            "signed-byte-order": ("LEFT", d.get("LEFT", 0) & 127),
            "saturating-word-add": ("RIGHT_HI", 0),
            "hexadecimal-format": ("VALUE", d.get("VALUE", 0) & 15),
            "hexadecimal-parser": ("SECOND", 48),
            "bounded-bit-writer": ("CURSOR", 0),
            "bitset-slot-allocation": ("USED", 0),
            "priority-event-queue": ("NEW_PRIORITY", 0),
            "high-score-insertion": ("SCORE", 0),
            "dictionary-lookup": ("KEY", 0),
            "bounded-text-wrap": ("WIDTH", 1),
            "rectangle-clipping": ("VIEW_RIGHT", 255),
            "swept-axis-collision": ("TARGET", d.get("OLD_POSITION", 0)),
            "nearest-target": ("ACTIVE", 1),
            "eight-way-direction": ("TO_Y", d.get("FROM_Y", 0)),
            "bitmap-mirror": ("ROW", d.get("ROW", 0) & 15),
            "bitmap-transpose": ("C0", 0),
            "packed-colour-step": ("COLOUR", 0),
            "bounded-delta-decoder": ("BASE", 0),
            "input-debounce": ("RUN", 0),
            "round-robin-service": ("NEXT", 0),
        }
        key, value = mutations[topic]
        d[key] = value
    if topic == "signed-byte-order":
        a = d["LEFT"] if d["LEFT"] < 128 else d["LEFT"] - 256
        b = d["RIGHT"] if d["RIGHT"] < 128 else d["RIGHT"] - 256
        d["ORDER"] = 1 + (a > b) - (a < b)
    elif topic == "saturating-word-add":
        n = d["LEFT_LO"] + 256 * d["LEFT_HI"] + d["RIGHT_LO"] + 256 * d["RIGHT_HI"]
        d["CLAMPED"] = int(n > 65535)
        d["SUM_HI"], d["SUM_LO"] = divmod(min(n, 65535), 256)
    elif topic == "hexadecimal-format":
        s = format(d["VALUE"], "02x" if d["LOWERCASE"] else "02X")
        d.update(HIGH_CHAR=ord(s[0]), LOW_CHAR=ord(s[1]))
    elif topic == "hexadecimal-parser":
        text = chr(d["FIRST"]) + chr(d["SECOND"])
        ok = all(c in "0123456789abcdefABCDEF" for c in text)
        d.update(VALUE=int(text, 16) if ok else 0, VALID=int(ok))
    elif topic == "bounded-bit-writer":
        cursor, count = d["CURSOR"], d["COUNT"]
        ok = count <= 8 and cursor <= 32 and cursor + count <= 32
        d["VALID"] = int(ok)
        if ok:
            bits = list("".join(f"{d[f'B{i}']:08b}" for i in range(4)))
            bits[cursor : cursor + count] = (
                list(format(d["VALUE"] & ((1 << count) - 1), f"0{count}b"))
                if count
                else []
            )
            d.update(
                {f"B{i}": int("".join(bits[i * 8 : i * 8 + 8]), 2) for i in range(4)}
            )
            d["CURSOR"] += count
    elif topic == "bitset-slot-allocation":
        ok = d["MODE"] < 2 and (d["MODE"] == 0 or d["REQUEST"] < 8)
        d.update(SLOT=255, RESULT=0, VALID=int(ok))
        if ok:
            used = {i for i in range(8) if d["USED"] & (1 << i)}
            slot = (
                next((i for i in range(8) if i not in used), None)
                if d["MODE"] == 0
                else d["REQUEST"]
                if d["REQUEST"] in used
                else None
            )
            if slot is not None:
                if d["MODE"] == 0:
                    used.add(slot)
                else:
                    used.remove(slot)
                d.update(SLOT=slot, RESULT=1, USED=sum(1 << i for i in used))
    elif topic == "priority-event-queue":
        n = d["COUNT"]
        ok = n <= 4 and d["MODE"] < 2
        d.update(EVENT=255, PRIORITY=0, RESULT=0, VALID=int(ok))
        if ok:
            pairs = [(d[f"P{i}"], d[f"E{i}"]) for i in range(n)]
            if d["MODE"] == 0 and n < 4:
                pairs.append((d["NEW_PRIORITY"], d["NEW_EVENT"]))
                pairs.sort(key=lambda pair: -pair[0])
                d.update(EVENT=d["NEW_EVENT"], PRIORITY=d["NEW_PRIORITY"], RESULT=1)
            elif d["MODE"] == 1 and n:
                priority, event = pairs.pop(0)
                d.update(EVENT=event, PRIORITY=priority, RESULT=1)
            if d["RESULT"]:
                d["COUNT"] = len(pairs)
                if d["MODE"] == 1:
                    pairs.append((0, 0))
                for i, (priority, event) in enumerate(pairs):
                    d[f"P{i}"] = priority
                    d[f"E{i}"] = event
    elif topic == "high-score-insertion":
        n = d["COUNT"]
        d.update(RANK=255, INSERTED=0, VALID=int(n <= 4))
        if n <= 4:
            pairs = [(d[f"S{i}"], d[f"I{i}"]) for i in range(n)]
            rank = sum(score >= d["SCORE"] for score, tag in pairs)
            if rank < 4:
                pairs.insert(rank, (d["SCORE"], d["TAG"]))
                pairs = pairs[:4]
                d.update(COUNT=len(pairs), RANK=rank, INSERTED=1)
                for i, (score, tag) in enumerate(pairs):
                    d[f"S{i}"] = score
                    d[f"I{i}"] = tag
    elif topic == "dictionary-lookup":
        n = d["COUNT"]
        d.update(VALUE=0, FOUND=0, VALID=int(n <= 8))
        if n <= 8:
            values = [d[f"Q{i}"] for i in range(n) if d[f"K{i}"] == d["KEY"]]
            if values:
                d.update(VALUE=values[0], FOUND=1)
    elif topic == "bounded-text-wrap":
        start, count, width = d["START"], d["COUNT"], d["WIDTH"]
        ok = count <= 16 and start <= count and 1 <= width <= 16
        d.update(LENGTH=0, NEXT=start, VALID=int(ok))
        if ok:
            text = bytes(d[f"C{i}"] for i in range(count))
            while start < count and text[start] == 32:
                start += 1
            end = min(start + width, count)
            if end < count and text[end] != 32:
                space = text.rfind(b" ", start, end)
                if space >= start:
                    end = space
            nextpos = end
            while nextpos < count and text[nextpos] == 32:
                nextpos += 1
            d.update(START=start, LENGTH=end - start, NEXT=nextpos)
    elif topic == "rectangle-clipping":
        ok = (
            d["LEFT"] <= d["RIGHT"]
            and d["TOP"] <= d["BOTTOM"]
            and d["VIEW_LEFT"] <= d["VIEW_RIGHT"]
            and d["VIEW_TOP"] <= d["VIEW_BOTTOM"]
        )
        d.update(
            OUT_LEFT=0, OUT_TOP=0, OUT_RIGHT=0, OUT_BOTTOM=0, VISIBLE=0, VALID=int(ok)
        )
        if ok:
            left = max(d["LEFT"], d["VIEW_LEFT"])
            top = max(d["TOP"], d["VIEW_TOP"])
            right = min(d["RIGHT"], d["VIEW_RIGHT"])
            bottom = min(d["BOTTOM"], d["VIEW_BOTTOM"])
            if left < right and top < bottom:
                d.update(
                    OUT_LEFT=left,
                    OUT_TOP=top,
                    OUT_RIGHT=right,
                    OUT_BOTTOM=bottom,
                    VISIBLE=1,
                )
    elif topic == "swept-axis-collision":
        old, target, size, a, b = (
            d[k] for k in ["OLD_POSITION", "TARGET", "SIZE", "WALL_START", "WALL_END"]
        )
        ok = bool(
            size
            and a < b
            and old + size <= 255
            and target + size <= 255
            and (old >= b or old + size <= a)
        )
        d.update(POSITION=old, HIT=0, VALID=int(ok))
        if ok:
            position = target
            if target > old and old + size <= a <= target + size:
                position = a - size
                d["HIT"] = 1
            if target < old and target <= b <= old:
                position = b
                d["HIT"] = 1
            d["POSITION"] = position
    elif topic == "nearest-target":
        candidates = [
            (abs(d[f"PX{i}"] - d["ORIGIN_X"]) + abs(d[f"PY{i}"] - d["ORIGIN_Y"]), i)
            for i in range(4)
            if d["ACTIVE"] & (1 << i)
        ]
        d.update(SLOT=255, DISTANCE_LO=0, DISTANCE_HI=0, FOUND=0)
        if candidates:
            distance, slot = min(candidates)
            hi, lo = divmod(distance, 256)
            d.update(SLOT=slot, DISTANCE_LO=lo, DISTANCE_HI=hi, FOUND=1)
    elif topic == "eight-way-direction":
        x, y = d["TO_X"] - d["FROM_X"], d["TO_Y"] - d["FROM_Y"]
        a, b = abs(x), abs(y)
        direction = 0
        if a or b:
            if 2 * a <= b:
                direction = 1 if y < 0 else 5
            elif 2 * b <= a:
                direction = 7 if x < 0 else 3
            else:
                direction = {
                    (False, False): 4,
                    (True, False): 6,
                    (False, True): 2,
                    (True, True): 8,
                }[x < 0, y < 0]
        d.update(DIRECTION=direction, DX=a, DY=b)
    elif topic == "bitmap-mirror":
        d["MIRRORED"] = int(format(d["ROW"], "08b")[::-1], 2)
    elif topic == "bitmap-transpose":
        pixels = [[bool(d[f"C{y}"] & (128 >> x)) for x in range(8)] for y in range(8)]
        d.update(
            {f"R{y}": sum(128 >> x for x in range(8) if pixels[x][y]) for y in range(8)}
        )
    elif topic == "packed-colour-step":
        a = [d["COLOUR"] >> 5, (d["COLOUR"] >> 2) & 7, d["COLOUR"] & 3]
        b = [d["TARGET"] >> 5, (d["TARGET"] >> 2) & 7, d["TARGET"] & 3]
        r = [x + (y > x) - (y < x) for x, y in zip(a, b, strict=True)]
        d["COLOUR"] = 32 * r[0] + 4 * r[1] + r[2]
    elif topic == "bounded-delta-decoder":
        n = d["COUNT"]
        d.update(WRITTEN=0, VALID=int(n <= 8))
        if n <= 8:
            import itertools

            values = list(
                itertools.accumulate(
                    [d["BASE"]]
                    + [
                        d[f"Q{i}"] if d[f"Q{i}"] < 128 else d[f"Q{i}"] - 256
                        for i in range(n)
                    ]
                )
            )[1:]
            d.update({f"R{i}": v % 256 for i, v in enumerate(values)})
            d["WRITTEN"] = n
    elif topic == "input-debounce":
        d["CHANGED"] = 0
        if d["THRESHOLD"] == 0:
            d["RUN"] = 0
        else:
            candidate, run = (
                (d["RAW"], 1)
                if d["RAW"] != d["CANDIDATE"]
                else (d["CANDIDATE"], min(255, d["RUN"] + 1))
            )
            d.update(CANDIDATE=candidate, RUN=run)
            if run >= d["THRESHOLD"] and d["STABLE"] != candidate:
                d.update(STABLE=candidate, CHANGED=1)
    elif topic == "round-robin-service":
        start = d["NEXT"] % 8
        order = [(start + i) % 8 for i in range(8)]
        slot = next((i for i in order if d["READY"] & (1 << i)), None)
        d.update(NEXT=start, SLOT=255, FOUND=0)
        if slot is not None:
            d.update(SLOT=slot, FOUND=1, NEXT=(slot + 1) % 8)
    else:
        raise ValueError(topic)
    assert all(0 <= v < 256 for v in d.values()), (topic, d)
    return [d[k] for k in fields]


def cases(topic: str, custom: bool = False) -> list[list[int]]:
    fields = TOPICS[topic]["fields"]
    n = min(64, max(16, 1000 // len(fields)))
    rng = random.Random(1988 + list(TOPICS).index(topic))
    rows = []
    for i in range(n):
        d = {k: rng.randrange(256) for k in fields}
        if topic == "signed-byte-order":
            d.update(
                LEFT=[0, 1, 127, 128, 129, 254, 255, 64][i % 8],
                RIGHT=[0, 1, 127, 128, 129, 254, 255, 64][i // 8],
            )
        elif topic == "saturating-word-add":
            a = [0, 1, 255, 256, 32767, 32768, 65534, 65535][i % 8]
            b = [0, 1, 255, 256, 32767, 32768, 65534, 65535][i // 8]
            d.update(
                LEFT_LO=a % 256, LEFT_HI=a // 256, RIGHT_LO=b % 256, RIGHT_HI=b // 256
            )
        elif topic == "hexadecimal-format":
            d.update(VALUE=i * 4 + i % 4, LOWERCASE=i % 2)
        elif topic == "hexadecimal-parser":
            d.update(
                FIRST=[
                    47,
                    48,
                    57,
                    58,
                    64,
                    65,
                    70,
                    71,
                    96,
                    97,
                    102,
                    103,
                    0,
                    255,
                    66,
                    98,
                ][i % 16],
                SECOND=[48, 57, 65, 102][i // 16],
            )
        elif topic == "bounded-bit-writer":
            d.update(
                CURSOR=[0, 1, 7, 8, 24, 25, 31, 32, 33, 255][i % 10],
                COUNT=[0, 1, 4, 8, 9, 255][i // 10 % 6],
            )
        elif topic == "bitset-slot-allocation":
            d.update(
                USED=[0, 1, 3, 127, 128, 254, 255, 85][i % 8],
                MODE=i // 8 % 3,
                REQUEST=i % 10,
            )
        elif topic == "priority-event-queue":
            d.update(COUNT=i % 6, MODE=i // 6 % 3, NEW_PRIORITY=[0, 1, 128, 255][i % 4])
            d.update({f"P{j}": [200, 128, 128, 0][j] for j in range(4)})
            d.update({f"E{j}": 10 + j for j in range(4)})
        elif topic == "high-score-insertion":
            d.update(
                COUNT=i % 6,
                SCORE=[0, 1, 80, 100, 150, 200, 254, 255][i // 6 % 8],
                S0=200,
                S1=100,
                S2=100,
                S3=0,
            )
        elif topic == "dictionary-lookup":
            d.update(COUNT=i % 10, KEY=[0, 3, 7, 8, 255][i // 10 % 5])
            d.update({f"K{j}": j if j < 7 else 3 for j in range(8)})
        elif topic == "bounded-text-wrap":
            text = [
                b"HELLO WORLD TEST ",
                b"ABCDEFGHIJKLMNOP",
                b"   A  B C       ",
                b"                ",
            ][i % 4]
            d.update({f"C{j}": v for j, v in enumerate(text)})
            d.update(
                COUNT=[0, 1, 15, 16, 17, 255][i // 4 % 6],
                START=[0, 1, 3, 15, 16, 17][i // 2 % 6],
                WIDTH=[0, 1, 3, 5, 16, 17, 255][i % 7],
            )
            if i < 12:
                d.update(COUNT=16, START=0, WIDTH=[1, 3, 5, 7, 8, 16][i % 6])
        elif topic == "rectangle-clipping":
            d.update(
                LEFT=[0, 5, 10, 20][i % 4],
                TOP=5,
                RIGHT=[0, 5, 15, 255][i // 4 % 4],
                BOTTOM=[0, 5, 15, 255][i // 16 % 4],
                VIEW_LEFT=5,
                VIEW_TOP=5,
                VIEW_RIGHT=15,
                VIEW_BOTTOM=15,
            )
            if i == n - 1:
                d.update(VIEW_LEFT=16, VIEW_RIGHT=15)
        elif topic == "swept-axis-collision":
            d.update(
                OLD_POSITION=[0, 5, 10, 12, 20, 250, 255, 128][i % 8],
                TARGET=[0, 5, 9, 10, 12, 20, 250, 255][i // 8],
                SIZE=[0, 1, 2, 3][i % 4],
                WALL_START=10,
                WALL_END=12,
            )
        elif topic == "nearest-target":
            d.update(
                ACTIVE=i % 17,
                ORIGIN_X=[0, 128, 255][i // 17 % 3],
                ORIGIN_Y=[255, 0, 128][i // 17 % 3],
            )
            d.update({f"PX{j}": [0, 255, 128, 128][j] for j in range(4)})
            d.update({f"PY{j}": [0, 255, 128, 128][j] for j in range(4)})
        elif topic == "eight-way-direction":
            d.update(
                FROM_X=128,
                FROM_Y=128,
                TO_X=[0, 1, 64, 127, 128, 129, 192, 255][i % 8],
                TO_Y=[0, 1, 64, 127, 128, 129, 192, 255][i // 8],
            )
        elif topic == "bitmap-mirror":
            d.update(ROW=i * 4 + i % 4)
        elif topic == "bitmap-transpose":
            if i < 8:
                d.update({f"C{j}": 128 >> i if j == i else 0 for j in range(8)})
            elif i < 16:
                d.update({f"C{j}": 255 if j == i - 8 else 0 for j in range(8)})
        elif topic == "packed-colour-step":
            d.update(
                COLOUR=[0, 3, 28, 31, 224, 227, 252, 255][i % 8],
                TARGET=[0, 1, 32, 64, 128, 192, 254, 255][i // 8],
            )
        elif topic == "bounded-delta-decoder":
            d.update(COUNT=i % 11, BASE=[0, 1, 127, 128, 254, 255][i // 11 % 6])
            d.update({f"Q{j}": [0, 1, 127, 128, 255][(i + j) % 5] for j in range(8)})
        elif topic == "input-debounce":
            d.update(
                RAW=i % 3,
                CANDIDATE=i // 3 % 3,
                STABLE=i // 9 % 3,
                RUN=[0, 1, 2, 254, 255][i % 5],
                THRESHOLD=[0, 1, 2, 3, 255][i // 5 % 5],
            )
        elif topic == "round-robin-service":
            d.update(
                NEXT=[0, 1, 6, 7, 8, 127, 254, 255][i % 8],
                READY=[0, 1, 128, 129, 85, 170, 254, 255][i // 8],
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

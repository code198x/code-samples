"""Integer contracts and bounded native cases for ten game-building tools."""

from __future__ import annotations

import random

TOPICS = {
    "fractional-position": {
        "title": "Fractional Position Updates",
        "category": "physics",
        "fields": ["POS_LO", "POS_HI", "VEL_LO", "VEL_HI"],
    },
    "bounded-acceleration": {
        "title": "Bounded Signed Acceleration",
        "category": "physics",
        "fields": [
            "VEL_LO",
            "VEL_HI",
            "ACC_LO",
            "ACC_HI",
            "LIMIT_LO",
            "LIMIT_HI",
            "CLIPPED",
            "VALID",
        ],
    },
    "jump-windows": {
        "title": "Jump Buffering and Coyote Time",
        "category": "physics",
        "fields": ["JUMPED", "COYOTE", "BUFFER", "GROUNDED", "PRESSED"],
    },
    "one-way-platform": {
        "title": "Land on a One-way Platform",
        "category": "physics",
        "fields": [
            "LANDED",
            "SNAP",
            "ACTOR_X",
            "ACTOR_W",
            "PREV_BOTTOM",
            "NEW_BOTTOM",
            "PLATFORM_X",
            "PLATFORM_W",
            "PLATFORM_Y",
            "DROP",
        ],
    },
    "camera-deadzone": {
        "title": "Camera Dead Zones",
        "category": "physics",
        "fields": [
            "CAMERA",
            "PLAYER",
            "LEFT_EDGE",
            "RIGHT_EDGE",
            "SCROLL_LIMIT",
            "SHIFTED",
            "VALID",
        ],
    },
    "menu-navigation": {
        "title": "Wrap and Skip Menu Options",
        "category": "input",
        "fields": ["SELECTED", "OPTION_COUNT", "ENABLED", "DELTA", "MOVED", "VALID"],
    },
    "text-entry-buffer": {
        "title": "A Counted Text-entry Buffer",
        "category": "input",
        "fields": [
            "LENGTH",
            "STATUS",
            "KEY",
            "MODE",
            "BUF0",
            "BUF1",
            "BUF2",
            "BUF3",
            "BUF4",
            "BUF5",
            "BUF6",
            "BUF7",
        ],
    },
    "tile-properties": {
        "title": "Look Up Tile Properties",
        "category": "rendering",
        "fields": ["ATTRS", "MATCH", "VALID", "TILE_ID", "MASK"],
    },
    "bounded-rle": {
        "title": "Decode Bounded RLE Data",
        "category": "framework",
        "fields": [
            "WRITTEN",
            "ERROR",
            "INPUT_START",
            "INPUT_END",
            "OUTPUT_LIMIT",
            "BUF0",
            "BUF1",
            "BUF2",
            "BUF3",
            "BUF4",
            "BUF5",
            "BUF6",
            "BUF7",
        ],
    },
    "streaming-crc8": {
        "title": "A Streaming CRC-8",
        "category": "framework",
        "fields": ["CRC", "DATA"],
    },
}
PROPERTIES = [0, 1, 1, 2, 4, 1, 8, 0, 3, 6, 12, 9, 15, 2, 4, 8]
STREAM = [3, 65, 2, 66, 1, 67, 0, 88, 5, 68, 1, 69, 2]


def signed(value: int) -> int:
    return value if value < 32768 else value - 65536


def step(
    topic: str, state: list[int], custom: bool = False, wrong: bool = False
) -> list[int]:
    fields = TOPICS[topic]["fields"]
    d = dict(zip(fields, state, strict=True))
    if wrong:
        if topic == "fractional-position":
            d["POS_LO"] = 0
        elif topic == "bounded-acceleration":
            d["ACC_HI"] = 0
        elif topic == "jump-windows":
            d["PRESSED"] = 1
        elif topic == "camera-deadzone":
            d["PLAYER"] = (d["PLAYER"] - d["CAMERA"]) % 256
        elif topic == "menu-navigation":
            d["SELECTED"] = (d["SELECTED"] + d["DELTA"]) % 256
            d["MOVED"] = 1
            d["VALID"] = 1
            return [d[f] for f in fields]
        elif topic == "text-entry-buffer" and d["MODE"] == 1 and d["LENGTH"] == 0:
            d["LENGTH"] = 255
            d["STATUS"] = 1
            return [d[f] for f in fields]
        elif topic == "tile-properties":
            d["ATTRS"] = d["TILE_ID"]
            d["MATCH"] = int(bool(d["TILE_ID"] & d["MASK"]))
            d["VALID"] = 1
            return [d[f] for f in fields]
        elif topic == "streaming-crc8":
            d["CRC"] = 0
    if topic == "fractional-position":
        position = d["POS_LO"] + 256 * d["POS_HI"]
        velocity = signed(d["VEL_LO"] + 256 * d["VEL_HI"])
        position = (position + velocity) % 65536
        d["POS_LO"] = position % 256
        d["POS_HI"] = position // 256
    elif topic == "bounded-acceleration":
        d["CLIPPED"] = d["VALID"] = 0
        limit = d["LIMIT_LO"] + 256 * d["LIMIT_HI"]
        if limit <= 32767:
            d["VALID"] = 1
            velocity = signed(d["VEL_LO"] + 256 * d["VEL_HI"])
            acceleration = signed(d["ACC_LO"] + 256 * d["ACC_HI"])
            total = velocity + acceleration
            result = max(-limit, min(limit, total))
            d["CLIPPED"] = int(result != total)
            word = result % 65536
            d["VEL_LO"] = word % 256
            d["VEL_HI"] = word // 256
    elif topic == "jump-windows":
        d["JUMPED"] = 0
        d["COYOTE"] = max(0, d["COYOTE"] - 1)
        d["BUFFER"] = max(0, d["BUFFER"] - 1)
        if d["GROUNDED"]:
            d["COYOTE"] = 2 if custom else 4
        if d["PRESSED"]:
            d["BUFFER"] = 2 if custom else 4
        if d["COYOTE"] and d["BUFFER"]:
            d["JUMPED"] = 1
            d["COYOTE"] = d["BUFFER"] = 0
    elif topic == "one-way-platform":
        overlap = (
            d["ACTOR_X"] < d["PLATFORM_X"] + d["PLATFORM_W"]
            and d["PLATFORM_X"] < d["ACTOR_X"] + d["ACTOR_W"]
        )
        crossing = d["PREV_BOTTOM"] <= d["PLATFORM_Y"] <= d["NEW_BOTTOM"]
        d["LANDED"] = int(
            not d["DROP"]
            and bool(d["ACTOR_W"])
            and bool(d["PLATFORM_W"])
            and overlap
            and crossing
        )
        d["SNAP"] = d["PLATFORM_Y"] if d["LANDED"] else d["NEW_BOTTOM"]
        if wrong and d["NEW_BOTTOM"] != d["PLATFORM_Y"]:
            d["LANDED"] = 0
            d["SNAP"] = d["NEW_BOTTOM"]
    elif topic == "camera-deadzone":
        d["VALID"] = d["SHIFTED"] = 0
        if d["LEFT_EDGE"] <= d["RIGHT_EDGE"] and d["CAMERA"] <= d["SCROLL_LIMIT"]:
            d["VALID"] = 1
            old = d["CAMERA"]
            relative = d["PLAYER"] - old
            desired = (
                d["PLAYER"] - d["LEFT_EDGE"]
                if relative < d["LEFT_EDGE"]
                else d["PLAYER"] - d["RIGHT_EDGE"]
                if relative > d["RIGHT_EDGE"]
                else old
            )
            d["CAMERA"] = max(0, min(d["SCROLL_LIMIT"], desired))
            d["SHIFTED"] = int(d["CAMERA"] != old)
    elif topic == "menu-navigation":
        d["MOVED"] = d["VALID"] = 0
        n = d["OPTION_COUNT"]
        old = d["SELECTED"]
        if 1 <= n <= 8 and old < n and d["DELTA"] in (0, 1, 255):
            d["VALID"] = 1
            if d["DELTA"]:
                direction = 1 if d["DELTA"] == 1 else -1
                candidates = [(old + direction * i) % n for i in range(1, n + 1)]
                d["SELECTED"] = next(
                    (i for i in candidates if d["ENABLED"] & (1 << i)), old
                )
                d["MOVED"] = int(d["SELECTED"] != old)
    elif topic == "text-entry-buffer":
        cap = 4 if custom else 8
        d["STATUS"] = 0
        if d["MODE"] == 2:
            d["LENGTH"] = 0
            d["STATUS"] = 1
            for i in range(8):
                d[f"BUF{i}"] = 0
        elif d["LENGTH"] > cap or d["MODE"] not in (0, 1):
            d["STATUS"] = 3
        elif d["MODE"] == 1:
            if d["LENGTH"]:
                d["LENGTH"] -= 1
                d[f"BUF{d['LENGTH']}"] = 0
                d["STATUS"] = 1
        elif not 32 <= d["KEY"] <= 126:
            d["STATUS"] = 2
        elif d["LENGTH"] < cap:
            d[f"BUF{d['LENGTH']}"] = d["KEY"]
            d["LENGTH"] += 1
            d["STATUS"] = 1
    elif topic == "tile-properties":
        d["ATTRS"] = d["MATCH"] = d["VALID"] = 0
        if d["TILE_ID"] < len(PROPERTIES):
            d["ATTRS"] = PROPERTIES[d["TILE_ID"]]
            d["VALID"] = 1
            d["MATCH"] = int(bool(d["ATTRS"] & d["MASK"]))
    elif topic == "bounded-rle":
        d["WRITTEN"] = d["ERROR"] = 0
        start, end, limit = d["INPUT_START"], d["INPUT_END"], d["OUTPUT_LIMIT"]
        if not 0 <= start <= end <= len(STREAM) or limit > 8:
            d["ERROR"] = 1
        else:
            for offset in range(start, end, 2):
                if offset + 1 >= end:
                    d["ERROR"] = 2
                    break
                count, value = STREAM[offset : offset + 2]
                if not count:
                    d["ERROR"] = 3
                    break
                fit = min(count, limit - d["WRITTEN"])
                for i in range(fit):
                    d[f"BUF{d['WRITTEN'] + i}"] = value
                d["WRITTEN"] += fit
                if fit < count:
                    d["ERROR"] = 4
                    break
        if wrong:
            d["WRITTEN"] = d["OUTPUT_LIMIT"]
    elif topic == "streaming-crc8":
        poly = 0x31 if custom else 7
        value = (d["CRC"] ^ d["DATA"]) << 8
        for bit in range(15, 7, -1):
            if value & (1 << bit):
                value ^= (256 | poly) << (bit - 8)
        d["CRC"] = value
    else:
        raise ValueError(topic)
    return [d[f] for f in fields]


def cases(topic: str, custom: bool = False) -> list[list[int]]:
    rng = random.Random(1981 + list(TOPICS).index(topic))
    fields = TOPICS[topic]["fields"]
    rows = []
    for i in range(64):
        d = {f: rng.randrange(256) for f in fields}
        if topic == "fractional-position":
            pos = [0, 1, 127, 128, 255, 256, 65534, 65535][i % 8]
            vel = [-32768, -257, -256, -1, 0, 1, 256, 32767][i // 8] % 65536
            d.update(
                POS_LO=pos % 256, POS_HI=pos // 256, VEL_LO=vel % 256, VEL_HI=vel // 256
            )
        elif topic == "bounded-acceleration":
            vel = [-32768, -32767, -1, 0, 1, 255, 32766, 32767][i % 8] % 65536
            acc = [-32768, -512, -1, 0, 1, 512, 32766, 32767][i // 8] % 65536
            limit = [0, 1, 255, 256, 32767, 32768, 65535, 512][i // 8]
            d.update(
                VEL_LO=vel % 256,
                VEL_HI=vel // 256,
                ACC_LO=acc % 256,
                ACC_HI=acc // 256,
                LIMIT_LO=limit % 256,
                LIMIT_HI=limit // 256,
            )
        elif topic == "jump-windows":
            d.update(
                COYOTE=[0, 1, 2, 3, 4, 5, 254, 255][i % 8],
                BUFFER=[0, 1, 2, 3, 4, 5, 254, 255][i // 8],
                GROUNDED=int(i % 3 == 0),
                PRESSED=int(i % 5 == 0),
            )
        elif topic == "one-way-platform":
            d.update(
                ACTOR_X=20,
                ACTOR_W=16,
                PLATFORM_X=10,
                PLATFORM_W=64,
                PLATFORM_Y=100,
                DROP=0,
                PREV_BOTTOM=[0, 1, 99, 100, 101, 254, 255, 110][i % 8],
                NEW_BOTTOM=[0, 99, 100, 101, 110, 254, 255, 90][i // 8],
            )
            if i < 10:
                d.update(PREV_BOTTOM=90, NEW_BOTTOM=110)
                overrides = [
                    {},
                    {"PREV_BOTTOM": 100, "NEW_BOTTOM": 100},
                    {"PREV_BOTTOM": 110, "NEW_BOTTOM": 90},
                    {"PREV_BOTTOM": 101},
                    {"NEW_BOTTOM": 99},
                    {"DROP": 1},
                    {"ACTOR_W": 0},
                    {"PLATFORM_W": 0},
                    {"ACTOR_X": 74},
                    {
                        "ACTOR_X": 250,
                        "ACTOR_W": 20,
                        "PLATFORM_X": 250,
                        "PLATFORM_W": 20,
                    },
                ]
                d.update(overrides[i])
        elif topic == "camera-deadzone":
            d.update(
                CAMERA=[0, 1, 100, 155, 156, 255, 40, 80][i % 8],
                PLAYER=[0, 1, 39, 40, 80, 81, 254, 255][i // 8],
                LEFT_EDGE=40 if i % 13 else 81,
                RIGHT_EDGE=80,
                SCROLL_LIMIT=155,
            )
        elif topic == "menu-navigation":
            d.update(
                SELECTED=[0, 1, 2, 7, 8, 255, 0, 2][i % 8],
                OPTION_COUNT=[0, 1, 2, 3, 4, 8, 9, 255][i // 8],
                ENABLED=[0, 1, 5, 128, 255][i % 5],
                DELTA=[0, 1, 255, 2][i % 4],
            )
            if i < 8:
                d.update(
                    OPTION_COUNT=3,
                    SELECTED=2,
                    ENABLED=[0, 1, 5, 7, 255, 0, 2, 4][i],
                    DELTA=1 if i < 4 else 255,
                )
        elif topic == "text-entry-buffer":
            d.update(
                LENGTH=[0, 1, 4, 7, 8, 9, 254, 255][i % 8],
                KEY=[0, 31, 32, 65, 126, 127, 255, 90][i // 8],
                MODE=i % 4,
            )
            if i < 8:
                examples = [
                    (0, 1, 65),
                    (0, 0, 65),
                    (7, 0, 90),
                    (8, 0, 65),
                    (0, 0, 31),
                    (4, 2, 65),
                    (255, 2, 0),
                    (255, 0, 65),
                ]
                length, mode, key = examples[i]
                d.update(LENGTH=length, MODE=mode, KEY=key)
        elif topic == "tile-properties":
            d.update(
                TILE_ID=i if i < 17 else [255, 254, 128, 127, 17, 16, 15, 6][i % 8],
                MASK=[0, 1, 2, 4, 8, 255, 3, 128][i % 8],
            )
        elif topic == "bounded-rle":
            start = [0, 2, 6, 8, 10, 12, 13, 14][i % 8]
            end = [0, 2, 6, 8, 10, 12, 13, 14][i // 8]
            limit = [0, 1, 3, 5, 6, 7, 8, 9][i % 8]
            if i < 12:
                start, end, limit = [
                    (0, 6, 8),
                    (0, 6, 5),
                    (0, 6, 0),
                    (6, 8, 8),
                    (12, 13, 8),
                    (0, 13, 8),
                    (8, 12, 8),
                    (13, 13, 8),
                    (2, 6, 8),
                    (255, 255, 8),
                    (0, 6, 9),
                    (7, 8, 8),
                ][i]
            d.update(INPUT_START=start, INPUT_END=end, OUTPUT_LIMIT=limit)
            for j in range(8):
                d[f"BUF{j}"] = 90 + j
        elif topic == "streaming-crc8":
            d.update(
                CRC=[0, 1, 128, 255][i % 4],
                DATA=[0, 1, 49, 57, 127, 128, 254, 255][i // 8]
                if i < 64
                else rng.randrange(256),
            )
        rows.append([d[f] for f in fields])
    return rows


def trace(topic: str, custom: bool = False) -> list[dict[str, int]]:
    if topic == "fractional-position":
        return [
            {"POS_LO": 0, "POS_HI": 100, "VEL_LO": 128 if custom else 64, "VEL_HI": 0}
        ] + [{} for _ in range(3)]
    if topic == "bounded-acceleration":
        return [
            {
                "ACC_LO": 128,
                "ACC_HI": 255,
                "LIMIT_LO": 0,
                "LIMIT_HI": 1 if custom else 2,
            }
        ] + [{} for _ in range(3)]
    if topic == "jump-windows":
        return [{"PRESSED": 1}, {"PRESSED": 0}, {}, {"GROUNDED": 1}, {}]
    if topic == "one-way-platform":
        return [
            {
                "ACTOR_X": 20,
                "ACTOR_W": 16,
                "PREV_BOTTOM": 90,
                "NEW_BOTTOM": 110,
                "PLATFORM_X": 10,
                "PLATFORM_W": 64,
                "PLATFORM_Y": 100,
                "DROP": int(custom),
            }
        ]
    if topic == "camera-deadzone":
        return [
            {
                "CAMERA": 0,
                "PLAYER": 90,
                "LEFT_EDGE": 60 if custom else 40,
                "RIGHT_EDGE": 60 if custom else 80,
                "SCROLL_LIMIT": 155,
            },
            {"PLAYER": 100},
        ]
    if topic == "menu-navigation":
        return [
            {
                "SELECTED": 2,
                "OPTION_COUNT": 3,
                "ENABLED": 7 if custom else 5,
                "DELTA": 255 if custom else 1,
            }
        ]
    if topic == "text-entry-buffer":
        return (
            [
                {"MODE": 0, "KEY": 65},
                {"KEY": 66},
                {"MODE": 1},
                {},
                {},
                {"MODE": 0, "KEY": 67},
            ]
            if custom
            else [{"MODE": 0, "KEY": 65}, {"KEY": 66}, {"MODE": 1}, {}, {}]
        )
    if topic == "tile-properties":
        return [{"TILE_ID": 1, "MASK": 8 if custom else 1}, {"TILE_ID": 6}]
    if topic == "bounded-rle":
        return [{"INPUT_START": 0, "INPUT_END": 6, "OUTPUT_LIMIT": 5 if custom else 8}]
    if topic == "streaming-crc8":
        return [{"DATA": v} for v in b"123456789"]
    raise ValueError(topic)


def packet(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    fields = TOPICS[topic]["fields"]
    n = len(fields)
    out = [165, list(TOPICS).index(topic), int(custom)] + [0] * n
    for row in cases(topic, custom):
        out += step(topic, row, custom)
    state = [0] * n
    for changes in trace(topic, custom):
        for f, value in changes.items():
            state[fields.index(f)] = value
        state = step(topic, state, custom, wrong)
        out += state
    return out + [239]


def preview(topic: str, custom: bool = False, wrong: bool = False) -> list[int]:
    n = len(TOPICS[topic]["fields"])
    return (packet(topic, custom, wrong)[-1 - n : -1] + [0] * 8)[:8]

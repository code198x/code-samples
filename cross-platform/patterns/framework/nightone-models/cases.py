"""Independent set, coordinate, container and integer contracts."""

from __future__ import annotations

import random

TOPICS = {
    "collision-layer-filter": {
        "title": "Filter Collision Pairs by Layer",
        "category": "physics",
        "fields": [
            "PAIR_KIND",
            "GROUP_A",
            "MASK_A",
            "GROUP_B",
            "MASK_B",
            "SOLID_A",
            "SOLID_B",
        ],
        "trace": [
            {
                "GROUP_A": 1,
                "MASK_A": 2,
                "GROUP_B": 4,
                "MASK_B": 1,
                "SOLID_A": 1,
                "SOLID_B": 1,
            }
        ],
        "custom_trace": [
            {
                "GROUP_A": 1,
                "MASK_A": 2,
                "GROUP_B": 2,
                "MASK_B": 1,
                "SOLID_A": 1,
                "SOLID_B": 0,
            }
        ],
    },
    "grid-turn-buffer": {
        "title": "Buffer Turns Through a Grid",
        "category": "framework",
        "fields": [
            "CELL",
            "DIRECTION",
            "PENDING",
            "MOVED",
            "VALID",
            "REQUEST",
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
            {"CELL": 8, "DIRECTION": 2, "REQUEST": 3, "C4": 1},
            {"REQUEST": 0},
            {},
        ],
        "custom_trace": [
            {"CELL": 0, "DIRECTION": 2, "REQUEST": 3},
            {"REQUEST": 0},
            {"REQUEST": 4},
        ],
    },
    "push-block-transaction": {
        "title": "Push a Block Atomically",
        "category": "framework",
        "fields": [
            "CELL",
            "RESULT",
            "VALID",
            "REQUEST",
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
        "trace": [{"CELL": 4, "REQUEST": 2, "C5": 2}, {}, {}],
        "custom_trace": [{"CELL": 8, "REQUEST": 3, "C4": 2}, {"REQUEST": 2}],
    },
    "spatial-bucket": {
        "title": "Build Bounded Spatial Buckets",
        "category": "physics",
        "fields": [
            "BUCKET",
            "COUNT",
            "INSERTED",
            "FULL",
            "VALID",
            "MODE",
            "INPUT_X",
            "INPUT_Y",
            "ITEM",
            "C0",
            "C1",
            "C2",
            "C3",
            "S0",
            "S1",
            "S2",
            "S3",
            "S4",
            "S5",
            "S6",
            "S7",
            "S8",
            "S9",
            "S10",
            "S11",
            "S12",
            "S13",
            "S14",
            "S15",
        ],
        "trace": [
            {"MODE": 1, "INPUT_X": 2, "INPUT_Y": 3, "ITEM": 7},
            {"ITEM": 8},
            {"MODE": 2},
        ],
        "custom_trace": [
            {"MODE": 1, "INPUT_X": 15, "INPUT_Y": 15, "ITEM": 255},
            {"ITEM": 1},
            {"ITEM": 2},
            {"ITEM": 3},
            {"ITEM": 4},
        ],
    },
    "contact-pair-cache": {
        "title": "Remember Contact Pairs for a Step",
        "category": "physics",
        "fields": [
            "FIRST",
            "VALID",
            "MODE",
            "OBJECT_A",
            "OBJECT_B",
            "B0",
            "B1",
            "B2",
            "B3",
            "B4",
            "B5",
            "B6",
            "B7",
        ],
        "trace": [
            {"MODE": 1, "OBJECT_A": 0, "OBJECT_B": 3},
            {},
            {"OBJECT_A": 3, "OBJECT_B": 0},
        ],
        "custom_trace": [
            {"MODE": 1, "OBJECT_A": 2, "OBJECT_B": 7},
            {"MODE": 2},
            {"MODE": 0},
            {"MODE": 1},
        ],
    },
    "moving-platform-carry": {
        "title": "Carry a Supported Passenger",
        "category": "physics",
        "fields": [
            "POSITION",
            "CLAMPED",
            "VALID",
            "PASSENGER",
            "PLATFORM_OLD",
            "PLATFORM_NEW",
            "SUPPORTED",
            "MINIMUM",
            "MAXIMUM",
        ],
        "trace": [
            {
                "PASSENGER": 20,
                "PLATFORM_OLD": 5,
                "PLATFORM_NEW": 9,
                "SUPPORTED": 1,
                "MINIMUM": 0,
                "MAXIMUM": 100,
            }
        ],
        "custom_trace": [
            {
                "PASSENGER": 2,
                "PLATFORM_OLD": 10,
                "PLATFORM_NEW": 0,
                "SUPPORTED": 1,
                "MINIMUM": 0,
                "MAXIMUM": 100,
            }
        ],
    },
    "camera-shake": {
        "title": "Keep Camera Shake out of World State",
        "category": "rendering",
        "fields": [
            "OFFSET_X",
            "OFFSET_Y",
            "REMAINING",
            "AMPLITUDE",
            "VALID",
            "TRIGGER",
            "STRENGTH",
            "DURATION",
            "NOISE_X",
            "NOISE_Y",
        ],
        "trace": [
            {"TRIGGER": 1, "STRENGTH": 3, "DURATION": 3, "NOISE_X": 0, "NOISE_Y": 6},
            {"TRIGGER": 0, "NOISE_X": 6, "NOISE_Y": 0},
            {"NOISE_X": 1, "NOISE_Y": 5},
        ],
        "custom_trace": [
            {"TRIGGER": 1, "STRENGTH": 15, "DURATION": 1, "NOISE_X": 255, "NOISE_Y": 0},
            {"TRIGGER": 0},
        ],
    },
    "moving-solid-push": {
        "title": "Push an Actor with a Moving Solid",
        "category": "physics",
        "fields": [
            "POSITION",
            "PUSHED",
            "BLOCKED",
            "VALID",
            "ACTOR_POSITION",
            "ACTOR_SIZE",
            "SOLID_OLD",
            "SOLID_NEW",
            "SOLID_SIZE",
            "MINIMUM",
            "MAXIMUM",
        ],
        "trace": [
            {
                "ACTOR_POSITION": 10,
                "ACTOR_SIZE": 2,
                "SOLID_OLD": 0,
                "SOLID_NEW": 12,
                "SOLID_SIZE": 2,
                "MINIMUM": 0,
                "MAXIMUM": 30,
            }
        ],
        "custom_trace": [
            {
                "ACTOR_POSITION": 5,
                "ACTOR_SIZE": 2,
                "SOLID_OLD": 10,
                "SOLID_NEW": 0,
                "SOLID_SIZE": 2,
                "MINIMUM": 0,
                "MAXIMUM": 30,
            }
        ],
    },
    "viewport-world-transform": {
        "title": "Project World Points into a Viewport",
        "category": "rendering",
        "fields": [
            "SCREEN_X",
            "SCREEN_Y",
            "VISIBLE",
            "VALID",
            "WORLD_X_LO",
            "WORLD_X_HI",
            "WORLD_Y_LO",
            "WORLD_Y_HI",
            "CAMERA_X_LO",
            "CAMERA_X_HI",
            "CAMERA_Y_LO",
            "CAMERA_Y_HI",
            "WIDTH",
            "HEIGHT",
        ],
        "trace": [
            {
                "WORLD_X_LO": 5,
                "WORLD_X_HI": 1,
                "WORLD_Y_LO": 10,
                "WORLD_Y_HI": 1,
                "CAMERA_X_LO": 250,
                "CAMERA_X_HI": 0,
                "CAMERA_Y_LO": 0,
                "CAMERA_Y_HI": 1,
                "WIDTH": 32,
                "HEIGHT": 24,
            }
        ],
        "custom_trace": [
            {
                "WORLD_X_LO": 255,
                "WORLD_X_HI": 255,
                "WORLD_Y_LO": 255,
                "WORLD_Y_HI": 255,
                "CAMERA_X_LO": 254,
                "CAMERA_X_HI": 255,
                "CAMERA_Y_LO": 254,
                "CAMERA_Y_HI": 255,
                "WIDTH": 2,
                "HEIGHT": 2,
            }
        ],
    },
    "surface-response": {
        "title": "Reflect a Surface-normal Speed with Restitution",
        "category": "physics",
        "fields": [
            "NORMAL_OUT",
            "DIRECTION_OUT",
            "TANGENT_OUT",
            "VALID",
            "NORMAL_IN",
            "DIRECTION_IN",
            "TANGENT_IN",
            "RESTITUTION",
        ],
        "trace": [
            {"NORMAL_IN": 11, "DIRECTION_IN": 1, "TANGENT_IN": 254, "RESTITUTION": 3}
        ],
        "custom_trace": [
            {"NORMAL_IN": 255, "DIRECTION_IN": 0, "TANGENT_IN": 128, "RESTITUTION": 4}
        ],
    },
}


def step(
    topic: str, row: list[int], custom: bool = False, wrong: bool = False
) -> list[int]:
    fields = TOPICS[topic]["fields"]
    d = dict(zip(fields, row, strict=True))
    if wrong:
        overrides = {
            "collision-layer-filter": ("MASK_A", 255),
            "grid-turn-buffer": ("PENDING", 0),
            "push-block-transaction": ("C6", 1),
            "spatial-bucket": ("MODE", 0),
            "contact-pair-cache": ("B0", 0),
            "moving-platform-carry": ("PLATFORM_OLD", d.get("PLATFORM_NEW", 0)),
            "camera-shake": ("REMAINING", 0),
            "moving-solid-push": ("SOLID_OLD", d.get("SOLID_NEW", 0)),
            "viewport-world-transform": ("WORLD_X_HI", 0),
            "surface-response": ("RESTITUTION", 4),
        }
        key, value = overrides[topic]
        d[key] = value
    if topic == "collision-layer-filter":
        ga = {i for i in range(8) if d["GROUP_A"] & (1 << i)}
        gb = {i for i in range(8) if d["GROUP_B"] & (1 << i)}
        ma = {i for i in range(8) if d["MASK_A"] & (1 << i)}
        mb = {i for i in range(8) if d["MASK_B"] & (1 << i)}
        d["PAIR_KIND"] = (
            0
            if ga.isdisjoint(mb) or gb.isdisjoint(ma)
            else 2
            if d["SOLID_A"] and d["SOLID_B"]
            else 1
        )
    elif topic == "grid-turn-buffer":
        cell = d["CELL"]
        ok = (
            cell < 16
            and all(d[k] <= 4 for k in ["DIRECTION", "PENDING", "REQUEST"])
            and (cell >= 16 or d[f"C{cell}"] == 0)
        )
        d.update(MOVED=0, VALID=int(ok))
        if ok:
            if d["REQUEST"]:
                d["PENDING"] = d["REQUEST"]
            x, y = cell % 4, cell // 4
            for direction, buffered in [(d["PENDING"], True), (d["DIRECTION"], False)]:
                if not direction:
                    continue
                dx, dy = {1: (-1, 0), 2: (1, 0), 3: (0, -1), 4: (0, 1)}[direction]
                nx, ny = x + dx, y + dy
                if 0 <= nx < 4 and 0 <= ny < 4 and d[f"C{ny * 4 + nx}"] == 0:
                    d.update(CELL=ny * 4 + nx, DIRECTION=direction, MOVED=1)
                    if buffered:
                        d["PENDING"] = 0
                    break
    elif topic == "push-block-transaction":
        cell, request = d["CELL"], d["REQUEST"]
        ok = cell < 16 and 1 <= request <= 4 and (cell >= 16 or d[f"C{cell}"] == 0)
        d.update(RESULT=0, VALID=int(ok))
        if ok:
            x, y = cell % 4, cell // 4
            dx, dy = {1: (-1, 0), 2: (1, 0), 3: (0, -1), 4: (0, 1)}[request]
            nx, ny = x + dx, y + dy
            if 0 <= nx < 4 and 0 <= ny < 4:
                target = ny * 4 + nx
                tile = d[f"C{target}"]
                if tile == 0:
                    d.update(CELL=target, RESULT=1)
                elif tile == 2:
                    bx, by = nx + dx, ny + dy
                    if 0 <= bx < 4 and 0 <= by < 4 and d[f"C{by * 4 + bx}"] == 0:
                        d[f"C{target}"] = 0
                        d[f"C{by * 4 + bx}"] = 2
                        d.update(CELL=target, RESULT=2)
    elif topic == "spatial-bucket":
        mode = d["MODE"]
        d.update(BUCKET=255, COUNT=0, INSERTED=0, FULL=0, VALID=0)
        if mode == 0:
            d.update({f"C{i}": 0 for i in range(4)})
            d.update({f"S{i}": 0 for i in range(16)})
            d["VALID"] = 1
        elif mode in [1, 2] and d["INPUT_X"] < 16 and d["INPUT_Y"] < 16:
            bucket = (d["INPUT_Y"] // 8) * 2 + d["INPUT_X"] // 8
            count = d[f"C{bucket}"]
            if count <= 4:
                d.update(BUCKET=bucket, COUNT=count, VALID=1)
                if mode == 1 and count < 4:
                    d[f"S{bucket * 4 + count}"] = d["ITEM"]
                    count += 1
                    d[f"C{bucket}"] = count
                    d.update(COUNT=count, INSERTED=1)
                d["FULL"] = int(count == 4)
    elif topic == "contact-pair-cache":
        mode, a, b = d["MODE"], d["OBJECT_A"], d["OBJECT_B"]
        d.update(FIRST=0, VALID=0)
        if mode == 0:
            d.update({f"B{i}": 0 for i in range(8)})
            d["VALID"] = 1
        elif mode in [1, 2] and a < 8 and b < 8 and a != b:
            low, high = sorted([a, b])
            seen = {
                (i, j)
                for i in range(8)
                for j in range(i + 1, 8)
                if d[f"B{i}"] & (1 << j)
            }
            d.update(FIRST=int((low, high) not in seen), VALID=1)
            if mode == 1:
                d[f"B{low}"] |= 1 << high
    elif topic == "moving-platform-carry":
        passenger = d["PASSENGER"]
        ok = d["MINIMUM"] <= passenger <= d["MAXIMUM"]
        d.update(POSITION=passenger, CLAMPED=0, VALID=int(ok))
        if ok and d["SUPPORTED"]:
            wanted = passenger + d["PLATFORM_NEW"] - d["PLATFORM_OLD"]
            position = max(d["MINIMUM"], min(d["MAXIMUM"], wanted))
            d.update(POSITION=position, CLAMPED=int(position != wanted))
    elif topic == "camera-shake":
        ok = d["STRENGTH"] <= 15 and (d["TRIGGER"] or d["AMPLITUDE"] <= 15)
        d.update(OFFSET_X=0, OFFSET_Y=0, VALID=int(bool(ok)))
        if ok:
            if d["TRIGGER"]:
                d.update(AMPLITUDE=d["STRENGTH"], REMAINING=d["DURATION"])
            if d["REMAINING"]:
                d["REMAINING"] -= 1
                span = 2 * d["AMPLITUDE"] + 1
                d["OFFSET_X"] = (d["NOISE_X"] % span - d["AMPLITUDE"]) % 256
                d["OFFSET_Y"] = (d["NOISE_Y"] % span - d["AMPLITUDE"]) % 256
    elif topic == "moving-solid-push":
        p, size, old, new, solid = (
            d[k]
            for k in [
                "ACTOR_POSITION",
                "ACTOR_SIZE",
                "SOLID_OLD",
                "SOLID_NEW",
                "SOLID_SIZE",
            ]
        )
        lo, hi = d["MINIMUM"], d["MAXIMUM"]
        ok = bool(
            size
            and solid
            and lo <= p <= hi
            and p + size <= 255
            and old + solid <= 255
            and new + solid <= 255
            and (old >= p + size or old + solid <= p)
        )
        d.update(POSITION=p, PUSHED=0, BLOCKED=0, VALID=int(ok))
        if ok:
            wanted = None
            if new > old and old + solid <= p < new + solid:
                wanted = new + solid
            elif new < old and new < p + size <= old:
                wanted = new - size
            if wanted is not None:
                if wanted < lo or wanted > hi or wanted + size > 255:
                    d["BLOCKED"] = 1
                else:
                    d.update(POSITION=wanted, PUSHED=1)
    elif topic == "viewport-world-transform":
        wx = d["WORLD_X_LO"] + 256 * d["WORLD_X_HI"]
        wy = d["WORLD_Y_LO"] + 256 * d["WORLD_Y_HI"]
        cx = d["CAMERA_X_LO"] + 256 * d["CAMERA_X_HI"]
        cy = d["CAMERA_Y_LO"] + 256 * d["CAMERA_Y_HI"]
        ok = bool(d["WIDTH"] and d["HEIGHT"])
        d.update(SCREEN_X=0, SCREEN_Y=0, VISIBLE=0, VALID=int(ok))
        if ok and 0 <= wx - cx < d["WIDTH"] and 0 <= wy - cy < d["HEIGHT"]:
            d.update(SCREEN_X=wx - cx, SCREEN_Y=wy - cy, VISIBLE=1)
    elif topic == "surface-response":
        ok = d["DIRECTION_IN"] <= 1 and d["RESTITUTION"] <= 4
        d.update(NORMAL_OUT=0, DIRECTION_OUT=0, TANGENT_OUT=0, VALID=int(ok))
        if ok:
            d.update(
                NORMAL_OUT=d["NORMAL_IN"] * d["RESTITUTION"] // 4,
                DIRECTION_OUT=1 - d["DIRECTION_IN"],
                TANGENT_OUT=d["TANGENT_IN"],
            )
    else:
        raise ValueError(topic)
    assert all(0 <= v < 256 for v in d.values()), (topic, d)
    return [d[k] for k in fields]


def cases(topic: str, custom: bool = False) -> list[list[int]]:
    fields = TOPICS[topic]["fields"]
    n = min(64, max(16, 1000 // len(fields)))
    rng = random.Random(1985 + list(TOPICS).index(topic))
    rows = []
    for i in range(n):
        d = {k: rng.randrange(256) for k in fields}
        if topic == "collision-layer-filter":
            d.update(
                GROUP_A=[0, 1, 2, 3, 128, 255, 85, 170][i % 8],
                GROUP_B=[1, 2, 3, 128, 255, 0, 170, 85][i // 8],
                MASK_A=[0, 1, 2, 3, 128, 255, 85, 170][i // 8],
                MASK_B=[255, 128, 3, 2, 1, 0, 170, 85][i % 8],
                SOLID_A=i % 2,
                SOLID_B=i // 2 % 2,
            )
        elif topic == "grid-turn-buffer":
            d.update(
                CELL=i % 18, DIRECTION=i // 9 % 6, PENDING=i // 3 % 6, REQUEST=i % 6
            )
            d.update({f"C{j}": int((i + j) % 5 == 0) for j in range(16)})
            if i < 16:
                d.update(
                    CELL=i, DIRECTION=i % 4 + 1, PENDING=0, REQUEST=(i + 1) % 4 + 1
                )
            if d["CELL"] < 16 and i % 7:
                d[f"C{d['CELL']}"] = 0
        elif topic == "push-block-transaction":
            d.update(CELL=i % 18, REQUEST=i // 5 % 6)
            d.update({f"C{j}": [0, 0, 0, 1, 2][(i + j) % 5] for j in range(16)})
            if i < 16:
                d.update(CELL=i, REQUEST=i % 4 + 1)
            if d["CELL"] < 16 and i % 7:
                d[f"C{d['CELL']}"] = 0
            if i in [16, 17, 18]:
                d.update(CELL=4, REQUEST=2, **{f"C{j}": 0 for j in range(16)})
                d.update(C5=2, C6=[0, 1, 2][i - 16])
        elif topic == "spatial-bucket":
            d.update(
                MODE=i % 4,
                INPUT_X=[0, 7, 8, 15, 16, 255][i % 6],
                INPUT_Y=[0, 7, 8, 15, 16, 255][i // 6 % 6],
            )
            d.update({f"C{j}": [0, 1, 3, 4, 5, 255][i % 6] for j in range(4)})
            if i < 6:
                d.update(MODE=1, INPUT_X=1, INPUT_Y=1, C0=i)
        elif topic == "contact-pair-cache":
            d.update(MODE=i // 10 % 4, OBJECT_A=i % 10, OBJECT_B=i // 3 % 10)
        elif topic == "moving-platform-carry":
            d.update(
                PASSENGER=[0, 1, 50, 100, 254, 255, 10, 128][i % 8],
                PLATFORM_OLD=[0, 255, 0, 128, 255, 127, 100, 0][i // 8],
                PLATFORM_NEW=[255, 0, 128, 0, 127, 255, 100, 0][i // 8],
                SUPPORTED=i % 2,
                MINIMUM=[0, 10][i // 4 % 2],
                MAXIMUM=[100, 255][i // 2 % 2],
            )
        elif topic == "camera-shake":
            d.update(
                REMAINING=[0, 1, 2, 255][i % 4],
                AMPLITUDE=[0, 1, 15, 16, 255][i // 4 % 5],
                TRIGGER=i % 2,
                STRENGTH=[0, 1, 3, 15, 16, 255][i // 8 % 6],
                DURATION=[0, 1, 3, 255][i % 4],
                NOISE_X=[0, 1, 127, 255][i // 4 % 4],
                NOISE_Y=[255, 127, 1, 0][i // 4 % 4],
            )
        elif topic == "moving-solid-push":
            d.update(
                ACTOR_POSITION=[0, 5, 10, 12, 20, 250, 254, 255][i % 8],
                ACTOR_SIZE=[0, 1, 2, 3][i % 4],
                SOLID_OLD=[0, 20, 8, 12][i // 8 % 4],
                SOLID_NEW=[20, 0, 12, 8][i // 8 % 4],
                SOLID_SIZE=2,
                MINIMUM=0,
                MAXIMUM=[20, 255][i // 4 % 2],
            )
            if i in [0, 1, 2, 3]:
                d.update(
                    ACTOR_POSITION=10,
                    ACTOR_SIZE=2,
                    SOLID_OLD=0,
                    SOLID_NEW=[8, 9, 12, 254][i],
                    SOLID_SIZE=2,
                    MINIMUM=0,
                    MAXIMUM=30,
                )
        elif topic == "viewport-world-transform":
            world = [0, 1, 255, 256, 257, 65534, 65535, 128][i % 8]
            camera = [0, 1, 250, 255, 256, 65534, 65535, 128][i // 8]
            d.update(
                WORLD_X_LO=world % 256,
                WORLD_X_HI=world // 256,
                WORLD_Y_LO=world % 256,
                WORLD_Y_HI=world // 256,
                CAMERA_X_LO=camera % 256,
                CAMERA_X_HI=camera // 256,
                CAMERA_Y_LO=camera % 256,
                CAMERA_Y_HI=camera // 256,
                WIDTH=[0, 1, 2, 32, 255][i % 5],
                HEIGHT=[255, 32, 2, 1, 0][i // 5 % 5],
            )
        elif topic == "surface-response":
            d.update(
                NORMAL_IN=[0, 1, 3, 4, 127, 128, 254, 255][i % 8],
                DIRECTION_IN=i // 8 % 3,
                TANGENT_IN=[0, 127, 128, 255][i % 4],
                RESTITUTION=i // 8 % 8,
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

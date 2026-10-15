"""Check the runnable AABB reference against independently occupied pixels."""

import argparse
import hashlib
import importlib.util
import itertools
import json
import random
import sys
from pathlib import Path
from types import ModuleType

ROOT = Path(__file__).resolve().parents[1]
Box = tuple[int, int, int, int]


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def pixels(box: Box) -> set[tuple[int, int]]:
    x, y, width, height = box
    return {(px, py) for px in range(x, x + width) for py in range(y, y + height)}


def load(path: Path) -> ModuleType:
    spec = importlib.util.spec_from_file_location("aabb_reference", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def scene_check(module: ModuleType, boxes: list[Box]) -> int:
    occupied = [pixels(box) for box in boxes]
    expected = {
        (a, b)
        for a, b in itertools.combinations(range(len(boxes)), 2)
        if occupied[a] & occupied[b]
    }
    candidates = module.candidate_pairs(boxes)
    require(len(candidates) == len(set(candidates)), "Duplicate candidate pair")
    require(
        all(0 <= a < b < len(boxes) for a, b in candidates), "Invalid object identity"
    )
    require(expected <= set(candidates), "Broad phase missed an overlapping pair")
    require(
        set(module.collisions(boxes)) == expected,
        "Collision set differs from occupied pixels",
    )
    return len(candidates)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    module = load(ROOT / "aabb.py")
    boxes = list(
        itertools.product(range(-2, 3), range(-2, 3), range(-1, 3), range(-1, 3))
    )
    occupied = [pixels(box) for box in boxes]
    pairs = 0
    for a, b in itertools.product(range(len(boxes)), repeat=2):
        require(
            module.check_collision(boxes[a], boxes[b])
            == bool(occupied[a] & occupied[b]),
            "Narrow phase differs from occupied pixels",
        )
        pairs += 1
    # Target-width boundaries: Python's integer reference must not wrap at 255.
    wide = [
        ((250, 0, 16, 16), (255, 0, 16, 16), True),
        ((2**80, 0, 2, 1), (2**80 + 1, 0, 2, 1), True),
        ((0, 0, 2, 2), (2, 0, 2, 2), False),
        ((0, 0, 2, 2), (0, 2, 2, 2), False),
    ]
    for a, b, expected in wide:
        require(
            module.check_collision(a, b) is expected, "Integer-width/edge regression"
        )
    neighbour_checks = 0
    for row in range(8):
        for col in range(8):
            # Independent geometric cell-pair enumeration, no copied direction list.
            expected = {
                r * 8 + c + 1
                for r in range(8)
                for c in range(8)
                if max(abs(r - row), abs(c - col)) == 1 and r * 8 + c > row * 8 + col
            }
            actual = module.neighbour_indices(col, row)
            require(
                len(actual) == len(set(actual)) and set(actual) == expected,
                "Neighbour coverage or grid-edge wrapping differs",
            )
            require(
                module.bucket_index((col * 32, row * 24, 32, 24)) == row * 8 + col + 1,
                "Maximum-size box assigned to wrong cell",
            )
            neighbour_checks += 1
    invalid = [
        (0, 0, 0, 1),
        (0, 0, 1, -1),
        (0, 0, 33, 1),
        (0, 0, 1, 25),
        (-1, 0, 1, 1),
        (0, -1, 1, 1),
        (255, 0, 2, 1),
        (0, 191, 1, 2),
    ]
    for box in invalid:
        require(
            module.bucket_index(box) == 0, "Unsupported box accepted by bucket index"
        )
        try:
            module.candidate_pairs([(0, 0, 1, 1), box])
        except ValueError:
            pass
        else:
            raise ValueError("Unsupported box silently entered candidate generation")
    for bad in [(0.5, 0, 1, 1), (True, 0, 1, 1), (0, 0, 1)]:
        try:
            module.bucket_index(bad)
        except TypeError:
            pass
        else:
            raise ValueError("Non-integer/malformed input accepted")
    rng = random.Random(120)
    scenes = [
        [(31, 24, 2, 2), (32, 23, 2, 2)],
        [(0, 0, 32, 24)] * 16,
        [(col * 32, row * 24, 32, 24) for row in range(8) for col in range(8)],
        [],
    ]
    # Place small boxes on both sides of every internal grid intersection.
    for x in range(32, 256, 32):
        for y in range(24, 192, 24):
            scenes.append([(x + dx, y + dy, 2, 2) for dx in [-1, 0] for dy in [-1, 0]])
    for _ in range(100):
        scene = []
        for _ in range(32):
            width, height = rng.randint(1, 32), rng.randint(1, 24)
            scene.append(
                (
                    rng.randint(0, 256 - width),
                    rng.randint(0, 192 - height),
                    width,
                    height,
                )
            )
        scenes.append(scene)
    scenes.extend([[(0, 0, 2, 2), (100, 100, 2, 2)], [(31, 24, 2, 2), (32, 23, 2, 2)]])
    candidate_count = sum(scene_check(module, scene) for scene in scenes)
    require(
        module.collisions(scenes[-2]) == []
        and module.collisions(scenes[-1]) == [(0, 1)],
        "Rebuilding after movement did not change collision result",
    )
    negative = []
    source = (ROOT / "aabb.py").read_text()
    mutations = [
        ("missing-bottom-left", "range(-1, 2)", "range(0, 2)", "broad"),
        ("eight-bit-wrap", "ax + aw <= bx", "(ax + aw) % 256 <= bx", "narrow"),
    ]
    for name, old, new, kind in mutations:
        require(source.count(old) == 1, "Mutation anchor must be unique")
        path = out / f"{name}.py"
        path.write_text(source.replace(old, new))
        mutant = load(path)
        if kind == "broad":
            try:
                scene_check(mutant, scenes[0])
            except ValueError as error:
                require(
                    str(error) == "Broad phase missed an overlapping pair",
                    f"Mutation failed for unrelated reason: {error}",
                )
            else:
                raise ValueError("Missing-diagonal mutation accepted")
        else:
            require(
                mutant.check_collision(*wide[0][:2]) is not wide[0][2],
                "Eight-bit-wrap mutation accepted",
            )
        negative.append({"mutation": name, "rejected": True})
    require(
        pairs == 160000 and neighbour_checks == 64 and candidate_count > 0,
        "Verification did not cover its declared space",
    )
    report = {
        "status": "passed",
        "target": "Python integer reference; host-only execution",
        "python_version": sys.version.split()[0],
        "sources_sha256": {
            p.name: hashlib.sha256(p.read_bytes()).hexdigest()
            for p in [ROOT / "aabb.py", Path(__file__)]
        },
        "narrow_phase_ordered_pairs": pairs,
        "small_box_count": len(boxes),
        "integer_width_and_edge_cases": len(wide),
        "all_grid_cells_checked": neighbour_checks,
        "unsupported_integer_boxes_rejected": len(invalid),
        "scenes_checked": len(scenes),
        "candidate_pairs_observed": candidate_count,
        "negative_controls": negative,
        "limits": "Bounded input enumeration and generated scenes, not an exhaustive proof of all "
        "scenes. No retro machine execution, coordinate overflow emulation or timing claim.",
    }
    (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()

"""Integer reference for the Code198x cross-platform AABB pattern (MIT)."""

from itertools import combinations

Box = tuple[int, int, int, int]  # x, y, width, height
Pair = tuple[int, int]  # zero-based indices in the supplied object list


def require_integers(box: Box) -> None:
    if len(box) != 4 or any(type(value) is not int for value in box):
        raise TypeError("A box needs four integers: x, y, width, height")


def check_collision(a: Box, b: Box) -> bool:
    """Half-open rectangles; non-positive dimensions are empty."""
    require_integers(a)
    require_integers(b)
    ax, ay, aw, ah = a
    bx, by, bw, bh = b
    if aw <= 0 or ah <= 0 or bw <= 0 or bh <= 0:
        return False
    if ax >= bx + bw or ax + aw <= bx:
        return False
    return not (ay >= by + bh or ay + ah <= by)


def bucket_index(box: Box) -> int:
    """One-based cell 1..64, or 0 for an unsupported integer box."""
    require_integers(box)
    x, y, width, height = box
    if width <= 0 or height <= 0 or width > 32 or height > 24:
        return 0
    if x < 0 or y < 0 or x + width > 256 or y + height > 192:
        return 0
    return (y // 24) * 8 + x // 32 + 1


def neighbour_indices(col: int, row: int) -> list[int]:
    """One-based right/bottom-left/bottom/bottom-right cells, without wrapping."""
    if (
        type(col) is not int
        or type(row) is not int
        or not (0 <= col < 8 and 0 <= row < 8)
    ):
        raise ValueError("Cell coordinates must be integers in 0..7")
    cells = []
    for dy in range(2):
        for dx in range(-1, 2):
            if dy == 1 or dx == 1:
                next_col, next_row = col + dx, row + dy
                if 0 <= next_col < 8 and 0 <= next_row < 8:
                    cells.append(next_row * 8 + next_col + 1)
    return cells


def candidate_pairs(boxes: list[Box]) -> list[Pair]:
    """Rebuild from current positions; reject unsupported inputs as a whole."""
    buckets: list[list[int]] = [[] for _ in range(64)]
    for index, box in enumerate(boxes):
        cell = bucket_index(box)
        if cell == 0:
            raise ValueError(f"Object {index} is outside the bucket contract")
        buckets[cell - 1].append(index)
    pairs = []
    for cell, objects in enumerate(buckets):
        pairs.extend(combinations(objects, 2))
        for neighbour in neighbour_indices(cell % 8, cell // 8):
            for a in objects:
                for b in buckets[neighbour - 1]:
                    pairs.append((min(a, b), max(a, b)))
    return pairs


def collisions(boxes: list[Box]) -> list[Pair]:
    return [
        pair
        for pair in candidate_pairs(boxes)
        if check_collision(boxes[pair[0]], boxes[pair[1]])
    ]


if __name__ == "__main__":
    scene = [(31, 24, 2, 2), (32, 23, 2, 2), (224, 168, 32, 24)]
    print("Colliding object indices:", collisions(scene))

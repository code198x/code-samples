"""Independent set model for AMOS-owned slots and full guarded snapshots."""
import struct

CAPACITIES = (1, 4, 8)
RECORD_BYTES = 248
MARKER = bytes([26, 43, 60, 77])
def cases() -> list[tuple[int, int, int]]:
    result = []
    for capacity in CAPACITIES:
        invalid = (-1, capacity, 8, 255, 65535, 2147483647)
        for mask in range(256):
            result.append((capacity, mask, invalid[mask % len(invalid)]))
    return result
def record(capacity: int, mask: int, bad_index: int, broken: bool = False) -> bytes:
    live = {i for i in range(capacity) if mask & (1 << i)}
    def flags() -> bytes:
        return struct.pack(">9i", *([int(i in live) if i < capacity else 77 for i in range(8)] + [99]))
    initial = struct.pack(">9i", *([0 if i < capacity else 77 for i in range(8)] + [99]))
    free = sorted(set(range(capacity)) - live)
    chosen = free[0] if free else capacity
    allocated = int(bool(free))
    if allocated:
        live.add(chosen)
    acquired = flags()
    release_ok = int(allocated and not broken)
    if release_ok:
        live.remove(chosen)
    released = flags()
    repeat_ok = int(chosen in live)
    if repeat_ok:
        live.remove(chosen)
    repeated = flags()
    # Every supplied bad index lies outside the configured extent.
    result = struct.pack(">12H", capacity, mask, chosen, allocated, 0,
                         allocated if broken else release_ok, 0 if (broken or release_ok) else 2,
                         repeat_ok, 0 if repeat_ok else 2, 0, 2, 1)
    return result + struct.pack(">i", bad_index) + initial + acquired + released + repeated + flags() + struct.pack(">9i", *([60] * 9)) + MARKER
def packet(broken: bool = False) -> bytes:
    return b"".join(record(c, m, bad, broken) for c, m, bad in cases()) + MARKER

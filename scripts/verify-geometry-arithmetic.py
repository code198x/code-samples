"""Exhaust the accepted nonzero ellipse radii to bound native error arithmetic.

This host-side numerical check is not machine execution. Native observations
separately cover four renderers and boundary workloads. Products in the implicit
reference equation use Python integers; the assembly uses incremental int32.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path


def verify() -> dict[str, int | list[int]]:
    peak = steps = 0
    peak_pair = [0, 0]
    for a in range(1, 256):
        aa = a * a
        for b in range(1, 256):
            bb = b * b
            x, y = -a, 0
            while x <= 0:
                previous_peak = peak
                dx = bb * (2 * x + 1)
                dy = aa * (2 * y + 1)
                error = bb * (x + 1) ** 2 + aa * (y + 1) ** 2 - aa * bb
                doubled = 2 * error
                peak = max(
                    peak, abs(dx), abs(dy), abs(error), abs(doubled), 2 * aa, 2 * bb
                )
                step_x = doubled >= dx
                step_y = doubled <= dy
                if not (step_x or step_y):
                    raise AssertionError("Non-progressing accepted ellipse")
                if step_x:
                    x += 1
                    peak = max(
                        peak, abs(bb * (x + 1) ** 2 + aa * (y + 1) ** 2 - aa * bb)
                    )
                if step_y:
                    y += 1
                if not (-a <= x <= 1 and 0 <= y <= b):
                    raise AssertionError("Coordinate offset exceeds radius")
                peak = max(peak, abs(bb * (x + 1) ** 2 + aa * (y + 1) ** 2 - aa * bb))
                if peak > previous_peak:
                    peak_pair = [a, b]
                steps += 1
    if not 0 < peak < 2**31:
        raise AssertionError("Signed 32-bit error overflow")
    return {
        "nonzero_radius_pairs": 255 * 255,
        "iterations": steps,
        "maximum_absolute_native_error_value": peak,
        "signed_bits": 32,
        "maximum_pair": peak_pair,
    }


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", type=Path)
    a = p.parse_args()
    r = verify()
    if a.output:
        a.output.write_text(json.dumps(r, indent=2) + "\n")
    print(r)

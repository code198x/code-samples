# AABB collision reference

Run the corrected [cross-platform AABB pattern](https://code198x.com/patterns/cross-platform/physics/aabb-collision/)
with Python integers. This is a maintained reference implementation of the
Code198x pseudocode, not a port from a third-party source project. Sample code
is MIT; the website baseline identity is in `verification/baseline.json`.

From this directory, using Python 3.13+ with no packages installed:

```sh
python3 aabb.py
python3 verification/verify.py --output /tmp/aabb-reference
```

The complete caller prints `Colliding object indices: [(0, 1)]`. Its two
2x2 boxes straddle a cell diagonal: `(31,24)` and `(32,23)` overlap at `(32,24)`.
The distant third object is not reported as a collision.

## Contract

A box is `(x, y, width, height)` with four Python integers. Non-integers,
including booleans, raise TypeError. `check_collision` accepts signed
coordinates and treats a non-positive dimension as empty. Rectangles are
half-open; touching edges do not collide. Python integers preserve sums above
255 and larger than machine words. A retro port must choose sufficient width
for position plus extent; this reference does not emulate overflow.

The optional broad phase accepts only boxes wholly inside 256x192, with
positive widths at most 32 and heights at most 24. `bucket_index` returns
one-based cells 1–64, or 0 for unsupported integer boxes. `candidate_pairs`
rejects any 0 result with ValueError before returning pairs, including when
valid objects precede an invalid one. It never indexes bucket -1 on a miss.

Each list position identifies a distinct object; equal boxes can represent
different objects. Candidate pairs are canonical zero-based object indices,
with smaller index first, and occur once. False positives are allowed in
candidates. `collisions` applies the rectangle test to obtain actual overlaps.
Both functions build fresh buckets from current positions each call. The
caller owns movement and the object list; no stale bucket state is retained.
Grid neighbours use one-based cell numbers as in the teaching pseudocode.

## Evidence and limits

`verification/results.json` records the interpreter version, source and observer
hashes, counts and negative controls. Regenerate it after source changes.
The verifier checks:

- All 160,000 ordered pairs from 400 small boxes: x/y -2 through 2 and
  dimensions -1 through 2. Occupied integer-pixel sets are the independent
  oracle, including empty rectangles and touching edges.
- Four explicit width/edge cases, including a right edge above 255 and
  coordinates above 64-bit range.
- Every cell's maximum-size box assignment and forward neighbour coverage,
  with independent geometric adjacency and no grid-edge wrapping.
- Eight unsupported integer boxes and three malformed/non-integer inputs.
- 155 scenes, including every internal cell intersection, all maximum-size
  grid boxes, equal-position objects, an empty scene, deterministic generated
  scenes and movement followed by rebuilding. Every true overlap must be a
  candidate; candidates must be unique; final collisions must equal occupied
  pixel intersections. The run observed 7,112 candidate pairs.
- Two mutations reproduce the original failure modes: removing
  bottom-left neighbours misses the diagonal pair, and wrapping a right edge
  to eight bits misses an overlap. Both mutated Python modules are rejected.

These are bounded host observations, not a proof of all scenes or qualification
of a retro machine, language dialect, speed or memory budget. The reference
allocates lists and pixel sets in its observer; no claim is made that those
allocations suit a constrained target. The teaching pattern's size limits are
what make its adjacent-cell search complete. Larger boxes need another scheme.

Scratch mutations and results live in the requested output directory. A failed
run removes a stale passing summary before checking; remove scratch after
inspection. No background process or external service is used.

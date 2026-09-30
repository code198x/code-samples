# Native checkpoint evidence

- `checkpoints.json`: twenty-four complete builds, upstream Pasmo 0.5.5 byte
  parity and 202 checks. Every source/data hash matches the maintained files.
  `pasmo_version` records the Pasmo banner (`Pasmo v. 0.5.5`) and
  `assembler_version` the Asm198x build.
- `opening-additions.json`: two additional static programs, native bitmap checks
  and upstream Pasmo 0.5.5 parity, 20 checks from the same run.
- `boundaries.json`: four keyboard-only contact/near-miss cases.
- `endpoint.json`: 49 native checks, including exact reference measurements and
  a separate fresh ROM tape load. It retains the accepted prototype source hash.
  Its ROM hash is the official 48K image (SHA-1 `5ea7c2b8...`); the earlier record
  named a locally patched copy since replaced.
- `title.png`, `flight.png`, `hit.png`, `miss.png`: inspected native captures.
- `phases-title.png`, `phases-play.png`, `phases-result.png`: inspected native
  captures of the `phases` checkpoint's three phases.
- `endpoint-tone.json`, `endpoint-sound-table.json`, `endpoint-sound-frames.json`:
  the endpoint suite run against each sound checkpoint. All three reproduce the
  accepted route's frames, ticks, times, scores and records exactly; neither
  blocking sounds nor sounds played in the frame wait moved them. In
  `endpoint-sound-frames.json` only the count of vertical-star samples differs
  (1656 and 822 against 1659 and 824): the harness samples at frame boundaries,
  most likely because the update now finishes earlier in its frame.

Run the three Python scripts in the parent directory to reproduce these reports,
passing an emulator executable and a temporary output directory. Captures and
build products go there; source files are not rewritten. `checkpoints.py` accepts
an optional upstream Pasmo 0.5.5 executable for binary comparison and refuses
any other Pasmo build. `checkpoints.json` keeps the twenty-four game programs; `opening-additions.json` keeps `pixel-address` and
`draw-ship`. The endpoint uses the independent accepted route from
`prototype/verification/model-results.json`.

The game reference source is unchanged; teaching-source cleanup is explicit in
the module README. Whole-tape hashes include the assembler's output-path-derived
code-header name; raw code parity is tested separately.

Some batched native result PNGs were incomplete even though bitmap-memory checks
found the full score line. They have not been selected as lesson illustrations.
Result-screen visual review belongs in browser/interactive verification before
publication. Audio captures exist in the temporary endpoint output; this record
does not claim listening review or physical-hardware testing.

The sound checkpoints' evidence comes from the same Emu198x build (0.24.0),
the official 48K ROM and upstream Pasmo 0.5.5. Loading a snapshot over a
running, unhalted CPU can resume at $0000 (emu198x/emu198x#1564), and a blocking
sound can leave the CPU running at a frame boundary, so the endpoint harness
resets first in that case only. Halted loads are unchanged and `endpoint.json`
reproduces exactly. Measured pitches and lengths of the sound captures are in
each checkpoint's README; nobody has yet listened to them.

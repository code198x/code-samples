# Native checkpoint evidence

- `checkpoints.json`: twenty-six complete builds, upstream Pasmo 0.5.5 byte
  parity and 248 checks. Every source/data hash matches the maintained files.
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
- `endpoint-debris.json`: the endpoint suite against `debris`, 50 checks. Every
  measurement matches `endpoint-sound-frames.json`, including the accepted route.
  Its lost path is longer: phase 2 now starts at contact with the destroyed phase,
  so the suite waits for `debris_time` to reach 0 (50 frames, recorded as
  `debris plays before the result`) before the result checks. It then aligns the
  retry to an odd frame count, as in the recorded runs: the next run's elapsed
  count starts on the frame `new_game` finishes, so a retry one frame later
  measures the same course one frame shorter (2091 instead of 2092).
- `debris-impact.png`, `debris-scatter.png`, `debris-result.png`: inspected native
  captures of the `debris` checkpoint's destroyed phase from `checkpoints.py`: two
  frames after contact (red border, the eight pieces bursting from where the ship
  was, the meteor that hit in their place), 24 frames after contact (the pieces
  spread in their arcs) and the result. `checkpoints.py` also compares the bitmap
  under the pieces at every halted frame of the phase (18 in the centre run) and
  finds it unchanged, so the pieces leave no trails. It checks the border flash
  (6 frames), that every piece stays between y=24 and the controls line, and that
  the result and the next run are black-bordered with no debris pixels.
- `endpoint-colour-bands.json`: the endpoint suite against `colour-bands`, 50
  checks. Every check and measurement matches `endpoint-debris.json`, including
  the accepted route, the destroyed phase and the retry alignment: the colour
  bands are presentation only. `checkpoints.py` adds six attribute checks for
  this checkpoint: the whole attribute map equals `row_colours`, row by row, on
  the title, in flight, late in the destroyed phase, at the result and after a
  retry, and ten samples through the keyboard route never differ from it.
- `colour-bands-flight.png`, `colour-bands-debris.png`: inspected native
  captures of `colour-bands`. The flight capture is `endpoint.py`'s frame 400 of
  the normal route: meteors in the cyan, green, yellow and red bands, a star,
  and the white ship. Several objects straddle a band edge and show the two
  bands' colours split along the row line; enlarged, no object changes colour at
  a vertical cell edge, so no cell shows clash. The debris capture is
  `checkpoints.py`'s frame 24 after contact: pieces red and yellow by where they
  fly, the meteor that hit red above and white below the row 19/20 line.
- `colour-bands-clash-prediction.png`: the README's prediction variant, not a
  checkpoint. Nine lines added to `draw_ship` write $46 into the ship's left
  cell on row 20; after steering left and back, the ship's top half is yellow
  and its bottom half white, the colour left in the cells it visited.

Run the three Python scripts in the parent directory to reproduce these reports,
passing an emulator executable and a temporary output directory. Captures and
build products go there; source files are not rewritten. `checkpoints.py` accepts
an optional upstream Pasmo 0.5.5 executable for binary comparison and refuses
any other Pasmo build. `checkpoints.json` keeps the twenty-six game programs; `opening-additions.json` keeps `pixel-address` and
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

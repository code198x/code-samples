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

- `voyage.json`: `checkpoints.py --only voyage`, 33 checks, from a later Emu198x
  build (its hash is recorded) without upstream Pasmo, which was not available
  for this run; Asm198x's pasmo and pasmonext dialects and PasmoNext 0.1.3 give
  identical bytes. The same build re-ran every checkpoint in `checkpoints.json`:
  each source, asset and binary hash matches, and every check and detail matches
  apart from the absent Pasmo comparison. The host model finds a keyboard route
  through each of the five courses (seeds 1986 to 1990) and the suite flies all
  five with Space held: every storm takes 19.6 to 21.6 seconds, each later storm
  starts on an empty playfield with the ship at X 116 and `elapsed` and `ticks`
  at 0, and the HUD reads `STORM 1/5` to `STORM 5/5`, read back from the bitmap.
  The score at each storm start reads 0, 960, 1940, 500 and 1490 and the result
  20: the true 5,140 points have wrapped the score byte twice. The voyage ends
  in clear space at course step 980 of the fifth storm, 980 frames into it,
  with that storm as `best_time`; the website's browser pilot reaches the
  same end state.
- `voyage-routes.json`: the five keyboard routes that run flew, ship X for each
  course step of each storm, written by `checkpoints.py` beside its voyage
  output. The website's browser pilot flies the voyage with the same routes.
- `voyage-interlude.png`, `voyage-storm-2-flight.png`, `voyage-storm-5-start.png`:
  inspected native captures of `voyage`: the first interlude (CLEAR SPACE, FINISH
  BONUS 0800, NEXT STORM, over the bands), the second storm's own course mid-way,
  and the fifth storm's first frames (clock at 00.00, ship centred, empty field).

- `two-byte-score.json`: `checkpoints.py --only two-byte-score`, 34 checks, same
  build and conditions as `voyage.json`. The same route ends at the same course
  step (980) with the score word at 514: the storm starts read 0, 960, 1940, 3060
  and 4050, the voyage's wrapped 500 and 1490 plus 2560. The result screen's
  `SCORE 05140` and `BEST SCORE 05140` are read back from the bitmap.
- `two-byte-score-result.png`: inspected native capture of that result screen.

- `storm-bonus.json`: `checkpoints.py --only storm-bonus`, 36 checks, same build
  and conditions. The same route ends at step 980; each clear space adds the
  bonus times the storm's number (80, 160, 240, 316 and 405 tens for bonuses of
  80, 80, 80, 79 and 81), each bonus line reads back as `FINISH BONUS nnn0 Xn`,
  and the voyage ends at 1,315 tens: 514 plus 801.
- `storm-bonus-interlude-3.png`: inspected native capture of the third storm's
  interlude, `FINISH BONUS 0800 X3`.

- `harder-storms.json`: `checkpoints.py --only harder-storms`, 37 checks, same
  build and conditions. The host model, reading each storm's rules from the
  program, finds a keyboard route through all five; the suite flies them. Falling
  objects move at 2-5, 3-6, 3-6, 4-7 and 4-7 pixels per update, each event's
  speed plus its storm's; 46 attribute samples match their storm's colour table
  in every cell; the storms take 20.92, 18.28, 15.56, 16.08 and 12.08 seconds.
- `harder-storms-storm-3-flight.png`, `harder-storms-storm-5-flight.png`:
  inspected native captures six seconds into the third and fifth storms.

- `furthest-storm.json`: `checkpoints.py --only furthest-storm`, 39 checks, same
  build and conditions. The whole voyage becomes the record (5 storms, 13,730),
  read back as `BEST VOYAGE 5/5 13730` on the result; a retry left idle (0
  storms) keeps it; Q shows it on the title.
- `furthest-storm-title.png`: inspected native capture of that title.

- `attract.json`: `checkpoints.py --only attract`, 43 checks, same build and
  conditions. The title's attributes are the colour table with FLASH on row 1,
  which holds SPACE TO LAUNCH; objects fall behind the title in phase 0; after
  the attract course ends and restarts (1,790 frames) the bitmap equals the
  title as drawn; a launch starts with no lit playfield rows and no objects; the
  voyage and record checks pass as for `furthest-storm`.
- `attract-title.png`: inspected native capture of the attract storm crossing
  the title text.

- `loading-screen.json`: `checkpoints.py --only loading-screen`, 43 checks, the
  same as `attract.json`: the program is unchanged.
- `loading-screen-routes.json`: the five keyboard routes that run flew under the
  harder storms' rules. The website's browser pilot flies the closing lesson's
  checkpoint with its own routes where they exist, and the voyage's otherwise.
- `loading-screen-tape.json`: `tape.py`, 4 checks. Unit 35's tape loaded through
  a fresh ROM: the screen is visibly black from frame 450, the SCREEN$ starts
  arriving by frame 925 and matches byte for byte at frame 2,350, stays exact in
  all 130 samples until the game starts by frame 5,600, and the game reaches its
  title. Loaders without the POKE to 23739 were tried first: the ROM's
  `Bytes: storm` message, black on black, wiped a strip of the picture.
- `loading-screen-partial.png`, `loading-screen-loaded.png`: inspected native
  captures mid-way through the SCREEN$ (pixels arriving unseen, INK and PAPER
  black) and once its attributes have arrived.

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
the official 48K ROM and upstream Pasmo 0.5.5. Measured pitches and lengths of
the sound captures are in each checkpoint's README; nobody has yet listened to
them.

The endpoint harness needs Emu198x 0.27.1 or later. It loads the snapshot
again over a running game, and earlier builds could resume that load at $0000
(emu198x/emu198x#1564), which fails `sound-table` at "start enters flight".
On 0.27.1 every checkpoint passes. One recorded detail differs from
`endpoint.json`: "releasing boost restores normal speed" counts 12 boost steps
where the 0.24.0 run counted 11. That comes from emulator timing changes between
the two builds, not from the harness, and the check passes either way.

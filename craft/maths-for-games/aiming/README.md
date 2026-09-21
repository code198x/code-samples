# Angle of attack

Local Maths for Games prototype, awaiting user review. A host-side mathematical
experiment; no native machine, assembler or emulator is involved. Not published.

Serve this directory, then open the printed address:

```sh
python3 -m http.server 1990 --bind 127.0.0.1
```

Try aiming manually and firing. Open **Work backwards from the target**, use its
calculated angle, and compare scale 4 with scale 256. Next target visits all four
quadrants and cardinal directions. Drag the range or use the native angle input
and slider; the latter work with keyboard arrows. Reduced-motion preference
shows completed trajectories immediately. Reset restores the starting challenge.

## Mathematical contract

World origin (0, 0), +X right, +Y up; degrees anticlockwise from +X. Conversion to
radians happens before trigonometry; screen Y is inverted only during drawing.
The triangle is scaled to target distance, while per-tick components use speed 3.
Targets have radius 5; shots are points. Swept segment contact prevents tunnelling.
Shots continue past contact to make their paths comparable. There is no gravity.

Reference positions use JavaScript floating-point numbers and n × velocity.
Fixed velocities are round(3 × cos/sin(angle) × scale), halves away from zero.
Position starts at integer zero and accumulates those integer components each
simulation tick. Decode by dividing by scale, without rounding to a display pixel.
Both integer components fit signed 16-bit velocity; accumulated positions fit
signed 32-bit position throughout this bounded experiment. JavaScript holds them
exactly; it does not emulate overflow or a particular machine's arithmetic costs.

The reference also has finite numerical precision. atan2 uses full target values;
displayed coordinates and readouts are rounded. There are no sine lookup tables
or quantised angles in this comparison: only velocity quantisation changes.
The 60-tick host playback is a presentation choice, not a retro performance claim.
Changing aim, range or precision cancels the old shot; its outcome cannot be
mistaken for evidence about the new settings.

## Verification

```sh
node --test model.test.mjs
node verify.mjs /tmp/aiming-review
```

Browser verification uses the adjacent website repo's Playwright and axe packages,
a local Chrome installation and the server at port 1990. Five model tests cover
quadrants, rounding, swept contact, precision and fractional accumulation.
Browser checks cover misses/hits, all six target directions, pointer and keyboard
input, reset, comparison toggling, reduced motion, accessibility and three widths.
Evidence is in `verification/`. These checks establish the model and controls;
they do not establish teaching effectiveness or user approval.

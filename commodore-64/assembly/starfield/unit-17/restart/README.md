# A fresh game needs fresh state

This optional unit-17 companion uses the real `enter_title`, `enter_game` and
`advance_wave` routines from `steps/step-04.asm`. It calls transitions directly:
these are three controlled game entries, not three complete playthroughs.
The normal game and its source remain unchanged.

## Build the comparison

From this folder, with Python 3 and Asm198x:

```sh
python3 prepare.py /tmp/starfield-restart
asm198x --dialect acme --prg /tmp/starfield-restart/baseline.asm -o /tmp/starfield-restart/baseline.prg
asm198x --dialect acme --prg /tmp/starfield-restart/faulty.asm -o /tmp/starfield-restart/faulty.prg
asm198x --dialect acme --prg /tmp/starfield-restart/repaired.asm -o /tmp/starfield-restart/repaired.prg
```

Load each PRG on a PAL C64 emulator and enter RUN. The final screen reports the
enemy count at entry to games 1, 2 and 3. Use an appropriate temporary output
path on our own computer. Cold-start each fixture rather than loading it over
a paused game. The original file's hash is checked before generation.

The baseline and repaired versions are identical. The faulty copy replaces only
`sta enemy_count` in `enter_game` with two NOPs. Those preserve the instruction's
byte footprint, so this experiment does not also relocate the game. This is a
labelled fault, not a proposed change to the working program.

## Know what the fixture does

`trial.asm` sets `enemy_count=3` **once**, explicitly, before the first entry.
That lets the faulty first game appear correct. It is not a claim about cold
C64 RAM: deleting the reset in an ordinary launch could fail immediately.

After each of the first two snapshots, it calls `advance_wave` five times,
reaching wave 6 and six enemies through the actual game routine. It also sets
score to BCD 1242, lives to 1, bullet-active to 1 and kills to 7 as deliberate
late-session test inputs. It then enters the title and starts another game.
It does not pretend these values came from joystick play or ten kills per wave.

Each entry records nine bytes at `$3803` (first), `$380c` (second) and `$3815`
(third), in this order:

| Field | Expected at every fresh game entry |
|---|---|
| enemy_count | 3 |
| score, score_hi | 0, 0 |
| lives | 3 |
| wave | 1 |
| kills | 0 |
| fall_speed | 1 |
| bullet_active | 0 |
| sprite enable `$d015` | `$1d`: ship and first three enemies, bullet off |

The diagnostic screen hides sprites after recording their enable state. We
observe the state at the boundary, before the normal gameplay loop can alter it.

## Predict and diagnose

Before running the faulty copy, write down all three expected enemy counts.
Which fields belong to a play session, and which did we only initialise once?
Use the lesson's hints after making a prediction.

The baseline and repair produce 3,3,3. The faulty copy produces 3,6,6 while the
other eight recorded bytes still match their fresh-game values. In particular,
wave 1 and three enabled enemy sprites can conceal a count of six. The game
loops use the count; a picture or W1 readout alone does not establish a reset.

Repair the per-game store before the spawn loop, not the display or wave table.
Changing a fixture's one-time seed would merely make one entry look correct.
Rebuild, repeat all three entries and compare the other fields as regressions.
Return to the untouched step-04 source to continue the course.

## Reproduce native checks

```sh
python3 verify.py --emulator /path/to/emu198x-c64 --build /tmp/starfield-restart
```

The verifier runs the PRGs through BASIC RUN and reads the fixture records and
screen digits without modifying guest memory. It checks every field on all
three entries and requires repaired/baseline PRGs to be byte-identical. Results
record source, PRG and emulator identities. Guest fixture setup writes are
explicit above; no host pokes manufacture the result.

This exercise does not verify SID handover, complete games, random distributions,
physical hardware or arbitrary launch environments. Those remain separate work.

[Recorded results](results.json): all three variants pass their expected outcomes
on 22 September 2026 in native C64 PAL emulation. Baseline and repaired PRGs
are byte-identical; all 27 recorded fields per variant and three displayed
counts match. Source and emulator hashes identify this run. Asm198x 0.0.58
assembled the fixtures. The baseline diagnostic screenshot was inspected.

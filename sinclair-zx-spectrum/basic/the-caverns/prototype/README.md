# The Caverns prototype

Stock 48K PAL Sinclair BASIC. Twelve named rooms, one fixed pit, a creature
walking an eight-room circuit and three treasures to return to the entrance.
This is a native-play trial, not an accepted lesson endpoint.

S starts; N/S/E/W move; Space waits; R restarts the fixed expedition; Q quits.
Read each exit's directional warning. Entering a pit or the creature's current
room loses. If the creature arrives in your room, you get one valid action to
leave. Waiting then loses. Invalid keys and walls cost no turn. No sound,
real-time deadline, generated map or machine-code helper.

## Reproduce

Set `EMU198X_SPECTRUM` to a built Spectrum executable configured with a lawful
48K ROM. From this directory:

```sh
python3 verification/model.py
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/audit.py
"$EMU198X_SPECTRUM" --machine spectrum_48k --tape verification/evidence/caverns.tap --autoload-tape --scale 3
```

The build enters the complete listing with ROM keyword keys and saves a
self-starting tape. Checks load the tape in a fresh process; game actions are
ordinary keys, with read-only memory observation. Captures are original emulator
output. The host model separately explores room, patrol-phase and treasure
states and checks that every reachable creature arrival offers an escape.
Neither the model nor scripted execution establishes enjoyment, learner
outcomes or original-hardware timing. Use native play to judge the fixed cave.

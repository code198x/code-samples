# Atari 800XL BASIC: wait for a command

Enter `caller.bas` then `routines.bas` as one numbered program in stock Atari
BASIC and RUN. Type 1, Return to take a turn; 0 is rejected. Waiting consumes no
game turn. GRAPHICS 0 clears the text screen before drawing TURN and FLAG.
The earlier `demo.bas` is retained for the original probe record; use the new
caller/routine pair when adopting this component.

## Call contract

Reserve lines 1000–1040, or renumber the GOSUB target and routine together.
Initialise N and S once, then set numeric command A and GOSUB 1000.

- N: integer-valued counter 0–255; accepted input adds S modulo 256.
- S: integer-valued step 0–255; input, preserved.
- A: submitted numeric command; input, preserved. Only 1 is accepted.
- C: result, 1 accepted or 0 rejected; replaced on every call.

The one-subtraction wrap assumes the stated bounds (maximum sum 510). It is not
a general modulo operation for arbitrary floating-point values. Atari BASIC
uses its normal numeric representation; these are globals, not byte variables.
The routine owns N/C and its interpreter return frame; it allocates no fixed
RAM, graphics buffer, clock or interrupt. Rename variables consistently if they
clash, and consume C before another routine reuses it. A full adventure still
needs command parsing, world state and game rules.

## Customise; diagnose

Use `customise.bas` plus the same routine: S=2 produces 0, 2, 4. Initialise N to
254 for 254, 255, 0, or 37 for 37, 38, 39. These change initial values without
adding another routine or global. Keep both the counter and step in range.

`mistakes/reset-each-turn.bas` is deliberately wrong: it erases N before every
rule call. Two accepted commands produce 0, 1, 1; rejected input can erase
progress too. Restore `caller.bas`; the verifier runs that repair afresh.
Text entered at numeric INPUT follows Atari BASIC's interpreter error handling.
This sample does not invent a universal parser or accept arbitrary malformed text.

INPUT blocks the game code. It cannot promise to return for animation, sound
updates or a deadline. The OS continues its own services. A timed turn needs a
non-blocking reader or a separately owned service and explicit expiry policy.
The assembly counterpart demonstrates sampled fire input with OS clock pacing;
it is a different input contract, not a mandatory optimisation of this caller.

## Execute again

```sh
python3 scripts/verify-xl-coleco-loops.py --only atari-basic --tools TOOL_RELEASE_DIRECTORY --firmware ROM_ROOT
python3 scripts/check-xl-coleco-loop-records.py
python3 -m unittest discover -s scripts -p test_xl_coleco_loop_records.py -v
```

The native observer types each numbered line separately with 60 native fields
for interpreter acceptance, submits actual keyboard commands and reads the
rendered counter/flag through SAVMSC, not a fixed screen address. Six fresh
cases cover default, custom step, nonzero, wrap, wrong and repaired callers.
`verification/reusable/` retains the captures and source-bound execution record.
Emu198x 0.44.1 and exact firmware/tool identities are recorded. No manufacturer
firmware is included; this does not qualify a complete emulator or real hardware.

Primary reference: Atari, *Atari BASIC Reference Manual*, GOSUB, RETURN, INPUT,
GRAPHICS and the numeric representation. See the assembly counterpart's notes
for the separate OS/joystick/clock contract.

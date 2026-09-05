# Meet BASIC: Lucky Number opening

Six complete checkpoints for proposed units 5 and 6 (B1/B2 in the agreed plan).
These extend Meet BASIC after its published Story Builder opening. They do not
replace the older standalone Lucky Number samples.

| Checkpoint | Change | Observable result |
|---|---|---|
| 5.1 | Known secret and equality test | 7 prints Correct; other guesses give no clue |
| 5.2 | Add the lower comparison | 4 prints Too low; 9 still gives no clue |
| 5.3 | Add the higher comparison | 4, 7 and 9 each receive exactly one response |
| 6.1 | Clear the old clue and repeat incorrect guesses | 4, 9, 7 reaches the ending without RUN between guesses |
| 6.2 | Initialise, increment and display the count | 4, 9, 7 takes three guesses; a new run with 7 takes one |
| 6.3 | Validate before counting; stop before the rejection handler | 0, 11 and 6.5 are rejected; 1, 10 and 7 count as three guesses |

The secret remains 7 intentionally. Random selection, audio and replay belong to
the next lessons. The introduction asks for a new, empty program; subsequent
checkpoints change only the explicitly named lines. Every file is runnable.

## Reproduce the checks

Use Python 3 and an absolute path to Emu198x Spectrum v0.22.0 or later, with a
lawfully supplied 48K ROM configured. Run these from this directory:

```sh
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/lucky-checks
python3 verification/verify_experiments.py --emulator /path/to/emu198x-spectrum --output /tmp/lucky-experiments
```

The first driver reuses the opening verification transport and types the exact
keyword chords, including THEN, not-equal and INT, through the real ROM editor.
It checks all six checkpoints, range boundaries, fractions, repeated incorrect
guesses without scrolling, correct-first-guess resets, and a real SAVE/export/
fresh-process named LOAD round trip. The second checks the lesson experiments
and the distinction between numeric expressions, undefined variables and editable
input syntax errors. Neither driver injects BASIC or patches memory.

## Evidence

On 5 September 2026, all 60 checkpoint/tape checks and 12 experiment checks passed
on the released Apple silicon Emu198x Spectrum v0.22.0 executable. The checked
binary SHA-256 is `548e02ab6eee68903b00b98a91485a21456de6390e8c7efa1f08e517154f830c`.
[Checkpoint results](verification/results.json) and
[experiment results](verification/experiments.json) contain source hashes,
expected output and observed screen rows.

The two lesson screenshots come from `unit-05-step-03-guess-4.png` and
`unit-06-step-03-case-3-guess-6.png` in the first run. They were visually inspected.
Generated TAP files and firmware are not committed.

This is MCP execution on the 48K configuration. It does not verify native host
keyboard events, menu use, speakers, other emulator models or original hardware.
Host/Original mode instructions were checked against the v0.22.0 mapping source;
the target key chords were executed. Reader testing of the new lessons is pending.

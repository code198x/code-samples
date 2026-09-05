# Meet BASIC: opening checkpoints

Draft implementation of the agreed A1–A4 authoring slice. These files are separate
from the current `meet-basic/unit-NN` samples so existing lessons keep their meaning.
Publishing identities will be assigned with the curriculum route migration.

| Checkpoint | Change | Expected output |
| --- | --- | --- |
| A1 step 1 | Store a greeting at line 10 | `Hello` |
| A1 step 2 | Add line 20 | `Hello`, then `from the Spectrum` |
| A1 step 3 | Insert line 15 | `Hello`, `to you`, `from the Spectrum` |
| A1 step 4 | Replace line 10 | `Welcome`, `to you`, `from the Spectrum` |
| A2 step 1 | Replace 10/15 with assignment and output | `Hello, Sam`, `from the Spectrum` |
| A2 step 2 | Change the assigned name | `Hello, Jo`, `from the Spectrum` |
| A2 step 3 | Change the recovered program | `Hello, Alex`, `from the Spectrum` |
| A3 step 1 | Replace assignment with input | Greeting uses the supplied name |
| A3 step 2 | Ask for two more words | Supplied words form a sentence |
| A4 step 1 | Ask for a place and reuse the animal | A setting, meeting and request |
| A4 step 2 | Remove the greeting; clear and arrange output | A titled story with deliberate spacing |

Every `.bas` is a complete listing. Learners enter only the changed lines between
checkpoints. The verification code is authoring tooling, not code learners must
understand or include in their program.

## Reproduce the keyboard and tape checks

With Python 3, a working `emu198x-spectrum` binary supporting MCP, and a lawfully
supplied 48K Spectrum ROM configured for it:

```sh
python3 verification/verify.py --emulator emu198x-spectrum --output /tmp/meet-basic-evidence
```

The driver uses real ROM keyboard entry. It does not inject tokenised BASIC or
patch ROM routines. It enters keywords by their K-mode keys, types characters
with Spectrum shift combinations, and pauses between presses for ROM key-release
handling. This is a functional check, not a keyboard-speed benchmark.

The run covers immediate output, all seven checkpoints, LIST, EDIT, cursor movement
and DELETE, an intentional unknown-variable report, BASIC SAVE, MCP tape export,
and loading the tape into a **new process**. It compares the recovered listing
with the saved source, runs it, then changes and reruns it. Outputs include PNG
captures, `greeting.tap` and `results.json`. The TAP is generated, not committed;
no firmware is distributed.

MCP `autoload_tape` enters the load command and starts tape transport. That verifies
target-side loading, not a learner choosing a file or using desktop menu commands.
The existing capture runner remains the route for normal content capture manifests;
this small driver supplies the keyboard/save round trip that direct source loading
cannot demonstrate.

## Reproduce the input checks

```sh
python3 verification/verify_input.py --emulator /path/to/emu198x-spectrum --output /tmp/meet-basic-input
```

This separate run starts with A2's last greeting and enters only changed or added
lines for A3. It checks two names in the first checkpoint, two sets of story words,
empty answers and long answers in the second. It checks each prompt and compares
complete output rows, including spaces and wrapping, followed by the completion
report. This verifies six scenarios with 20 named prompt/output checks. It neither
loads BASIC directly into RAM nor verifies saving or native desktop interaction.

[input-results.json](verification/input-results.json) records the passing run on
5 September 2026, with input-check source and binary hashes. The story and long-answer
captures were visually inspected. The normal story capture is used in the A3 draft.

## Recorded evidence and limits

On 5 September 2026, all 16 named checks passed using a local debug binary reporting
Emu198x Spectrum `0.21.0`. [results.json](verification/results.json) records screen
observations and source/TAP hashes. Binary SHA-256:
`49d7bcf91c4a06592bbeb10e6d7abbd0c511c113809ac2bdf38fe0940e8ce390`.

The screenshots used in the lesson drafts were visually inspected. Tested target:
Spectrum 48K, normal ROM, MCP keyboard entry and tape SAVE/LOAD. No original
hardware, other model, other emulator, fresh installation or native GUI has been
verified. Emulator source was inspected at `8bdfb0e998927cf5e338c2e5f05ab88f29a34c21`;
that is a source-inspection reference, not a claim about this binary's build commit.

## Reproduce the finished-story checks

```sh
python3 verification/verify_story.py --emulator /path/to/emu198x-spectrum --output /tmp/meet-basic-story
python3 verification/verify_named_story.py --emulator /path/to/emu198x-spectrum --greeting /tmp/meet-basic-evidence/greeting.tap --story /tmp/meet-basic-story/story.tap --output /tmp/meet-basic-named-story
```

The story driver enters the A3 listing through the ROM editor, then applies only
A4's additions, replacements and numbered-line deletions. It compares complete
output rows for both checkpoints, changed answers, empty answers and long answers,
including wrapping and unused rows. It saves `story`, exports it and runs the
recovered program with new answers in a fresh emulator process.
[story-results.json](verification/story-results.json) records the passing run,
source and binary hashes, and observations.

The named-load driver combines the two real SAVE captures from these commands,
retaining their bytes with the greeting first. It types `LOAD "story"`, starts
tape playback, and checks that the recovered program produces the finished story.
[named-story-results.json](verification/named-story-results.json) records the
passing check and input hashes. This exercises named loading, not the native
file picker or a physical cassette.

## Reader acceptance and publication

Steve reports testing and approving revised A1–A3, including native host-keyboard
operation. Desktop tape export is implemented in
[Emu198x PR #1447](https://github.com/emu198x/emu198x/pull/1447); the revised A2
describes that route. Host Keyboard mode is in
[PR #1448](https://github.com/emu198x/emu198x/pull/1448). A4 awaits reader review.
Publication still requires the coordinated curriculum route/catalogue migration.

## Source basis

Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second
edition (Sinclair Research, 1983): chapters 1–2 for keyboard/editor/program behaviour,
chapter 7 for variable naming, chapter 15 (including p. 103) for input prompts, text layout and CLS, chapter 20 pp. 141–145 for tape storage. Emu198x's
Spectrum UI keyboard map supplies host key mappings; native use has user-reported
acceptance for A1–A3. Runtime observations above are separate evidence.

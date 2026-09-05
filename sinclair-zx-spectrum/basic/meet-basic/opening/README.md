# Meet BASIC: opening checkpoints

Draft implementation of the agreed A1/A2 authoring slice. These files are separate
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

**Publication blocker:** [Emu198x #1446](https://github.com/emu198x/emu198x/issues/1446)
requests desktop export of recorded BASIC SAVE data. MCP export and fresh-process
reload work, but the desktop workflow is incomplete. The A2 draft must gain
checked file-selection, export, close/reopen and load instructions before publishing.
A snapshot must not be presented as if it were a BASIC tape save.

## Source basis

Steven Vickers, edited by Robin Bradbeer, *ZX Spectrum BASIC Programming*, second
edition (Sinclair Research, 1983): chapters 1–2 for keyboard/editor/program behaviour,
chapter 7 for variable naming, chapter 20 pp. 141–145 for tape storage. Emu198x's
Spectrum UI keyboard map supplies host key mappings; these still need a native
interface check. Runtime observations above are separate evidence.

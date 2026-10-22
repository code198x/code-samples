# An untimed FORTH key loop: Jupiter Ace

Enter [demo.fth](demo.fth) one definition at a time, then TURNS. It displays TURN 0. Press 1 for TURN 1; keep holding it and the counter stays at 1. Release and press again for TURN 2. Other keys are ignored. Return is not needed for each action.

NEWKEY waits for release, then returns one nonzero INKEY value on the stack. TURNS keeps one unsigned 16-bit counter cell: DUP U. displays it, NEWKEY 49 = tests the digit 1, and 1+ advances it. The false condition consumed by 0 UNTIL keeps the word running without growing the stack. The count wraps at 65535.

To reuse it, keep NEWKEY as a word and replace the accepted-key body with your state update. Keep its release wait if one action per press matters. The stock FORTH ROM owns display and keyboard routines; there are no arbitrary RAM reservations. This is a blocking, untimed game. A timeout needs another input policy that checks an explicit clock while waiting.

Verify from the repository root:

```sh
python3 scripts/verify-ace-command-loop.py --native /path/to/native/binaries
```

[The retained record](verification/results.json) pins the ROM, executable and sources. It checks idle, ignored keys, two actions, a 120-frame held key and a rejected fabricated-key variant. The default 3 KiB machine is qualified; no frame clock or physical-hardware accuracy is claimed.

## Current-release qualification and variations

The current retained baseline is executed on released Emu198x 0.44.1. Use `scripts/verify-dragon-ace-loops.py --native /path/to/binaries-and-producer-locks --assembler /path/to/asm198x --only refresh` to refresh both stock-language routes. `scripts/verify-dragon-ace-language-variants.py --native /path/to/binaries` executes the maintained customisation, reset fault, separate repair and nonzero initialiser; `scripts/check-dragon-ace-loops.py` independently checks retained observations.

`customise` changes the accepted update from one to three. The deliberately broken `mistakes/reset-each-command` erases progress at the next iteration. Restore the original loop target/initialisation to repair it; normal state survives idle and ignored input. `verification/variants.json` and its native images keep those runs separate from the older baseline. These are untimed policies; a turn deadline needs its own clock and input policy.

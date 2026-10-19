# An untimed FORTH key loop: Jupiter Ace

Enter [demo.fth](demo.fth) one definition at a time, then TURNS. It displays TURN 0. Press 1 for TURN 1; keep holding it and the counter stays at 1. Release and press again for TURN 2. Other keys are ignored. Return is not needed for each action.

NEWKEY waits for release, then returns one nonzero INKEY value on the stack. TURNS keeps one unsigned 16-bit counter cell: DUP U. displays it, NEWKEY 49 = tests the digit 1, and 1+ advances it. The false condition consumed by 0 UNTIL keeps the word running without growing the stack. The count wraps at 65535.

To reuse it, keep NEWKEY as a word and replace the accepted-key body with your state update. Keep its release wait if one action per press matters. The stock FORTH ROM owns display and keyboard routines; there are no arbitrary RAM reservations. This is a blocking, untimed game. A timeout needs another input policy that checks an explicit clock while waiting.

Verify from the repository root:

```sh
python3 scripts/verify-ace-command-loop.py --native /path/to/native/binaries
```

[The retained record](verification/results.json) pins the ROM, executable and sources. It checks idle, ignored keys, two actions, a 120-frame held key and a rejected fabricated-key variant. The default 3 KiB machine is qualified; no frame clock or physical-hardware accuracy is claimed.

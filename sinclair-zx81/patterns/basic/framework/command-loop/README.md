# A running-total loop: ZX81, 1 KiB

The caller starts by printing 0. Submit 1 and it prints 1; submit another 1 and it prints 2. Waiting, or submitting 0, leaves the total unchanged. This is an untimed numeric input loop: other values are added too.

## Enter and adapt it

Enter [demo.bas](demo.bas) through the original keyword keyboard, then RUN. LET is L, CLS is V, PRINT is P, INPUT is I, GOTO is G, and RUN is R. Use Shift+L for `=` and Shift+K for `+`. Line numbers come before the keyword key. The verifier holds each key for 10 native frames and leaves 30 after release so the ROM accepts each edit.

Initialise N once, keep INPUT as the player-submission point, and replace `N=N+A` with your command validation and world update. N and A belong to this caller; BASIC owns their memory and its keyboard/display work. Renumber when combining listings. There is no machine-code dependency or direct display write.

The ZX81 uses its normal numeric arithmetic and ROM display service. This is not a FAST-mode game loop or a display-ownership routine. The small listing fits the tested 1024-byte configuration; adding a large display or more variables consumes that same tight memory budget.

## Verify

```sh
python3 scripts/verify-zx-command-loops.py --native /path/to/native/binaries --only sinclair-zx81
```

[The retained record](verification/results.json) includes exact ROM/executable/source hashes, idle and submitted-input observations, and a nonzero 7 → 8 check. A deliberately doubled addition must fail the same one-unit guard. The observer reads the first printed line through the live D_FILE pointer; it does not search arbitrary RAM for the expected number. No deadline or held-key edge-detection claim is made.

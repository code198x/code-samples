# Cipher teaching checkpoints

Six lessons use five independently runnable stock 48K PAL Sinclair BASIC
programs. The finished source is byte-identical to the prototype authorised for
teaching. The saving lesson reuses that source.

| Checkpoint | Behaviour |
|---|---|
| reveal | Fixed T guess in BOTTLE; both matches, then STOP |
| guess | Direct letter input and retained reveal; unlimited attempts; Enter quits |
| rules | Seven distinct misses, free repeats, scores, pause and results; fixed word |
| board | Spaced word, mistake markers, stored alphabet and selective updates |
| finished | Complete title, 24-word DATA list, random selection and replay |

`checkpoints.json` records exact additions, replacements and deletions, while
`changes.bas` contains the ordinary lines to enter. The first program is new;
the sixth lesson adds no source lines. The audit reconstructs every transition.

## Reproduce

Set `EMU198X_SPECTRUM` to a built emulator with a lawfully supplied 48K ROM.
Run from this directory:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence --jobs 4
python3 ../prototype/verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence/finished
python3 verification/audit.py
```

Each build enters complete source through keyword keys in a fresh ROM and saves
`SAVE "cipher" LINE 10`. Checks load that tape in another process. Memory
observation is read-only. The first checkpoint's L/Z experiments edit the stated
line through the ROM and restore it. Finished-game content coverage uses labelled
ROM commands to select each DATA entry; captures are from ordinary play.

The evidence distinguishes emulator execution from independent learner success
or original-hardware timing. Current publication status is maintained in the
[implementation record](https://github.com/code198x/docs/blob/main/platforms/sinclair-zx-spectrum/games/cipher/lessons.md).

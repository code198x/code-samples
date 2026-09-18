# Cipher native trial

A compact word game in stock 48K PAL Sinclair BASIC. Choose letters to reveal a
hidden everyday word. Every occurrence is revealed together. Seven distinct
misses lose the round; repeating a hit or miss costs nothing. The 24-word list
rejects an immediate repeat, but does not provide a shuffled deck.

## Controls

- Title: S starts; Q quits.
- Playing: A–Z guesses immediately, in either case. Enter pauses.
- Pause: C continues; R resets the session and scores; Q quits to BASIC.
- Result: Space chooses another word; R resets; Q quits.

Q and R are guesses during play. There is no whole-word submission or timer.
The alphabet marks used letters with dots, while misses have their own list.
The remaining-mistake count and seven markers convey the same information
without relying on colour. This trial is deliberately silent.

## Build and check

Set `EMU198X_SPECTRUM` to a built emulator with a lawfully supplied 48K ROM.
From this directory:

```sh
python3 verification/build.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/check.py --emulator "$EMU198X_SPECTRUM" --output verification/evidence
python3 verification/audit.py
"$EMU198X_SPECTRUM" --machine spectrum_48k --tape verification/evidence/cipher.tap --autoload-tape --scale 3
```

The builder enters keywords using ROM keys and records `SAVE "cipher" LINE 10`.
The checker loads that tape in a fresh process and observes memory read-only.
Ordinary key play supplies the captures. All-word coverage additionally uses
explicit ROM commands (`LET pick=...`, `GO TO 230`) after quitting; the results
record those diagnostic fixtures separately. No diagnostic capture is presented
as ordinary play. The audit binds source, tape, stored tokens and execution
identities. Timing observations concern this emulator configuration, not
original-hardware measurements or human reaction time.

Native execution is separate from player approval. The existing published
lessons remain unchanged while this trial is reviewed.

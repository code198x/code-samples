# Locksmith — BASIC prototype

Crack a four-digit code using digits 1–6. Digits may repeat. Ten guesses, one visible history, and two numeric clues: EXACT counts correct digits in their correct positions; OTHER counts correct digits elsewhere. Each occurrence counts once. Clues apply to the whole guess, not individual positions. Repeated guesses consume an attempt.

The user accepted the native trial: “Locksmith is great”. The maintained source includes a subsequent display-only cleanup: clear stale input advice before revealing the code and use a result label that works for one or several attempts. Rules, scoring, controls and difficulty are unchanged. Seven [executed teaching checkpoints](../teaching/README.md) now support nine planned lessons, preserving this final source. Replacement lesson prose remains to be authored.

## Play

Load `verification/evidence/locksmith.tap` through the stock 48K ROM. It starts at line 10.

- **S** starts from the title.
- **1–6** enter digits; a held key enters once until released.
- **D** or Spectrum **DELETE** removes the last digit.
- **Enter** submits four digits. A short guess keeps the current attempt.
- **R** starts a new random code during play or after a result.
- **Q** quits from the title, play or result.

History remains visible after a win or loss. The result reveals the code. There is no time pressure, sound, solver, hint system or machine-code helper. Numeric labels carry the clues; colour is supplementary. The title panel is original text artwork.

## Reproduce

With Emu198x Spectrum 0.25.0 and a lawfully supplied stock 48K ROM configured, from this directory:

```sh
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/check.py --emulator /path/to/emu198x-spectrum --output verification/evidence
python3 verification/audit.py
```

The build enters the listing through the ROM keyboard and saves an auto-starting tape. Checks fresh-load the tape, drive keys and inspect state without changing the secret or results. The independent scoring model removes matching occurrences rather than reusing the BASIC frequency-count algorithm. Eighteen check groups cover 42 submitted guesses, input editing, held and excess digits, incomplete submission, both outcomes, replay and quit. Four complete losing rounds check every history row against the model. Source, stored lines, both TAP checksums, line-10 autostart and evidence hashes are audited.

PNG captures are original emulator output and were visually inspected. Tests establish this configuration's behaviour, not original-hardware timing or independent learner outcomes. The game is turn-based; release each key before entering the next. Native feedback establishes acceptance of the game, not completion of its teaching progression.

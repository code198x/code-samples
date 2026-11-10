# Raster stripes: the production verifier's fixture

A small timed effect that proves the schema 2 production record
(`../../production.py`) before a real production depends on it. It changes the
border colour once a scan line for 56 lines of the top border, timed to each
model's line length: 224 T-states on the 48K and Pentagon, 228 on the 128K
family. It measures the frame at start-up to tell which it is on, and stores
what it found at `$8F01` and an end marker at `$8F00`.

Each colour change falls in the horizontal retrace, so a correctly timed build
shows level bands whatever phase it starts in. That matters: HALT wakes on a
4 T-state boundary, so the start phase depends on how long the tape took to
load, and any change to the program changes that.

Two controls run with every full verify:

| Control | Change | Must fail on |
|---|---|---|
| `stripes-mistimed.asm` | the 128K family gets the 48K's 224 T-state loop | the 128K and +2A, whose bands slant |
| `stripes-padded.asm` | 64 harmless bytes, so loading takes longer | nothing |

Run it from the code-samples root with Asm198x and Emu198x built at the locked
revisions (`proof.lock.json`) and each model's ROMs under `~/.emu198x/roms`:

```sh
python3 _capture/verify.py _capture/fixtures/raster-stripes/proof.manifest.json --full
```

`--public` stops after the build, for machines without the ROMs. `--record`
writes new reference hashes into the record; use it only after looking at the
captures, because the references are claims about what is right.

The Pentagon boots to a menu that Emu198x's tape autoload doesn't drive, so its
record types its way into 48 BASIC and starts the tape itself
([emu198x#2343](https://github.com/emu198x/emu198x/issues/2343)).

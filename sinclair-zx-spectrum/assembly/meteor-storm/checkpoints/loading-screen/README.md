# Draw a loading screen

A Spectrum game took minutes to load from cassette, and most commercial releases filled the wait with a picture: a loading screen, loaded first so that it stayed up while the game itself followed. This checkpoint's program is the previous one, unchanged. What is new is the tape: a BASIC loader, a picture and the game, in that order.

## The picture

The screen is 6,912 bytes from 16384 ($4000): 6,144 bytes of bitmap, then 768 of attributes. A file of exactly those bytes is a SCREEN$. `compose.py` draws `loading-screen.png` from the game's own artwork: the ship, meteor and star rows from `assets.py`, and a wordmark drawn here. It colours by place, as the game does: every 8×8 cell has black PAPER and the bright INK of its row, so nothing can clash. `build198x image` converts the PNG to `meteor-storm.scr`:

```sh
python3 compose.py
build198x image loading-screen.png --machine sinclair-zx-spectrum \
    --format scr --dither none -o meteor-storm.scr
```

Because every cell already has two colours or fewer, the converter reports a mean error of 0 and calls the input "already constrained". `--dither none` keeps it that way. The PNG and the SCREEN$ are both kept here, so building the tape needs no Python.

`screen.asm` turns the SCREEN$ into a tape block: `org 16384` and `incbin "meteor-storm.scr"` make a CODE block of 6,912 bytes whose header says it belongs at 16384.

## The loader

```basic
  10 BORDER 0: PAPER 0: INK 0: CLEAR 32767
  20 LOAD ""SCREEN$
  30 POKE 23739,111
  40 LOAD ""CODE
  50 RANDOMIZE USR 32768
```

- Line 10 makes everything black and clears the screen. `CLEAR 32767` also lowers RAMTOP, the top of BASIC's memory, below 32768, so BASIC keeps out of the space the game loads into.
- Line 20 loads the next block into the screen. `SCREEN$` is shorthand for `CODE 16384,6912`.
- Line 30 stops the ROM printing over the picture. Before each block the ROM prints its header, `Bytes: storm`, on the main screen. The main screen's output goes through channel S, and the address of channel S's print routine is kept at 23739-23740: $09F4. POKE 23739,111 changes its low byte to $6F, and the ROM byte at $096F is RET, so printing on the main screen does nothing. Without it, the message prints at the picture's print position in black on black: invisible, but it wipes a strip of the picture.
- Line 40 loads the game's code to the address its header gives, 32768.
- Line 50 runs it.

`build198x basic` tokenises `loader.bas` into a BASIC program that runs from line 10 when loaded.

## The tape

`unit-35/Makefile` builds three blocks and joins them: a TAP file is its blocks one after another, so `cat` makes the tape. A block's tape header carries a ten-character name: `--name meteor` sets the loader's, and `asm198x` takes the others from its output file, so they are built in `build/` as `screen` and `storm`.

| Block | Header | Contents |
|---|---|---|
| `meteor` | Program, autostart line 10 | the loader |
| `screen` | Bytes, 6912 at 16384 | the SCREEN$ |
| `storm` | Bytes, 11757 at 32768 | the game |

With INK and PAPER both black, the picture's pixels arrive unseen behind the loading stripes in the border. The attributes come last, in the final 768 bytes, so the picture appears all at once when its colours arrive. The game then loads for about a minute and a half beneath it, and its title replaces it.

Predict, then check: change line 10's `INK 0` to `INK 7`. The bitmap now draws in as it arrives, in the order unit 3 untangled: the top pixel line of every character row in the top third, then the next line down, and so on, then the middle third, then the bottom. What else changes? The ROM's `Bytes: screen` message, printed before line 30's POKE, is now white and visible until the picture covers it. Then remove line 30 and predict where the next message, `Bytes: storm`, lands. It is invisible, but look for the strip it leaves.

Load `unit-35/meteor-storm.tap` on a fresh 48K Spectrum with `LOAD ""`. The screen turns black, the picture appears, and after the game's block the title starts.

Sources: the ZX Spectrum BASIC manual, chapter 20 (Tape storage) for `SCREEN$` as `CODE 16384,6912` and for `LOAD ""CODE`; chapter 24 (The memory) for the display file and attributes, for CLEAR, which clears the display file and sets RAMTOP, and for the channel information that holds the devices, from CHANS at 23734. The channel records themselves were read from a running 48K machine: channel S's output address at 23739-23740 is $09F4, and the ROM byte at $096F is RET.

This is the previous program, packaged. See the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).

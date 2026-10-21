# Make a maze and replace the glyph

Run `make`, then load `build/maze.a26` or `build/reflected.a26` in the NTSC
emulator. Both wrappers include `caller.inc`; they select MAZE_REFLECT=0/1.
The caller includes the unchanged parent `playfield.inc` and `kernel.inc`.

`CUSTOM PICTURE` clears the buffer, draws 84 perimeter cells, makes 21 interior-
wall cell writes, erases a doorway and stamps 35 opaque arrow cells. That is 141 cell
writes after the 72-write clear (213 total). The original caller makes 36 cell
writes after clear. Work happens once during setup, before the first field.
For a game, schedule your own preparation within a measured blanking budget.

The seven bytes under `CUSTOM GLYPH` are an original five-bit-wide arrow.
Replace them with any seven values 0..31; bit 4 is leftmost. The origin remains
(2,4). Zero bits erase cells under the stamp. Keep whole stamps inside x<=15,
y<=17. The foreground changes from $0E to $46 before drawing; COLUBK stays zero.
The palette is the selected emulator's NTSC interpretation, not a calibrated
physical television colour claim. CTRLPF chooses repetition/reflection for the
entire half-picture, including the arrow and all passages.

The reusable components stay 197 code +64 table bytes; picture/context remain
72/16 bytes, with one seven-byte glyph. The startup instruction span from start
to ready grows from 81 to 162 bytes; this is assembled code size, not cycles.
Cartridge size remains 4 KiB. Both steady field periods remain 59736 colour
clocks and the same 192-line kernel. Changing the number of bands, buffer
placement, kernel work or register ownership requires new verification.

`verification/` retains exact source hashes, buffers, full native repetition /
reflection captures and measured field periods. Fresh reproduction:
`python3 scripts/verify-tia-maria-customise.py --tools /path/to/tools --output /path/to/output`
from the samples root. The independent model uses logical cells and original
arrow rows. No routines or their normal callers are changed by this example.

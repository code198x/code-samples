# Tail Chase prototype

Accepted after native play on a stock 48K PAL Spectrum in Emu198x 0.25.0. This is the playable endpoint for a proposed continuation after Crates; teaching stages are not yet agreed or published.

Eat eight foods in a 24×16 arena, growing from four to twelve cells. I/J/K/L steer up/left/down/right; S starts, R retries and Q quits. Opposite directions are ignored. One perpendicular turn can be queued per movement step. Walls and the body end the attempt, except that a non-growing head may enter the departing tail's cell.

Load [the recorded tape](verification/tail.tap) through the Spectrum ROM with `LOAD ""`; it starts at the instructions. [The BASIC source](tail-chase.bas) is maintained here. Seven original UDGs distinguish walls, directional heads, body and food. Collision uses stored coordinates and occupancy, never screen colour. The game is silent.

## Build and verification

Use an Emu198x Spectrum executable with its stock 48K ROM configured. From this directory:

```sh
python3 verification/build.py --emulator /path/to/emu198x-spectrum --output /tmp/tail-chase-review
python3 verification/verify.py --emulator /path/to/emu198x-spectrum --output /tmp/tail-chase-review
python3 verification/controls.py --emulator /path/to/emu198x-spectrum --output /tmp/tail-chase-review
```

The builder enters source through ROM keyboard tokens and records `SAVE "tail" LINE 10`. Verification loads that tape in a fresh session, supplies real keyboard events and reads state without injecting fixtures. The entry tool reuses the maintained Meet BASIC ROM-keyboard harness in this repository.

[Results](verification/results.json) record eleven checks, including a complete eight-food round with independently checked ordered body and all occupancy cells. [Control results](verification/controls.json) add queued-turn locking, simultaneous-direction handling and exit from the result screen. [The manifest](verification/manifest.json) identifies the accepted source, tape and four inspected captures. The tape contains one header/data pair with valid checksums.

The user accepted the native prototype: “Works, just fine”. This is distinct from automated correctness evidence and does not establish original-hardware performance or novice learning outcomes. Timing samples observe movement commits during drawing; growth observations wait for replacement food. The 18-frame threshold is a minimum, not a fixed update period or a measurement of host input latency.

Next: agree runnable teaching stages that explain ordered positions, growth and the relationship between body order and occupancy. The circular buffer must be motivated before it becomes lesson code.

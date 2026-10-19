# Input, drawing and sound — sega-master-system

Press **Button 1**. A new press moves an eight-row VRAM glyph, placed in adjacent name-table cells; holding it does not repeat. Release and press again to restore the original position. A short sound uses **SN76489 tone channel 0** while display/input service continues.

This extends the maintained `framework/turn-deadline` caller. `demo.asm` retains its startup and input handling; `picture.inc` owns display setup and drawing; `sound.inc` owns the sound channel and a frame-serviced duration. Include each once, call initialisation before entering the loop, and keep other writers out of those resources. The caller takes over until reset.

`picture.inc` establishes the display state before the main loop. `sound.inc` sets the duration on an accepted press and services it once per loop update. These simple probes own the whole display and the stated sound channel. They do not arbitrate with a music player or preserve an underlying game scene.

Run `make` here with Asm198x available. Sega builds finish a standard 32 KiB cartridge checksum. Use the framework caller's loading and model notes: MTX uses the stock BASIC DATA/POKE/USR route and Einstein uses a stock MOS disk boot; they do not assert cassette or CP/M support. Cartridge systems use their normal reset/firmware entry, with the explicit 7800 authentication limitation retained from its input caller.

The Atari 2600 produces its own field. Its overscan work window is two scanlines, followed by 27 explicit waits; together with the initial overscan line this leaves 30. This is a bounded diagnostic kernel, not room for arbitrary game work. The 5200 and 7800 retain hardware display service.

From the repository root, run `python3 scripts/verify-hardware-capabilities.py --only sega-master-system --native /path/to/native/binaries`. Supply firmware separately with `--firmware-root`. The verifier checks idle/press/hold/release state, captures a fixed-background drawing change and its restoration, records actual PCM, and requires separately omitted drawing and sound calls to fail their original guards. It checks full MTX program loads in chunks rather than assuming one debug read returns an unbounded region.

`verification/results.json` records source, binary, firmware and emulator identities. This is evidence for one named configuration. A changing PCM signal establishes sound output; it does not establish pitch accuracy or every sound mode.

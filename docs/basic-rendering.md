# BASIC maps, text regions and pixel/box adapters

The route inventory is `docs/basic-rendering.json`. Each sample has a complete
caller, includable routines, a contract, retained native captures and the exact
verification callers. The maintained source remains separate from generated
build outputs.

These are independent BASIC language routes. The text-region entries do not
establish native tile, bitmap, scrolling or hardware timing support. Native
assembly entries remain separate. The new map ports add BBC Micro, Electron,
C64, MTX and Spectrum coverage; text-region extraction covers those five and
the ten established BASIC map implementations. Four ROM graphics adapters add
pixels and boxes in BBC, Electron, CPC and Spectrum BASIC.

## Reproduce

Use Emu198x 0.44.1 native executables and their matching producer lock files.
Spectrum also needs Build198x 0.2.13 for its tape. Supply lawful local firmware;
its hashes are retained, not the ROMs. No additional Python packages are needed.

Run from the sample repository, with paths to the tools and firmware:

```sh
python3 scripts/verify-basic-map-regions.py map acorn-bbc-micro acorn-electron commodore-64 memotech-mtx sinclair-zx-spectrum --native /path/to/tools --firmware-root /path/to/roms
python3 scripts/verify-basic-map-regions.py region acorn-atom acorn-bbc-micro acorn-electron amstrad-cpc atari-800xl commodore-pet commodore-vic-20 dragon-32 mattel-aquarius msx oric-atmos spectravideo-svi-328 commodore-64 memotech-mtx sinclair-zx-spectrum --native /path/to/tools --firmware-root /path/to/roms
python3 scripts/verify-basic-pixel-boxes.py acorn-bbc-micro acorn-electron amstrad-cpc sinclair-zx-spectrum --native /path/to/tools --firmware-root /path/to/roms
```

Fresh executions write `build/verification` in each sample. Committed
`verification` directories retain the qualified observations. CI checks these
records and deliberately altered evidence; it does not rerun restricted ROMs.

The Spectrum verification caller reserves a byte at 60000 with CLEAR 59999,
loads a Build198x tape through the real ROM and waits for completion. Other
machines accept numbered lines through their stock keyboard/ROM. MTX uses
physical symbol key chords; BBC explicitly loads the BASIC sideways ROM.
Aquarius uses a 16 KB RAM expansion for the larger diagnostic harness.
Dragon entry allows a full 60 frames after each line: a four-frame gap can
miss the next short line following a long one. The Oric entry helper reads
back its tokenised program before executing it.

Native captures are compared after PNG decoding. Map checks specify logical
results independently, including a non-square stride, invalid coordinates,
rejected writes and world-to-cell boundaries. Region checks require rejection
before any output for an invalid late tile. Pixel/box checks compare whole
rasters with direct ROM line drawing, including erase, far-edge and thin-box
cases. Wrong stride, omitted plotting and wrong coordinate conversion must
fail the same positive guards.

These observations qualify the recorded calls and configurations. They are not
original-hardware tests, performance measurements or whole-emulator claims.

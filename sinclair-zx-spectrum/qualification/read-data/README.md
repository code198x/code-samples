# Read Data diagnostic

The program cold-loads through the +3 ROM disk loader, then reads 3,072 bytes
from three seeded sectors into an uncontended buffer, then copies them to the screen bitmap. It performs single-sector
and multi-sector reads through logical A0/A2, attempts a missing sector, and
reads a valid sector afterwards. A completion signature is written only after
all five commands return their expected number of bytes and seven result bytes.
The external runner checks the actual payload, status, CHRN and byte counts.

This is a fixture for a named PAL +3 configuration, not a claim that every
Spectrum or every Read Data behaviour is qualified. The operation's component,
native-state and release evidence is tracked in
[umbrella #231](https://github.com/stevehill1981/198x/issues/231).

From this repository, with Asm198x 0.0.71 and Build198x 0.2.12 on PATH:

```sh
mkdir -p build/read-data
asm198x --dialect pasmo --cpu z80 --message-format=json \
  sinclair-zx-spectrum/qualification/read-data/diagnostic.asm \
  -o build/read-data/diagnostic.bin > build/read-data/assembly.json
build198x plus3 \
  --basic sinclair-zx-spectrum/qualification/read-data/loader.bas \
  --code build/read-data/diagnostic.bin --load-address 32768 \
  -o build/read-data/mastered.dsk --format json > build/read-data/mastering.json
python3 sinclair-zx-spectrum/qualification/read-data/seed-sectors.py \
  build/read-data/mastered.dsk build/read-data/seeded.dsk build/read-data/fixture.json
```

Use a fresh output directory for another run; the fixture script refuses to
replace an output file. It validates standard 40-track, single-sided,
9×512-byte-sector DSK geometry using the existing `disk-plus3/rearrange.py`
helper. It rejects occupied allocation blocks and non-pristine target sectors.
It changes only track9/head0/sectors1–3 and records exact offsets and hashes.
The original Build198x disk is retained. No new production mastering option is
needed for this synthetic fixture.

Mount `seeded.dsk` in drive A of a cold +3 with English v4.0 firmware and choose
Loader. Do not inject memory or restore a snapshot. Use legitimately obtained
local firmware; this fixture contains no ROM. The BASIC loader runs CODE at
32768. The program explicitly selects non-DMA MFM, seeks track9, and uses
bounded polling. Reads use RAM at49152 to avoid ULA contention during the byte-service window. Runtime host and emulated-time limits belong to the runner.

The expected screen starts with sectors `1,1,2,3,2,3`, each 512 bytes. Byte `i`
of sector `s` is `((i*37) XOR (i>>1) XOR (s*33)) AND255`. The remaining 3,072
bitmap bytes are 170; all 768 attributes are 71. This deliberately makes the
screen depend on bytes transferred by the controller. The original CODE does
not contain the transferred data or the completed signature at its destination.

At completion, addresses 28672–28673 contain 165,90, the final stage at28675 is5,
and PC loops at33011. Trace records begin at28688; their count is at28674.
Each command writes three five-byte records: stage/ST0/ST1/ST2/C,
stage/H/R/N/following-MSR, then stage/count-low/count-high/destination-low/high.
Setup Sense Interrupt records use the existing qualification layout.

Assembly, BASIC and fixture code are MIT licensed. A successful build or a
signature alone does not qualify Read Data. The runner separately verifies
payload bytes, result framing, normal ROM loading, fresh reference execution
and deliberate failures. DMA handshakes, physical flux/search timing and other
machine/firmware configurations remain outside this fixture's claim.

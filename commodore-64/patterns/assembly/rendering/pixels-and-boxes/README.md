# commodore-64: reusable pixels, spans and boxes

Start with demo.asm: initialise its named display configuration, reserve BP,
include the backend once, then call bp_pixel, bp_read, bp_hspan, bp_vspan,
bp_fill or bp_box. It makes a normal direct call before the optional diagnostic
mailbox. Your game does not need that mailbox.

The [shared contract](../../../../../cross-platform/patterns/rendering/remaining-primitives/README.md)
explains every field, native byte order, trusted tables/stride, memory/colour/
DMA/interrupt ownership, stack/register effects, work and storage trade-offs.
6502 callers must enter with decimal mode off; they use CLD during setup.

```sh
make -C commodore-64/patterns/assembly/rendering/pixels-and-boxes ASM198X=/path/to/asm198x
python3 scripts/verify-remaining-primitives.py --system c64 --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-remaining-primitives.py
```

Retained complete observations are under verification/. Fresh runs write
build/verification/. This is an original reset fixture, not stock firmware,
OS loading, physical timing or live-rendering coexistence qualification.

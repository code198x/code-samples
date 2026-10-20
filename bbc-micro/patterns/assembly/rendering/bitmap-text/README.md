# acorn-bbc-micro: fixed-width bitmap text

Start with `demo.asm`: it initialises the stated native mode and directly calls
`text_string` before entering an optional diagnostic mailbox. Copy its setup,
reserve T and BP, include the text component and backend once, provide a readable
font/string and call `text_char` or `text_string` in your own project.

The [shared contract](../../../../../cross-platform/patterns/rendering/bitmap-text/README.md)
explains all fields, signed origin/scissor, native byte order, foreground and
background pens, fallback, advance, source ownership, resources and costs.

From repository root:

```sh
make -C bbc-micro/patterns/assembly/rendering/bitmap-text ASM198X=/path/to/asm198x
python3 scripts/verify-bitmap-text.py --system acorn-bbc-micro --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-bitmap-text.py
```

The fixture is original code, not vendor firmware. Reviewed full observations
are retained under `verification/`; a fresh run writes `build/verification/`.
This establishes the named reset configuration, not an OS application, physical
hardware timings or live-rendering coexistence. See the shared contract before
changing memory allocations, mode or bank ownership.

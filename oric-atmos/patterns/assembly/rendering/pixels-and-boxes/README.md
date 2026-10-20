# oric-atmos: reusable pixels, spans and boxes

Start with `demo.asm`: it owns the stated video configuration, makes a normal
`bp_box` call, then enters an optional diagnostic mailbox. Your game needs the
setup and direct call, not the mailbox. Include the backend once, reserve BP in
zero page and provide the caller's CPU row tables.

The [shared contract](../../../../../cross-platform/patterns/rendering/extended-primitives/README.md)
sets out all six entry points, inputs/outputs, strict bounds, memory ownership,
clobbers, costs and the machine-specific display policy. Read it before changing
the bitmap, mode, attributes, display list, bank mapping or interrupt ownership.

```sh
make -C oric-atmos/patterns/assembly/rendering/pixels-and-boxes ASM198X=/path/to/asm198x
python3 scripts/verify-extended-primitives.py --system oric --native /path/to/native-binaries --assembler /path/to/asm198x
python3 scripts/check-extended-primitives.py
```

This is an original reset fixture. On 5200 that includes an original generated
reset stub, not the manufacturer BIOS. Reviewed complete observations and native
images are retained in verification/. A fresh run writes build/verification/.

# Bounded bitmap text layout — amstrad-cpc

The reusable layout component is `cross-platform/patterns/rendering/text-layout/z80.inc`.
Read the [shared include/init/call contract](../../../../../cross-platform/patterns/rendering/text-layout/README.md).
This caller reuses this machine's existing bitmap-text setup and backend; it does not establish OS coexistence or a frame budget.

Run `make ASM198X=/path/to/asm198x` here. `build/positive/fixture.bin` is the ordinary reset caller; `build/customise/fixture.bin` changes width, alignment, spacing and message data. Load with `--rom` in the named native emulator. No manufacturer firmware is included. The reader-facing caller inputs are in `prepare.inc`; the mailbox in `caller.inc` is only a verification aid.

Reserve TL at $4480 for 64 bytes, T at $4400 for 96, and BP at $4300 for 48 in this reset configuration. Adjust allocations and include paths deliberately for your project. TL/T/BP, source, font, code, stack and display must not overlap.

The retained `verification/` records distinguish positive calls, the customisation, two common mistakes and both repairs. They pin exact sources and tools. The shared verification commands perform fresh execution or retained checking separately.

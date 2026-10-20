# Shared glyphs on SG-1000

Include the maintained [Z80 glyph routine](../../../../../msx/patterns/assembly/rendering/custom-glyphs/glyphs.inc), reserve 24 RAM bytes at G, set G+10=$BE and G+11=$BF, configure Graphics I, then initialise/install/select as shown by `demo.asm`. The diagnostic read port is separately $BE.

The complete [contract, context offsets, costs, maths, source references and verification instructions](../../../../../cross-platform/patterns/rendering/tms-glyphs/README.md) apply. The machine owns patterns $0000–$07FF, names $1800–$1AFF, colours separately, and the VDP address latch. Coordinate IRQ/NMI/bank/OS users. Native qualification uses this original `cart` reset image and default selected emulator configuration; it does not prove stock-OS loading, hardware timing or live transfer budgets.

Run `make ASM=/path/to/asm198x` to build a positive fixture. Run the shared verifier with `--system sega-sg-1000` for this target. `verification/` retains all 24 calls and two completed faulty executables, full 16 KiB snapshots, public outputs/guards and native frames. The 256-byte CPU readback buffer and mailbox are optional diagnostics; games call `glyph_install`, `glyph_replace`, `glyph_select` and `glyph_init` directly.

Original caller, glyph data and captures: Code198x, MIT. No third-party firmware or game assets.

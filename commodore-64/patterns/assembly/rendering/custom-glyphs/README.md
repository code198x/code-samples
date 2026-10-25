# C64 hi-res text: reusable character pictures

Include `glyphs.inc`, reserve G (24 zero-page bytes), establish the caller-owned video/interrupt policy, then call the init/install/select/replace entries directly. The complete `demo.asm` shows setup and `example_install`; its mailbox is optional evidence transport.

Read the [complete contract, encoding, costs, boundaries and references](../../../../../cross-platform/patterns/rendering/native-glyphs/README.md) before combining this with another renderer. This is a specific allocation, not an OS-safe universal font routine.

Build with `make ASM=/path/to/asm198x`. Retained `verification/` contains full memory observations, native frames, public state and source/tool hashes. The family checker independently replays all 20 calls per build, including completed wrong-slot and wrong-name controls. Original assets and code are MIT licensed.

## Keep the standard letters and add your own pictures

You do not have to redraw an alphabet to add a door or a character. `glyph_init_rom` copies one 2 KiB half of the machine's character ROM into the existing $2000 font allocation. Then use the same `glyph_install`, `glyph_replace` and `glyph_select` routines above. Unchanged letters retain their familiar shapes; every cell using a replaced slot changes together.

The new `rom-demo.asm` is a **stock-ROM-loaded PRG**, separate from the original reset-ROM fixture. Load it and RUN. The first Fire press and release installs an original sketch in slot 1 and selects it in cells 82 and 83. The next Fire press replaces that sketch in both cells; holding the button adds no further replacement. `rom-custom.asm` chooses the lowercase ROM half. This is a standalone takeover program and stays in its own loop.

### Include and call the ROM initializer

Define G as 24 private zero-page bytes, ROM_WRONG=0 for the working initializer, and include `glyphs.inc` followed by `rom-init.inc`. Keep the code, context and stack below $A000. Supply **A=0 or 1** for the ROM half and **X=your known $01 output-latch shadow**. After the call, G+7 is accepted/rejected and G+8/9 is the destination-byte count, as with the other glyph routines. Inputs G through G+6 survive; A/X/Y change. The caller's processor flags, including decimal and interrupt state, are restored.

The wrapper requires the three banking DDR bits to be outputs and KERNAL to be already banked out. It checks those conditions and that the shadow matches the port's output bits before making any destination writes. It cannot discover an incorrect shadow for a pin configured as an input: keep the real latch shadow yourself. Reading $01 is not a substitute for that shadow.

**Own NMI handling too.** Disable CIA2 NMI sources and provide a safe RAM NMI vector and handler before calling. The handler must tolerate I/O being hidden. SEI only masks IRQ; it does not mask NMI. This wrapper keeps KERNAL out so the RAM vector stays visible. It is not an OS-friendly routine that can borrow arbitrary BASIC/KERNAL state and return safely.

The temporary mapping selects character ROM rather than the VIC/SID/CIA registers. The exact caller-supplied latch value is restored afterwards; $00 is untouched. The initializer writes **2,048 font bytes**, without clearing the screen or colour RAM. Configure VIC bank 0 and the $2000 font as in the complete caller. See the [Commodore Programmer's Reference Guide, memory management](https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference_guide-05-basic_to_machine_language.pdf) for the bank-control port.

### Why the screen must survive

The old blank-font initializer fills names with code zero. Doing that with a copied ROM font would fill the screen with @ characters. This variant deliberately leaves every name alone. The caller fills its screen with **screen-code 32** spaces, adds its caption and later selects the two original sketches. Screen codes and PETSCII still have different jobs.

### Common error: copying I/O instead of ROM

The wrong build changes one immediate mask from 1 to 5, leaving CHAREN set. The bounded copy completes, but reads I/O-register values rather than the alphabet. Its status and 2,048-byte write count alone cannot prove success. Comparing the full private native font with the selected ROM half catches the error; the native image shows damaged letters. The repaired PRG is byte-for-byte identical to the working PRG.

Restoring an all-RAM CPU mapping also hides I/O. The boundary fixture checks exact restoration, then explicitly selects its I/O-visible map before reading the next joystick handshake. Restoring ownership is not the same as choosing a mapping suitable for the caller's next operation.

### Customisation, cost and evidence

Choose ROM half 0 or 1; change the installed slot and eight source bytes to suit your picture. Reserve slots carefully: replacing a letter also changes every occurrence of that letter. Move the fixed RAM font allocation only by adapting the existing component and VIC configuration together. Proportional text, arbitrary positions, multicolour and a different VIC bank need different allocation/rendering choices.

The wrapper adds **102 code bytes**, uses the existing 24-byte context and copies 2,048 bytes during setup. The complete stock-ROM PRG is 778 bytes including its two-byte load address. One later shared replacement still writes only eight bytes. This is startup work, not a claim that a whole font fits your VBlank budget. The wrapper needs eight stack bytes including its direct call and nested copy helper; allow more for the surrounding caller and any interrupts.

Five native runs on Emu198x 0.44.2 with Asm198x 0.0.72 verify stock-PRG identity before RUN, both ROM halves, untouched screen, complete private font comparison, shared install/replacement, held input, guards and native pixels. A separate six-case guest caller checks invalid half, banking DDR, shadow mismatch, KERNAL visibility, all-RAM restoration and the lowercase half, including preserved decimal/interrupt/carry flags. Nineteen corruption controls reject altered evidence, including a coupled wrong displayed glyph. Complete licensed ROM/font dumps remain private; the retained evidence records hashes and only the few glyphs visible in each capture. This does not establish arbitrary interrupt coexistence or physical-hardware timing.

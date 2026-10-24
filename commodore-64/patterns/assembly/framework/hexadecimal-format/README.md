# Format a Byte as Hexadecimal on C64

Two hexadecimal digits are a compact way to show a byte in a debugger, password or diagnostic panel.

## Use it in a project

VALUE is any byte. Return two ASCII codes, HIGH_CHAR then LOW_CHAR. LOWERCASE=0 selects A–F; any other value selects a–f. No terminator or display write is emitted.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **HIGH_CHAR, LOW_CHAR, VALUE, LOWERCASE**. They occupy 4 contiguous bytes. Also reserve the private workspace: **T0, T1, T2** (3 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `hexadecimal_format_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `hexadecimal_format_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | none |
| Supply before service | VALUE and LOWERCASE |
| Read after service | HIGH_CHAR and LOW_CHAR |

Each nibble selects a decimal digit or a letter offset. The output order is most-significant nibble first, regardless of the machine’s word byte order.

## Machine contract

A/X/status may change; Y and decimal mode are preserved. Use CLD for binary arithmetic. A direct JSR needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. The samples use fixed symbol bindings. Scope or rename every label and binding, including the component_end measurement marker, and allocate a separate block for each independent instance. Different helpers can also use common field names, so combining them needs separate namespaces or explicitly renamed bindings. Give each block one mutation owner.

The diagnostic PRG owns screen, font and colour RAM and disables interrupts; it does not return to BASIC. The reusable helper does none of those things.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Select lower-case digits for FE. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller keeps only the low nibble. AB becomes 0B. Pass the whole byte and let the formatter split the two digits.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 113 code bytes; public state is 4 bytes and private scratch is 3 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Constant work with no lookup table. A sixteen-byte digit table saves branches at the cost of ROM space.

The output is ASCII, not PETSCII screen codes or a NES tile index. Translate through the game’s font mapping before drawing.

## Execution evidence

Four variants run on PAL stock-ROM PRG, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.

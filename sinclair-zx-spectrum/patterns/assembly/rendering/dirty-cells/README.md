# Remember Which Cells Need Redrawing on Spectrum

Changing one cell should not force a whole board to be redrawn.

## Use it in a project

A 16-cell board uses two dirty-mask bytes. MODE=0 marks CELL 0–15; repeated marks coalesce. MODE=1 takes and clears the lowest pending cell, returning FOUND=1 and its CELL; empty returns FOUND=0 and CELL=255. MODE=2 marks all cells. Other modes or an invalid mark index reject without changing masks.

Include `component.inc` once (MOS callers include the shared 6502 implementation through it). Reserve the public fields in this exact order: **MASK_LO, MASK_HI, CELL, MODE, FOUND, VALID**. They occupy 6 contiguous bytes. Also reserve the private workspace: **T0, T1, T2, T3** (4 bytes). Array names in the explanation refer to the numbered consecutive bindings, such as C0, C1 and so on.

Call `dirty_cells_init` once at the intended reset boundary. It clears inputs as well as outputs and workspace. Set your starting state and configuration afterwards, then call `dirty_cells_step` whenever the described event occurs. The helper reads no device, waits for no frame and installs no interrupt handler.

| Ownership | Fields |
|---|---|
| Retain between calls | MASK_LO and MASK_HI |
| Supply before service | MODE and CELL when marking |
| Read after service | CELL when taking, FOUND and VALID |

A bit represents pending work rather than how many times the cell changed. Marking it repeatedly is cheap and idempotent. Taking the lowest bit provides a predictable order for a renderer with a small per-frame budget.

## Machine contract

AF/BC/DE/HL may change; IX/IY are preserved. A direct CALL needs two return-address stack bytes. The helper makes no nested calls and adds no other stack use. Its named scratch is private workspace, not a pointer, a ROM variable or shared zero-page space that the game may borrow concurrently. Scope or rename routine and field labels and allocate a separate block for each independent instance. Give each block one mutation owner.

The 48K diagnostic boots through ROM tape loading and USR, disables interrupts and owns the screen. The helper performs no port or screen writes.

## Adapt the caller

`demo.asm` supplies the bindings and include order. `exercise.inc` first runs table cases, then a separate client retaining state between calls. A game can call the public step entry directly and remove the diagnostic packet and display. Do not copy the diagnostic's hardware takeover into an existing game loop.

Build with `make ASM198X=/path/to/asm198x`. The Makefile produces normal, custom, deliberately wrong and repaired programs. Tools must already be installed; the sample downloads nothing.

## Customise it

Start with all sixteen cells dirty, then drain three. The maintained custom caller changes its inputs or client sequence rather than hiding a different implementation behind the same label. Compare every state of the two clients, not only their final display.

## Mistake and repair

The wrong caller clears both masks before each operation. Pending redraw work disappears before it can be drained. Retain marks across updates and re-mark a taken cell if its redraw cannot be completed.

The BROKEN branch lives in the sequential client, not the reusable helper. `wrong.asm` selects it; `repaired.asm` restores the normal call sequence. The repaired executable matches the normal program (for Spectrum, compare loaded CODE rather than the tape filename).

## Cost and alternatives

The measured helper extent is 402 code bytes; public state is 6 bytes and private scratch is 4 bytes. There are no immutable helper tables. Caller data, the test cases, return-address stack, alignment and display buffers cost additional space. These are assembled sizes, not cycle measurements.

Marking or finding a bit takes at most seven shifts. Sixteen cells need two persistent bytes; a byte-per-cell list is easier to index but takes eight times the flag storage.

Dirty means work pending, not work completed. This take operation clears before drawing, so a failed or deferred draw must re-mark the cell. Interrupt writers need a policy protecting read-modify-write. Hardware tile maps, character grids and bitmap cells use different redraw backends.

## Execution evidence

Four variants run on 48K PAL ROM tape load and USR, using Asm198x 0.0.72, Emu198x 0.44.2. Each executes 64 boundary/varied/error table cases, dirty initialisation and the separate retained-state client. An independent mathematical/container model checks every public byte after every call. This is bounded example coverage, not exhaustive correctness for every possible state.

The records retain loaded immutable code, completion, register sentinels, full packets, source/tool/firmware hashes and captures. The public gate validates these retained observations and rejects altered evidence; it does not run restricted firmware. No firmware is distributed. The eight displayed bytes are the first eight public fields, zero-padded when shorter; the packet includes every field.

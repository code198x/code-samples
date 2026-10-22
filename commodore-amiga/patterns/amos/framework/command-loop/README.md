# Advance an untimed game by accepted commands (AMOS)

Use this in AMOS Professional 2.00, with its own default graphics screen and keyboard buffer. A changes the counter, X does nothing, and Q leaves. This is an untimed command loop: waiting for a decision does not advance the game. It does not promise animation or a turn deadline while input blocks.

## Include, initialise and call

`caller.amos` and `routines.amos` are two readable pieces of one program. Append the routines **after End**; `demo.amos` is that exact combined source. Do not run the routines by themselves or fall through into a Return. Initialise the counter and step once. Supply a command, call PL_ADVANCE, and inspect PL_ACCEPTED before triggering feedback.

PL_COUNT and PL_STEP (Blitz: PL_count.l and PL_step.l) are caller-owned integer values in 0..255. PL_KEY$ supplies an uppercase command; PL_ACCEPTED returns 1 for A and 0 otherwise. Only A changes the counter. The addition wraps modulo 256. With both inputs bounded to 255 the sum is at most 510, so one subtraction suffices. Values outside those bounds need a different contract. Q is handled by the caller, not by the reusable state routine.

The update routine neither reads input nor draws, waits, allocates a bitmap, starts audio or installs an interrupt. Its string and integer globals must not collide with another module. This is a single mutable context: distinct players require distinct state or an explicit parameter/context adaptation. No reentrancy claim follows.

## Make it your own

`customise.amos` changes only the initial step from 1 to 3. Three accepted commands should produce 0, 3, 6, 9. At 254 a step of 3 gives 1. The routine and state layout stay the same; no extra asset is required. This changes the rule, not the input speed. Signed integer arithmetic must be retained on Blitz; a byte variable could wrap before the comparison.

## A reset in the wrong place

`mistakes/reset-each-command.amos` is deliberately broken. Initialising the counter inside the command loop discards earlier turns. A then A shows 1 then 1 instead of 1 then 2. Move that single assignment back before Repeat. Restore `demo.amos` to check the repair. The wrong source is separate from the working download.

## Costs and alternatives

State work is one command comparison and, for A, an addition, range test and possible subtraction. This is an operation count, not a cycle or whole-frame budget. The interpreter/compiler, strings, console/screen and resident runtime cost much more than these few values; source bytes are not executable or runtime memory use. The reader owns the blocking wait and display policy.

A sampled game loop is a different choice when movement, audio servicing or deadlines must continue while the player thinks. Keep the clock and presentation separate from accepting an action. Do not replace every wait with a busy loop and call it real-time support.

## Execution status

The native records and captures are in [verification/](verification/README.md). Six variants were executed separately from the same booted, empty-editor checkpoint. Each was imported/entered, checked or compiled, and exercised with actual keyboard input. The retained checker reads counter glyphs from the framebuffer; transport success alone is insufficient.

## AMOS input and screen ownership

PL_READ_FRESH reuses the established Bank or Risk reader: retain PL_LASTSCAN=-1 initially and then across calls. It waits for release of the previous delivered key, clears the buffer, then accepts an uppercase INKEY$ character and retains its scan code. Other simultaneous keys, typeahead and keyboard repeat are not promised as queued commands: clearing the buffer discards them deliberately. WAIT VBL yields at each poll; it is not an elapsed-time simulation clock. A press wholly between samples can be missed.

The caller sets palette entries 0/1, paper/pen, clears the current screen and hides the pointer; it restores pointer visibility at normal exit. Integrating it into an existing screen requires choosing your own palette, drawing area and exit policy. It does not restore the old screen pixels or palette. Labels and globals use PL_ to avoid AMOS command-prefix name collisions.

The `.amos` files here contain ASCII source, not tokenised saved projects. Merge ASCII a copy named `.asc` into a blank project; F2 checks syntax and F1 runs. A native saved project is a separate artefact. See the original manual: [keyboard](https://amospromanual.dev/10-01-using-the-keyboard.html), [control structures](https://amospromanual.dev/05-04-control-structures.html), and the maintained [fresh-key source](../../../../amos/bank-or-risk/stages/session/read-fresh.amos).

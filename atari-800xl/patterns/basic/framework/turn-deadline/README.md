# Optional turn deadlines in Atari BASIC

Joystick-one fire takes one turn; a held button needs release before another action. Waiting takes no turn until SELECT enables a deadline. OPTION stops the caller after release. Timing starts at 240 OS clock ticks, about four seconds on the qualified NTSC 800XL. The first eight screen cells show hexadecimal turns, expiries and enabled state.

## Build and use

Run `make` here. Enter the complete build/demo.bas through stock Atari BASIC, one numbered line at a time, then RUN. NEW/reset before replacing complete variants. There is no assembly dependency, tokenised program injection or supplied ROM. The build concatenates maintained sources; line numbers determine execution order. Keep them unique and renumber every reference together.

The caller sets RAMTOP (106) to 124 before GRAPHICS 0. BASIC and the display stay below $7C00, leaving a 1 KiB clear/scroll margin below the optional native observer at $8000–$8012. The display address follows SAVMSC (88/89). This is a named 64 KiB layout, not a memory allocator; no DOS/cartridge/other routine may own the reserved RAM. Removing observer calls and monitor.bas removes the mailbox requirement, but your own screen and memory layout still need a valid reservation. The sample leaves that reservation in place after STOP.

## Take the countdown

The unchanged maintained helper is dragon-32/patterns/basic/framework/turn-deadline/routines.bas. Atari BASIC supports its statements and decimal arithmetic contract; the native boundary caller checks the required integer range.

- Supply DU and DC as whole tick values 0..65535. GOSUB 3000 initialises DP/DR/DA/DX/DE, retaining duration and starting disabled.
- GOSUB 3100 starts a nonzero duration. It retains the latest sampled baseline; poll immediately before starting if that instant matters.
- Supply the next DC and GOSUB 3200 on every iteration, including while disabled. DR is remaining, DA active, DX the one-poll expiry flag, DE elapsed and DP previous. Read DX before another poll/start clears it.

The helper owns those seven global numeric names and uses the interpreter's GOSUB stack. It owns no screen, input or interrupt service. Use a separate context/name set for another timer; one global context is not re-entrant. Validate the caller's integer range; this helper does not clamp arbitrary fractional or out-of-range inputs.

Subtraction wraps modulo 65536: 65526 to 10 means twenty ticks. Poll less than one full cycle apart, roughly 18 minutes 12 seconds at nominal 60 Hz. An extra whole cycle cannot be recovered. Reinitialise after an external clock reset. Zero duration means off. Late polling emits once, not a burst of catch-up turns; restart at observation time can drift. A wider clock/helper or preserved pause is a different policy with more state and work.

## Read without owning the OS

clock.bas samples PEEK(19), PEEK(20), then PEEK(19) again. A changed middle byte retries the read, avoiding a carry-torn low-word sample. DH/DL are scratch; DC is the result. Normal VBI runs under NMI: SEI in an assembly caller would not stop it. This BASIC adapter never writes RTCLOK. The full OS clock occupies 18–20; this helper deliberately uses its low sixteen bits. PAL needs a different tick-to-seconds conversion. Clock sampling is not display pacing.

input.bas returns K=0 none, 1 action, 2 toggle, 3 quit. KH is the release gate, CS/F scratch. STRIG(0) and GTIA CONSOL are active-low; OPTION wins over SELECT over fire. All three controls must be observed released to re-arm. START is ignored. A short press entirely between polls can be missed. The adapter does not consume the keyboard buffer or write input shadows/registers. Atari BASIC AND is a logical operation; console bits are tested by division and INT, not a borrowed bitwise expression.

The pure dispatch.bas takes K/DX, owns N/EX and produces CH for redraw. Expiry wins over commands, including quit and toggle. An action restarts only enabled timing; an untimed action remains untimed. Disabling discards the remainder, enabling starts a full duration. Counters wrap as bytes. Replace the increment with a world update. Blocking INPUT would stop deadline service; menu waits need a deliberate timing policy.

presentation.bas draws only the first eight GRAPHICS 0 cells using ANTIC screen codes and the current SAVMSC pointer. SB/V/O/H/L are scratch. It does not change a font or display list. Redrawing only on CH avoids repeated BASIC display work. It requires N/EX to remain byte values and DA to remain 0/1.

monitor.bas serialises a coherent nineteen-byte observation, with its completion marker cleared first and written last. It owns no game policy. MB is the base, offsets 0..3 are N/EX/DA/DX; little-endian words at 4/6/8/10/12 are DR/DC/DP/DE/DU. Offsets 16/17 are guards and 18 completion. O/V/H/L overlap presentation scratch only in sequential calls. Remove monitoring from your own game when unnecessary; its runtime is part of these observed service intervals.

## Customise, break and repair

customise.bas changes DU=240 to 120, about two seconds on this configuration. Choose units and maximum polling gap before a number. The Maths for Games connections are units, unsigned ranges, modular differences and choosing elapsed-time service independently of rendering.

mistakes/reset-baseline.bas deliberately replaces clock.bas and sets DP=DC just before polling. The clock advances but every elapsed interval is zero, remaining stays full and the display remains 01 00 01. Restore clock.bas and rebuild; a fresh repaired run reaches 03 01 01. The fault adds six tokenised bytes; customisation leaves the program/helper sizes unchanged. Never combine both adapters. Keep helper code unchanged when demonstrating an adapter mistake.

## Measured costs

The complete working program occupies 1,992 native tokenised bytes, including line headers; the shared helper accounts for 273. The observed program has 22 scalar variables: 176 value-table bytes and 37 name-table bytes. The helper's seven two-letter names use 56 value bytes plus 14 name bytes, 70 total. These costs belong to Atari BASIC, not to the shared source text across all dialects. They are snapshots rather than peak interpreter stack/workspace bounds.

Observed instrumented service intervals are commonly 18–20 nominal 60 Hz ticks. That includes BASIC interpretation, input, arbitration and optional serialisation, not a helper-only timing. The sample is suitable for turn deadlines; it is not a claim of smooth 60 Hz BASIC game updates. Removing monitoring reduces work; a faster assembly service or coarser world updates have different development/runtime trade-offs.

## Native checks and limits

The verifier enters every source line through the real keyboard. It inventories native tokenised records and scalar name/value tables before RUN, checks the program remains unchanged during execution, exercises real fire/console controls, and requires BASIC arithmetic after STOP. It does not write program RAM or set the PC. The immediate-mode record uses line number 32768: three bytes when empty, six with the entered RUN command. Its bounded extent is checked separately from numbered program text.

Independent working/custom/wrong/repaired callers are accompanied by a second caller supplying twelve clock pairs and three simultaneous-event policies. A deliberately wrong equality check completes its guards but fails the independent unsigned oracle. These supplied samples do not establish an observed eighteen-minute live rollover. Captures are checked against native screen codes and ROM glyphs, with falsified records required to fail.

Qualification names Emu198x 0.44.2, stock 800XL NTSC OS Rev 2 and the recorded Atari BASIC ROM. Firmware/source/tool identities accompany the observations. This is not original-hardware, every-region/ROM or whole-emulator qualification. Run scripts/verify-atari-xl-basic-deadlines.py with your own firmware; recheck retained results with scripts/check-atari-xl-basic-deadlines.py and its unittest controls.

Primary references: Atari BASIC Reference Manual, GRAPHICS, STRIG, POSITION, PEEK/POKE and numeric variables; Ian Chadwick, Mapping the Atari, RTCLOK 18–20, SAVMSC 88–89, RAMTOP 106, BASIC pointers 128–145, variable name/value tables 130–137 and CONSOL 53279. Public scan: https://www.atarimania.com/documents/Mapping-the-Atari.pdf . Countdown, retry sampling and arbitration are implementation choices.

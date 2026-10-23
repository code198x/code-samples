# Optional timed turns on C64 in assembly

Space takes one turn. Initially nothing happens while you wait. T enables a 240-jiffy deadline; expiry takes one turn without input. Space then takes a turn and restarts the active deadline. T disables it and discards remaining time. Re-enabling starts a fresh deadline. Reset leaves the demonstration.

## Build and integrate

Run `make -C commodore-64/patterns/assembly/framework/turn-deadline ASM198X=/path/to/asm198x` from this checkout. The checked assembler is Asm198x 0.0.72. Load `build/demo.prg` as a BASIC program and RUN; its SYS stub starts the caller. The evidence configuration is **40-column PAL C64** with the named stock ROMs and normal KERNAL interrupts. C64 verification imports the PRG in the headless startup path, saves that booted state and resumes it in MCP before typing RUN; the VIC-20 uses its program importer and stock RUN/SYS. Neither writes debugger state.

`demo.asm` includes settings, clock/input adapters, the existing BBC/Electron policy dispatcher and the shared `cross-platform/patterns/framework/elapsed-deadline/6502.inc`. VIC-20 uses the C64 clock/input adapters directly. Keep the whole checkout when building those relative includes. Code belongs at the machine's own BASIC load address; do not load the C64 PRG on the VIC-20.

The PRG occupies **483 bytes** including its BASIC stub and padding (485 bytes on disk including the load address). The shared deadline helper is 140 bytes and the adapter is 63 bytes, already included in that total. The working VIC-20 image ends at $11E3, below the fixture/state/screen allocations. The independently run larger boundary caller also fits stock RAM; it is a test program, not required by a game.

## Call contract

Reserve the 12-byte DEADLINE context at $C000; duration is offsets 0–1, remaining 2–3, active 4, one-poll expiry 5, elapsed 6–7, previous sample 8–9 and scratch 10–11. The caller adds two guard bytes, ten STATE bytes and eight CLOCK bytes at $C030: **32 owned bytes**, excluding code and the ordinary hardware stack. Clear the eight clock bytes once before the first sample. The example owns those allocations while running. BASIC is suspended inside SYS; do not run interpreter allocation or another owner over the same memory.

Set duration 1–65535 ticks (zero disables), CLD, preserve normal IRQ service, then call `sample_clock` and `deadline_init`. It starts disabled. `deadline_start` copies duration into remaining time. On every service iteration call `sample_clock` then `deadline_poll`, including while disabled. A/X carry the low/high 16-bit sample. `deadline_poll` clobbers A/X/P and preserves Y; the KERNAL adapter/input/display paths may clobber A/X/Y/P. They are mainline routines, not interrupt-safe services; RDTIM itself enables interrupts. Give each countdown its own context if extending this fixed-address example to multiple owners.

`normalise_clock` is separately callable with **A low, X middle, Y high** raw KERNAL time. It remembers the previous 24-bit value, corrects the midnight reset by adding the low word of 5,184,000, and returns a 16-bit sample in A/X. The native fixture is a second caller: it tests ordinary low-word wrap, midnight, exact expiry and overdue polls using guest instructions. It also checks that expiry beats Space or T and that T beats Space when both input bits are present.

Keep consecutive samples less than 65536 jiffies apart and do not call SETTIM or reset TI$ in another part of the program. The adapter treats a backward raw clock as the ordinary daily reset; it cannot distinguish arbitrary external clock changes. Reinitialise the adapter and deadline after an intentional clock change. This is nominally a 60 Hz service clock, not a raster clock: the retained 30-PAL-field samples count 35–36 ticks. Those observations do not measure helper execution cycles. Long IRQ blocking can lose clock service; a countdown cannot recover uncounted time.

## Input and arbitration

The caller restores default channels with CLRCHN and polls GETIN. Space maps to bit 0 and T to bit 1. These are **delivered characters**, not physical press edges. Firmware repeat and buffered characters are possible. Keep GETIN on its keyboard channel; a project using CHKIN must restore channels or supply a different sampler. Physical edge routines are a separate option, not a promise of this entry.

Poll the clock, read one character, then dispatch expiry first. An expiry discards that iteration's character, spends one turn and starts one new deadline; there is no catch-up burst. Otherwise T toggles before Space. Untimed actions stay untimed. Drawing happens after changes, not on every poll. Neither a blocking GET nor a frame wait belongs between clock samples if it can exceed the sampling bound.

## Make it your own

Change `DURATION = 240` in settings.inc to `DURATION = 120`. The retained `custom-duration` build applies precisely that change: the same caller expires after half as many clock ticks, with no code-size change. This changes game policy, not the clock rate. The setting costs two bytes already allocated in DEADLINE. Different input, pause-preserve, multiple timers or catch-up policies need their own design and qualification.

## A revealing mistake

`bbc-micro/patterns/assembly/framework/turn-deadline/mistakes/input-gated-expiry.inc` deliberately returns when no input bit is present, before consuming expiry. In the independently run `wrong-input-gate` caller the helper reaches inactive/zero remaining, but no automatic turn happens: the screen stays `0001 00 01` because it was never redrawn. The native state and stale screen are different observations. Replace that dispatcher with the maintained normal dispatcher: `repaired` is byte-identical to `working` and shows `0002 01 01` after the same sequence.

The boundary fixtures also prove that changing exact-expiry equality or omitting midnight correction fails an independent arithmetic oracle. They complete with a marker before being rejected; an incomplete loader cannot count as an arithmetic failure. Captures of these fixture programs are not visual arithmetic demonstrations; their retained byte results are the evidence.

## Verification and sources

`verification/results.json` and `configuration.json` bind released Emu198x 0.44.2, assembler and firmware hashes, all maintained source/observer hashes, seven independent boots, code-image comparisons and framebuffer captures. The retained checker decodes the visible native digits as well as checking clock/state progression; 24 deliberate record corruptions must fail. Run `python3 scripts/check-commodore-deadlines.py` and `python3 -m unittest discover -s scripts -p test_commodore_deadlines.py -v`. Fresh capture requires the observer's explicit released tool and lawful firmware arguments. ROMs are not redistributed.

Primary sources: Commodore's [C64 KERNAL source listing](https://www.pagetable.com/docs/C64_KERNAL_03_LST.pdf), RDTIM/SETTIM at $F6DD/$F6E4, and the KERNAL sections of the C64 and VIC-20 Programmer's Reference Guides. The C64 guide's RDTIM register description reverses the outer bytes; the original source and the actual named firmware implement A=low, X=middle, Y=high. GETIN is channel-sensitive and normal IRQ service owns clock/keyboard updates. Configuration-specific emulator execution is not original-hardware verification, proof of other ROMs, a minimum-RAM measurement or a worst-case game budget.

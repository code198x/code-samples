# Optional timed turns on PET in assembly

Space takes one turn. Initially nothing happens while you wait. T enables a 240-jiffy deadline; expiry takes one turn without input. Space then takes a turn and restarts the active deadline. T disables it and discards remaining time. Re-enabling starts a fresh deadline. Reset leaves the demonstration.

## Build and integrate

Run `make -C commodore-pet/patterns/assembly/framework/turn-deadline ASM198X=/path/to/asm198x` from this checkout. The checked assembler is Asm198x 0.0.72. Load `build/demo.prg` as a BASIC program and RUN; its SYS stub starts the caller. The evidence configuration is **40-column upgrade-ROM PET, 32 KiB, default emulator timing** with the named stock ROMs and normal KERNAL interrupts. The PET uses its program importer and stock RUN/SYS; the observer never writes debugger state.

`demo.asm` includes settings, clock/input adapters, the existing BBC/Electron policy dispatcher and the shared `cross-platform/patterns/framework/elapsed-deadline/6502.inc`. PET shares the C64 input sampler, with its own clock adapter. Keep the whole checkout when building those relative includes. Code belongs at the machine's own BASIC load address; do not load the C64 PRG on the PET.

The PRG occupies **489 bytes** including its BASIC stub and padding (491 bytes on disk including the load address). The shared deadline helper is 140 bytes and the adapter is 69 bytes, already included in that total. The working PET image ends at $05E9, below the fixture/state/screen allocations. The independently run larger boundary caller also fits stock RAM; it is a test program, not required by a game.

## Call contract

Reserve the 12-byte DEADLINE context at $7000; duration is offsets 0–1, remaining 2–3, active 4, one-poll expiry 5, elapsed 6–7, previous sample 8–9 and scratch 10–11. The caller adds two guard bytes, ten STATE bytes and eight CLOCK bytes at $7030: **32 owned bytes**, excluding code and the ordinary hardware stack. Clear the eight clock bytes once before the first sample. The example owns those allocations while running. BASIC is suspended inside SYS; do not run interpreter allocation or another owner over the same memory.

Set duration 1–65535 ticks (zero disables), CLD, preserve normal IRQ service, then call `sample_clock` and `deadline_init`. It starts disabled. `deadline_start` copies duration into remaining time. On every service iteration call `sample_clock` then `deadline_poll`, including while disabled. A/X carry the low/high 16-bit sample. `deadline_poll` clobbers A/X/P and preserves Y; the KERNAL adapter/input/display paths may clobber A/X/Y/P. They are mainline routines; the input/display firmware has its own effects. The PET clock sampler preserves the interrupt-enable flag rather than calling a later machine’s RDTIM. Give each countdown its own context if extending this fixed-address example to multiple owners.

The PET clock adapter snapshots $8D high, $8E middle and $8F low inside PHP/SEI/PLP, preserving the interrupt-enable flag during the three-byte read. Its later arithmetic clobbers flags as stated. It does not call the later VIC-20/C64 RDTIM entry: that address is not a compatible clock API in the named PET firmware. `normalise_clock` is separately callable with **A low, X middle, Y high** raw firmware time. It remembers the previous 24-bit value, corrects the midnight reset by adding the low word of 5,184,000, and returns a 16-bit sample in A/X. The native fixture is a second caller: it tests ordinary low-word wrap, midnight, exact expiry and overdue polls using guest instructions. It also checks that expiry beats Space or T and that T beats Space when both input bits are present.

Keep consecutive samples less than 65536 jiffies apart and do not write the firmware clock or reset TI$ in another part of the program. The adapter treats a backward raw clock as the ordinary daily reset; it cannot distinguish arbitrary external clock changes. Reinitialise the adapter and deadline after an intentional clock change. In this released 40-column configuration, the retained 30-field samples count 30 ticks. Its default PAL frame is 20,032 CPU cycles at 1 MHz (about 49.92 fields/s), so 240 observed clock ticks are about 4.8 seconds here. The manual’s nominal 1/60-second description must not be used as a wall-clock conversion for this configuration. The deadline counts firmware ticks; it does not install display pacing. Those observations do not measure helper execution cycles. Long IRQ blocking can lose clock service; a countdown cannot recover uncounted time.

## Input and arbitration

The caller restores default channels with CLRCHN and polls GETIN. Space maps to bit 0 and T to bit 1. These are **delivered characters**, not physical press edges. Firmware repeat and buffered characters are possible. Keep GETIN on its keyboard channel; a project using CHKIN must restore channels or supply a different sampler. Physical edge routines are a separate option, not a promise of this entry.

Poll the clock, read one character, then dispatch expiry first. An expiry discards that iteration's character, spends one turn and starts one new deadline; there is no catch-up burst. Otherwise T toggles before Space. Untimed actions stay untimed. Drawing happens after changes, not on every poll. Neither a blocking INPUT nor a frame wait belongs between clock samples if it can exceed the sampling bound.

## Make it your own

Change `DURATION = 240` in settings.inc to `DURATION = 120`. The retained `custom-duration` build applies precisely that change: the same caller expires after half as many clock ticks, with no code-size change. This changes game policy, not the clock rate. The setting costs two bytes already allocated in DEADLINE. Different input, pause-preserve, multiple timers or catch-up policies need their own design and qualification.

## A revealing mistake

`bbc-micro/patterns/assembly/framework/turn-deadline/mistakes/input-gated-expiry.inc` deliberately returns when no input bit is present, before consuming expiry. In the independently run `wrong-input-gate` caller the helper reaches inactive/zero remaining, but no automatic turn happens: the screen stays `0001 00 01` because it was never redrawn. The native state and stale screen are different observations. Replace that dispatcher with the maintained normal dispatcher: `repaired` is byte-identical to `working` and shows `0002 01 01` after the same sequence.

The boundary fixtures also prove that changing exact-expiry equality or omitting midnight correction fails an independent arithmetic oracle. They complete with a marker before being rejected; an incomplete loader cannot count as an arithmetic failure. Captures of these fixture programs are not visual arithmetic demonstrations; their retained byte results are the evidence.

## Verification and sources

`verification/results.json` and `configuration.json` bind released Emu198x 0.44.2, assembler and firmware hashes, all maintained source/observer hashes, seven independent boots, code-image comparisons and framebuffer captures. The retained checker decodes the visible native digits as well as checking clock/state progression; 12 deliberate record corruptions must fail. Run `python3 scripts/check-pet-deadlines.py` and `python3 -m unittest discover -s scripts -p test_pet_deadlines.py -v`. Fresh capture requires the observer's explicit released tool and lawful firmware arguments. ROMs are not redistributed.

Primary source: the [Commodore PET User Manual, table 6-2, revision-3 memory map](https://www.manualslib.com/manual/1024284/Commodore-Pet.html?page=349) places the high-to-low jiffy clock at $8D–$8F, with a 5,184,000-jiffy reset. The retained firmware hashes identify the upgrade-ROM configuration. Do not infer the original BASIC 1 ROM map or later VIC-20/C64 jump-table semantics. GETIN is channel-sensitive and normal IRQ service owns clock/keyboard updates. Configuration-specific emulator execution is not original-hardware verification, proof of other ROMs, a minimum-RAM measurement or a worst-case game budget.

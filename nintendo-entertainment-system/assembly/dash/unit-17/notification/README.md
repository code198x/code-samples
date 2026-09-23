# Dash: account for a missed notification

C09d investigates the read/clear shape in unit 17's actual `nmi_flag` main loop. It deliberately widens the vulnerable interval in a separate diagnostic copy. It establishes a possible interleaving, not an observed glitch during ordinary play. The ordinary game, ROM, music player and WASM are unchanged. This counter is not the preceding request mailbox.

## Reproduce and baseline

```sh
python3 check.py --emulator /path/to/emu198x-nes --output /tmp/dash-notification
```

The runner pins `dash.asm` to SHA-256 `c167968967e48ee77e54ca540beabe61e7272a9b4c92a7a1ad6528d1b6ed43dc`, rebuilds it byte-identically to the maintained `dash.nes`, then writes generated diagnostic sources and ROMs outside the project. The original source and ROM are the recovery checkpoint. `results.json` records Asm198x version, emulator identity and generated source/ROM hashes. Target: NES NTSC, native Emu198x MCP execution, normal reset and title setup. No host memory injection, input replay or original-hardware check.

The fixture replaces main dispatch with a diagnostic sequence, retaining the original title display and NMI save/restore, DMA and PPU work. Scratch bytes $50–$58 and log rows $0300–$0317 do not overlap this game's variables, stack or OAM. `notification_armed` controls diagnostic event production; it is not part of the proposed counter protocol. `wait_notification` waits for an actual VBlank NMI, not a host callback. Generated source makes the inserted wait inspectable.

## Two different contracts

A flag says “at least one event is pending”; repeated writes of 1 merge events. That can be an intentional redraw policy. It cannot promise one service per event. A read followed by a separate clear also permits a new write between them to disappear.

Here we deliberately require one acknowledgement per generated notification. `counter.asm` assigns `produced` to NMI and `consumed` to main. Both begin equal. Pending count is their unsigned byte difference, with capacity 255. NMI refuses the increment that would make a full counter indistinguishable from empty, sets sticky `notification_overflow` and stops accepting further notifications. Main stops taking new work once it observes overflow. A take already in flight can finish if overflow arrives after its check; this is not transactional cancellation. Reset/recovery requires stopping the producer before reinitialising both bytes. No live reset protocol is implemented here.

`take_one` acknowledges at most one notification per call. It does not play a note, advance simulation or recover earlier input. Carry reports an acknowledgement; the separate overflow byte distinguishes a stopped experiment from an empty counter. A real caller needs an explicit failure/recovery policy. We retain backlog rather than drain it in an unbounded loop. Capacity does not establish an acceptable delay: an application should react to unacceptable lateness far sooner than 255 outstanding frames.

An NMI can make the sampled produced value stale. With one writer per byte, no nested NMI and the capacity rule, this can delay discovery of new work; it cannot clear the producer's increment. `INC consumed` operates on ordinary RAM and completes before interrupt service. Do not transfer this reasoning to device registers, a second consumer, multicore code or a producer that can lap the counter unchecked. The handler preserves A/X/Y; interrupt return restores status and the interrupted main context.

## Predict, then inspect

Each row records `[produced, consumed, unsigned difference, flag, serviced, overflow]`. In the faulty variant, the counters are observation machinery only: main clears the flag and increments `serviced`; it never advances `consumed`. Its difference column is therefore not the true remaining service count.

| Case | Before take | After interruption and first take | After second attempt |
|---|---|---|---|
| Flag | flag 1, generated 1 | generated 2, flag 0, serviced 1 | still serviced 1: one notification lost |
| Counter | produced 1, consumed 0 | produced 2, consumed 1 | produced 2, consumed 2: empty |
| Wrap | produced 255, consumed 254 | produced 0, consumed 255 | both 0: empty |
| Backlog | produced 3, consumed 0 | produced 4, consumed 1 | produced 4, consumed 2: two remain |
| Overflow | seeded with 254 pending | first event reaches 255; second sets overflow | third cannot wrap; no new take |

Empty takes after the counter and wrap cases must return carry clear without increasing `serviced`. The backlog test deliberately ends with two retained notifications; it does not pretend to have serviced them. Overflow is an artificial near-capacity initialisation, not a claim that 256 events were played or heard.

## Execution evidence and limits

All five generated cases and fresh-process repeats pass. The checker steps each exercised NMI through RTI, checks A/X/Y and stack restoration, and records handler cycles and return scanline. Measured costs include DMA and diagnostic machinery but exclude interrupt entry and preceding-instruction latency. Observed instrumented handler costs span 825–841 CPU cycles, including DMA. All measured title paths return on scanline 248, within NTSC VBlank. Consult `results.json` for individual costs; these are observed paths, not a worst-case proof or an entire-frame graphics allowance. No additional graphics or audio work was moved into NMI.

The three overflow interrupts also demonstrate that the sticky stop survives another producer call. The ordinary source rebuild matches its ROM. This is not a gameplay regression run, a PAL check, an audio-quality comparison or a learner trial.

## Hardware basis

[NESdev CPU interrupts](https://www.nesdev.org/wiki/Interrupts), including its instruction-polling discussion, distinguishes NMI from maskable IRQ. [Visual6502 interrupt timing research](https://www.nesdev.org/wiki/Visual6502wiki/6502_Timing_of_Interrupt_Handling) provides focused instruction-boundary evidence. SEI does not exclude NES VBlank NMI; toggling PPU NMI enable is not used as a lock. This companion concerns a software notification lost after an interrupt has run, not a missing electrical NMI edge.

The small routine addresses notification accounting only. A counter cannot reconstruct inputs, make late audio punctual or decide whether stale presentation work should be dropped. Those require an explicit game policy and timing measurements.

The 2,468-page Astro build passes. The generated lesson renders its source and all three new disclosures open using the keyboard at 1280px and 390px widths; both views were inspected. Route, template-whitespace and diff checks pass. This is local preview evidence, not publication or a learner trial.

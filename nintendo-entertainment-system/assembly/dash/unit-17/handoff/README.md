# Dash: publish a complete period request

C09c is an isolated main/NMI handoff experiment. Dash's ordinary `tune_tick` runs in main; it does not already use this mailbox or exhibit the demonstrated fault. The companion generates copies of unit 17, preserves its title rendering and normal NMI save/restore/display work, and replaces gameplay dispatch with a short diagnostic producer. It is not a game release or a second music engine.

## Reproduce

```sh
python3 check.py --emulator /path/to/emu198x-nes --output /tmp/dash-handoff
```

The runner pins `dash.asm`, requires a byte-identical rebuild of its maintained ROM, then assembles early-publication and complete-publication copies into the output directory. `mailbox.asm` is the small protocol; `experiment.asm` supplies deliberate waits and logging. No host memory injection is used. Ordinary samples, ROM and WASM are unchanged.

## Ownership and contract

One main-code producer and one non-reentrant NMI consumer share three ordinary RAM bytes: ready, period low and period high. Only an empty slot belongs to main. Main fills it, publishes ready with a final byte store, then leaves it untouched. The handler uses the complete pair and clears ready after the last read. NMI's existing A/X/Y preservation covers the extra consumer. Main is suspended while the handler executes; there are not two CPU threads running at once.

`publish_period` takes X/Y as the period pair. Carry clear means accepted; carry set means full and no payload write occurred. The caller retains its intention and retries after a later interrupt; it does not spin inside NMI or silently discard the request. The fixture reloads the refused pair explicitly on retry. This is one slot, not a queue. Main's empty check is sufficient under these assumptions because the consumer can only empty the slot and no other producer can fill it.

The consumer does not wait or loop. It applies at most one pair to pulse 1. During the test the normal main player is not running, so it cannot compete for those registers. After the final empty check the diagnostic main code silences the channel as an explicit end to the experiment. These by-value bytes have no external buffer lifetime. A pointer to sample or pattern data would require a separate lifetime agreement.

## Deterministic interleaving

`wait_handoff_nmi` waits for the handler's clock byte to change. These waits deliberately stretch the interval between stores; they are diagnostic machinery, not part of the repaired publisher. The NMI clock can wrap, but the fixture waits for one change over six stages, not for a long elapsed count.

Initial storage is `$011C`, matching an existing title-note period. Main wants `$00D5`, an existing fanfare period. The faulty copy publishes before updating the pair, writes `$D5` low, waits for a real VBlank NMI, then writes high zero. The safe copy keeps ready clear through the identical wait, completes high zero, then publishes.

| Stage | Early publication | Complete publication |
|---|---|---|
| 1: empty | No period writes | No period writes |
| 2: low changed, high still old | Consumes `$01D5` | Ignores incomplete storage |
| 3: high now zero | Empty; intended pair was never delivered | Consumes `$00D5` |
| 4: request A `$0152`, then B `$017C` while full | B refused; consumes A | B refused; consumes A |
| 5: retry B | Consumes B | Consumes B |
| 6: empty again | No repeat | No repeat |

The two-byte period is not one atomic update. A single completed ready-byte store can publish it relative to this CPU interrupt observer. That does not make every byte-based operation atomic: C09d separately investigates a read/clear notification sequence.

## Native evidence

`results.json` records native NTSC execution, source/ROM/emulator hashes, six actual handler-entry observations per copy and a matching cold repeat. It also records the A values at executed `STA $4002` and `STA $4003` instructions. Empty stages execute neither period write. Both full-slot checks preserve `$0152`; the deferred flag records the refused B request.

Each instrumented title NMI preserves A/X/Y and returns with balanced interrupt-stack use on scanline 248. From first handler instruction through RTI, including OAM DMA and diagnostic logging, observed cost is 864–865 CPU cycles for empty cases and 895 for consuming cases. Interrupt entry and preceding instruction latency are excluded. This checks the named paths, not every possible graphics load, PAL timing, original hardware, native audio quality or gameplay regression. The experiment intentionally replaces gameplay; the original is recoverable and its rebuild is checked.

The request bytes use $50–$59 for protocol and diagnostic state; six four-byte records occupy $0300–$0317, outside this game's variables, stack and OAM. Logging costs time. Removing it would require remeasuring, not presenting this total as an uninstrumented budget.

## Hardware basis and limits

NESdev's original community research on [NMI](https://www.nesdev.org/wiki/NMI) and [CPU interrupts](https://www.nesdev.org/wiki/Interrupts) explains instruction-boundary interruption and maskable IRQ versus NMI. SEI does not block NMI. Changing PPU NMI enable is not used as a lock. Disabling a maskable interrupt on another system also has a latency cost and cannot replace an ownership contract.

The byte-publishing argument depends on one producer, a non-reentrant consumer, ordinary RAM and instruction-boundary pre-emption. It is not a portable multicore memory-ordering recipe. No general queue, multi-producer protocol, notification-counter fix or music-player migration into NMI is included.

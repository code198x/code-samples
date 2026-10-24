# Held, pressed and released NES controls

A is held for movement or charging; a new A press can spend one action; releasing A can finish that charge. These are three different events from one serial input sample. The maintained input.inc and presses.inc remain unchanged. edges.inc adds released bits as previous AND NOT current.

## Include and call

Provide writable BSS and the normal reset/stack setup. Include the maintained framework/input-to-sound/input.inc, then presses.inc and edges.inc once. Initialise previous_controls and released_controls to zero. Each chosen update calls read_controls then detect_control_edges once. controls is held, new_presses is newly pressed, released_controls is newly released. The wrapper changes A/X/flags and preserves Y. Its two private bytes are released_controls and edge_scratch. It uses the existing JSR stack; one state set is not re-entrant.

The pure release_bits entry takes A=previous and X=current byte and returns A=released; X/Y survive, flags/private scratch change. All eight bits are meaningful: A=$80, B=$40, Select=$20, Start=$10, Up=$08, Down=$04, Left=$02, Right=$01. A byte is a bit set, not a priority code.

Zero initial history counts already-held buttons as first presses. For a scene that should ignore them, take/discard an initial sample before accepting actions. Share the result rather than polling independently in each subsystem. A second poll consumes an edge. Very short pulses, physical bounce, intentional repeat and contradictory-direction policy remain separate problems.

The simple reader writes the shared $4016 strobe and reads controller 1 eight times. A two-controller owner must latch once and consume both streams; unrelated readers can disturb each other. Keep DMC sample DMA disabled. This wrapper does not make the existing reader DMC-safe; that needs a separately verified sampling policy.

## Run the caller

Run make ASM198X=/path/to/asm198x and load build/edges-demo.nes. This is NTSC NROM-256: 32 KiB PRG ROM, 8 KiB CHR ROM and horizontal mirroring. No external firmware is required. The caller owns reset/stack, its RAM, PPU/NMI setup, APU/DMC disable state and the controller strobe. Reset to leave; it does not restore a surrounding engine.

A press spends one action; a hold does not repeat it. Four hexadecimal bytes show held, pressed, released and the action count. The original small geometric hexadecimal font uses 17 tiles/272 CHR bytes. The caller clears the nametable while rendering is off, waits for vblank, writes a short status row, then restores the scroll state. It uses polling rather than an NMI worker. Rendering/input transfer must stay within the chosen vblank budget; this diagnostic is not a general VRAM scheduler.

Guest diagnostic latches/counters preserve short press/release pulses after a field is drawn. They are caller instrumentation, not another helper requirement. The stable final picture shows 00 00 00 03 after the normal sequence, including an all-button chord. Its still does not show the timing of every edge.

## Make it your own

edges-custom.asm changes ACTION_MASK from $80 (A) to $02 (Left), with identical code/state and cartridge sizes. The controller reader and edge helper stay unchanged. A wider selected mask counts one event if any chosen bit is new; counting individual buttons requires another action policy.

## Common mistake

The labelled edges-wrong.asm clears previous_controls before every edge check. A held A then counts repeatedly, and releases disappear because the previous set is always empty. Restore the normal jump to detect_control_edges. A fresh repaired run has the same cartridge as the working caller. The fault adds 5 instruction bytes but does not increase the fixed NROM file size. Keep the wrong cartridge separate from the normal one.

## Costs and verification

The wrapper/pure release leaf occupy 32 instruction bytes and 2 state bytes, alongside the existing reader/press detector's 3 state bytes. The complete caller/helper code prefix is 314 bytes, plus 6 vector bytes. Its six caller diagnostic/state bytes are separate from those five input-state bytes. The font consumes 272 bytes inside an 8 KiB CHR allocation; PRG/CHR padding makes each complete cartridge 40,976 bytes including its 16-byte header. Smaller source code does not shrink this fixed mapper layout. These byte counts are not CPU-cycle, vblank-budget or complete-game memory measurements.

Six native cases on released Emu198x 0.44.2/Asm198x 0.0.72 cover working/custom/wrong/repaired callers and an independent guest-owned release caller. The latter streams all 65,536 previous/current byte pairs through 256 complete rows; debugger stops observe the results without changing the PC or guest state. Each row index and a final marker must complete. A wrong OR leaf completes those guards but fails independent bit-set arithmetic. Contradictory directions qualify byte arithmetic, not a physical D-pad promise.

Real host controller events, native event counters, all 32 KiB of immutable PRG ROM, original-font screenshot pixels, source/tool/cartridge hashes and rejected corruptions are retained under verification/edges. Run scripts/verify-nes-input-edges.py, check-nes-input-edges.py and the unittest controls. Qualification names this NTSC NROM/DMC-off configuration, not every mapper/region, original hardware or the entire emulator.

The hardware interface and limits remain those of the maintained serial reader and this named caller. Its DMC exclusion remains binding; these emulation observations do not establish a new hardware exception. Set difference, sampling and event mapping connect to Maths for Games; action timing remains a separate game-loop decision.

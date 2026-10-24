# Reusable Spectrum keyboard edges

QAOP and Space are represented as normalised held bits: Up=1, Down=2, Left=4, Right=8, Fire=16. The maintained matrix reader and presses.inc are reused unchanged. edges.inc adds releases as previous AND NOT current, retaining their interfaces.

Include input.inc, presses.inc, edges.inc once, in that order. After read_controls, call detect_control_edges once per update. controls is held, new_presses is newly pressed, released_controls is newly released. AF/BC change; DE/HL/IX/IY survive. The wrapper owns one extra release byte. Its pure release_bits entry takes A=previous, B=current normalised five-bit masks and returns A=released; C/flags change, B/DE/HL/IX/IY survive. One state set is not re-entrant. These are bit sets, not a key-priority code.

Initialise previous_controls/released_controls to zero before the first sample. Held keys on entry then count as presses. To ignore them when a scene opens, read/detect once and discard the result, then let the next sample compare against it. Share one sample with all consumers: polling twice consumes an edge. Short pulses, ghosting, switch bounce, deliberate repeat and opposite-direction policy remain separate issues. The accepted configuration exercises QAOP/Space; it is not a guarantee for every electrical keyboard chord.

Run make ASM198X=/path/to/asm198x. LOAD the generated build/edges-demo.tap through the normal 48K ROM. END start makes its BASIC loader enter the caller through USR. The payload is 297 bytes at $8000; the loader reserves RAM below it. The caller owns a stack below $FF00 and the screen, resets its state, retains the stock IY/IM1 environment and uses EI/HALT/DI around the normal ROM frame interrupt. Reset to leave; it does not promise a BASIC return. The helper itself owns no port, IRQ or display resource. The reader still reads the four relevant matrix half-rows, once each; O/P share one read.

Four hexadecimal bytes show held, pressed, released and action count. Space spends one action per press. Diagnostic latches/counters retain one-update edge pulses after the beam has drawn a frame; the current pressed/released display can already be zero in a stable screenshot. The normal sample sequence ends with count 03, including an all-five-key chord; native latches record which bits arrived together.

## Make it your own

edges-custom.asm changes ACTION_MASK from $10 (Space) to $04 (O/Left), with unchanged code/state/payload sizes. The mapping is separate from electrical reading and edge detection. A wider action mask counts one event if any selected bit is new; counting per button is another caller policy.

## Common mistake

The explicitly labelled edges-wrong.asm clears previous_controls immediately before detecting edges. A held Space becomes new every update, the action count rises during the hold and release events disappear. Restore the normal jump to detect_control_edges. The independently executed repair has the same payload as the working version. The fault adds four bytes. Do not use the wrong build as the normal tape.

## Costs and qualification

The wrapper/pure release leaf occupy 28 instruction bytes plus one release byte. The existing reader/press detector retain their own three state bytes; the caller adds four diagnostic bytes, an action counter and ready marker. The full 297-byte working payload includes its tables, code and state. Code size is not a frame-budget or contended-memory timing claim. Normalised five-bit state is a precondition for the pure helper.

Six ROM-tape-loaded cases on Emu198x 0.44.2/Asm198x 0.0.72 and the recorded stock 48K PAL ROM cover normal/custom/wrong/repaired callers and a second guest-owned caller with all 1,024 previous/current pairs. A deliberately wrong OR operation completes its guards but fails independent bit-set arithmetic. Native host keys, event counters, complete immutable TAP image, bitmap/font/PNG pixels and source/tool/ROM identities are retained. Thirteen corruptions/pixel controls are required to fail. Read scripts/verify-spectrum-input-edges.py and check-spectrum-input-edges.py. These are configuration-specific native observations, not physical-hardware or all-ROM/region qualification.

Primary source: Sinclair ZX Spectrum BASIC Programming (1982), chapter 23, keyboard port half-rows and active-low input. The state/arbitration policies are this implementation's choices. Bit-set difference, sampling and one-event actions link naturally to Maths for Games and the shared clock/input discussion.

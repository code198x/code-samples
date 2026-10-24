; SPDX-License-Identifier: MIT
; Menu Key Repeat. Bind these contiguous private bytes: HELD, WAS_HELD, TIMER, PULSE.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
input_repeat_init:
    xor a
    ld (HELD),a
    ld (WAS_HELD),a
    ld (TIMER),a
    ld (PULSE),a
    ret
input_repeat_step:
    xor a
    ld (PULSE),a
    ld a,(HELD)
    or a
    jr z,repeat_release
    ld a,(WAS_HELD)
    or a
    jr z,repeat_first
    ld a,(TIMER)
    or a
    jr z,repeat_again
    dec a
    ld (TIMER),a
    jr nz,repeat_held
repeat_again:
    ld a,REPEAT_RATE
    jr repeat_pulse
repeat_first:
    ld a,REPEAT_DELAY
repeat_pulse:
    ld (TIMER),a
    ld a,1
    ld (PULSE),a
repeat_held:
    ld a,1
    ld (WAS_HELD),a
    ret
repeat_release:
    ld (TIMER),a
    ld (WAS_HELD),a
    ret
component_end:

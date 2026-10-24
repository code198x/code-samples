; SPDX-License-Identifier: MIT
; Menu Key Repeat. Bind these contiguous private bytes: HELD, WAS_HELD, TIMER, PULSE.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; D0-D3/A0-A1/CCR may change; D4-D7/A2-A6 survive.
input_repeat_init:
    clr.b HELD
    clr.b WAS_HELD
    clr.b TIMER
    clr.b PULSE
    rts
input_repeat_step:
    clr.b PULSE
    tst.b HELD
    beq.s repeat_release
    tst.b WAS_HELD
    beq.s repeat_first
    tst.b TIMER
    beq.s repeat_again
    subq.b #1,TIMER
    bne.s repeat_held
repeat_again:
    move.b #REPEAT_RATE,TIMER
    bra.s repeat_pulse
repeat_first:
    move.b #REPEAT_DELAY,TIMER
repeat_pulse:
    move.b #1,PULSE
repeat_held:
    move.b #1,WAS_HELD
    rts
repeat_release:
    clr.b TIMER
    clr.b WAS_HELD
    rts
component_end:

; SPDX-License-Identifier: MIT
; Menu Key Repeat. Bind these contiguous private bytes: HELD, WAS_HELD, TIMER, PULSE.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; A/X/flags may change; Y and decimal mode survive. Binary arithmetic requires D=0.
input_repeat_init:
    lda #0
    sta HELD
    sta WAS_HELD
    sta TIMER
    sta PULSE
    rts
input_repeat_step:
    lda #0
    sta PULSE
    lda HELD
    beq repeat_release
    lda WAS_HELD
    beq repeat_first
    lda TIMER
    beq repeat_again
    dec TIMER
    bne repeat_held
repeat_again:
    lda #REPEAT_RATE
    jmp repeat_pulse
repeat_first:
    lda #REPEAT_DELAY
repeat_pulse:
    sta TIMER
    inc PULSE
repeat_held:
    lda #1
    sta WAS_HELD
    rts
repeat_release:
    sta TIMER
    sta WAS_HELD
    rts
component_end:

; Load and RUN. Reset to leave. Use either joystick port; release keyboard keys.
; White blocks show held inputs; NEW FIRE counts sampled presses in hexadecimal.
* = $0801
    !byte $0b, $08, $0a, $00, $9e
    !text "2064"
    !byte 0, 0, 0
* = $0810
start:
    sei
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$35
    sta $01
    lda #<nmi_return
    sta $fffa
    lda #>nmi_return
    sta $fffb
    lda #0
    sta $dc0e
    sta $dc0f                ; no timer output on keyboard/joystick pins
    sta $d015
    sta $d020
    sta $d021
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00
    lda #$14
    sta $d018
    lda #$1b
    sta $d011
    lda #8
    sta $d016
    ldx #0
clear_screen:
    lda #32
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $06e8, x
    lda #1
    sta $d800, x
    sta $d900, x
    sta $da00, x
    sta $dae8, x
    inx
    bne clear_screen
    ldx #5
titles:
    lda title1, x
    sta $0458, x
    lda title2, x
    sta $0598, x
    dex
    bpl titles
    ldx #8
counter_labels:
    lda counter_label, x
    sta $0520, x
    sta $0660, x
    dex
    bpl counter_labels
    ldx #4
input_labels:
    ldy columns, x
    lda labels, x
    sta $04a0, y
    sta $05e0, y
    dex
    bpl input_labels
    jsr joy_init
wait_top:
    bit $d011
    bmi wait_top
wait_bottom:
    bit $d011
    bpl wait_bottom
read_inputs:
    jsr joy_poll
    jsr show_inputs
    inc frames
frame_done:
    jmp wait_top
nmi_return:
    rti
frames: !byte 0

show_inputs:
    ldx #4
show_bit:
    ldy columns, x
    lda joy1
    and masks, x
    beq blank1
    lda #160                ; reversed space is a solid character cell
    bne store1
blank1:
    lda #32
store1:
    sta $04c8, y
    lda joy2
    and masks, x
    beq blank2
    lda #160
    bne store2
blank2:
    lda #32
store2:
    sta $0608, y
    dex
    bpl show_bit
    lda joy1_fires
    lsr
    lsr
    lsr
    lsr
    tay
    lda hex_digits, y
    sta $052a
    lda joy1_fires
    and #15
    tay
    lda hex_digits, y
    sta $052b
    lda joy2_fires
    lsr
    lsr
    lsr
    lsr
    tay
    lda hex_digits, y
    sta $066a
    lda joy2_fires
    and #15
    tay
    lda hex_digits, y
    sta $066b
    rts

title1: !byte 16, 15, 18, 20, 32, 49
title2: !byte 16, 15, 18, 20, 32, 50
counter_label: !byte 14, 5, 23, 32, 6, 9, 18, 5, 58
labels: !byte 21, 4, 12, 18, 6
columns: !byte 8, 12, 16, 20, 24
masks: !byte 1, 2, 4, 8, 16
hex_digits: !byte 48,49,50,51,52,53,54,55,56,57,1,2,3,4,5,6

!source "joystick.inc"

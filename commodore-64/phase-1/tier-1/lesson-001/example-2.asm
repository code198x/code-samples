; Lesson 001, Example 2: ADSR Envelope Variation
; Demonstrates different envelope shape - slow attack, long release

        * = $0801

        !byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810

init:   ; Clear SID
        lda #$00
        ldx #$00
clear:  sta $d400,x
        inx
        cpx #$1d
        bne clear

        ; Set frequency for middle C (261.63 Hz) - A440 PAL tuning
        ; Frequency value: $1167
        lda #$67
        sta $d400
        lda #$11
        sta $d401

        ; Set waveform and gate
        lda #$21        ; Sawtooth wave (bit 5) + gate on
        sta $d404

        ; Set ADSR envelope - DIFFERENT from example 1
        lda #$99        ; Attack = 9 (500ms), Decay = 9 (750ms)
        sta $d405
        lda #$c6        ; Sustain = 12 (80%), Release = 6 (300ms)
        sta $d406

        ; Set volume
        lda #$0f
        sta $d418

loop:   jmp loop

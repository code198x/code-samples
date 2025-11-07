; Lesson 001, Example 1: Your First Note
; Plays middle C (261.63 Hz) continuously

        * = $0801       ; BASIC start address

        ; BASIC stub: 10 SYS 2064
        .byte $0c,$08,$0a,$00,$9e,$20,$32,$30,$36,$34,$00,$00,$00

        * = $0810       ; Machine code start (2064 decimal)

init:   ; Clear all SID registers
        lda #$00
        ldx #$00
clear:  sta $d400,x
        inx
        cpx #$1d        ; 29 SID registers ($00-$1C)
        bne clear

        ; Set frequency for middle C (261.63 Hz)
        ; Frequency value: $1111 (4369 decimal)
        lda #$11        ; Low byte
        sta $d400       ; Voice 1 frequency low
        lda #$11        ; High byte
        sta $d401       ; Voice 1 frequency high

        ; Set waveform and gate
        lda #$11        ; Bit 4 = triangle wave, bit 0 = gate on
        sta $d404       ; Voice 1 control register

        ; Set ADSR envelope
        lda #$08        ; Attack = 0 (instant), Decay = 8
        sta $d405
        lda #$f0        ; Sustain = 15 (max), Release = 0
        sta $d406

        ; Set master volume
        lda #$0f        ; Volume = 15 (maximum)
        sta $d418       ; Volume and filter register

loop:   jmp loop        ; Infinite loop (note continues playing)

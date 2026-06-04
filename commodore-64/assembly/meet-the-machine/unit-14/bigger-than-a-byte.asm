; Meet the Machine - Unit 14: Bigger Than a Byte
; Assemble with: acme -f cbm -o wide.prg wide.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        ; hold the 16-bit value $04F0 as two bytes: low, then high
        lda #$f0
        sta $fb         ; low byte
        lda #$04
        sta $fc         ; high byte

        ; add 40 ($28) to it — 16 bits, low byte first
        clc
        lda $fb
        adc #$28        ; low + 40 overflows past 255 -> carry set
        sta $fb
        lda $fc
        adc #$00        ; high + 0 + the carry that just climbed up
        sta $fc

        lda $fc         ; show the high byte ...
        sta $d020       ; ... it was 4, now it's 5 — green
loop    jmp loop

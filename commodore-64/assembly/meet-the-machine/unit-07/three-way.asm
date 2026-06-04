; Meet the Machine - Unit 7: branch three ways
; Assemble with: acme -f cbm -o three-way.prg three-way.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #5
        cmp #5
        bcc less        ; carry clear => A was less than 5  (blue)
        beq equal       ; zero set    => A equals 5         (green)
        lda #2          ; otherwise   => A was greater      (red)
        sta $d020
        jmp hold
less    lda #6
        sta $d020
        jmp hold
equal   lda #5
        sta $d020
hold    jmp hold

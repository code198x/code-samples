; Meet the Machine - Unit 13: Working With Bits
; Assemble with: acme -f cbm -o bits.prg bits.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #%00000010  ; colour 2 — red
        ora #%00000001  ; SET bit 0, leave the rest alone
        sta $d020       ; %00000011 = 3 = cyan
loop    jmp loop

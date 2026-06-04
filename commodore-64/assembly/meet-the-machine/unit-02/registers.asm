; Meet the Machine - Unit 2: LDA Is Not LET
; Assemble with: acme -f cbm -o registers.prg registers.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #5          ; A = 5
        tax             ; X = 5   (copy A into X)
        lda #0          ; A = 0   (wipe A, so we have to trust X)
        txa             ; A = 5   (bring it back from X)
        sta $d020       ; show it on the border — green
loop    jmp loop

; Meet the Machine - Unit 15: The Machine Trusts You
; Assemble with: acme -f cbm -o oops.prg oops.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        ldx #0
fill    lda #$a0
        sta $0400,x     ; shape
        lda #2          ; red
        sta $d800,x     ; colour, same cell
        inx
        cpx #255        ; BUG: we meant 40 (one row)
        bne fill
loop    jmp loop

; Meet the Machine - Unit 10: The Counted Loop
; Assemble with: acme -f cbm -o loop.prg loop.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        ldx #0          ; X is the counter AND the finger — start at 0
fill    lda #$a0        ; the block ...
        sta $0400,x     ; ... into the cell the finger rests on
        lda #2          ; red
        sta $d800,x     ; colour the same cell, same X (Unit 6's two maps)
        inx             ; step on / bump the count
        cpx #40         ; done all 40 cells?
        bne fill        ; if not, go round again
loop    jmp loop

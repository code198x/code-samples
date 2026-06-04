; Meet the Machine - Unit 9: A Finger on the Boxes
; Assemble with: acme -f cbm -o finger.prg finger.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        ldx #0          ; X is the finger — offset 0
        lda #$a0        ; the block to write
        sta $0400,x     ; shape into box $0400 + X ...
        lda #2          ; red
        sta $d800,x     ; ... and its colour, same finger (Unit 6's two maps)
        lda #$a0        ; reload the block
        inx             ; move the finger one box along
        sta $0400,x
        lda #2
        sta $d800,x
        lda #$a0
        inx
        sta $0400,x
        lda #2
        sta $d800,x
loop    jmp loop

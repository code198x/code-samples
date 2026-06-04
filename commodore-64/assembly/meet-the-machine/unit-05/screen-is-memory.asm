; Meet the Machine - Unit 5: The Screen Is Memory
; Assemble with: acme -f cbm -o screen.prg screen.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #$a0        ; screen code $A0 — a solid block
        sta $0400       ; the top-left box of the screen

        lda #1          ; white — a "stage light" so we can SEE it
        sta $d800       ; (the next unit explains what $D800 is)
loop    jmp loop

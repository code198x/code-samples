; Meet the Machine - Unit 4: A Street of Numbered Boxes
; Assemble with: acme -f cbm -o numbered-boxes.prg numbered-boxes.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #5          ; A = 5
        sta $c000       ; store A into the box at $C000
        lda #0          ; wipe A clean
        lda $c000       ; read the box back into A
        sta $d020       ; show it — green
loop    jmp loop

; Meet the Machine - Unit 6: Colour Is a Separate Map
; Assemble with: acme -f cbm -o colour.prg colour.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #$a0        ; a solid block ...
        sta $0400       ; ... at the top-left cell  (its SHAPE, in screen RAM)
        lda #2          ; red
        sta $d800       ; the colour map for that same cell  (its COLOUR)
loop    jmp loop

; Meet the Machine - Unit 6: four cells, four colours
; Assemble with: acme -f cbm -o colour-block.prg colour-block.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #$a0        ; a solid block ...
        sta $0400       ; ... in four cells: top-left
        sta $0401       ;     next right
        sta $0428       ;     row below, left
        sta $0429       ;     row below, right

        lda #2          ; red
        sta $d800       ; colour for cell $0400
        lda #5          ; green
        sta $d801       ; colour for cell $0401
        lda #6          ; blue
        sta $d828       ; colour for cell $0428
        lda #7          ; yellow
        sta $d829       ; colour for cell $0429
loop    jmp loop

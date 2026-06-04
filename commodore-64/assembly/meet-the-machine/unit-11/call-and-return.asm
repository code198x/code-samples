; Meet the Machine - Unit 11: Call, Return, and a Stack You Can See
; Assemble with: acme -f cbm -o call.prg call.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        ldx #0          ; first run: start at cell 0  (top row)
        jsr fill8
        ldx #40         ; second run: start at cell 40 (the next row)
        jsr fill8
loop    jmp loop

; fill8 — write eight blocks (red) starting at screen cell X
fill8   ldy #8          ; Y counts the eight cells
f8loop  lda #$a0
        sta $0400,x     ; shape
        lda #2          ; red
        sta $d800,x     ; colour the same cell, same X
        inx
        dey
        bne f8loop
        rts

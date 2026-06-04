; Meet the Machine - Unit 1: Assemble and Run
; Assemble with: acme -f cbm -o border.prg border.asm

; A one-line BASIC program — 10 SYS 2061 — that launches the machine code.
; The same stub for every program in this course; it always jumps to $080d.
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #2          ; put the number 2 into A
        sta $d020       ; store A at the border colour register
loop    jmp loop        ; hold the picture still

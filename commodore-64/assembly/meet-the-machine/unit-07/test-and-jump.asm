; Meet the Machine - Unit 7: Test, Then Jump
; Assemble with: acme -f cbm -o decide.prg decide.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #5
        cmp #5          ; compare A with 5 — sets the zero flag if equal
        beq equal       ; jump to 'equal' if the zero flag is set
        lda #2          ; (the red road) not equal
        sta $d020
        jmp hold
equal   lda #5          ; (the green road) equal
        sta $d020
hold    jmp hold

; Meet the Machine - Unit 12: Adding and Taking Away
; Assemble with: acme -f cbm -o maths.prg maths.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #2          ; start at 2
        clc             ; clear the carry BEFORE adding
        adc #1          ; 2 + 1 = 3
        adc #1          ; 3 + 1 = 4
        adc #1          ; 4 + 1 = 5
        sta $d020       ; show it — green
loop    jmp loop

; Meet the Machine - Unit 3: Everything Is a Number
; Assemble with: acme -f cbm -o letter.prg letter.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #'A'        ; load the LETTER 'A' ... which to the machine is just 65
        sta $d020       ; show that byte on the border
loop    jmp loop

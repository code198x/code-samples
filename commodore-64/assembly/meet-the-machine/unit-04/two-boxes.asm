; Meet the Machine - Unit 4: two boxes don't interfere
; Assemble with: acme -f cbm -o two-boxes.prg two-boxes.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #2
        sta $c000       ; box $C000 gets 2
        lda #5
        sta $c001       ; box $C001 gets 5
        lda $c000       ; read $C000 back — the 2
        sta $d020       ; red
loop    jmp loop

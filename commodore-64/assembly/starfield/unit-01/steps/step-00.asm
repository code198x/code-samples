; Starfield - Unit 1: Ship on Screen
; Cumulative steps: step-00 (bare program) -> step-01 (+ black screen) -> step-02 (+ the ship)
; Assemble: acme -f cbm -o <step>.prg <step>.asm

; ------------------------------------------------
; BASIC stub
; ------------------------------------------------
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

; ------------------------------------------------
; Program — nothing yet, just hand control to a do-nothing loop
; ------------------------------------------------
*= $080d
loop:
        jmp loop

; Starfield - Unit 1: Ship on Screen
; Cumulative steps: step-00 (bare program) -> step-01 (+ black screen) -> step-02 (+ the ship)
; Assemble: acme -f cbm -o <step>.prg <step>.asm

; ------------------------------------------------
; BASIC stub
; ------------------------------------------------
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

; ------------------------------------------------
; Program
; ------------------------------------------------
*= $080d
        ; Black screen
        lda #$00
        sta $d020           ; Border colour
        sta $d021           ; Background colour

        ; Clear the screen (fill with spaces)
        ldx #$00
-       lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne -

loop:
        jmp loop

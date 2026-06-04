; Meet the Machine - Unit 8: The Machine Can Hear You
; Assemble with: acme -f cbm -o joystick.prg joystick.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
read    lda $dc00       ; read joystick port 2
        and #%00010000  ; isolate bit 4 — FIRE
        beq pressed     ; result 0 => bit clear => FIRE is held
        lda #6          ; not pressed: blue border
        sta $d020
        jmp read
pressed lda #2          ; pressed: red border
        sta $d020
        jmp read

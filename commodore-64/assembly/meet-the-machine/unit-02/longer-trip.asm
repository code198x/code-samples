; Meet the Machine - Unit 2: a longer trip
; Assemble with: acme -f cbm -o longer-trip.prg longer-trip.asm

*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

*= $080d
        lda #6          ; A = 6
        tax             ; X = 6
        lda #0          ; A = 0   (wipe — only X holds 6 now)
        ; We want 6 in Y. There is no X-to-Y transfer, so route it through A:
        txa             ; A = 6   (from X)
        tay             ; Y = 6   (from A)
        lda #0          ; A = 0   (wipe again — only Y holds 6 now)
        tya             ; A = 6   (back from Y)
        sta $d020       ; show it — blue
loop    jmp loop

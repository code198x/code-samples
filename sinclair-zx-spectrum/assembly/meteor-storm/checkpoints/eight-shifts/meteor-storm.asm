; Bit-shift microscope: inspect the two rows at screen y=64.
 org 32768
start:
 di
 ld sp,$FCF0
 call clear
 ; One source row at eight sub-column positions, one position per scanline.
 ld hl,rows
 ld de,$480C
 ld b,8
copy_row:
 ld a,(hl)
 ld (de),a
 inc hl
 inc e
 ld a,(hl)
 ld (de),a
 inc hl
 dec e
 inc d
 djnz copy_row
hold:
 jr hold
; Each pair is $8100 shifted right by the row number.
rows: defb $81,$00, $40,$80, $20,$40, $10,$20
      defb $08,$10, $04,$08, $02,$04, $01,$02
clear:
 xor a
 out ($FE),a
 ld hl,$4000
 ld de,$4001
 ld bc,6143
 ld (hl),a
 ldir
 ld hl,$5800
 ld de,$5801
 ld bc,767
 ld (hl),$47
 ldir
 ret
 end start

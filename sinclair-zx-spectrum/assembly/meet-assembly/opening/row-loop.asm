; Copy eight pattern bytes into the top-left character cell.
 org 32768
start:
 ld a,0
 out ($FE),a
 ld a,71
 ld ($5800),a
 ld hl,patterns
 ld de,$4000
 ld b,8
row:
 ld a,(hl)
 ld (de),a
 inc hl
 inc d
 djnz row
hold:
 jr hold
patterns:
 defb %00011000
 defb %00111100
 defb %01111110
 defb %11011011
 defb %11111111
 defb %00111100
 defb %01100110
 defb %01000010
 end start

; Call one drawing routine with two different destinations.
 org 32768
start:
 ld a,0
 out ($FE),a
 ld a,71
 ld ($5800),a
 ld ($5801),a
 ld ($5802),a
 ld hl,patterns
 ld de,$4000
 call draw_character
second:
 ld hl,patterns
 ld de,$4001
 call draw_character
hold:
 jr hold
; In: HL points to eight bytes; DE points to row 1 of a top-row cell.
; Out: HL += 8, D += 8, E unchanged, B = 0, A = last pattern.
; Changes flags; balanced CALL/RET restores SP. Does not set colours.
draw_character:
 ld b,8
row:
 ld a,(hl)
 ld (de),a
 inc hl
 inc d
 djnz row
 ret
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

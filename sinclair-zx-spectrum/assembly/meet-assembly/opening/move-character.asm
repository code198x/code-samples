; O left, P right. Release both before each new move.
 org 32768
start:
 di
 xor a
 out ($FE),a
 ; Own the first character row: clear its 32 cells.
 ld e,0
clear_row:
 ld d,$40
 ld hl,blank
 call draw_character
 inc e
 ld a,e
 cp 32
 jr nz,clear_row
 ld hl,$5800
 ld b,32
 ld a,71
colours:
 ld (hl),a
 inc hl
 djnz colours
 ld a,(position)
 call draw_at
poll:
 ld bc,$DFFE
 in a,(c)
 and 3
 ld (keys),a
 cp 3
 jr z,released
 ld a,(armed)
 or a
 jr z,poll
 xor a
 ld (armed),a
 ld a,(keys)
 cp 1
 jr z,left
 cp 2
 jr z,right
 jr poll
released:
 ld a,1
 ld (armed),a
 jr poll
left:
 ld a,(position)
 or a
 jr z,poll
 dec a
 jr move
right:
 ld a,(position)
 cp 31
 jr z,poll
 inc a
move:
 ld (next_position),a
 ld a,(keys)
 ld (move_keys),a
 ld a,(position)
 ld (previous),a
 ; Erase the old picture before changing its position.
 ld e,a
 ld d,$40
 ld hl,blank
 call draw_character
 ld a,(next_position)
 ld (position),a
 call draw_at
 ld a,(moves)
 inc a
 ld (moves),a
 jr poll
; In: A is a column 0..31. Changes A, B, HL, DE and flags.
draw_at:
 ld e,a
 ld d,$40
 ld hl,patterns
 call draw_character
 ret
; In: HL points to 8 bytes; DE is $4000..$401F.
; Out: HL += 8, D += 8, E unchanged, B = 0, A = last byte.
draw_character:
 ld b,8
row:
 ld a,(hl)
 ld (de),a
 inc hl
 inc d
 djnz row
 ret
position: defb 15
next_position: defb 15
previous: defb 15
keys: defb 3
armed: defb 0
move_keys: defb 3
moves: defb 0
blank: defb 0,0,0,0,0,0,0,0
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

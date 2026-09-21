; Hold O/P. One movement opportunity every interval frame interrupts.
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
 ; Use the stock 48K ROM interrupt service and its system variables.
 ld iy,$5C3A
 im 1
 ld a,(interval)
 ld (remaining),a
 ei
wait_frame:
 halt
 ld a,(frames)
 inc a
 ld (frames),a
 ld bc,$DFFE
 in a,(c)
 and 3
 ld (keys),a
 ld a,(remaining)
 dec a
 ld (remaining),a
 jr nz,wait_frame
 ld a,(interval)
 ld (remaining),a
 ld a,(updates)
 inc a
 ld (updates),a
 ld a,(keys)
 cp 1
 jr z,left
 cp 2
 jr z,right
 jr wait_frame
left:
 ld a,(position)
 or a
 jr z,wait_frame
 dec a
 jr move
right:
 ld a,(position)
 cp 31
 jr z,wait_frame
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
 jr wait_frame
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
interval: defb 6
remaining: defb 6
frames: defb 0
updates: defb 0
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

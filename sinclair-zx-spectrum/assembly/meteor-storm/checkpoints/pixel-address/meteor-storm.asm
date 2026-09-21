; Find a bitmap byte from pixel coordinates; no movement or sprite table.
 org 32768
start:
 di
 ld sp,$FCF0
 call clear
 ld d,64
 ld e,14
 call pixel_address
 ld (address),hl
 ld (hl),%00000010
hold:
 jr hold
pixel_address:
 ld a,d
 and 7
 or $40
 ld h,a
 ld a,d
 and $C0
 rrca
 rrca
 rrca
 or h
 ld h,a
 ld a,d
 and $38
 rlca
 rlca
 ld l,a
 ld a,e
 rrca
 rrca
 rrca
 and 31
 or l
 ld l,a
 ret
clear:
 xor a
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
 ld hl,$5800
 ld b,64
clear_top:
 ld (hl),$45
 inc hl
 djnz clear_top
 ret

address: defw 0
 end start

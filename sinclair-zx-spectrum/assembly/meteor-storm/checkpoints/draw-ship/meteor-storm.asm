; One XOR drawing call, before input and movement are introduced.
 org 32768
start:
 di
 ld sp,$FCF0
 call clear
 ld d,160
 ld e,116
 ld hl,ship_sprites
 ld a,16
 call draw_sprite
hold:
 jr hold
draw_sprite:
 ld (sprite_height),a
 push de
 ld a,e
 and 7
 ld e,a
 ld d,0
 sla e
 rl d
 sla e
 rl d
 sla e
 rl d
 sla e
 rl d
 sla e
 rl d
 sla e
 rl d
 add hl,de
 ld (sprite_ptr),hl
 pop de
 call pixel_address
 ld de,(sprite_ptr)
 ld a,(sprite_height)
 ld b,a
draw_sprite_row:
 push hl
 rept 4
 ld a,(de)
 xor (hl)
 ld (hl),a
 inc de
 inc hl
 endm
 pop hl
 call next_scanline
 djnz draw_sprite_row
 ret

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
next_scanline:
 inc h
 ld a,h
 and 7
 ret nz
 ld a,l
 add a,32
 ld l,a
 ret c
 ld a,h
 sub 8
 ld h,a
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

sprite_ptr: defw 0
sprite_height: defb 0
 include "assets.inc"
 end start

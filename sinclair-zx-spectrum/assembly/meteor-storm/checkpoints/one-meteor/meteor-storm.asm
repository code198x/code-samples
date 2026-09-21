; Meteor Storm checkpoint 3: complete standalone program.
 org 32768
SHIP_Y equ 160
start:
 di
 ld sp,$FCF0
 ; A minimal IM2 interrupt avoids borrowing the ROM keyboard/timing service.
 ld hl,$FE00
 ld de,$FE01
 ld bc,256
 ld (hl),$FD
 ldir
 ld a,$C3
 ld ($FDFD),a
 ld hl,interrupt
 ld ($FDFE),hl
 ld a,$FE
 ld i,a
 im 2
 xor a
 out ($FE),a
 ei
 jp restart
interrupt:
 push af
 ld a,(frames)
 inc a
 ld (frames),a
 pop af
 ei
 reti

restart:
 call clear
 ld a,116
 ld (ship_x),a
 xor a
 ld (phase),a
 ld (updates),a
 ld a,116
 ld (meteor_x),a
 ld a,24
 ld (meteor_y),a
 ld a,1
 ld (active),a
 call meteor
 ld bc,$0001
 ld de,controls
 call text
 call ship
main_loop:
 halt
 ld a,(frames)
 and 1
 jr nz,main_loop
 ld bc,$FBFE
 in a,(c)
 bit 3,a
 jp z,restart
 ld a,(phase)
 or a
 jr nz,main_loop
 call ship
 call steer
 call ship
 ld a,(updates)
 inc a
 ld (updates),a
 ld a,(active)
 or a
 jr z,main_loop
 call meteor
 ld a,(meteor_y)
 add a,3
 ld (meteor_y),a
 cp 174
 jr nc,retire
 call meteor
 jp main_loop
retire:
 xor a
 ld (active),a
 ld a,3
 ld (phase),a
 ld bc,$0201
 ld de,clear_text
 call text
 jp main_loop
steer:
 ld e,2
steer_keys:
 ld bc,$DFFE
 in a,(c)
 and 3
 cp 1
 jr z,steer_left
 cp 2
 ret nz
 ld a,(ship_x)
 add a,e
 cp 225
 jr c,steer_store
 ld a,224
 jr steer_store
steer_left:
 ld a,(ship_x)
 sub e
 cp 8
 jr nc,steer_store
 ld a,8
steer_store:
 ld (ship_x),a
 ret

; Toggle exactly the ship pixels. Call at the old position before moving,
; then at the new position. XOR twice restores the underlying bitmap.
ship:
 ld a,(ship_x)
 ld e,a
 ld d,SHIP_Y
 ld hl,ship_sprites
 ld a,16
 jp draw_sprite
meteor:
 ld a,(meteor_x)
 ld e,a
 ld a,(meteor_y)
 ld d,a
 ld hl,meteor_sprites
 ld a,12
 jp draw_sprite
; draw_sprite: D=y, E=x, HL=shift table, A=height. Changes AF/BC/DE/HL.
; Eight shifts each occupy 64 bytes: sixteen rows of four bytes.
; pixel_address preserves BC/DE; next_scanline changes AF/HL.
; text: B=row, C=column, DE=zero-terminated ASCII; changes primary registers.
; Screen writes assume x=8..224, y+height<=192, with no scrolling background.
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

text:
 ld a,b
 cp 24
 ret nc
 ld a,c
 cp 32
 ret nc
 ld a,(de)
 or a
 ret z
 inc de
 push de
 push bc
 ld l,a
 ld h,0
 add hl,hl
 add hl,hl
 add hl,hl
 ld de,$3C00
 add hl,de
 push hl
 ld a,b
 add a,a
 add a,a
 add a,a
 ld d,a
 ld a,c
 add a,a
 add a,a
 add a,a
 ld e,a
 call pixel_address
 pop de
 ld b,8
text_glyph:
 ld a,(de)
 ld (hl),a
 inc de
 inc h
 djnz text_glyph
 pop bc
 pop de
 inc c
 jr text

controls: defb "O/P STEER   R RESTART",0
clear_text: defb "CLEAR SPACE - R TO REPEAT",0
hit_text: defb "HIT! R TO RETRY",0
frames: defb 0
phase: defb 0
updates: defb 0
ship_x: defb 116
sprite_ptr: defw 0
sprite_height: defb 0
meteor_x: defb 116
meteor_y: defb 24
active: defb 1
 include "assets.inc"
 end start

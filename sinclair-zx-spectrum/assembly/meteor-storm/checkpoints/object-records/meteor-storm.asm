; Meteor Storm checkpoint object-records: complete standalone program. Stock 48K PAL.
; Explicit state drives collision; the screen is only a view.
; Build: asm198x --dialect pasmo --cpu z80 --tapbas meteor-storm.asm -o meteor-storm.tap
 org 32768
SHIP_Y equ 160
SLOTS equ 3

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
 jp title
interrupt:
 push af
 ld a,(frames)
 inc a
 ld (frames),a
 pop af
 ei
 reti

title:
 xor a
 ld (phase),a
 call clear
 ld bc,$030A
 ld de,name_text
 call text
 ld bc,$0602
 ld de,title_goal
 call text
 ld bc,$0A06
 ld de,title_keys
 call text
 ld bc,$1408
 ld de,title_start
 call text
 call release_keys
title_title_wait:
 halt
 ld bc,$7FFE
 in a,(c)
 bit 0,a
 jr nz,title_title_wait
 call release_keys
 call new_game
main_loop:
 halt
 ld a,(frames)
 and 1
 jr nz,main_loop
 call erase_ship
 ld bc,$FBFE
 in a,(c)
 bit 0,a
 jp z,title
 call steer
 call draw_ship
 call advance_meteors
 ld a,(hull)
 or a
 jp z,lost
 ; Offset 2 of each four-byte record is its active byte.
 ld a,(objects+2)
 ld hl,objects+6
 or (hl)
 ld hl,objects+10
 or (hl)
 jp z,won
 jp main_loop

new_game:
 call clear
 xor a
 ld hl,state_start
 ld de,state_start+1
 ld bc,state_end-state_start-1
 ld (hl),a
 ldir
 ld a,1
 ld (phase),a
 ld a,116
 ld (ship_x),a
 ld a,1
 ld (hull),a
 ; Three meteors start together, one in each record.
 ld ix,objects
 ld a,80
 ld (spawn_x),a
 ld a,2
 ld (spawn_speed),a
 call spawn
 ld ix,objects+4
 ld a,116
 ld (spawn_x),a
 ld a,3
 ld (spawn_speed),a
 call spawn
 ld ix,objects+8
 ld a,170
 ld (spawn_x),a
 ld a,4
 ld (spawn_speed),a
 call spawn
 ld bc,$1702
 ld de,controls
 call text
 call draw_ship
 ret
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

; One explicit call per record; IX says which record each call handles.
advance_meteors:
 ld ix,objects
 call advance_meteor
 ld ix,objects+4
 call advance_meteor
 ld ix,objects+8
 call advance_meteor
 ret

; IX=record: 0 X, 1 Y, 2 active, 3 speed.
advance_meteor:
 ld a,(ix+2)
 or a
 ret z
 ld e,(ix+0)
 ld d,(ix+1)
 call draw_meteor
 ld a,(ix+1)
 add a,(ix+3)
 ld (ix+1),a
 cp 174
 jr nc,advance_meteor_remove
 ; Inset rectangles: meteor y+2..9, ship y+3..13.
 cp 154
 jr c,advance_meteor_draw
 cp 172
 jr nc,advance_meteor_draw
 ld a,(ship_x)
 ld c,a
 ld a,(ix+0)
 sub c
 jr nc,advance_meteor_absolute
 neg
advance_meteor_absolute:
 cp 16
 jr nc,advance_meteor_draw
 ; One contact ends this attempt; no recovery state is needed.
 xor a
 ld (hull),a
 call impact_sound
advance_meteor_remove:
 ld (ix+2),0
 ret
advance_meteor_draw:
 ld e,(ix+0)
 ld d,(ix+1)
 jp draw_meteor

; IX=record to fill with spawn_x, Y=24, active and spawn_speed.
spawn:
 ld a,(spawn_x)
 ld (ix+0),a
 ld (ix+1),24
 ld a,1
 ld (ix+2),a
 ld a,(spawn_speed)
 ld (ix+3),a
 ld e,(ix+0)
 ld d,24
 jp draw_meteor

 ; XOR removes exactly the old sprite, preserving overlapping objects.
draw_meteor:
 ld hl,meteor_sprites
 ld a,12
 jp draw_sprite

erase_ship:
 ld a,(ship_visible)
 or a
 ret z
 xor a
 ld (ship_visible),a
 ld a,(ship_x)
 ld e,a
 ld d,SHIP_Y
 ld hl,ship_sprites
 ld a,16
 jp draw_sprite
draw_ship:
 ld a,1
 ld (ship_visible),a
 ld a,(ship_x)
 ld e,a
 ld d,SHIP_Y
 ld hl,ship_sprites
 ld a,16
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

impact_sound:
 ; Brief per-event burst; bounded CPU time, not a long blocking tune.
 ld c,12
impact_sound_loop:
 ld a,16
 out ($FE),a
 ld b,12
impact_sound_a: djnz impact_sound_a
 xor a
 out ($FE),a
 ld b,8
impact_sound_b: djnz impact_sound_b
 dec c
 jr nz,impact_sound_loop
 ret

lost:
 ld a,2
 ld (phase),a
 ld de,lost_text
 jr result
won:
 ld a,3
 ld (phase),a
 ld de,won_text
result:
 push de
 call clear
 pop de
 ld bc,$0608
 call text
 ld bc,$0A04
 ld de,result_text
 call text
 ld bc,$0E07
 ld de,retry_text
 call text
 call release_keys
result_wait:
 halt
 ld bc,$FBFE
 in a,(c)
 bit 0,a
 jp z,title
 bit 3,a
 jr nz,result_wait
 call release_keys
 call new_game
 jp main_loop

release_keys:
 halt
 ld bc,$7FFE
 in a,(c)
 bit 0,a
 jr z,release_keys
 ld bc,$FBFE
 in a,(c)
 and 9
 cp 9
 jr nz,release_keys
 ret

name_text: defb "METEOR STORM",0
title_goal: defb "DODGE ROCKS. ONE HIT ENDS IT",0
title_keys: defb "O LEFT       P RIGHT",0
title_start: defb "SPACE TO LAUNCH",0
controls: defb "O/P STEER  Q QUIT",0
lost_text: defb "SHIP DESTROYED",0
won_text: defb "CLEAR SPACE",0
result_text: defb "METEOR STORM - FLIGHT ENDED",0
retry_text: defb "R RETRY   Q TITLE",0
frames: defb 0
sprite_ptr: defw 0
sprite_height: defb 0
state_start:
phase: defb 0
ship_x: defb 116
hull: defb 1
ship_visible: defb 0
spawn_speed: defb 0
spawn_x: defb 0
objects: defs SLOTS*4
state_end:
 include "assets.inc"
 end start

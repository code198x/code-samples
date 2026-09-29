; Meteor Storm checkpoint boost: complete standalone program. Stock 48K PAL.
; Explicit state drives collision; the screen is only a view.
; Build: asm198x --dialect pasmo --cpu z80 --tapbas meteor-storm.asm -o meteor-storm.tap
 org 32768
SHIP_Y equ 160
SLOTS equ 20
WAVES equ 120

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
 ; Fixed 25 Hz updates: rendering density must not set movement speed.
 ld a,(frames)
 ld c,a
 ld a,(last_frame)
 ld b,a
 ld a,c
 sub b
 ld (frame_delta),a
 ld a,c
 ld (last_frame),a
 ld hl,(elapsed)
 ld a,(frame_delta)
 ld e,a
 ld d,0
 add hl,de
 ld (elapsed),hl
 call boost
 ld a,(boost_time)
 inc a
 ld (steps_left),a
race_step:
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
 call waves
 call count_objects
 ld hl,(ticks)
 inc hl
 ld (ticks),hl
 ld a,(wave)
 cp WAVES
 jr nz,race_continue
 ld a,(active_count)
 or a
 jr nz,race_continue
 jp won
race_continue:
 ld a,(steps_left)
 dec a
 ld (steps_left),a
 jp nz,race_step
 call hud
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
 ld a,20
 ld (wave_timer),a
 ld bc,$1702
 ld de,controls
 call text
 call draw_ship
 call count_objects
 call hud
 ld a,(frames)
 ld (last_frame),a
 ret

 ; Hold Space for unlimited double-speed travel through the same course.
boost:
 ld bc,$7FFE
 in a,(c)
 and 1
 xor 1
 ld (boost_time),a
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

advance_meteors:
 ld ix,objects
 ld b,SLOTS
advance_meteors_next:
 ld a,(ix+2)
 or a
 jp z,advance_meteors_skip
 push bc
 ld e,(ix+0)
 ld d,(ix+1)
 call draw_meteor
 pop bc
 ; Stars fall vertically; meteors drift one pixel every fourth update.
 ld a,(ix+2)
 cp 2
 jr z,drift_done
 ld a,(ticks)
 and 3
 jr nz,drift_done
 ld a,(ix+0)
 add a,(ix+4)
 cp 8
 jr c,drift_left_edge
 cp 225
 jr nc,drift_right_edge
 jr drift_store
drift_left_edge:
 ld (ix+4),1
 ld a,8
 jr drift_store
drift_right_edge:
 ld (ix+4),255
 ld a,224
drift_store:
 ld (ix+0),a
drift_done:
 ld a,(ix+1)
 add a,(ix+3)
 ld (ix+1),a
 cp 174
 jr nc,advance_meteors_remove
 ; Inset rectangles: meteor y+2..9, ship y+3..13.
 cp 154
 jp c,advance_meteors_skip
 cp 172
 jp nc,advance_meteors_skip
 ld a,(ship_x)
 ld c,a
 ld a,(ix+0)
 sub c
 jr nc,advance_meteors_absolute
 neg
advance_meteors_absolute:
 cp 16
 jp nc,advance_meteors_skip
 ld a,(ix+2)
 cp 2
 jr nz,meteor_contact
 ld a,(boost_time)
 inc a
 ld c,a
 ld a,(score)
 add a,c
 ld (score),a
 jr advance_meteors_remove
meteor_contact:
 ; One contact ends this attempt; no recovery state is needed.
 xor a
 ld (hull),a
 push bc
 call impact_sound
 pop bc
advance_meteors_remove:
 ld (ix+2),0
advance_meteors_skip:
 ld a,(ix+2)
 or a
 jr z,advance_meteors_next_slot
 push bc
 ld e,(ix+0)
 ld d,(ix+1)
 call draw_meteor
 pop bc
advance_meteors_next_slot:
 ld de,5
 add ix,de
 dec b
 jp nz,advance_meteors_next
 ret

waves:
 ld a,(wave)
 cp WAVES
 ret z
 ld a,(wave_timer)
 dec a
 ld (wave_timer),a
 ret nz
 ld a,(wave)
 ld e,a
 ld d,0
 ld hl,meteor_events
 add hl,de
 add hl,de
 add hl,de
 add hl,de
 add hl,de
 ld a,(hl)
 ld (spawn_x),a
 inc hl
 ld a,(hl)
 ld (spawn_speed),a
 inc hl
 ld a,(hl)
 ld (wave_timer),a
 inc hl
 ld a,(hl)
 ld (spawn_drift),a
 inc hl
 ld a,(hl)
 ld (spawn_kind),a
 ld a,(wave)
 inc a
 ld (wave),a
 jp spawn
spawn:
 ld ix,objects
 ld b,SLOTS
spawn_find:
 ld a,(ix+2)
 or a
 jr z,spawn_found
 ld de,5
 add ix,de
 djnz spawn_find
 ; A full pool is a verification failure.
 ld a,1
 ld (pool_overflow),a
 ret
spawn_found:
 ld a,(spawn_x)
 ld (ix+0),a
 ld (ix+1),24
 ld a,(spawn_kind)
 ld (ix+2),a
 ld a,(spawn_drift)
 ld (ix+4),a
 ld a,(spawn_speed)
 ld (ix+3),a
 ld e,(ix+0)
 ld d,24
 jp draw_meteor

 ; XOR removes exactly the old sprite, preserving overlapping objects.
draw_meteor:
 ld hl,meteor_sprites
 ld a,(ix+2)
 cp 2
 jr nz,draw_object
 ld hl,star_sprites
draw_object:
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

count_objects:
 xor a
 ld (active_count),a
 ld ix,objects
 ld b,SLOTS
count_objects_next:
 ld a,(ix+2)
 or a
 jr z,count_objects_skip
 ld a,(active_count)
 inc a
 ld (active_count),a
count_objects_skip:
 ld de,5
 add ix,de
 djnz count_objects_next
 ret
draw_ship:
 ld a,1
 ld (ship_visible),a
 ld a,(ship_x)
 ld e,a
 ld d,SHIP_Y
 ld hl,ship_sprites
 ld a,16
 jp draw_sprite

; D=y, E=x. Four-byte rows include horizontal pixel offset.
; Ship 24x16, meteors 24x12; x is bounded to 8..224. A is row count.
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

; Spectrum pixel address, D=y E=x. BC and DE preserved; AF/HL changed.
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

; B=character row C=column DE=zero-terminated ASCII. ROM font only,
; no ROM calls or implicit print state. All primary registers changed.
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

 ; A to three decimal digits at HL.
decimal3:
 ld b,'0'
decimal_hundreds:
 cp 100
 jr c,decimal_hundred_done
 sub 100
 inc b
 jr decimal_hundreds
decimal_hundred_done:
 ld (hl),b
 inc hl
 ld b,'0'
decimal_tens:
 cp 10
 jr c,decimal_ten_done
 sub 10
 inc b
 jr decimal_tens
decimal_ten_done:
 ld (hl),b
 inc hl
 add a,'0'
 ld (hl),a
 ret

; HL holds elapsed PAL frames. Return seconds in A, remainder in L.
seconds:
 ld b,0
 ld de,50
seconds_loop:
 or a
 sbc hl,de
 jr c,seconds_done
 inc b
 jr seconds_loop
seconds_done:
 add hl,de
 ld a,b
 ret

; HL frames, DE output MM.SS-style seconds/hundredths buffer (SS.CC).
format_time:
 push de
 call seconds
 ld (time_seconds),a
 ld a,l
 add a,a
 ld (time_fraction),a
 pop hl
 push hl
 dec hl
 ld a,(time_seconds)
 call decimal3
 pop hl
 inc hl
 inc hl
 ld (hl),'.'
 push hl
 ld a,(time_fraction)
 call decimal3
 pop hl
 ld (hl),'.'
 ret

score_line:
 ld a,(score)
 ld hl,score_digits_text
 call decimal3
 ld bc,$0201
 ld de,score_text
 jp text

hud:
 ld hl,(elapsed)
 ld de,time_digits
 call format_time
 ld a,(hud_drawn)
 or a
 jr z,hud_full_time
 ld bc,$0007
 ld de,time_digits
 call text
 jr hud_choose_speed
hud_full_time:
 ld bc,$0001
 ld de,time_text
 call text
hud_choose_speed:
 ld a,(hud_drawn)
 or a
 jr z,hud_speed_changed
 ld a,(hud_last_boost)
 ld b,a
 ld a,(boost_time)
 cp b
 jr z,hud_choose_score
hud_speed_changed:
 ld a,(boost_time)
 ld (hud_last_boost),a
 ld de,boost_ready
 or a
 jr z,hud_speed
 ld de,boost_active
hud_speed:
 ld bc,$0101
 call text
hud_choose_score:
 ld a,(hud_drawn)
 or a
 jr z,hud_score_changed
 ld a,(hud_last_score)
 ld b,a
 ld a,(score)
 cp b
 ret z
hud_score_changed:
 ld a,(score)
 ld (hud_last_score),a
 call score_line
 ld a,1
 ld (hud_drawn),a
 ret

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
 push de
 xor a
 ld (hud_drawn),a
 call hud
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
controls: defb "O/P STEER  SPACE BOOST  Q QUIT",0
time_text: defb "TIME "
time_pad: defb ' '
time_digits: defb "00.00",0
boost_ready: defb "1X  HOLD SPACE: 2X",0
boost_active: defb "2X  STARS X2      ",0
time_seconds: defb 0
time_fraction: defb 0
lost_text: defb "SHIP DESTROYED",0
won_text: defb "CLEAR SPACE",0
result_text: defb "METEOR STORM - FLIGHT ENDED",0
retry_text: defb "R RETRY   Q TITLE",0
score_text: defb "SCORE "
score_digits_text: defb "0000",0
frames: defb 0
sprite_ptr: defw 0
sprite_height: defb 0
state_start:
phase: defb 0
ship_x: defb 116
hull: defb 1
wave: defb 0
wave_timer: defb 0
ticks: defw 0
active_count: defb 0
pool_overflow: defb 0
last_frame: defb 0
frame_delta: defb 0
hud_drawn: defb 0
hud_last_boost: defb 0
hud_last_score: defb 0
boost_time: defb 0
elapsed: defw 0
steps_left: defb 0
ship_visible: defb 0
score: defb 0
spawn_drift: defb 0
spawn_kind: defb 0
spawn_speed: defb 0
spawn_x: defb 0
objects: defs SLOTS*5
state_end:
 include "assets.inc"
 end start

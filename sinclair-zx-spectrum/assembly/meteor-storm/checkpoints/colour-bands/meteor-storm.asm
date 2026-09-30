; Meteor Storm checkpoint colour-bands: complete standalone program. Stock 48K PAL.
; Explicit state drives collision; the screen is only a view.
; Build: asm198x --dialect pasmonext --cpu z80 --tapbas meteor-storm.asm -o meteor-storm.tap
 org 32768
SHIP_Y equ 160
SLOTS equ 20
WAVES equ 120
DEBRIS equ 8
DEBRIS_ROWS equ 5
DEBRIS_UPDATES equ 25
DEBRIS_FLOOR equ 179
FLASH_BORDER equ 2
FLASH_UPDATES equ 3

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
 ld a,(border)
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
 ld b,$03
 ld de,name_text
 call text_center
 ld b,$06
 ld de,title_goal
 call text_center
 ld b,$0A
 ld de,title_keys
 call text_center
 ld b,$0D
 ld de,title_hint
 call text_center
 ld b,$0F
 ld de,title_hull
 call text_center
 ld b,$11
 ld de,title_bonus
 call text_center
 ld b,$14
 ld de,title_start
 call text_center
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
 call wait_frame
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
 jp z,destroyed
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
 ; Sound only on the press: held now, not held at the previous update.
 ld c,a
 ld a,(boost_last)
 ld b,a
 ld a,c
 ld (boost_last),a
 cp b
 ret z
 or a
 ret z
 ld hl,boost_sound
 jp start_sound

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
 ; At 2X keep the old image until both physics steps finish. Save its
 ; position, then erase/redraw each object once on the second step.
 ld a,(boost_time)
 or a
 jr z,remember_image
 ld a,(steps_left)
 cp 1
 jr z,erase_old_image
remember_image:
 ld a,(ix+0)
 ld (ix+5),a
 ld a,(ix+1)
 ld (ix+6),a
 ld a,(steps_left)
 cp 2
 jr z,image_ready
erase_old_image:
 push bc
 ld e,(ix+5)
 ld d,(ix+6)
 call draw_meteor
 pop bc
image_ready:
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
 ld hl,star_sound
 call start_sound
 jr advance_meteors_remove
meteor_contact:
 ; One contact ends this attempt. The meteor keeps its slot and its image,
 ; so the destroyed phase shows what hit the ship.
 xor a
 ld (hull),a
 ld hl,impact_sound
 call start_sound
 jr advance_meteors_skip
advance_meteors_remove:
 ld a,(steps_left)
 cp 2
 jr nz,remove_image_done
 push bc
 ld e,(ix+5)
 ld d,(ix+6)
 call draw_meteor
 pop bc
remove_image_done:
 ld (ix+2),0
advance_meteors_skip:
 ld a,(ix+2)
 or a
 jr z,advance_meteors_next_slot
 ld a,(steps_left)
 cp 2
 jr z,advance_meteors_next_slot
 push bc
 ld e,(ix+0)
 ld d,(ix+1)
 call draw_meteor
 pop bc
advance_meteors_next_slot:
 ld de,7
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
 ld de,7
 add ix,de
 djnz spawn_find
 ; A full pool is a verification failure.
 ld a,1
 ld (pool_overflow),a
 ret
spawn_found:
 ld a,(spawn_x)
 ld (ix+0),a
 ld (ix+5),a
 ld (ix+6),24
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
 ld de,7
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
 ; Colour by place: each character row takes one byte from row_colours,
 ; written to all 32 of its cells. Objects take the colour of the row
 ; they pass through, so no two objects in one cell can disagree.
 ld hl,$5800
 ld de,row_colours
 ld c,24
clear_row:
 ld a,(de)
 ld b,32
clear_cell:
 ld (hl),a
 inc hl
 djnz clear_cell
 inc de
 dec c
 jr nz,clear_row
 ret

 ; B=row, DE=string. Centre from the actual character count.
text_center:
 ld h,d
 ld l,e
 ld c,0
text_measure:
 ld a,(hl)
 or a
 jr z,text_measured
 inc hl
 inc c
 jr text_measure
text_measured:
 ld a,32
 sub c
 jr nc,text_centre_column
 xor a
text_centre_column:
 srl a
 ld c,a
 jp text

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

bonus_line:
 ld a,(finish_points)
 ld hl,bonus_digits
 call decimal3
 ld bc,$0C05
 ld de,bonus_text
 jp text

records:
 ld a,(best_score)
 ld hl,best_score_digits
 call decimal3
 ld hl,(best_time)
 ld a,h
 and l
 cp 255
 jr z,records_unset
 ld de,best_time_digits
 call format_time
 jr records_draw
records_unset:
 ld hl,best_time_digits
 ld (hl),'-'
 inc hl
 ld (hl),'-'
 inc hl
 ld (hl),'.'
 inc hl
 ld (hl),'-'
 inc hl
 ld (hl),'-'
records_draw:
 ld bc,$1103
 ld de,best_time_text
 call text
 ld bc,$1203
 ld de,best_score_text
 jp text

save_score:
 ld a,(best_score)
 ld b,a
 ld a,(score)
 cp b
 ret c
 ld (best_score),a
 ret

; HL = sound: notes of (half-period count, cycle count), ended by 0.
; Changes AF/BC/DE/HL. Blocks until every note has played.
play_sound:
 ld a,(border)
 and 7
 ld d,a
play_sound_note:
 ld a,(hl)
 or a
 ret z
 ld c,a
 inc hl
 ld e,(hl)
 inc hl
 call tone
 jr play_sound_note

; D = border, C = half-period count, E = cycle count (1-255).
; Period 26*C+51 T-states. Changes AF/B/E.
tone:
 ld a,d
 or 16
 out ($FE),a
 ld b,c
tone_high: djnz tone_high
 ld a,d
 out ($FE),a
 ld b,c
tone_low: djnz tone_low
 dec e
 jr nz,tone
 ret

; HL = sound. Start it; the frame waits play it. Changes A/HL.
start_sound:
 ld (sound_note),hl
 inc hl
 ld a,(hl)
 ld (sound_left),a
 ret

; Wait for the next frame interrupt. With a sound due, play it during the
; wait instead of halting, one period at a time, until `frames` changes;
; the rest of the note carries over to the next wait. Changes AF/BC/DE/HL/IX.
wait_frame:
 ld a,(sound_left)
 or a
 jr nz,wait_sound
 halt
 ret
wait_sound:
 ld e,a
 ld a,(border)
 and 7
 ld d,a
 ld a,(frames)
 ld l,a
 ld ix,(sound_note)
wait_note:
 ld c,(ix+0)
 ; The frame check costs 24 T-states; two fewer delay passes pay 26.
 dec c
wait_period:
 ld a,d
 or 16
 out ($FE),a
 ld b,c
wait_high: djnz wait_high
 ld a,d
 out ($FE),a
 ld b,c
wait_low: djnz wait_low
 dec e
 jr z,wait_next_note
 ld a,(frames)
 cp l
 jr z,wait_period
 ld a,e
 ld (sound_left),a
 ret
wait_next_note:
 inc ix
 inc ix
 ld (sound_note),ix
 ld e,(ix+1)
 ld a,(ix+0)
 or a
 jr nz,wait_note
 ld (sound_left),a
wait_rest:
 ld a,(frames)
 cp l
 jr z,wait_rest
 ret

; Period 26*half+51 T-states at 3.5 MHz in tone, 26*half+49 in wait_frame.
; Star, boost and impact play during frame waits; arrival blocks.
star_sound: defb 40,8, 30,10, 0
boost_sound: defb 100,4, 70,6, 0
arrival_sound: defb 127,63, 100,79, 84,94, 62,250, 0
impact_sound: defb 150,30, 200,30, 255,60, 0

; The storm stops where it is. The ship becomes DEBRIS pieces that fly
; apart for DEBRIS_UPDATES updates while the impact sound plays in the
; frame waits. No keys are read, so nothing can cut the phase short.
destroyed:
 ld a,2
 ld (phase),a
 ; Flash the border. The impact sound's speaker writes carry `border`.
 ld a,FLASH_BORDER
 ld (border),a
 out ($FE),a
 call erase_ship
 ld hl,debris_start
 ld de,debris
 ld bc,DEBRIS*4
 ldir
 ; Every piece starts at the ship's X. Its artwork sits where it was in
 ; the ship, so together the pieces first draw the whole ship.
 ld ix,debris
 ld b,DEBRIS
 ld de,4
 ld a,(ship_x)
destroyed_place:
 ld (ix+0),a
 add ix,de
 djnz destroyed_place
 call draw_debris
 ld a,DEBRIS_UPDATES
 ld (debris_time),a
destroyed_wait:
 call wait_frame
 ld a,(frames)
 and 1
 jr nz,destroyed_wait
 call draw_debris
 call move_debris
 call draw_debris
 ld a,(debris_time)
 dec a
 ld (debris_time),a
 ; After FLASH_UPDATES updates the border returns to black.
 cp DEBRIS_UPDATES-FLASH_UPDATES
 jr nz,destroyed_count
 xor a
 ld (border),a
 out ($FE),a
destroyed_count:
 ld a,(debris_time)
 or a
 jr nz,destroyed_wait
lost:
 call save_score
 ld a,2
 ld (phase),a
 ld de,lost_text
 jr result
won:
 ; Finish bonus: ten points for each second below 100 seconds.
 ld hl,(elapsed)
 call seconds
 ld b,a
 ld a,100
 sub b
 jr nc,finish_bonus
 xor a
finish_bonus:
 ld (finish_points),a
 ld b,a
 ld a,(score)
 add a,b
 ld (score),a
 call save_score
 ld hl,(elapsed)
 ld de,(best_time)
 or a
 sbc hl,de
 jr nc,finish_recorded
 ld hl,(elapsed)
 ld (best_time),hl
finish_recorded:
 ld a,3
 ld (phase),a
 ld hl,arrival_sound
 call play_sound
 ld de,won_text
result:
 push de
 call clear
 pop de
 push de
 xor a
 ld (hud_drawn),a
 call hud
 call bonus_line
 call records
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

; XOR every piece at its record's position: the first call draws, the
; same call at the same positions erases. Piece n's artwork is the nth
; 512-byte shift table from debris_sprites. Changes AF/BC/DE/HL/IX.
draw_debris:
 ld ix,debris
 ld hl,debris_sprites
 ld b,DEBRIS
draw_debris_next:
 push bc
 push hl
 ld e,(ix+0)
 ld d,(ix+1)
 ld a,DEBRIS_ROWS
 call draw_sprite
 pop hl
 ld de,512
 add hl,de
 pop bc
 ld de,4
 add ix,de
 djnz draw_debris_next
 ret

; Add each piece's dX and dY. A piece that would leave X 8..224 keeps its
; X, so draw_sprite's bounds hold. Gravity adds 1 to dY every update, so a
; rising piece slows, stops and falls. A piece that would pass DEBRIS_FLOOR
; lands there and stops moving sideways. Changes AF/BC/DE/IX.
move_debris:
 ld ix,debris
 ld b,DEBRIS
move_debris_next:
 ld a,(ix+0)
 add a,(ix+2)
 cp 8
 jr c,debris_x_kept
 cp 225
 jr nc,debris_x_kept
 ld (ix+0),a
debris_x_kept:
 inc (ix+3)
 ld a,(ix+1)
 add a,(ix+3)
 cp DEBRIS_FLOOR+1
 jr c,debris_y_store
 ld (ix+2),0
 ld a,DEBRIS_FLOOR
debris_y_store:
 ld (ix+1),a
 ld de,4
 add ix,de
 djnz move_debris_next
 ret

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
title_hint: defb "HOLD SPACE: DOUBLE SPEED",0
title_hull: defb "STARS: 10 / BOOST: 20",0
title_bonus: defb "FASTER FINISH = MORE POINTS",0
bonus_text: defb "FINISH BONUS "
bonus_digits: defb "0000",0
title_start: defb "SPACE TO LAUNCH",0
controls: defb "O/P STEER  SPACE BOOST  Q QUIT",0
time_text: defb "TIME "
time_pad: defb ' '
time_digits: defb "00.00",0
boost_ready: defb "1X  HOLD SPACE: 2X",0
boost_active: defb "2X  STARS X2      ",0
best_time_text: defb "BEST TIME "
best_time_pad: defb ' '
best_time_digits: defb "--.--",0
best_score_text: defb "BEST SCORE "
best_score_digits: defb "0000",0
best_time: defw 65535
best_score: defb 0
border: defb 0
time_seconds: defb 0
time_fraction: defb 0
lost_text: defb "SHIP DESTROYED",0
won_text: defb "CLEAR SPACE",0
result_text: defb "METEOR STORM - FLIGHT ENDED",0
retry_text: defb "R RETRY   Q TITLE",0
score_text: defb "SCORE "
score_digits_text: defb "0000",0
; One attribute byte per character row, top to bottom. Bit 7 FLASH,
; bit 6 BRIGHT, bits 5-3 PAPER, bits 2-0 INK: $40+INK is BRIGHT INK on
; black PAPER. Cool at the top of the storm, hot just above the ship.
row_colours:
 defb $45,$45,$47          ; rows 0-2: HUD, cyan; the score row white
 defb $45,$45,$45,$45      ; rows 3-6: cyan
 defb $44,$44,$44,$44      ; rows 7-10: green
 defb $46,$46,$46,$46      ; rows 11-14: yellow
 defb $42,$42,$42,$42,$42  ; rows 15-19: red
 defb $47,$47,$47,$47      ; rows 20-23: white; the ship and the controls
; Debris records: X (set from ship_x), Y, dX, dY. The Y values are the
; ship rows where each piece's artwork begins: nose, middle, tail.
debris_start:
 defb 0,SHIP_Y+1,-3,-11
 defb 0,SHIP_Y+1,3,-11
 defb 0,SHIP_Y+6,-5,-8
 defb 0,SHIP_Y+6,0,-12
 defb 0,SHIP_Y+6,5,-8
 defb 0,SHIP_Y+11,-6,-4
 defb 0,SHIP_Y+11,-1,1
 defb 0,SHIP_Y+11,6,-4
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
boost_last: defb 0
elapsed: defw 0
steps_left: defb 0
ship_visible: defb 0
score: defb 0
finish_points: defb 0
spawn_drift: defb 0
spawn_kind: defb 0
spawn_speed: defb 0
spawn_x: defb 0
sound_note: defw 0
sound_left: defb 0
debris_time: defb 0
debris: defs DEBRIS*4
objects: defs SLOTS*7
state_end:
 include "assets.inc"
 end start

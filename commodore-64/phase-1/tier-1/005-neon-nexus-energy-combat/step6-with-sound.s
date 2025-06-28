; Neon Nexus - Lesson 5 Step 6
; Complete with SID sound effects

*= $0801

; BASIC stub: 10 SYS 2061
!word next_line
!word 10
!byte $9e
!text "2061"
!byte 0
next_line:
!word 0

; Constants
MAX_BULLETS = 3

; Start of our program
start:
        jsr setup_arena
        jsr init_sid
        jsr create_player
        jsr create_enemy
        
game_loop:
        ; Wait for raster sync
wait_raster:
        lda $d012
        cmp #$ff
        bne wait_raster
        
        jsr read_keyboard
        jsr update_enemy_movement
        jsr update_all_bullets
        jsr check_bullet_collisions
        jsr update_sounds
        
        ; Update player if moved
        lda player_moved
        beq check_enemy_moved
        
        jsr update_player
        lda #$00
        sta player_moved

check_enemy_moved:
        ; Update enemy if moved
        lda enemy_moved
        beq check_player_collision
        
        jsr update_enemy
        lda #$00
        sta enemy_moved

check_player_collision:
        jsr check_collision
        
        jmp game_loop

init_sid:
        ; Initialize SID chip
        lda #$00
        ldx #$00
clear_sid:
        sta $d400,x
        inx
        cpx #$19
        bne clear_sid
        
        ; Set master volume
        lda #15
        sta $d418
        
        rts

play_fire_sound:
        ; Quick blast sound
        
        ; Voice 1 setup
        lda #$00
        sta $d405       ; Attack/Decay
        lda #$f0        
        sta $d406       ; Sustain/Release
        
        ; High frequency for laser sound
        lda #$40
        sta $d400       ; Frequency low
        lda #$20
        sta $d401       ; Frequency high
        
        ; Noise waveform for blast
        lda #$81        ; Noise + gate on
        sta $d404
        
        ; Set sound timer
        lda #$04
        sta sound_timer
        
        rts

play_hit_sound:
        ; Enemy hit sound effect
        
        ; Voice 2 setup
        lda #$09        ; Fast attack, medium decay
        sta $d40c       ; Attack/Decay
        lda #$00        
        sta $d40d       ; Sustain/Release
        
        ; Lower frequency for explosion
        lda #$00
        sta $d407       ; Frequency low
        lda #$08
        sta $d408       ; Frequency high
        
        ; Noise for explosion
        lda #$81        ; Noise + gate on
        sta $d40b
        
        ; Set sound timer
        lda #$08
        sta hit_sound_timer
        
        rts

update_sounds:
        ; Update fire sound
        lda sound_timer
        beq check_hit_sound
        dec sound_timer
        bne check_hit_sound
        
        ; Turn off fire sound
        lda #$80        ; Gate off
        sta $d404
        
check_hit_sound:
        ; Update hit sound
        lda hit_sound_timer
        beq sounds_done
        dec hit_sound_timer
        bne sounds_done
        
        ; Turn off hit sound
        lda #$80        ; Gate off
        sta $d40b
        
sounds_done:
        rts

find_bullet_slot:
        ldx #0
find_loop:
        lda bullet_active,x
        beq found_slot      ; Found inactive bullet
        inx
        cpx #MAX_BULLETS
        bne find_loop
        
        ; No free slots
        ldx #$ff
        rts
        
found_slot:
        ; X contains free slot index
        rts

fire_bullet:
        jsr find_bullet_slot
        cpx #$ff
        beq cant_fire       ; No free bullet slots
        
        ; Activate bullet in slot X
        lda #$01
        sta bullet_active,x
        
        lda player_x
        sta bullet_x,x
        
        lda player_y
        sec
        sbc #1
        sta bullet_y,x
        
        ; Play fire sound
        jsr play_fire_sound
        
cant_fire:
        rts

update_all_bullets:
        ldx #0
update_bullet_loop:
        lda bullet_active,x
        beq skip_bullet
        
        ; Store current position for clearing
        lda bullet_x,x
        sta old_bullet_x
        lda bullet_y,x
        sta old_bullet_y
        
        ; Move bullet
        dec bullet_y,x
        
        ; Check screen boundary
        lda bullet_y,x
        bpl bullet_on_screen
        
        ; Deactivate off-screen bullet
        lda #$00
        sta bullet_active,x
        
        ; Clear the old position
        jsr clear_old_bullet
        jmp skip_bullet
        
bullet_on_screen:
        ; Clear old position
        jsr clear_old_bullet
        
        ; Draw at new position
        lda bullet_x,x
        sta player_x
        lda bullet_y,x
        sta player_y
        jsr draw_bullet
        
skip_bullet:
        inx
        cpx #MAX_BULLETS
        bne update_bullet_loop
        rts

clear_old_bullet:
        ; Use stored old position
        lda old_bullet_x
        sta player_x
        lda old_bullet_y
        sta player_y
        jsr calculate_screen_pos
        lda #$20        ; Space
        ldy #$00
        sta ($fb),y
        rts

draw_bullet:
        jsr calculate_screen_pos
        
        ; Draw bullet character
        lda #$2e        ; Period/dot character
        ldy #$00
        sta ($fb),y
        
        ; Set bullet color
        lda #$01        ; White
        sta $d800 + 200
        
        rts

check_bullet_collisions:
        ldx #0
bullet_collision_loop:
        ; Check if this bullet is active
        lda bullet_active,x
        beq next_bullet
        
        ; Check collision with enemy
        lda bullet_x,x
        cmp enemy_x
        bne next_bullet
        
        lda bullet_y,x
        cmp enemy_y
        bne next_bullet
        
        ; Hit detected!
        jsr handle_enemy_hit
        
        ; Deactivate bullet
        lda #$00
        sta bullet_active,x
        
        ; Clear bullet
        lda bullet_x,x
        sta player_x
        lda bullet_y,x
        sta player_y
        jsr calculate_screen_pos
        lda #$20
        ldy #$00
        sta ($fb),y
        
next_bullet:
        inx
        cpx #MAX_BULLETS
        bne bullet_collision_loop
        rts

handle_enemy_hit:
        ; Play hit sound
        jsr play_hit_sound
        
        ; Flash effect
        lda #$01        ; White
        sta $d020       ; Border flash
        
        ; Move enemy to new position
        lda #5
        sta enemy_x
        lda #5
        sta enemy_y
        
        ; Increment score (could add here)
        
        ; Brief flash delay
        ldy #$20
flash_delay:
        nop
        dey
        bne flash_delay
        
        ; Restore border
        lda #$06
        sta $d020
        
        ; Force enemy redraw
        lda #$01
        sta enemy_moved
        
        rts

setup_arena:
        ; Set border color to dark blue
        lda #$06     
        sta $d020
        
        ; Set background color to black
        lda #$00
        sta $d021
        
        ; Clear screen manually
        lda #$20        ; Space character
        ldx #$00
clear_loop:
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne clear_loop
        
        rts

create_player:
        jsr calculate_screen_pos
        
        lda #$5a        ; Diamond character
        ldy #$00
        sta ($fb),y
        
        ; Set color
        lda #$07        ; Yellow
        sta $d800 + 500
        
        rts

create_enemy:
        ; Create enemy at fixed position
        lda enemy_x
        sta player_x
        lda enemy_y
        sta player_y
        
        jsr calculate_screen_pos
        
        lda #$2a        ; Star character
        ldy #$00
        sta ($fb),y
        
        ; Set enemy color to red
        lda #$02        ; Red
        sta $d800 + 200
        
        ; Restore player position
        lda #20
        sta player_x
        lda #12
        sta player_y
        
        rts

update_enemy_movement:
        ; Check enemy movement delay
        lda enemy_delay
        beq enemy_can_move
        dec enemy_delay
        rts
        
enemy_can_move:
        ; Set movement flag
        lda #$01
        sta enemy_moved
        
        ; Reset delay
        lda #$08
        sta enemy_delay
        
        rts

update_enemy:
        ; Store enemy's old position
        lda enemy_x
        sta old_enemy_x
        lda enemy_y
        sta old_enemy_y
        
        ; Simple AI: move toward player
        lda player_x
        cmp enemy_x
        beq check_y_movement
        bcc move_enemy_left
        
        ; Player is right
        inc enemy_x
        jmp enemy_movement_done
        
move_enemy_left:
        dec enemy_x
        jmp enemy_movement_done
        
check_y_movement:
        lda player_y
        cmp enemy_y
        beq enemy_movement_done
        bcc move_enemy_up
        
        ; Player is down
        inc enemy_y
        jmp enemy_movement_done
        
move_enemy_up:
        dec enemy_y
        
enemy_movement_done:
        ; Keep enemy in bounds
        lda enemy_x
        bpl check_enemy_x_max
        lda #0
        sta enemy_x
        
check_enemy_x_max:
        lda enemy_x
        cmp #40
        bcc check_enemy_y_min
        lda #39
        sta enemy_x
        
check_enemy_y_min:
        lda enemy_y
        bpl check_enemy_y_max
        lda #0
        sta enemy_y
        
check_enemy_y_max:
        lda enemy_y
        cmp #25
        bcc enemy_bounds_ok
        lda #24
        sta enemy_y
        
enemy_bounds_ok:
        ; Clear old enemy position
        lda old_enemy_x
        sta player_x
        lda old_enemy_y
        sta player_y
        
        jsr calculate_screen_pos
        lda #$20        ; Space
        ldy #$00
        sta ($fb),y
        
        ; Draw enemy at new position
        lda enemy_x
        sta player_x
        lda enemy_y
        sta player_y
        
        jsr calculate_screen_pos
        lda #$2a        ; Star
        ldy #$00
        sta ($fb),y
        
        ; Restore player position
        lda #20
        sta player_x
        lda #12
        sta player_y
        
        rts

check_collision:
        ; Check if player and enemy positions match
        lda player_x
        cmp enemy_x
        bne no_collision
        
        lda player_y
        cmp enemy_y
        bne no_collision
        
        ; Collision detected!
        jsr handle_collision
        
no_collision:
        rts

handle_collision:
        ; Play collision sound
        ; Voice 3 - low rumble
        lda #$0f
        sta $d413       ; Attack/Decay
        lda #$00
        sta $d414       ; Sustain/Release
        
        lda #$00
        sta $d40e       ; Frequency low
        lda #$04
        sta $d40f       ; Frequency high
        
        lda #$21        ; Sawtooth + gate
        sta $d412
        
        ; Flash border red
        lda #$02        ; Red
        sta $d020
        
        ; Reset positions
        lda #5
        sta enemy_x
        lda #5
        sta enemy_y
        
        lda #30
        sta player_x
        lda #15
        sta player_y
        
        ; Brief delay
        ldx #$50
collision_delay:
        nop
        dex
        bne collision_delay
        
        ; Turn off collision sound
        lda #$20        ; Gate off
        sta $d412
        
        ; Restore border
        lda #$06        ; Blue
        sta $d020
        
        ; Force redraw
        lda #$01
        sta player_moved
        sta enemy_moved
        
        rts

calculate_screen_pos:
        ; Calculate screen address from player_x and player_y
        ; Formula: $0400 + (Y * 40) + X
        
        ; Start with base screen address
        lda #$00
        sta $fb         ; Low byte
        lda #$04        ; High byte ($0400)
        sta $fc
        
        ; Add Y offset (Y * 40)
        ldy player_y
        beq add_x       ; Skip if Y=0
        
multiply_y:
        ; Add 40 for each row
        lda $fb
        clc
        adc #40
        sta $fb
        bcc no_carry
        inc $fc         ; Handle carry to high byte
no_carry:
        dey
        bne multiply_y
        
add_x:
        ; Add X offset
        lda $fb
        clc
        adc player_x
        sta $fb
        bcc done
        inc $fc
done:
        rts

read_keyboard:
        ; Check movement delay first
        lda move_delay
        beq can_move
        dec move_delay
        rts
        
can_move:
        ; Check for SPACE key (fire)
        lda #$7f        ; Row 7
        sta $dc00
        lda $dc01
        and #$10        ; Bit 4 = SPACE
        bne check_w
        
        ; Check if we can fire
        lda fire_delay
        bne check_w
        
        ; Fire bullet
        jsr fire_bullet
        
        ; Set fire delay
        lda #$08        ; Prevent rapid fire
        sta fire_delay
        
check_w:
        ; Decrement fire delay if active
        lda fire_delay
        beq check_movement
        dec fire_delay
        
check_movement:
        ; Check for W key (up)
        lda #$fd
        sta $dc00
        lda $dc01
        and #$02
        bne check_s
        
        ; W pressed - move up
        lda player_y
        beq check_s
        
        jsr store_old_position
        dec player_y
        lda #$01
        sta player_moved
        lda #$04
        sta move_delay
        rts
        
check_s:
        ; Check for S key (down)
        lda #$fd
        sta $dc00
        lda $dc01
        and #$20
        bne check_a
        
        ; S pressed - move down
        lda player_y
        cmp #24
        beq check_a
        
        jsr store_old_position
        inc player_y
        lda #$01
        sta player_moved
        lda #$04
        sta move_delay
        rts
        
check_a:
        ; Check for A key (left)
        lda #$fd
        sta $dc00
        lda $dc01
        and #$04
        bne check_d
        
        ; A pressed - move left
        lda player_x
        beq check_d
        
        jsr store_old_position
        dec player_x
        lda #$01
        sta player_moved
        lda #$04
        sta move_delay
        rts
        
check_d:
        ; Check for D key (right)
        lda #$fb
        sta $dc00
        lda $dc01
        and #$04
        bne done_keys
        
        ; D pressed - move right
        lda player_x
        cmp #39
        beq done_keys
        
        jsr store_old_position
        inc player_x
        lda #$01
        sta player_moved
        lda #$04
        sta move_delay
        
done_keys:
        rts

store_old_position:
        lda player_x
        sta old_player_x
        lda player_y  
        sta old_player_y
        rts

update_player:
        ; Temporarily store current position
        lda player_x
        sta $02
        lda player_y
        sta $03
        
        ; Use old position to clear
        lda old_player_x
        sta player_x
        lda old_player_y
        sta player_y
        
        ; Clear old position
        jsr calculate_screen_pos
        lda #$20        ; Space
        ldy #$00
        sta ($fb),y
        
        ; Restore current position
        lda $02
        sta player_x
        lda $03
        sta player_y
        
        ; Draw at current position
        jsr create_player
        rts

; Variables at end
player_x:     !byte 20
player_y:     !byte 12
old_player_x: !byte 20
old_player_y: !byte 12
move_delay:   !byte 0
player_moved: !byte 0

; Enemy data
enemy_x:        !byte 10
enemy_y:        !byte 8
old_enemy_x:    !byte 10
old_enemy_y:    !byte 8
enemy_delay:    !byte 0
enemy_moved:    !byte 0

; Bullet arrays
bullet_active:  !fill MAX_BULLETS, 0
bullet_x:       !fill MAX_BULLETS, 0
bullet_y:       !fill MAX_BULLETS, 0

; Temporary storage
old_bullet_x:   !byte 0
old_bullet_y:   !byte 0

; Fire control
fire_delay:     !byte 0

; Sound timers
sound_timer:    !byte 0
hit_sound_timer:!byte 0
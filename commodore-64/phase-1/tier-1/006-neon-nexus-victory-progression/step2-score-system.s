; Neon Nexus - Lesson 6 Step 2
; BCD score implementation

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
        jsr display_score
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

display_score:
        ; Position cursor for score
        lda #<($0400 + 40)      ; Row 1, column 0
        sta $fb
        lda #>($0400 + 40)
        sta $fc
        
        ; Display "SCORE:"
        ldy #0
score_text_loop:
        lda score_text,y
        beq score_digits
        sta ($fb),y
        
        ; Set color
        lda #$01        ; White
        sta $d800 + 40,y
        
        iny
        bne score_text_loop
        
score_digits:
        ; Display 6 digits
        ldx #2          ; 3 bytes
        ldy #7          ; Screen position after "SCORE: "
        
score_byte_loop:
        lda score,x     ; Get BCD byte
        pha             ; Save it
        
        ; High nibble
        lsr
        lsr
        lsr
        lsr
        ora #$30        ; Convert to PETSCII digit
        sta ($fb),y
        
        ; Set color
        lda #$07        ; Yellow
        sta $d800 + 40,y
        
        iny
        
        ; Low nibble
        pla
        and #$0f
        ora #$30        ; Convert to PETSCII digit
        sta ($fb),y
        
        ; Set color
        lda #$07        ; Yellow
        sta $d800 + 40,y
        
        iny
        
        dex
        bpl score_byte_loop
        
        rts

add_to_score:
        ; Add 10 points (standard hit value)
        sed             ; Set decimal mode
        clc
        lda score
        adc #$10        ; Add 10 in BCD
        sta score
        lda score+1
        adc #$00        ; Handle carry
        sta score+1
        lda score+2
        adc #$00
        sta score+2
        cld             ; Clear decimal mode
        
        jsr display_score
        rts

handle_enemy_hit:
        ; Add score for hit
        jsr add_to_score
        
        ; Play hit sound
        jsr play_hit_sound
        
        ; Flash effect
        lda #$01        ; White
        sta $d020       ; Border flash
        
        ; Clear old enemy position
        lda enemy_x
        sta player_x
        lda enemy_y
        sta player_y
        jsr calculate_screen_pos
        lda #$20
        ldy #$00
        sta ($fb),y
        
        ; Move enemy to new position
        lda random_seed
        and #$1f        ; 0-31
        clc
        adc #4          ; 4-35
        sta enemy_x
        
        lda random_seed
        lsr
        lsr
        and #$0f        ; 0-15
        clc
        adc #3          ; 3-18
        sta enemy_y
        
        ; Update random seed
        lda random_seed
        asl
        adc #23
        sta random_seed
        
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
        ; Quick laser blast sound
        lda #$00
        sta $d405       ; Attack/Decay
        lda #$f0        
        sta $d406       ; Sustain/Release
        
        lda #$40
        sta $d400       ; Frequency low
        lda #$20
        sta $d401       ; Frequency high
        
        lda #$81        ; Noise + gate on
        sta $d404
        
        lda #$04
        sta sound_timer
        
        rts

play_hit_sound:
        ; Enemy hit explosion sound
        lda #$09        ; Fast attack, medium decay
        sta $d40c       ; Attack/Decay
        lda #$00        
        sta $d40d       ; Sustain/Release
        
        lda #$00
        sta $d407       ; Frequency low
        lda #$08
        sta $d408       ; Frequency high
        
        lda #$81        ; Noise + gate on
        sta $d40b
        
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
        
        ; Set color properly
        lda $fb
        sta $fd
        lda $fc
        clc
        adc #$d4
        sta $fe
        
        lda #$07        ; Yellow
        ldy #$00
        sta ($fd),y
        
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
        
        ; Set enemy color properly
        lda $fb
        sta $fd
        lda $fc
        clc
        adc #$d4
        sta $fe
        
        lda #$02        ; Red
        ldy #$00
        sta ($fd),y
        
        ; Restore player position
        lda #20
        sta player_x
        lda #12
        sta player_y
        
        rts

find_bullet_slot:
        ldx #0
find_loop:
        lda bullet_active,x
        beq found_slot
        inx
        cpx #MAX_BULLETS
        bne find_loop
        
        ldx #$ff
        rts
        
found_slot:
        rts

fire_bullet:
        jsr find_bullet_slot
        cpx #$ff
        beq cant_fire
        
        lda #$01
        sta bullet_active,x
        
        lda player_x
        sta bullet_x,x
        
        lda player_y
        sec
        sbc #1
        sta bullet_y,x
        
        jsr play_fire_sound
        
cant_fire:
        rts

update_all_bullets:
        ldx #0
update_bullet_loop:
        lda bullet_active,x
        beq skip_bullet
        
        lda bullet_x,x
        sta old_bullet_x
        lda bullet_y,x
        sta old_bullet_y
        
        dec bullet_y,x
        
        lda bullet_y,x
        bpl bullet_on_screen
        
        lda #$00
        sta bullet_active,x
        
        jsr clear_old_bullet
        jmp skip_bullet
        
bullet_on_screen:
        jsr clear_old_bullet
        
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
        lda old_bullet_x
        sta player_x
        lda old_bullet_y
        sta player_y
        jsr calculate_screen_pos
        lda #$20
        ldy #$00
        sta ($fb),y
        rts

draw_bullet:
        stx $02
        
        jsr calculate_screen_pos
        
        lda #$51        ; Circle character
        ldy #$00
        sta ($fb),y
        
        lda $fb
        sta $fd
        lda $fc
        clc
        adc #$d4
        sta $fe
        
        lda #$01        ; White
        ldy #$00
        sta ($fd),y
        
        ldx $02
        
        rts

check_bullet_collisions:
        ldx #0
bullet_collision_loop:
        lda bullet_active,x
        beq next_bullet
        
        lda bullet_x,x
        cmp enemy_x
        bne next_bullet
        
        lda bullet_y,x
        cmp enemy_y
        bne next_bullet
        
        ; Hit detected!
        jsr handle_enemy_hit
        
        lda #$00
        sta bullet_active,x
        
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

update_enemy_movement:
        lda enemy_delay
        beq enemy_can_move
        dec enemy_delay
        rts
        
enemy_can_move:
        lda #$01
        sta enemy_moved
        
        lda #$08
        sta enemy_delay
        
        rts

update_enemy:
        lda enemy_x
        sta old_enemy_x
        lda enemy_y
        sta old_enemy_y
        
        ; Simple AI
        lda player_x
        cmp enemy_x
        beq check_y_movement
        bcc move_enemy_left
        
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
        
        inc enemy_y
        jmp enemy_movement_done
        
move_enemy_up:
        dec enemy_y
        
enemy_movement_done:
        ; Keep in bounds
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
        ; Clear old position
        lda old_enemy_x
        sta player_x
        lda old_enemy_y
        sta player_y
        
        jsr calculate_screen_pos
        lda #$20
        ldy #$00
        sta ($fb),y
        
        ; Draw at new position
        lda enemy_x
        sta player_x
        lda enemy_y
        sta player_y
        
        jsr calculate_screen_pos
        lda #$2a
        ldy #$00
        sta ($fb),y
        
        lda $fb
        sta $fd
        lda $fc
        clc
        adc #$d4
        sta $fe
        
        lda #$02        ; Red
        ldy #$00
        sta ($fd),y
        
        lda #20
        sta player_x
        lda #12
        sta player_y
        
        rts

check_collision:
        lda player_x
        cmp enemy_x
        bne no_collision
        
        lda player_y
        cmp enemy_y
        bne no_collision
        
        jsr handle_collision
        
no_collision:
        rts

handle_collision:
        ; Play collision sound
        lda #$0f
        sta $d413
        lda #$00
        sta $d414
        
        lda #$00
        sta $d40e
        lda #$04
        sta $d40f
        
        lda #$21
        sta $d412
        
        ; Flash screen
        lda #$02
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
        
        ; Delay
        ldx #$50
collision_delay:
        nop
        dex
        bne collision_delay
        
        lda #$20
        sta $d412
        
        lda #$06
        sta $d020
        
        lda #$01
        sta player_moved
        sta enemy_moved
        
        rts

calculate_screen_pos:
        lda #$00
        sta $fb
        lda #$04
        sta $fc
        
        ldy player_y
        beq add_x
        
multiply_y:
        lda $fb
        clc
        adc #40
        sta $fb
        bcc no_carry
        inc $fc
no_carry:
        dey
        bne multiply_y
        
add_x:
        lda $fb
        clc
        adc player_x
        sta $fb
        bcc done
        inc $fc
done:
        rts

read_keyboard:
        lda move_delay
        beq can_move
        dec move_delay
        rts
        
can_move:
        ; Check SPACE for fire
        lda #$7f
        sta $dc00
        lda $dc01
        and #$10
        bne check_w
        
        lda fire_delay
        bne check_w
        
        jsr fire_bullet
        
        lda #$08
        sta fire_delay
        
check_w:
        lda fire_delay
        beq check_movement
        dec fire_delay
        
check_movement:
        ; Check W
        lda #$fd
        sta $dc00
        lda $dc01
        and #$02
        bne check_s
        
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
        ; Check S
        lda #$fd
        sta $dc00
        lda $dc01
        and #$20
        bne check_a
        
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
        ; Check A
        lda #$fd
        sta $dc00
        lda $dc01
        and #$04
        bne check_d
        
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
        ; Check D
        lda #$fb
        sta $dc00
        lda $dc01
        and #$04
        bne done_keys
        
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
        lda player_x
        sta $02
        lda player_y
        sta $03
        
        lda old_player_x
        sta player_x
        lda old_player_y
        sta player_y
        
        jsr calculate_screen_pos
        lda #$20
        ldy #$00
        sta ($fb),y
        
        lda $02
        sta player_x
        lda $03
        sta player_y
        
        jsr create_player
        rts

; Data
score_text: !text "SCORE: ", 0

; Variables
player_x:     !byte 20
player_y:     !byte 12
old_player_x: !byte 20
old_player_y: !byte 12
move_delay:   !byte 0
player_moved: !byte 0

enemy_x:        !byte 10
enemy_y:        !byte 8
old_enemy_x:    !byte 10
old_enemy_y:    !byte 8
enemy_delay:    !byte 0
enemy_moved:    !byte 0

bullet_active:  !fill MAX_BULLETS, 0
bullet_x:       !fill MAX_BULLETS, 0
bullet_y:       !fill MAX_BULLETS, 0

old_bullet_x:   !byte 0
old_bullet_y:   !byte 0

fire_delay:     !byte 0

sound_timer:    !byte 0
hit_sound_timer:!byte 0

random_seed:    !byte 42

; Score storage (BCD format - 6 digits)
score:  !byte 0, 0, 0    ; 000000
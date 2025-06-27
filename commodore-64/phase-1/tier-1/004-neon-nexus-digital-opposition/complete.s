; Neon Nexus - Lesson 4 Complete
; Final program with enemy AI and collision detection

*= $0801

; BASIC stub: 10 SYS 2061
!word next_line
!word 10
!byte $9e
!text "2061"
!byte 0
next_line:
!word 0

; Start of our program
start:
        jsr setup_arena
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
        
        ; Update player if moved
        lda player_moved
        beq check_enemy_moved
        
        jsr update_player
        lda #$00
        sta player_moved

check_enemy_moved:
        ; Update enemy if moved
        lda enemy_moved
        beq check_collision_detect
        
        jsr update_enemy
        lda #$00
        sta enemy_moved

check_collision_detect:
        jsr check_collision
        
        jmp game_loop

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
        sta $0400,x     ; Screen page 1
        sta $0500,x     ; Screen page 2
        sta $0600,x     ; Screen page 3
        sta $0700,x     ; Screen page 4
        inx
        bne clear_loop
        
        rts

create_player:
        jsr calculate_screen_pos
        
        lda #$5a        ; Diamond character
        ldy #$00
        sta ($fb),y
        
        ; Set color (simplified version)
        lda #$07        ; Yellow
        sta $d800 + 500 ; Approximate center color
        
        rts

create_enemy:
        ; Create enemy at fixed position
        lda enemy_x
        sta player_x        ; Temporarily use player vars
        lda enemy_y
        sta player_y
        
        jsr calculate_screen_pos
        
        lda #$2a            ; Star character for enemy
        ldy #$00
        sta ($fb),y
        
        ; Set enemy color to red
        lda #$02            ; Red color
        sta $d800 + 200     ; Approximate enemy color position
        
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
        
        ; Reset delay (slower than player)
        lda #$08        ; 8 frame delay
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
        beq check_y_movement    ; Same X, check Y
        bcc move_enemy_left     ; Player is left
        
        ; Player is right
        inc enemy_x
        jmp enemy_movement_done
        
move_enemy_left:
        dec enemy_x
        jmp enemy_movement_done
        
check_y_movement:
        lda player_y
        cmp enemy_y
        beq enemy_movement_done ; Same position
        bcc move_enemy_up       ; Player is up
        
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
        lda #$20            ; Space
        ldy #$00
        sta ($fb),y
        
        ; Draw enemy at new position
        lda enemy_x
        sta player_x
        lda enemy_y
        sta player_y
        
        jsr calculate_screen_pos
        lda #$2a            ; Star
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
        ; Flash border and screen several times
        ldx #$08        ; Number of flashes
        
flash_loop:
        ; Flash red
        lda #$02        ; Red
        sta $d020
        sta $d021
        
        ; Short delay
        ldy #$30
red_delay:
        nop
        dey
        bne red_delay
        
        ; Flash blue
        lda #$06        ; Blue
        sta $d020
        lda #$00        ; Black
        sta $d021
        
        ; Short delay
        ldy #$30
blue_delay:
        nop
        dey
        bne blue_delay
        
        dex
        bne flash_loop
        
        ; Reset positions farther apart
        lda #5
        sta enemy_x
        lda #5
        sta enemy_y
        
        lda #30
        sta player_x
        lda #15
        sta player_y
        
        ; Force redraw of both entities
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
        dec move_delay      ; Count down delay
        rts                 ; Exit if still in delay
        
can_move:
        ; Check for W key (up)
        lda #$fd
        sta $dc00
        lda $dc01
        and #$02
        bne check_s
        
        ; W pressed - move up
        lda player_y
        beq check_s     ; Already at top
        
        jsr store_old_position  ; Store position before changing
        dec player_y            ; Now change position
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
        beq check_a     ; Already at bottom
        
        jsr store_old_position  ; Store position before changing
        inc player_y            ; Now change position
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
        beq check_d     ; Already at left edge
        
        jsr store_old_position  ; Store position before changing
        dec player_x            ; Now change position
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
        beq done_keys   ; Already at right edge
        
        jsr store_old_position  ; Store position before changing
        inc player_x            ; Now change position
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
        ; Temporarily store current position in zero page
        lda player_x
        sta $02         ; Temp storage for X
        lda player_y
        sta $03         ; Temp storage for Y
        
        ; Use old position to calculate where to clear
        lda old_player_x
        sta player_x    ; Temporarily use old X
        lda old_player_y
        sta player_y    ; Temporarily use old Y
        
        ; Clear old position
        jsr calculate_screen_pos
        lda #$20        ; Space character
        ldy #$00
        sta ($fb),y     ; Clear old position
        
        ; Restore current position
        lda $02
        sta player_x
        lda $03
        sta player_y
        
        ; Now draw at current position
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
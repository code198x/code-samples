; Neon Nexus - Lesson 3: Electronic Pulse
; Step 9: Fixed trail issue with proper old position clearing
; Assemble with: acme -f cbm -o movement.prg step9-proper-clearing.s

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
        
game_loop:
        ; Wait for raster line 255 (bottom of screen)
wait_raster:
        lda $d012       ; Current raster line
        cmp #$ff        ; Wait for line 255
        bne wait_raster
        
        jsr read_keyboard
        
        ; Only update display if player moved
        lda player_moved
        beq game_loop
        
        jsr update_player
        lda #$00
        sta player_moved    ; Clear flag
        
        jmp game_loop

setup_arena:
        ; Set up arena colors
        lda #$06        ; Dark blue border
        sta $d020
        lda #$00        ; Black background
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

read_keyboard:
        ; Check movement delay first
        lda move_delay
        beq can_move
        dec move_delay
        rts
        
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
        beq check_a     ; Already at bottom
        
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
        beq check_d     ; Already at left edge
        
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
        beq done_keys   ; Already at right edge
        
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
        
        ; Clear old color too
        lda #$00
        sta $fd
        lda #$d8
        sta $fe
        
        ldy old_player_y
        beq clear_x_color
color_clear_loop:
        lda $fd
        clc
        adc #40
        sta $fd
        bcc no_carry_clear
        inc $fe
no_carry_clear:
        dey
        bne color_clear_loop
clear_x_color:
        lda $fd
        clc
        adc old_player_x
        sta $fd
        bcc do_clear
        inc $fe
do_clear:
        lda #$00
        ldy #$00
        sta ($fd),y
        
        ; Restore current position
        lda $02
        sta player_x
        lda $03
        sta player_y
        
        ; Now draw at current position
        jsr create_player
        rts

create_player:
        jsr calculate_screen_pos
        
        lda #$5a        ; Diamond character
        ldy #$00
        sta ($fb),y
        
        ; Set color
        lda #$00
        sta $fd
        lda #$d8
        sta $fe
        
        ldy player_y
        beq add_x_color
color_loop:
        lda $fd
        clc
        adc #40
        sta $fd
        bcc no_carry_color
        inc $fe
no_carry_color:
        dey
        bne color_loop
add_x_color:
        lda $fd
        clc
        adc player_x
        sta $fd
        bcc place_color
        inc $fe
place_color:
        lda #$07        ; Yellow
        ldy #$00
        sta ($fd),y
        
        rts

calculate_screen_pos:
        ; Calculate $0400 + (Y * 40) + X
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
        bcc done_calc
        inc $fc
done_calc:
        rts

; Player data (at end to avoid breaking BASIC stub)
player_x:     !byte 20    ; X position (column)
player_y:     !byte 12    ; Y position (row)
move_delay:   !byte 0     ; Movement speed limiter
player_moved: !byte 0     ; Movement flag
old_player_x: !byte 20    ; For clearing old position
old_player_y: !byte 12    ; For clearing old position
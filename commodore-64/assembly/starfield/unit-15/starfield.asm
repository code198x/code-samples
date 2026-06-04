; Starfield - Unit 14: Starfield
; Assemble with: acme -f cbm -o starfield.prg starfield.asm

; ------------------------------------------------
; Zero-page variables
; ------------------------------------------------
bullet_active  = $02   ; 0 = no bullet, 1 = active
bullet_y       = $03   ; Bullet Y position
score          = $07   ; Score (0-99, BCD format)
enemy_x_tbl   = $08   ; 3 bytes ($08, $09, $0a)
enemy_y_tbl   = $0b   ; 3 bytes ($0b, $0c, $0d)
flash_tbl      = $0e   ; 3 bytes ($0e, $0f, $10)
game_state     = $11   ; 0 = playing, 1 = game over
lives          = $12   ; Lives remaining (starts at 3)
death_timer    = $13   ; Death flash countdown (0 = no flash)
star_row       = $14   ; 8 bytes ($14-$1b) — row 0-24
star_col       = $1c   ; 8 bytes ($1c-$23) — column 0-39
frame_count    = $24   ; Frame counter for parallax timing

; $fb-$fc: temporary pointer (used by star routines)

; ------------------------------------------------
; BASIC stub
; ------------------------------------------------
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

; ------------------------------------------------
; One-time hardware setup
; ------------------------------------------------
*= $080d
        ; Black screen
        lda #$00
        sta $d020           ; Border colour
        sta $d021           ; Background colour

        ; Sprite 1 colour (yellow, never changes)
        lda #$07
        sta $d028

        ; Set score colour to white (persists across restarts)
        lda #$01
        sta $d800
        sta $d801

        ; Set lives colour to white (persists across restarts)
        sta $d827

        ; SID setup — voice 1 laser sound
        lda #$0f
        sta $d418           ; Volume to maximum

        lda #$00
        sta $d400           ; Frequency low byte
        lda #$10
        sta $d401           ; Frequency high byte

        lda #$09
        sta $d405           ; Attack=0, Decay=9
        lda #$00
        sta $d406           ; Sustain=0, Release=0

        ; First-time init
        jsr clear_screen
        jsr init_game

!ifdef SCREENSHOT_MODE {
        ; Set a visible score
        lda #$05
        sta score
        lda #$30
        sta $0400
        lda #$35
        sta $0401

        ; Lives at 2 (lost one life)
        lda #$02
        sta lives
        lda #$32
        sta $0427

        ; Position bullet mid-screen
        lda $d000
        sta $d002
        lda #140
        sta $d003

        ; Enable all sprites (ship + bullet + 3 enemies)
        lda #%00011111
        sta $d015

        ; Freeze the game
        lda #$01
        sta game_state
}

; ------------------------------------------------
; Game loop — runs once per frame
; ------------------------------------------------
game_loop:
        ; Wait for the raster beam to reach line 255
-       lda $d012
        cmp #$ff
        bne -

        ; --- Check game state ---
        lda game_state
        beq game_active

        ; --- Game over: poll fire button ---
        lda $dc00
        and #%00010000
        bne game_loop           ; Not pressed, keep waiting

        ; Fire pressed — restart the game
        jsr clear_screen
        jsr init_game
        jmp game_loop

game_active:

        ; --- Update frame counter ---
        inc frame_count

        ; --- Update stars ---
        ldx #$00
star_loop:
        jsr erase_star

        ; Check if star should move this frame
        cpx #$04
        bcc move_star           ; Close stars (0-3) always move

        ; Distant star — only move on odd frames
        lda frame_count
        and #$01
        beq skip_move           ; Even frame, don't move

move_star:
        inc star_row,x
        lda star_row,x
        cmp #25
        bcc skip_move

        ; Wrap to row 0
        lda #$00
        sta star_row,x

skip_move:
        jsr draw_star

        inx
        cpx #$08
        bne star_loop

        ; --- Death timer (invulnerability flash) ---
        lda death_timer
        beq no_death_flash

        dec death_timer
        bne no_death_flash

        ; Timer expired — restore border to black
        lda #$00
        sta $d020

no_death_flash:

        ; --- Read joystick and move ship ---

        ; UP (bit 0)
        lda $dc00
        and #%00000001
        bne not_up
        dec $d001
        dec $d001
not_up:

        ; DOWN (bit 1)
        lda $dc00
        and #%00000010
        bne not_down
        inc $d001
        inc $d001
not_down:

        ; LEFT (bit 2)
        lda $dc00
        and #%00000100
        bne not_left
        dec $d000
        dec $d000
not_left:

        ; RIGHT (bit 3)
        lda $dc00
        and #%00001000
        bne not_right
        inc $d000
        inc $d000
not_right:

        ; --- Fire button (bit 4) ---
        lda $dc00
        and #%00010000
        bne no_fire

        lda bullet_active
        bne no_fire

        ; Spawn bullet at ship position
        lda $d000
        sta $d002
        lda $d001
        sta bullet_y

        ; Enable sprite 1
        lda $d015
        ora #%00000010
        sta $d015

        lda #$01
        sta bullet_active

        ; Trigger laser sound
        lda #$20
        sta $d404
        lda #$21
        sta $d404

no_fire:

        ; --- Update bullet ---
        lda bullet_active
        beq no_bullet

        ; Move bullet up
        lda bullet_y
        sec
        sbc #$04
        sta bullet_y
        sta $d003

        ; Off-screen check
        cmp #$1e
        bcs no_bullet

        lda #$00
        sta bullet_active
        lda $d015
        and #%11111101
        sta $d015

no_bullet:

        ; --- Check bullet-enemy collision ---
        lda bullet_active
        bne check_collision
        jmp no_hit
check_collision:

        ldx #$00
collision_loop:
        lda flash_tbl,x
        bne next_collision

        ; Check Y distance
        lda bullet_y
        sec
        sbc enemy_y_tbl,x
        cmp #$10
        bcc check_x
        cmp #$f0
        bcc next_collision

check_x:
        ; Check X distance
        lda $d002
        sec
        sbc enemy_x_tbl,x
        cmp #$10
        bcc hit_enemy
        cmp #$f0
        bcc next_collision
        jmp hit_enemy

next_collision:
        inx
        cpx #$03
        bne collision_loop
        jmp no_hit

hit_enemy:
        ; Deactivate bullet
        lda #$00
        sta bullet_active
        lda $d015
        and #%11111101
        sta $d015

        ; Flash this enemy white
        lda #$08
        sta flash_tbl,x
        ldy sprite_colour_off,x
        lda #$01
        sta $d000,y

        ; Explosion sound — SID voice 2 (noise)
        lda #$00
        sta $d407
        lda #$08
        sta $d408
        lda #$09
        sta $d40c
        lda #$00
        sta $d40d
        lda #$80
        sta $d40b
        lda #$81
        sta $d40b

        ; Increment score (BCD)
        sed
        lda score
        clc
        adc #$01
        sta score
        cld

        ; Update score display — tens digit
        lda score
        lsr
        lsr
        lsr
        lsr
        clc
        adc #$30
        sta $0400

        ; Update score display — ones digit
        lda score
        and #$0f
        clc
        adc #$30
        sta $0401

no_hit:

        ; --- Update all enemies ---
        ldx #$00
enemy_loop:
        lda flash_tbl,x
        bne do_flash

        ; Move down 1 pixel per frame
        lda enemy_y_tbl,x
        clc
        adc #$01
        sta enemy_y_tbl,x

        ; Off-screen check
        cmp #$f8
        bcc update_enemy_sprite

        ; Respawn at top
        lda #$32
        jsr spawn_enemy
        jmp next_enemy

do_flash:
        dec flash_tbl,x
        bne update_enemy_sprite

        ; Flash done — respawn
        lda #$32
        jsr spawn_enemy
        jmp next_enemy

update_enemy_sprite:
        ldy sprite_pos_off,x
        lda enemy_x_tbl,x
        sta $d000,y
        lda enemy_y_tbl,x
        sta $d001,y

next_enemy:
        inx
        cpx #$03
        bne enemy_loop

        ; --- Check ship-enemy collision ---
        lda death_timer
        bne skip_ship_collision

        ldx #$00
ship_collision_loop:
        lda flash_tbl,x
        bne next_ship_check

        ; Check Y distance
        lda $d001
        sec
        sbc enemy_y_tbl,x
        cmp #$10
        bcc check_ship_x
        cmp #$f0
        bcc next_ship_check

check_ship_x:
        ; Check X distance
        lda $d000
        sec
        sbc enemy_x_tbl,x
        cmp #$10
        bcc ship_hit
        cmp #$f0
        bcc next_ship_check
        jmp ship_hit

next_ship_check:
        inx
        cpx #$03
        bne ship_collision_loop

skip_ship_collision:
        jmp game_loop

ship_hit:
        ; Decrement lives
        dec lives

        ; Update lives display
        lda lives
        clc
        adc #$30
        sta $0427

        ; Check if lives exhausted
        lda lives
        bne life_lost

        ; Game over
        lda #$01
        sta game_state
        lda #$02
        sta $d027
        lda #$00
        sta $d020
        sta death_timer
        jsr show_game_over
        jmp play_death_sound

life_lost:
        ; Reset ship position
        lda #172
        sta $d000
        lda #220
        sta $d001

        ; Start death flash
        lda #16
        sta death_timer
        lda #$02
        sta $d020

play_death_sound:
        ; SID voice 3 (descending sawtooth)
        lda #$00
        sta $d40e
        lda #$10
        sta $d40f
        lda #$0a
        sta $d412
        lda #$00
        sta $d413
        lda #$20
        sta $d411
        lda #$21
        sta $d411

        jmp game_loop

; ------------------------------------------------
; Subroutine: erase_star
; X = star index. Writes space to the star's screen position.
; ------------------------------------------------
erase_star:
        ldy star_row,x
        lda row_addr_lo,y
        sta $fb
        lda row_addr_hi,y
        sta $fc
        ldy star_col,x
        lda #$20
        sta ($fb),y
        rts

; ------------------------------------------------
; Subroutine: draw_star
; X = star index. Writes character and colour at the star's position.
; ------------------------------------------------
draw_star:
        ldy star_row,x
        lda row_addr_lo,y
        sta $fb
        lda row_addr_hi,y
        sta $fc
        ldy star_col,x

        ; Write character to screen RAM
        lda star_char_tbl,x
        sta ($fb),y

        ; Switch pointer to colour RAM (high byte + $D4)
        lda $fc
        clc
        adc #$d4
        sta $fc

        ; Write colour
        lda star_colour_tbl,x
        sta ($fb),y
        rts

; ------------------------------------------------
; Subroutine: clear_screen
; Fills screen RAM with spaces ($20)
; ------------------------------------------------
clear_screen:
        ldx #$00
-       lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne -
        rts

; ------------------------------------------------
; Subroutine: init_game
; Resets all game state for a new game
; ------------------------------------------------
init_game:
        ; Sprite data pointers (must be set after clear_screen)
        lda #128
        sta $07f8           ; Ship (block 128 = $2000)
        lda #129
        sta $07f9           ; Bullet (block 129 = $2040)
        lda #130
        sta $07fa           ; Enemy 0 (block 130 = $2080)
        sta $07fb           ; Enemy 1
        sta $07fc           ; Enemy 2

        ; Ship position and colour
        lda #172
        sta $d000
        lda #220
        sta $d001
        lda #$01
        sta $d027

        ; Enemy colours
        lda #$05
        sta $d029
        sta $d02a
        sta $d02b

        ; Spawn three enemies at staggered heights
        lda #$32
        ldx #$00
        jsr spawn_enemy
        lda #$82
        ldx #$01
        jsr spawn_enemy
        lda #$d2
        ldx #$02
        jsr spawn_enemy

        ; Enable sprites 0, 2, 3, 4 (bullet starts disabled)
        lda #%00011101
        sta $d015

        ; Reset state
        lda #$00
        sta bullet_active
        sta game_state
        sta score
        sta death_timer
        sta frame_count
        sta $d020               ; Border black

        ; Score display
        lda #$30
        sta $0400
        sta $0401

        ; Lives
        lda #$03
        sta lives
        lda #$33
        sta $0427

        ; Initialize and draw stars
        ldx #$00
-       lda star_init_row,x
        sta star_row,x
        lda star_init_col,x
        sta star_col,x
        jsr draw_star
        inx
        cpx #$08
        bne -

        rts

; ------------------------------------------------
; Subroutine: show_game_over
; Writes "GAME OVER" to screen RAM, row 12, col 16
; ------------------------------------------------
show_game_over:
        lda #$07
        sta $05f0
        lda #$01
        sta $05f1
        lda #$0d
        sta $05f2
        lda #$05
        sta $05f3
        lda #$20
        sta $05f4
        lda #$0f
        sta $05f5
        lda #$16
        sta $05f6
        lda #$05
        sta $05f7
        lda #$12
        sta $05f8

        lda #$01
        sta $d9f0
        sta $d9f1
        sta $d9f2
        sta $d9f3
        sta $d9f4
        sta $d9f5
        sta $d9f6
        sta $d9f7
        sta $d9f8

        rts

; ------------------------------------------------
; Subroutine: spawn_enemy
; A = starting Y position, X = enemy index
; ------------------------------------------------
spawn_enemy:
        sta enemy_y_tbl,x

        ; Random X from raster
        lda $d012
        and #$7f
        clc
        adc #$30
        sta enemy_x_tbl,x

        ; Clear flash timer
        lda #$00
        sta flash_tbl,x

        ; Restore sprite colour to green
        ldy sprite_colour_off,x
        lda #$05
        sta $d000,y

        ; Update VIC-II sprite position
        ldy sprite_pos_off,x
        lda enemy_x_tbl,x
        sta $d000,y
        lda enemy_y_tbl,x
        sta $d001,y

        rts

; ------------------------------------------------
; Lookup tables
; ------------------------------------------------

; VIC-II sprite register offsets
sprite_pos_off:
        !byte $04, $06, $08

sprite_colour_off:
        !byte $29, $2a, $2b

; Screen RAM row start addresses (rows 0-24)
row_addr_lo:
        !byte $00, $28, $50, $78, $a0, $c8, $f0, $18
        !byte $40, $68, $90, $b8, $e0, $08, $30, $58
        !byte $80, $a8, $d0, $f8, $20, $48, $70, $98, $c0

row_addr_hi:
        !byte $04, $04, $04, $04, $04, $04, $04, $05
        !byte $05, $05, $05, $05, $05, $06, $06, $06
        !byte $06, $06, $06, $06, $07, $07, $07, $07, $07

; Star initial positions (8 stars: 0-3 close, 4-7 distant)
star_init_row:
        !byte 2, 8, 14, 20, 5, 11, 17, 23

star_init_col:
        !byte 5, 28, 15, 35, 18, 7, 32, 22

; Star appearance (close = bright asterisk, distant = dim period)
star_char_tbl:
        !byte $2a, $2a, $2a, $2a, $2e, $2e, $2e, $2e

star_colour_tbl:
        !byte $01, $01, $01, $01, $0b, $0b, $0b, $0b

; ------------------------------------------------
; Sprite data at $2000 (block 128) — ship
; ------------------------------------------------
*= $2000
        !byte $00,$18,$00   ;        ##
        !byte $00,$3c,$00   ;       ####
        !byte $00,$3c,$00   ;       ####
        !byte $00,$7e,$00   ;      ######
        !byte $00,$7e,$00   ;      ######
        !byte $00,$ff,$00   ;     ########
        !byte $00,$ff,$00   ;     ########
        !byte $01,$ff,$80   ;    ##########
        !byte $03,$ff,$c0   ;   ############
        !byte $07,$ff,$e0   ;  ##############
        !byte $07,$ff,$e0   ;  ##############
        !byte $07,$e7,$e0   ;  ###..####..###
        !byte $03,$c3,$c0   ;   ##....##....##
        !byte $01,$ff,$80   ;    ##########
        !byte $00,$ff,$00   ;     ########
        !byte $00,$ff,$00   ;     ########
        !byte $00,$db,$00   ;     ##.##.##
        !byte $00,$db,$00   ;     ##.##.##
        !byte $00,$66,$00   ;      ##..##
        !byte $00,$24,$00   ;       #..#
        !byte $00,$00,$00   ;

; ------------------------------------------------
; Sprite data at $2040 (block 129) — bullet
; ------------------------------------------------
*= $2040
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;

; ------------------------------------------------
; Sprite data at $2080 (block 130) — enemy
; ------------------------------------------------
*= $2080
        !byte $00,$66,$00   ;      ##..##
        !byte $00,$3c,$00   ;       ####
        !byte $00,$7e,$00   ;      ######
        !byte $00,$db,$00   ;     ##.##.##
        !byte $00,$ff,$00   ;     ########
        !byte $01,$ff,$80   ;    ##########
        !byte $01,$7e,$80   ;    #.######.#
        !byte $01,$3c,$80   ;    #..####..#
        !byte $00,$a5,$00   ;     #.#..#.#
        !byte $01,$81,$80   ;    ##......##
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;
        !byte $00,$00,$00   ;

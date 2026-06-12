; Starfield - Unit 17: The Curve
; Cumulative steps: step-00 (the finished Unit 16 game) -> step-01 (+ waves: a speed table, a live fall speed, a HUD wave digit, a wave-up chirp) -> step-02 (+ a SID title jingle, and a dwell on both ends of the loop)
; This step: the wave system.
; Assemble: acme -f cbm -o <step>.prg <step>.asm

; ------------------------------------------------
; Zero-page variables
; ------------------------------------------------
bullet_active = $02     ; 0 = no bullet, 1 = active
bullet_y      = $03     ; Bullet Y position
laser_timer   = $04     ; Frames of laser pitch-sweep remaining (0 = idle)
laser_freq    = $05     ; Our copy of the sweep pitch (SID freq regs are write-only)
score         = $06     ; Two-digit score, BCD (one decimal digit per nybble)
; Parallel arrays — index 0,1,2 picks enemy 0,1,2 (sprites 2,3,4)
enemy_x_tbl   = $07     ; 3 bytes ($07,$08,$09): each enemy's X
enemy_y_tbl   = $0a     ; 3 bytes ($0a,$0b,$0c): each enemy's Y
flash_tbl     = $0d     ; 3 bytes ($0d,$0e,$0f): each enemy's flash timer
state         = $10     ; 0 = title, 1 = playing, 2 = game over
lives         = $11     ; lives remaining (starts at 3)
death_timer   = $12     ; frames of post-hit flash (and, in step 2, invulnerability)
frame_count   = $13     ; free-running frame counter (parallax timing)
star_row      = $14     ; 12 stars: row of each   ($14-$1f)
star_col      = $20     ; 12 stars: column of each ($20-$2b)
wave          = $2c     ; wave counter (1, 2, 3, ... — never stops climbing)
kills         = $2d     ; hits this wave; 10 advances the wave
fall_speed    = $2e     ; pixels per frame the enemies fall — poked by advance_wave
; $fb/$fc: scratch pointer used by the star routines

; ------------------------------------------------
; BASIC stub
; ------------------------------------------------
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

; ------------------------------------------------
; Initialisation
; ------------------------------------------------
*= $080d
start:
        ; --- One-time hardware setup (runs once, not per game) ---
        lda #$00
        sta $d020           ; border black
        sta $d021           ; background black
        sta $d010           ; ship 9th X bit clear

        ; Fixed sprite colours
        lda #$01
        sta $d027           ; ship white
        lda #$07
        sta $d028           ; bullet yellow

        ; SID voice 1 — the laser
        lda #$0f
        sta $d418           ; volume to maximum
        lda #$00
        sta $d400
        lda #$10
        sta $d401
        lda #$06
        sta $d405
        lda #$00
        sta $d406

        ; Star positions (drawn by enter_title / enter_game)
        sta frame_count     ; A is still 0
        ldx #$00
init_star_loop:
        lda star_init_row,x
        sta star_row,x
        lda star_init_col,x
        sta star_col,x
        inx
        cpx #12
        bne init_star_loop

        ; Open on the title screen
        jsr enter_title

; ------------------------------------------------
; Game loop — runs once per frame
; ------------------------------------------------
game_loop:
        ; Wait for the raster beam to reach line 255
        ; This syncs our code to the display (~50Hz PAL)
-       lda $d012
        cmp #$ff
        bne -

        ; --- Parallax starfield: scrolls in every state (title, play, over) ---
        inc frame_count
        ldx #$00
star_loop:
        jsr erase_star
        ; Does THIS star move this frame? Near (0-3) every frame, mid (4-7)
        ; every 2nd frame, far (8-11) every 4th frame.
        cpx #$04
        bcc star_do_move        ; near layer: always
        cpx #$08
        bcc star_mid            ; mid layer
        ; far layer: only when the low two frame bits are clear (1 in 4)
        lda frame_count
        and #%00000011
        bne star_move_done
        beq star_do_move
star_mid:
        lda frame_count
        and #%00000001          ; every other frame
        bne star_move_done
star_do_move:
        inc star_row,x          ; one row down
        lda star_row,x
        cmp #25
        bcc star_move_done
        lda #$00                ; past the bottom -> wrap to the top
        sta star_row,x
star_move_done:
        jsr draw_star
        inx
        cpx #12
        bne star_loop

        ; --- State machine: title (0) / playing (1) / game over (2) ---
        lda state
        beq title_state
        cmp #$02
        beq over_state
        jmp game_active             ; 1 = playing

title_state:
        jsr show_title              ; repaint, in case a star scrolled across it
        lda $dc00
        and #%00010000              ; fire button (bit 4)
        bne loop_again              ; not pressed — wait on the title
        jsr enter_game              ; fire -> start a game
loop_again:
        jmp game_loop

over_state:
        jsr show_game_over          ; repaint over any star damage
        lda $dc00
        and #%00010000
        bne loop_again
        jsr enter_title             ; fire -> back to the title screen
        jmp game_loop

game_active:

        ; --- Read joystick and move ship ---

        ; UP (bit 0) — clamp to Y >= 50
        lda $dc00           ; Read joystick port 2
        and #%00000001      ; Isolate bit 0
        bne not_up          ; Bit is 1 = NOT pressed (active low)
        lda $d001
        cmp #52             ; 50 + room for a 2-pixel move
        bcc not_up          ; already at the top — don't move
        dec $d001           ; Move ship up (decrease Y)
        dec $d001           ; 2 pixels per frame
not_up:

        ; DOWN (bit 1) — clamp to Y <= 234
        lda $dc00
        and #%00000010
        bne not_down
        lda $d001
        cmp #233            ; 234 - room for a 2-pixel move
        bcs not_down        ; already at the bottom — don't move
        inc $d001           ; Move ship down (increase Y)
        inc $d001
not_down:

        ; LEFT (bit 2) — 9-bit X, clamp to X >= 24
        lda $dc00
        and #%00000100
        bne not_left
        lda $d010
        and #$01
        bne left_ok         ; high bit set: X >= 256, always safe to go left
        lda $d000
        cmp #26             ; 24 + room for a 2-pixel move
        bcc not_left        ; already at the left edge — don't move
left_ok:
        ; before each step, flip the 9th bit when X is about to wrap $00 -> $ff
        lda $d000
        bne +
        lda $d010
        eor #$01            ; the eor bit-flip from the Primer, on sprite 0's high X bit
        sta $d010
+       dec $d000
        lda $d000
        bne +
        lda $d010
        eor #$01
        sta $d010
+       dec $d000
not_left:

        ; RIGHT (bit 3) — 9-bit X, clamp to X <= 320
        lda $dc00
        and #%00001000
        bne not_right
        lda $d010
        and #$01
        beq right_ok        ; high bit clear: X < 256, always safe to go right
        lda $d000
        cmp #63             ; (320 - 256) - room for a 2-pixel move
        bcs not_right       ; already at the right edge — don't move
right_ok:
        ; after each step, flip the 9th bit when X wraps $ff -> $00
        inc $d000
        bne +
        lda $d010
        eor #$01
        sta $d010
+       inc $d000
        bne +
        lda $d010
        eor #$01
        sta $d010
+
not_right:

        ; --- Fire button (bit 4) ---
        lda $dc00
        and #%00010000
        bne no_fire         ; Bit is 1 = NOT pressed

        ; Only spawn if no bullet is already flying
        lda bullet_active
        bne no_fire

        ; Spawn the bullet at the ship's position
        lda $d000           ; Ship X (low byte) -> bullet X
        sta $d002
        lda $d001           ; Ship Y -> bullet Y
        sta bullet_y

        ; Copy the ship's 9th X bit (bit 0) to the bullet's (bit 1),
        ; so a shot fired from the right half spawns under the ship
        lda $d010
        and #%11111101      ; clear the bullet's 9th bit first
        sta $d010
        lda $d010
        and #$01            ; the ship's 9th bit
        asl                 ; shift it into the bullet's position (bit 1)
        ora $d010
        sta $d010

        ; Enable sprite 1 (keep sprite 0 enabled)
        lda $d015
        ora #%00000010
        sta $d015

        lda #$01
        sta bullet_active

        ; Trigger laser sound: start the pitch high, gate off then on
        lda #$40
        sta laser_freq      ; start high
        sta $d401           ; SID frequency high byte
        lda #$20
        sta $d404           ; Sawtooth, gate OFF (reset envelope)
        lda #$21
        sta $d404           ; Sawtooth, gate ON (start sound)
        lda #$0a
        sta laser_timer     ; sweep down over 10 frames

no_fire:

        ; --- Laser pitch sweep: the 'pew' ---
        ; Drop the pitch a little each frame while the sweep is running.
        ; We keep our own copy because SID frequency registers are write-only.
        lda laser_timer
        beq no_sweep
        lda laser_freq
        sec
        sbc #$06
        sta laser_freq
        sta $d401           ; write the new pitch to the SID
        dec laser_timer
no_sweep:

        ; --- Update the bullet ---
        lda bullet_active
        beq no_bullet

        ; Move it up 4 pixels a frame
        lda bullet_y
        sec
        sbc #$04
        sta bullet_y
        sta $d003           ; sprite 1 Y

        ; Gone off the top? (Y < 30) -> remove it
        cmp #$1e
        bcs no_bullet

        lda #$00
        sta bullet_active
        lda $d015
        and #%11111101      ; disable sprite 1, keep sprite 0
        sta $d015
        lda $d010
        and #%11111101      ; clear the bullet's 9th bit
        sta $d010

no_bullet:

        ; --- Update every enemy: one indexed loop does all of them ---
        ldx #$00
enemy_loop:
        lda flash_tbl,x
        bne do_flash            ; this enemy is mid-flash

        ; not flashing: drift down at the wave's pace
        lda enemy_y_tbl,x
        clc
        adc fall_speed          ; the wave's tuning, read fresh every frame
        sta enemy_y_tbl,x
        cmp #$f8                ; off the bottom? (Y >= 248)
        bcc update_sprite       ; still on screen
        lda #$32                ; respawn this enemy at the top, new column
        jsr spawn_enemy
        jmp next_enemy

do_flash:
        dec flash_tbl,x
        bne update_sprite       ; still flashing -> stay frozen, white
        lda #$32                ; flash done -> respawn (spawn_enemy restores green)
        jsr spawn_enemy
        jmp next_enemy

update_sprite:
        ; copy this enemy's position into its VIC-II sprite registers
        ldy sprite_pos_off,x
        lda enemy_x_tbl,x
        sta $d000,y             ; sprite X  ($d004, $d006, ...)
        lda enemy_y_tbl,x
        sta $d001,y             ; sprite Y  ($d005, $d007, ...)

next_enemy:
        inx
        cpx #$03                ; the full wave of three
        bne enemy_loop

        ; --- Bullet vs the wave: test each enemy until one is hit ---
        lda bullet_active
        bne check_collision
        jmp no_hit
check_collision:
        ldx #$00
collision_loop:
        lda flash_tbl,x
        bne next_collision      ; skip an enemy that's already exploding

        ; Y distance (8-bit subtract wraps, so two ranges count as close)
        lda bullet_y
        sec
        sbc enemy_y_tbl,x
        cmp #$10
        bcc check_x             ; 0..15 apart: close
        cmp #$f0
        bcc next_collision      ; 16..239 apart: too far
check_x:
        ; A bullet in the right portion (9th bit set) is past X=255, far from
        ; any enemy, so rule it out before comparing low bytes.
        lda $d010
        and #%00000010          ; bullet's 9th X bit (sprite 1)
        bne next_collision
        lda $d002
        sec
        sbc enemy_x_tbl,x
        cmp #$10
        bcc hit_enemy           ; 0..15 apart: close
        cmp #$f0
        bcc next_collision      ; 16..239 apart: too far
        jmp hit_enemy           ; 240..255: close from the other side

next_collision:
        inx
        cpx #$03
        bne collision_loop
        jmp no_hit

hit_enemy:
        ; X = the enemy that was hit. Remove the bullet.
        lda #$00
        sta bullet_active
        lda $d015
        and #%11111101          ; sprite 1 (bullet) off
        sta $d015

        ; Flash THIS enemy white and start its 8-frame timer. The enemy loop
        ; freezes it white until the timer runs out, then respawns it.
        lda #$08
        sta flash_tbl,x
        ldy sprite_colour_off,x
        lda #$01
        sta $d000,y             ; this enemy's colour register = white

        ; Explosion sound — SID voice 2, noise waveform (voice 1 keeps the laser)
        lda #$00
        sta $d407               ; voice 2 frequency low
        lda #$08
        sta $d408               ; voice 2 frequency high (a low rumble)
        lda #$09
        sta $d40c               ; attack 0, decay 9
        lda #$00
        sta $d40d               ; sustain 0, release 0
        lda #$80
        sta $d40b               ; noise, gate OFF (reset the envelope)
        lda #$81
        sta $d40b               ; noise, gate ON (trigger the burst)

        ; Score one hit. In decimal mode ADC carries at 10, so the byte stays
        ; readable as two decimal digits (BCD) — no conversion needed.
        sed                     ; decimal mode on
        lda score
        clc
        adc #$01
        sta score
        cld                     ; decimal mode off (every later ADC/SBC needs it off)

        ; Refresh the two digits: high nybble -> tens, low nybble -> ones
        lda score
        lsr
        lsr
        lsr
        lsr                     ; high nybble down to 0-9
        clc
        adc #$30                ; to screen code
        sta $0400               ; tens digit
        lda score
        and #$0f                ; low nybble, 0-9
        clc
        adc #$30
        sta $0401               ; ones digit

        ; Ten hits clear the wave: the lanes quicken
        inc kills
        lda kills
        cmp #10
        bcc no_hit
        jsr advance_wave

no_hit:

        ; --- Ship vs the wave: has any enemy reached the ship? ---
        ; ...but not while the life-lost flash runs — the ship is invulnerable
        lda death_timer
        beq do_ship_collision   ; not flashing -> run the check
        jmp no_ship_hit         ; flashing -> skip it (jmp, the target is far)
do_ship_collision:
        ldx #$00
ship_collision_loop:
        lda flash_tbl,x
        bne next_ship_check     ; ignore an exploding enemy
        ; Y distance: ship Y ($d001) vs this enemy's Y
        lda $d001
        sec
        sbc enemy_y_tbl,x
        cmp #$10
        bcc check_ship_x
        cmp #$f0
        bcc next_ship_check
check_ship_x:
        ; ship past X=255 (9th bit set) is far from any enemy — rule it out
        lda $d010
        and #%00000001          ; ship's 9th X bit (sprite 0)
        bne next_ship_check
        lda $d000
        sec
        sbc enemy_x_tbl,x
        cmp #$10
        bcc ship_hit
        cmp #$f0
        bcc next_ship_check
        jmp ship_hit            ; 240..255: close from the other side

next_ship_check:
        inx
        cpx #$03
        bne ship_collision_loop
        jmp no_ship_hit

ship_hit:
        ; Lose a life and update the readout
        dec lives
        lda lives
        clc
        adc #$30
        sta $0427               ; lives digit, top-right

        lda lives
        bne life_lost           ; lives remain -> respawn and play on

        ; Out of lives -> game over state (the dispatch handles the freeze)
        lda #$02
        sta state
        sta $d027               ; ship turns red ($02 = red, reused here)
        jsr show_game_over
        jmp death_sound

life_lost:
        ; Respawn the ship at its start position
        lda #172
        sta $d000
        lda #220
        sta $d001
        lda $d010
        and #%11111110          ; clear the ship's 9th bit (back under X=256)
        sta $d010

        ; Start the life-lost flash (step 2 makes it an invulnerability window too)
        lda #90
        sta death_timer

death_sound:
        ; Death sound — SID voice 3 (plays on every death)
        lda #$00
        sta $d40e               ; voice 3 frequency low
        lda #$10
        sta $d40f               ; voice 3 frequency high
        lda #$0a
        sta $d413               ; attack 0, decay 10 (a long, slow fade)
        lda #$00
        sta $d414               ; sustain 0, release 0
        lda #$20
        sta $d412               ; sawtooth, gate OFF (reset the envelope)
        lda #$21
        sta $d412               ; sawtooth, gate ON (trigger)

no_ship_hit:

        ; --- Life-lost flash: while the timer runs, blink the border ---
        lda death_timer
        beq flash_done
        dec death_timer
        lda death_timer
        and #%00001000          ; bit 3 toggles every 8 frames
        bne flash_bright
        lda #$00                ; dark phase
        sta $d020
        jmp flash_tick
flash_bright:
        lda #$02                ; bright phase (red border)
        sta $d020
flash_tick:
        lda death_timer
        bne flash_done
        lda #$00                ; just expired -> border back to black
        sta $d020
flash_done:

        jmp game_loop

; ------------------------------------------------
; Subroutine: spawn one enemy
;   A = starting Y, X = enemy index (X is preserved)
; ------------------------------------------------
spawn_enemy:
        sta enemy_y_tbl,x
        lda $d012               ; raster line -> pseudo-random column
        and #$7f
        clc
        adc #$30                ; 48-175, inside the visible width
        sta enemy_x_tbl,x
        lda #$00
        sta flash_tbl,x         ; not flashing
        ldy sprite_colour_off,x
        lda #$05
        sta $d000,y             ; this enemy's colour = green
        ldy sprite_pos_off,x
        lda enemy_x_tbl,x
        sta $d000,y             ; sprite X
        lda enemy_y_tbl,x
        sta $d001,y             ; sprite Y
        rts

; Per-enemy VIC-II register offsets (sprites 2, 3, 4)
sprite_pos_off:
        !byte $04, $06, $08     ; X offsets: $d004, $d006, $d008
sprite_colour_off:
        !byte $29, $2a, $2b     ; colour offsets: $d029, $d02a, $d02b

; ------------------------------------------------
; Subroutine: print "GAME OVER" at row 12, column 16
;   Row 12 x 40 + 16 = 496 = $1f0, so screen RAM $05f0, colour RAM $d9f0
; ------------------------------------------------
show_game_over:
        lda #$07            ; G
        sta $05f0
        lda #$01            ; A
        sta $05f1
        lda #$0d            ; M
        sta $05f2
        lda #$05            ; E
        sta $05f3
        lda #$20            ; (space)
        sta $05f4
        lda #$0f            ; O
        sta $05f5
        lda #$16            ; V
        sta $05f6
        lda #$05            ; E
        sta $05f7
        lda #$12            ; R
        sta $05f8
        ; colour the nine cells white ($d9f0..$d9f8)
        lda #$01
        ldx #$00
-       sta $d9f0,x
        inx
        cpx #$09
        bne -
        rts

; ------------------------------------------------
; Subroutine: clear_and_stars — wipe the screen, then repaint every star
; ------------------------------------------------
clear_and_stars:
        ldx #$00
cas_clear:
        lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne cas_clear
        ldx #$00
cas_draw:
        jsr draw_star
        inx
        cpx #12
        bne cas_draw
        rts

; ------------------------------------------------
; Subroutine: enter_title — show the title, hide the game, state = 0
; ------------------------------------------------
enter_title:
        jsr clear_and_stars
        lda #$00
        sta $d015               ; all sprites off: the title has no ship or wave
        sta $d020               ; border black
        jsr show_title
        lda #$00
        sta state               ; 0 = title
        rts

; ------------------------------------------------
; Subroutine: enter_game — set up a fresh game, state = 1
; ------------------------------------------------
enter_game:
        jsr clear_and_stars
        ; The sprite data pointers live in screen RAM ($07f8+), so the clear just
        ; wiped them — set them here, after the clear, or the sprites show garbage.
        lda #128
        sta $07f8           ; ship
        lda #129
        sta $07f9           ; bullet
        lda #130
        sta $07fa           ; enemy 0
        sta $07fb           ; enemy 1
        sta $07fc           ; enemy 2
        ; Ship at its start, white (it may have gone red on game over)
        lda #172
        sta $d000
        lda #220
        sta $d001
        lda #$01
        sta $d027
        lda #$00
        sta $d010
        ; Enable ship + three enemies (the bullet stays off)
        lda #%00011101
        sta $d015
        ; Spawn the wave at staggered heights
        lda #$32
        ldx #$00
        jsr spawn_enemy
        lda #$82
        ldx #$01
        jsr spawn_enemy
        lda #$d2
        ldx #$02
        jsr spawn_enemy
        ; Reset per-game state
        lda #$00
        sta bullet_active
        sta death_timer
        sta $d020               ; border black
        sta score
        ; Score "00", white
        lda #$30
        sta $0400
        sta $0401
        lda #$01
        sta $d800
        sta $d801
        ; Lives "3", white
        lda #$03
        sta lives
        lda #$33
        sta $0427
        lda #$01
        sta $d827
        ; Wave 1: counter, kills, the live speed, and the readout
        lda #$01
        sta wave
        lda #$00
        sta kills
        lda wave_speed_tbl      ; first table entry
        sta fall_speed
        jsr draw_wave
        ; state = playing
        lda #$01
        sta state
        rts

; ------------------------------------------------
; Subroutine: advance_wave — ten kills: quicken the lanes, say so
;   Three different caps live here, and they are not the same thing:
;   the COUNTER never stops, the table INDEX clamps at the last row,
;   and the DIGIT shows 9 forever after. The player's number tells the
;   truth; the physics admits it ran out of new ideas.
; ------------------------------------------------
advance_wave:
        lda #$00
        sta kills
        inc wave
        ; table index = wave - 1, clamped to the last entry
        ldy wave
        dey
        cpy #WAVE_TOP
        bcc wave_speed_ok
        ldy #WAVE_TOP
wave_speed_ok:
        lda wave_speed_tbl,y
        sta fall_speed
        jsr draw_wave
        ; The chirp — voice 3, a bright triangle ding over the explosion
        lda #$00
        sta $d40e               ; voice 3 frequency low
        lda #$40
        sta $d40f               ; voice 3 frequency high (a high ding)
        lda #$09
        sta $d413               ; attack 0, decay 9
        lda #$00
        sta $d414               ; sustain 0, release 0
        lda #$10
        sta $d412               ; triangle, gate OFF (reset the envelope)
        lda #$11
        sta $d412               ; triangle, gate ON
        rts

; ------------------------------------------------
; Subroutine: draw_wave — "W" and the wave digit, top centre
;   The digit caps at 9; the wave itself keeps counting.
; ------------------------------------------------
draw_wave:
        lda #$17                ; W
        sta $0413
        lda wave
        cmp #$0a
        bcc wave_digit_ok
        lda #$09                ; show 9 from here on
wave_digit_ok:
        clc
        adc #$30                ; to screen code
        sta $0414
        lda #$01                ; white
        sta $d813
        sta $d814
        rts

; Pixels per frame, one entry per wave; the last entry is the wall
WAVE_TOP = 4                    ; last index of the table below
wave_speed_tbl:
        !byte 1, 2, 2, 3, 3

; ------------------------------------------------
; Subroutine: show_title — "STARFIELD" (row 10) and "PRESS FIRE" (row 14)
; ------------------------------------------------
show_title:
        lda #$13            ; S
        sta $05a0
        lda #$14            ; T
        sta $05a1
        lda #$01            ; A
        sta $05a2
        lda #$12            ; R
        sta $05a3
        lda #$06            ; F
        sta $05a4
        lda #$09            ; I
        sta $05a5
        lda #$05            ; E
        sta $05a6
        lda #$0c            ; L
        sta $05a7
        lda #$04            ; D
        sta $05a8
        lda #$01            ; white
        ldx #$00
-       sta $d9a0,x
        inx
        cpx #$09
        bne -
        lda #$10            ; P
        sta $063f
        lda #$12            ; R
        sta $0640
        lda #$05            ; E
        sta $0641
        lda #$13            ; S
        sta $0642
        lda #$13            ; S
        sta $0643
        lda #$20            ; (space)
        sta $0644
        lda #$06            ; F
        sta $0645
        lda #$09            ; I
        sta $0646
        lda #$12            ; R
        sta $0647
        lda #$05            ; E
        sta $0648
        lda #$0f            ; light grey
        ldx #$00
-       sta $da3f,x
        inx
        cpx #$0a
        bne -
        rts

; ------------------------------------------------
; Subroutine: erase_star  (X = star index)
;   blanks the star's current cell back to a space
; ------------------------------------------------
erase_star:
        ldy star_row,x
        lda row_addr_lo,y       ; point $fb/$fc at the start of this star's row
        sta $fb
        lda row_addr_hi,y
        sta $fc
        ldy star_col,x          ; Y = the column offset along that row
        lda #$20                ; a space
        sta ($fb),y             ; "finger on the boxes" — pointer + Y offset
        rts

; ------------------------------------------------
; Subroutine: draw_star  (X = star index)
;   writes the star's character + colour at its (row, col)
; ------------------------------------------------
draw_star:
        ldy star_row,x
        lda row_addr_lo,y
        sta $fb                 ; row start, low byte
        lda row_addr_hi,y
        sta $fc                 ; row start, high byte
        ldy star_col,x          ; Y = column
        lda star_char_tbl,x
        sta ($fb),y             ; STA ($fb),Y -> the screen-RAM cell
        ; screen RAM $04xx-$07xx maps to colour RAM $d8xx-$dbxx: high byte + $d4
        lda $fc
        clc
        adc #$d4
        sta $fc
        lda star_colour_tbl,x
        sta ($fb),y             ; same column offset, now into colour RAM
        rts

; ------------------------------------------------
; Star data tables
; ------------------------------------------------
; Screen-RAM start address of each row (row x 40 + $0400), rows 0-24
row_addr_lo:
        !byte $00,$28,$50,$78,$a0,$c8,$f0,$18
        !byte $40,$68,$90,$b8,$e0,$08,$30,$58
        !byte $80,$a8,$d0,$f8,$20,$48,$70,$98,$c0
row_addr_hi:
        !byte $04,$04,$04,$04,$04,$04,$04,$05
        !byte $05,$05,$05,$05,$05,$06,$06,$06
        !byte $06,$06,$06,$06,$07,$07,$07,$07,$07

; 12 stars. Columns avoid 0, 1 and 39 — the score and lives cells.
star_init_row:
        !byte 2, 8, 14, 20, 5, 11, 17, 23, 3, 9, 16, 22
star_init_col:
        !byte 5, 28, 15, 35, 18, 7, 32, 22, 12, 30, 9, 25
; Appearance reinforces the depth: near = bright white '*', far = dim grey '.'
star_char_tbl:
        !byte $2a,$2a,$2a,$2a, $2a,$2a,$2a,$2a, $2e,$2e,$2e,$2e
star_colour_tbl:
        !byte $01,$01,$01,$01, $0f,$0f,$0f,$0f, $0b,$0b,$0b,$0b

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
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$18,$00   ;        ##
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
        !byte $00,$00,$00
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

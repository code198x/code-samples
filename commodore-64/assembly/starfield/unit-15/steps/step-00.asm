; Starfield - Unit 15: Starfield
; Cumulative steps: step-00 (black space) -> step-01 (+ a scrolling starfield) -> step-02 (+ parallax: three depths at three speeds)
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
game_over     = $10     ; 0 = playing, 1 = the ship has been hit
lives         = $11     ; lives remaining (starts at 3)
death_timer   = $12     ; frames of post-hit flash (and, in step 2, invulnerability)

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
        ; Black screen
        lda #$00
        sta $d020           ; Border colour
        sta $d021           ; Background colour

        ; Clear the screen
        ldx #$00
-       lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $0700,x
        inx
        bne -

        ; Sprite 0 setup (ship)
        lda #128
        sta $07f8           ; Data pointer (block 128 = $2000)
        lda #172
        sta $d000           ; X position
        lda #220
        sta $d001           ; Y position
        lda #$01
        sta $d027           ; Colour (white)
        lda #%00011101
        sta $d015           ; Enable sprites 0 (ship), 2-4 (three enemies)
        lda #$00
        sta $d010           ; sprite high-X bits clear (ship starts under X=256)

        ; Sprite 1 setup (bullet)
        lda #129
        sta $07f9           ; Data pointer (block 129 = $2040)
        lda #$07
        sta $d028           ; Colour (yellow)

        ; Enemy sprites 2, 3 and 4 share the one enemy shape in block 130.
        ; Colour and position are set per-enemy by spawn_enemy, below.
        lda #130
        sta $07fa           ; sprite 2 data pointer
        sta $07fb           ; sprite 3 data pointer
        sta $07fc           ; sprite 4 data pointer

        ; Bullet starts inactive
        lda #$00
        sta bullet_active

        ; SID setup — voice 1 laser sound
        lda #$0f
        sta $d418           ; Volume to maximum

        lda #$00
        sta $d400           ; Frequency low byte
        lda #$10
        sta $d401           ; Frequency high byte ($1000 = mid-high pitch)

        lda #$06
        sta $d405           ; Attack=0, Decay=6 (a short, snappy fall)
        lda #$00
        sta $d406           ; Sustain=0, Release=0

        ; Score readout: "00" in the top-left, white. (We've written to screen
        ; RAM since Unit 1's clear loop — now we write characters, not spaces.)
        lda #$00
        sta score
        lda #$30            ; screen code for '0'
        sta $0400           ; tens digit (row 0, col 0)
        sta $0401           ; ones digit (row 0, col 1)
        lda #$01
        sta $d800           ; colour both digits white
        sta $d801

        ; Three lives, shown in the top-right corner
        lda #$03
        sta lives
        lda #$33            ; screen code for '3'
        sta $0427           ; row 0, col 39
        lda #$01
        sta $d827           ; colour white

        ; Spawn the wave at staggered heights (A = start Y, X = enemy index)
        lda #$32
        ldx #$00
        jsr spawn_enemy
        lda #$82
        ldx #$01
        jsr spawn_enemy
        lda #$d2
        ldx #$02
        jsr spawn_enemy

        ; The game starts alive
        lda #$00
        sta game_over
        sta death_timer         ; not flashing

; ------------------------------------------------
; Game loop — runs once per frame
; ------------------------------------------------
game_loop:
        ; Wait for the raster beam to reach line 255
        ; This syncs our code to the display (~50Hz PAL)
-       lda $d012
        cmp #$ff
        bne -

        ; Game over? Wait for fire to restart; otherwise play on.
        lda game_over
        beq game_active
        lda $dc00
        and #%00010000          ; fire button (bit 4)
        bne game_loop           ; not pressed — hold the GAME OVER screen
        jmp start               ; fire pressed — restart the whole game
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

        ; not flashing: drift down 1 pixel per frame
        lda enemy_y_tbl,x
        clc
        adc #$01                ; clc before adc, the addition from the Primer
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

        ; Out of lives -> end the game (the freeze + restart from Unit 12)
        lda #$01
        sta game_over
        lda #$02
        sta $d027               ; ship turns red
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

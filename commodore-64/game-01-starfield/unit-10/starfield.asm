; Starfield - Unit 10: Player Death
; Assemble with: acme -f cbm -o starfield.prg starfield.asm

; ------------------------------------------------
; Zero-page variables
; ------------------------------------------------
bullet_active = $02     ; 0 = no bullet, 1 = active
bullet_y      = $03     ; Bullet Y position
score         = $07     ; Score (0-99, BCD format)
enemy_x_tbl   = $08    ; 3 bytes ($08, $09, $0a)
enemy_y_tbl   = $0b    ; 3 bytes ($0b, $0c, $0d)
flash_tbl      = $0e   ; 3 bytes ($0e, $0f, $10)
game_over      = $11   ; 0 = playing, 1 = game over

; ------------------------------------------------
; BASIC stub
; ------------------------------------------------
*= $0801
!byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$31,$00,$00,$00

; ------------------------------------------------
; Initialisation
; ------------------------------------------------
*= $080d
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

        ; Sprite 1 setup (bullet)
        lda #129
        sta $07f9           ; Data pointer (block 129 = $2040)
        lda #$07
        sta $d028           ; Colour (yellow)

        ; Sprites 2, 3, 4 setup (enemies)
        lda #130
        sta $07fa           ; Sprite 2 data pointer
        sta $07fb           ; Sprite 3 data pointer
        sta $07fc           ; Sprite 4 data pointer
        lda #$05
        sta $d029           ; Sprite 2 colour (green)
        sta $d02a           ; Sprite 3 colour (green)
        sta $d02b           ; Sprite 4 colour (green)

        ; Spawn three enemies at staggered heights
        lda #$32            ; Top
        ldx #$00
        jsr spawn_enemy
        lda #$82            ; Middle
        ldx #$01
        jsr spawn_enemy
        lda #$d2            ; Lower
        ldx #$02
        jsr spawn_enemy

        ; Enable sprites 0, 2, 3, 4 (bullet starts disabled)
        lda #%00011101
        sta $d015

        ; Bullet starts inactive
        lda #$00
        sta bullet_active

        ; Game starts in playing state
        lda #$00
        sta game_over

        ; Score starts at zero (BCD)
        lda #$00
        sta score

        ; Write "00" to screen RAM (top-left corner)
        lda #$30            ; Screen code for '0'
        sta $0400           ; Tens digit (row 0, col 0)
        sta $0401           ; Ones digit (row 0, col 1)

        ; Set score colour to white
        lda #$01
        sta $d800
        sta $d801

        ; SID setup — voice 1 laser sound
        lda #$0f
        sta $d418           ; Volume to maximum

        lda #$00
        sta $d400           ; Frequency low byte
        lda #$10
        sta $d401           ; Frequency high byte ($1000 = mid-high pitch)

        lda #$09
        sta $d405           ; Attack=0, Decay=9
        lda #$00
        sta $d406           ; Sustain=0, Release=0

!ifdef SCREENSHOT_MODE {
        ; Set a visible score
        lda #$07
        sta score
        lda #$30
        sta $0400
        lda #$37
        sta $0401

        ; Ship is dead — turn red
        lda #$02
        sta $d027
        lda #$01
        sta game_over

        ; Position enemy 1 near the ship (just collided)
        lda #200
        sta enemy_y_tbl+1
        lda $d000
        sta enemy_x_tbl+1
        ldy #$06
        lda enemy_x_tbl+1
        sta $d000,y
        lda enemy_y_tbl+1
        sta $d001,y

        ; Enable sprites (ship + 3 enemies, no bullet)
        lda #%00011101
        sta $d015
}

; ------------------------------------------------
; Game loop — runs once per frame
; ------------------------------------------------
game_loop:
        ; Wait for the raster beam to reach line 255
-       lda $d012
        cmp #$ff
        bne -

        ; --- Check game over ---
        lda game_over
        beq game_active
        jmp game_loop       ; Game frozen — just keep waiting

game_active:

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
        bne no_fire         ; Bit is 1 = NOT pressed

        ; Fire is pressed — only spawn if no bullet active
        lda bullet_active
        bne no_fire         ; Already active, skip

        ; Spawn bullet at ship position
        lda $d000           ; Ship X → bullet X
        sta $d002
        lda $d001           ; Ship Y → bullet Y
        sta bullet_y

        ; Enable sprite 1 (keep other sprites enabled)
        lda $d015
        ora #%00000010
        sta $d015

        ; Mark bullet active
        lda #$01
        sta bullet_active

        ; Trigger laser sound (gate off then on to retrigger)
        lda #$20
        sta $d404           ; Sawtooth, gate OFF (reset envelope)
        lda #$21
        sta $d404           ; Sawtooth, gate ON (start sound)

no_fire:

        ; --- Update bullet ---
        lda bullet_active
        beq no_bullet       ; Not active, skip

        ; Move bullet up (4 pixels per frame)
        lda bullet_y
        sec
        sbc #$04
        sta bullet_y
        sta $d003           ; Update sprite 1 Y position

        ; Check if bullet has left the screen (Y < 30)
        cmp #$1e
        bcs no_bullet       ; Y >= 30, still on screen

        ; Deactivate bullet
        lda #$00
        sta bullet_active

        ; Disable sprite 1 (keep other sprites enabled)
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
        bne next_collision      ; Skip flashing enemies

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
        lda $d002               ; Bullet X (sprite 1)
        sec
        sbc enemy_x_tbl,x
        cmp #$10
        bcc hit_enemy
        cmp #$f0
        bcc next_collision
        jmp hit_enemy           ; >= $F0 = close (negative)

next_collision:
        inx
        cpx #$03
        bne collision_loop
        jmp no_hit

hit_enemy:
        ; X = index of hit enemy
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
        sta $d000,y             ; White

        ; Explosion sound — SID voice 2 (noise)
        lda #$00
        sta $d407               ; Frequency low
        lda #$08
        sta $d408               ; Frequency high (low rumble)
        lda #$09
        sta $d40c               ; Attack=0, Decay=9
        lda #$00
        sta $d40d               ; Sustain=0, Release=0
        lda #$80
        sta $d40b               ; Noise, gate OFF (reset envelope)
        lda #$81
        sta $d40b               ; Noise, gate ON (trigger)

        ; Increment score (BCD)
        sed                     ; Decimal mode
        lda score
        clc
        adc #$01
        sta score
        cld                     ; Back to binary mode

        ; Update score display — tens digit
        lda score
        lsr
        lsr
        lsr
        lsr                     ; High nybble in A (0-9)
        clc
        adc #$30                ; Convert to screen code
        sta $0400               ; Write tens digit

        ; Update score display — ones digit
        lda score
        and #$0f                ; Low nybble in A (0-9)
        clc
        adc #$30                ; Convert to screen code
        sta $0401               ; Write ones digit

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

        ; Off-screen check (Y >= 248)
        cmp #$f8
        bcc update_sprite

        ; Respawn at top
        lda #$32
        jsr spawn_enemy
        jmp next_enemy

do_flash:
        dec flash_tbl,x
        bne update_sprite       ; Still flashing

        ; Flash done — respawn
        lda #$32
        jsr spawn_enemy
        jmp next_enemy

update_sprite:
        ; Copy position to VIC-II
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
        ldx #$00
ship_collision_loop:
        lda flash_tbl,x
        bne next_ship_check     ; Skip flashing enemies

        ; Check Y distance (ship Y vs enemy Y)
        lda $d001               ; Ship Y
        sec
        sbc enemy_y_tbl,x
        cmp #$10
        bcc check_ship_x
        cmp #$f0
        bcc next_ship_check

check_ship_x:
        ; Check X distance (ship X vs enemy X)
        lda $d000               ; Ship X
        sec
        sbc enemy_x_tbl,x
        cmp #$10
        bcc ship_hit
        cmp #$f0
        bcc next_ship_check
        jmp ship_hit            ; >= $F0 = close (negative)

next_ship_check:
        inx
        cpx #$03
        bne ship_collision_loop
        jmp no_ship_hit

ship_hit:
        ; Ship is destroyed
        lda #$01
        sta game_over

        ; Turn ship red
        lda #$02
        sta $d027

        ; Death sound — SID voice 3 (descending sawtooth)
        lda #$00
        sta $d40e               ; Frequency low
        lda #$10
        sta $d40f               ; Frequency high
        lda #$0a
        sta $d412               ; Attack=0, Decay=10 (long decay)
        lda #$00
        sta $d413               ; Sustain=0, Release=0
        lda #$20
        sta $d411               ; Sawtooth, gate OFF (reset envelope)
        lda #$21
        sta $d411               ; Sawtooth, gate ON (trigger)

no_ship_hit:
        jmp game_loop

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
        sta $d000,y             ; Sprite X
        lda enemy_y_tbl,x
        sta $d001,y             ; Sprite Y (offset + 1)

        rts

; ------------------------------------------------
; Lookup tables
; ------------------------------------------------
sprite_pos_off:
        !byte $04, $06, $08    ; VIC-II X-position offsets for sprites 2, 3, 4

sprite_colour_off:
        !byte $29, $2a, $2b   ; VIC-II colour register offsets

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

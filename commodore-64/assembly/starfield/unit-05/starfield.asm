; Starfield - Unit 5: Enemy Appears
; Assemble with: acme -f cbm -o starfield.prg starfield.asm

; ------------------------------------------------
; Zero-page variables
; ------------------------------------------------
bullet_active = $02     ; 0 = no bullet, 1 = active
bullet_y      = $03     ; Bullet Y position
enemy_x       = $04     ; Enemy X position
enemy_y       = $05     ; Enemy Y position

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

        ; Sprite 2 setup (enemy)
        lda #130
        sta $07fa           ; Data pointer (block 130 = $2080)
        lda #$05
        sta $d029           ; Colour (green)

        ; Enemy starting position
        lda #100
        sta enemy_x
        sta $d004           ; X position
        lda #$32
        sta enemy_y
        sta $d005           ; Y position

        ; Enable sprites 0 and 2 (bullet starts disabled)
        lda #%00000101
        sta $d015

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

        lda #$09
        sta $d405           ; Attack=0, Decay=9
        lda #$00
        sta $d406           ; Sustain=0, Release=0

!ifdef SCREENSHOT_MODE {
        ; Place a static bullet for screenshot capture
        lda $d000
        sta $d002           ; Bullet X = ship X
        lda #140
        sta $d003           ; Bullet Y mid-screen

        ; Enable all three sprites
        lda #%00000111
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

        ; --- Update enemy ---
        lda enemy_y
        clc
        adc #$01            ; Move down 1 pixel per frame
        sta enemy_y
        sta $d005           ; Update sprite 2 Y position

        ; Check if enemy has left the screen (Y > 248)
        cmp #$f8
        bcc no_respawn      ; Y < 248, still on screen

        ; Respawn at top with new X position
        lda #$32
        sta enemy_y
        sta $d005           ; Reset Y to top

        lda $d012           ; Pseudo-random from raster position
        and #$7f            ; Range 0-127
        clc
        adc #$30            ; Range 48-175
        sta enemy_x
        sta $d004           ; New X position

no_respawn:
        jmp game_loop

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

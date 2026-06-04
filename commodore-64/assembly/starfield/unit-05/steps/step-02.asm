; Starfield - Unit 5: Laser Sound
; Cumulative steps: step-00 (silent ship + bullet) -> step-01 (+ SID configured) -> step-02 (+ gate: a flat blip) -> step-03 (+ pitch sweep: a 'pew')
; Assemble: acme -f cbm -o <step>.prg <step>.asm

; ------------------------------------------------
; Zero-page variables
; ------------------------------------------------
bullet_active = $02     ; 0 = no bullet, 1 = active
bullet_y      = $03     ; Bullet Y position

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
        lda #%00000001
        sta $d015           ; Enable sprite 0
        lda #$00
        sta $d010           ; sprite high-X bits clear (ship starts under X=256)

        ; Sprite 1 setup (bullet)
        lda #129
        sta $07f9           ; Data pointer (block 129 = $2040)
        lda #$07
        sta $d028           ; Colour (yellow)

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

; ------------------------------------------------
; Game loop — runs once per frame
; ------------------------------------------------
game_loop:
        ; Wait for the raster beam to reach line 255
        ; This syncs our code to the display (~50Hz PAL)
-       lda $d012
        cmp #$ff
        bne -

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

        ; Trigger laser sound (gate off then on to retrigger)
        lda #$20
        sta $d404           ; Sawtooth, gate OFF (reset envelope)
        lda #$21
        sta $d404           ; Sawtooth, gate ON (start sound)

no_fire:

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

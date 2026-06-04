; Starfield - Unit 3: Screen Edges
; Cumulative steps: step-00 (ship + 4-way joystick, 8-bit X) -> step-01 (+ 9th X bit) -> step-02 (+ edge clamping)
; Assemble: acme -f cbm -o <step>.prg <step>.asm

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

        ; UP (bit 0)
        lda $dc00           ; Read joystick port 2
        and #%00000001      ; Isolate bit 0
        bne not_up          ; Bit is 1 = NOT pressed (active low)
        dec $d001           ; Move ship up (decrease Y)
        dec $d001           ; 2 pixels per frame
not_up:

        ; DOWN (bit 1)
        lda $dc00
        and #%00000010
        bne not_down
        inc $d001           ; Move ship down (increase Y)
        inc $d001
not_down:

        ; LEFT (bit 2) — 9-bit X
        lda $dc00
        and #%00000100
        bne not_left
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

        ; RIGHT (bit 3) — 9-bit X
        lda $dc00
        and #%00001000
        bne not_right
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

        jmp game_loop

; ------------------------------------------------
; Sprite data at $2000 (block 128)
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

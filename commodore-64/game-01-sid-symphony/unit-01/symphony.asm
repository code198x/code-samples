; ============================================================================
; SID SYMPHONY - Unit 1: Hello SID
; ============================================================================
; Your first contact with the SID chip. Three tracks, three keys, three voices.
; Press Z/X/C to trigger sounds and see the tracks flash.
;
; Controls: Z = Track 1 (high), X = Track 2 (mid), C = Track 3 (low)
; ============================================================================

; ----------------------------------------------------------------------------
; Memory Addresses
; ----------------------------------------------------------------------------

SCREEN      = $0400             ; Screen memory base
COLRAM      = $D800             ; Colour RAM base
BORDER      = $D020             ; Border colour
BGCOL       = $D021             ; Background colour

; SID registers
SID         = $D400             ; SID base address
SID_V1_FREQ_LO = $D400          ; Voice 1 frequency low
SID_V1_FREQ_HI = $D401          ; Voice 1 frequency high
SID_V1_PWLO = $D402             ; Voice 1 pulse width low
SID_V1_PWHI = $D403             ; Voice 1 pulse width high
SID_V1_CTRL = $D404             ; Voice 1 control register
SID_V1_AD   = $D405             ; Voice 1 attack/decay
SID_V1_SR   = $D406             ; Voice 1 sustain/release

SID_V2_FREQ_LO = $D407          ; Voice 2 frequency low
SID_V2_FREQ_HI = $D408          ; Voice 2 frequency high
SID_V2_PWLO = $D409             ; Voice 2 pulse width low
SID_V2_PWHI = $D40A             ; Voice 2 pulse width high
SID_V2_CTRL = $D40B             ; Voice 2 control register
SID_V2_AD   = $D40C             ; Voice 2 attack/decay
SID_V2_SR   = $D40D             ; Voice 2 sustain/release

SID_V3_FREQ_LO = $D40E          ; Voice 3 frequency low
SID_V3_FREQ_HI = $D40F          ; Voice 3 frequency high
SID_V3_PWLO = $D410             ; Voice 3 pulse width low
SID_V3_PWHI = $D411             ; Voice 3 pulse width high
SID_V3_CTRL = $D412             ; Voice 3 control register
SID_V3_AD   = $D413             ; Voice 3 attack/decay
SID_V3_SR   = $D414             ; Voice 3 sustain/release

SID_FLTLO   = $D415             ; Filter cutoff low
SID_FLTHI   = $D416             ; Filter cutoff high
SID_FLTCTRL = $D417             ; Filter control
SID_VOLUME  = $D418             ; Volume and filter mode

; CIA keyboard
CIA1_PRA    = $DC00             ; CIA1 Port A (keyboard column)
CIA1_PRB    = $DC01             ; CIA1 Port B (keyboard row)

; Colours
BLACK       = 0
WHITE       = 1
RED         = 2
CYAN        = 3
PURPLE      = 4
GREEN       = 5
BLUE        = 6
YELLOW      = 7
ORANGE      = 8
BROWN       = 9
LIGHT_RED   = 10
DARK_GREY   = 11
GREY        = 12
LIGHT_GREEN = 13
LIGHT_BLUE  = 14
LIGHT_GREY  = 15

; Track positions (row on screen)
TRACK1_ROW  = 8                 ; High voice track
TRACK2_ROW  = 12                ; Mid voice track
TRACK3_ROW  = 16                ; Low voice track

; Hit zone column
HIT_ZONE_COL = 3                ; Where notes need to be hit

; ----------------------------------------------------------------------------
; BASIC Stub - SYS 2064
; ----------------------------------------------------------------------------

            * = $0801

            !byte $0C, $08      ; Pointer to next line
            !byte $0A, $00      ; Line number 10
            !byte $9E           ; SYS token
            !text "2064"        ; Address
            !byte $00           ; End of line
            !byte $00, $00      ; End of program

; ----------------------------------------------------------------------------
; Main Program
; ----------------------------------------------------------------------------

            * = $0810

start:
            jsr init_screen     ; Set up the display
            jsr init_sid        ; Configure SID chip

main_loop:
            ; Wait for raster (smooth timing)
            lda #$FF
-           cmp $D012
            bne -

            ; Reset track colours to default
            jsr reset_track_colours

            ; Check keyboard and play sounds
            jsr check_keys

            jmp main_loop

; ----------------------------------------------------------------------------
; Initialize Screen
; ----------------------------------------------------------------------------
; Clears screen and draws the three tracks with hit zones

init_screen:
            ; Set border and background
            lda #BLACK
            sta BORDER
            sta BGCOL

            ; Clear screen with spaces
            ldx #0
            lda #$20            ; Space character
-           sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne -

            ; Set all colours to grey
            ldx #0
            lda #GREY
-           sta COLRAM,x
            sta COLRAM+$100,x
            sta COLRAM+$200,x
            sta COLRAM+$2E8,x
            inx
            bne -

            ; Draw track lines
            jsr draw_tracks

            ; Draw hit zones
            jsr draw_hit_zones

            ; Draw labels
            jsr draw_labels

            rts

; ----------------------------------------------------------------------------
; Draw Tracks
; ----------------------------------------------------------------------------
; Draws horizontal lines for each track using minus characters

draw_tracks:
            ; Track 1 (row 8)
            ldx #0
            lda #$2D            ; Minus character for track line
-           sta SCREEN + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne -

            ; Track 2 (row 12)
            ldx #0
-           sta SCREEN + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne -

            ; Track 3 (row 16)
            ldx #0
-           sta SCREEN + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne -

            rts

; ----------------------------------------------------------------------------
; Draw Hit Zones
; ----------------------------------------------------------------------------
; Draws vertical bars at the hit zone position

draw_hit_zones:
            ; Draw vertical line at hit zone column
            ; Using pipe character for hit zone marker
            lda #$7D            ; Pipe character

            ; Hit zone spans from track 1 to track 3
            sta SCREEN + (TRACK1_ROW * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK1_ROW-1) * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK1_ROW+1) * 40) + HIT_ZONE_COL

            sta SCREEN + (TRACK2_ROW * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK2_ROW-1) * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK2_ROW+1) * 40) + HIT_ZONE_COL

            sta SCREEN + (TRACK3_ROW * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK3_ROW-1) * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK3_ROW+1) * 40) + HIT_ZONE_COL

            ; Colour the hit zones yellow
            lda #YELLOW
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COL
            sta COLRAM + ((TRACK1_ROW-1) * 40) + HIT_ZONE_COL
            sta COLRAM + ((TRACK1_ROW+1) * 40) + HIT_ZONE_COL

            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COL
            sta COLRAM + ((TRACK2_ROW-1) * 40) + HIT_ZONE_COL
            sta COLRAM + ((TRACK2_ROW+1) * 40) + HIT_ZONE_COL

            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COL
            sta COLRAM + ((TRACK3_ROW-1) * 40) + HIT_ZONE_COL
            sta COLRAM + ((TRACK3_ROW+1) * 40) + HIT_ZONE_COL

            rts

; ----------------------------------------------------------------------------
; Draw Labels
; ----------------------------------------------------------------------------
; Draws track labels and instructions

draw_labels:
            ; Title "SID SYMPHONY" at top
            ldx #0
-           lda title_text,x
            beq +
            sta SCREEN + 13,x
            lda #WHITE
            sta COLRAM + 13,x
            inx
            bne -
+
            ; Track labels
            ; "Z" for track 1
            lda #$1A            ; Z
            sta SCREEN + (TRACK1_ROW * 40)
            lda #LIGHT_RED
            sta COLRAM + (TRACK1_ROW * 40)

            ; "X" for track 2
            lda #$18            ; X
            sta SCREEN + (TRACK2_ROW * 40)
            lda #LIGHT_GREEN
            sta COLRAM + (TRACK2_ROW * 40)

            ; "C" for track 3
            lda #$03            ; C
            sta SCREEN + (TRACK3_ROW * 40)
            lda #LIGHT_BLUE
            sta COLRAM + (TRACK3_ROW * 40)

            ; Instructions at bottom
            ldx #0
-           lda instr_text,x
            beq +
            sta SCREEN + (23 * 40) + 5,x
            lda #GREY
            sta COLRAM + (23 * 40) + 5,x
            inx
            bne -
+
            rts

title_text:
            !scr "sid symphony"
            !byte 0

instr_text:
            !scr "press z, x, c to play"
            !byte 0

; ----------------------------------------------------------------------------
; Initialize SID
; ----------------------------------------------------------------------------
; Sets up SID with three distinct voices ready to play

init_sid:
            ; Clear all SID registers first
            ldx #$18
            lda #0
-           sta SID,x
            dex
            bpl -

            ; Set volume to maximum
            lda #$0F
            sta SID_VOLUME

            ; Voice 1 - High pitch, sawtooth wave
            lda #$00
            sta SID_V1_FREQ_LO
            lda #$1C            ; High frequency (~523 Hz, C5)
            sta SID_V1_FREQ_HI
            lda #$09            ; Attack=0, Decay=9
            sta SID_V1_AD
            lda #$00            ; Sustain=0, Release=0
            sta SID_V1_SR

            ; Voice 2 - Mid pitch, pulse wave
            lda #$00
            sta SID_V2_FREQ_LO
            lda #$0E            ; Mid frequency (~262 Hz, C4)
            sta SID_V2_FREQ_HI
            lda #$08            ; 50% pulse width
            sta SID_V2_PWHI
            lda #$09            ; Attack=0, Decay=9
            sta SID_V2_AD
            lda #$00            ; Sustain=0, Release=0
            sta SID_V2_SR

            ; Voice 3 - Low pitch, triangle wave
            lda #$00
            sta SID_V3_FREQ_LO
            lda #$07            ; Low frequency (~131 Hz, C3)
            sta SID_V3_FREQ_HI
            lda #$09            ; Attack=0, Decay=9
            sta SID_V3_AD
            lda #$00            ; Sustain=0, Release=0
            sta SID_V3_SR

            rts

; ----------------------------------------------------------------------------
; Reset Track Colours
; ----------------------------------------------------------------------------
; Returns tracks to their default colours

reset_track_colours:
            ; Track 1 - default grey
            ldx #0
            lda #GREY
-           sta COLRAM + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne -

            ; Track 2 - default grey
            ldx #0
-           sta COLRAM + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne -

            ; Track 3 - default grey
            ldx #0
-           sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne -

            ; Restore key labels
            lda #LIGHT_RED
            sta COLRAM + (TRACK1_ROW * 40)
            lda #LIGHT_GREEN
            sta COLRAM + (TRACK2_ROW * 40)
            lda #LIGHT_BLUE
            sta COLRAM + (TRACK3_ROW * 40)

            ; Restore hit zone colours
            lda #YELLOW
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COL
            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COL
            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COL

            rts

; ----------------------------------------------------------------------------
; Check Keys
; ----------------------------------------------------------------------------
; Reads keyboard and triggers sounds for Z, X, C keys

check_keys:
            ; Check Z key (row 1, column 2)
            ; Z is at keyboard matrix position: row=$FD (bit 1 low), col=$10 (bit 4)
            lda #$FD            ; Select row 1 (bit 1 = 0)
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Check column 4 (Z key)
            bne +               ; Branch if not pressed
            jsr play_voice1
            jsr flash_track1
+
            ; Check X key (row 2, column 7)
            ; X is at keyboard matrix position: row=$FB (bit 2 low), col=$80 (bit 7)
            lda #$FB            ; Select row 2 (bit 2 = 0)
            sta CIA1_PRA
            lda CIA1_PRB
            and #$80            ; Check column 7 (X key)
            bne +               ; Branch if not pressed
            jsr play_voice2
            jsr flash_track2
+
            ; Check C key (row 2, column 4)
            ; C is at keyboard matrix position: row=$FB (bit 2 low), col=$10 (bit 4)
            lda #$FB            ; Select row 2 (bit 2 = 0)
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Check column 4 (C key)
            bne +               ; Branch if not pressed
            jsr play_voice3
            jsr flash_track3
+
            ; Reset keyboard scanning
            lda #$FF
            sta CIA1_PRA

            rts

; ----------------------------------------------------------------------------
; Play Voice 1
; ----------------------------------------------------------------------------
; Triggers voice 1 (high, sawtooth)

play_voice1:
            lda #$21            ; Gate on + sawtooth waveform
            sta SID_V1_CTRL
            rts

; ----------------------------------------------------------------------------
; Play Voice 2
; ----------------------------------------------------------------------------
; Triggers voice 2 (mid, pulse)

play_voice2:
            lda #$41            ; Gate on + pulse waveform
            sta SID_V2_CTRL
            rts

; ----------------------------------------------------------------------------
; Play Voice 3
; ----------------------------------------------------------------------------
; Triggers voice 3 (low, triangle)

play_voice3:
            lda #$11            ; Gate on + triangle waveform
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Flash Track 1
; ----------------------------------------------------------------------------
; Highlights track 1 in red

flash_track1:
            ldx #0
            lda #RED
-           sta COLRAM + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne -
            ; Keep label visible
            lda #WHITE
            sta COLRAM + (TRACK1_ROW * 40)
            rts

; ----------------------------------------------------------------------------
; Flash Track 2
; ----------------------------------------------------------------------------
; Highlights track 2 in green

flash_track2:
            ldx #0
            lda #GREEN
-           sta COLRAM + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne -
            ; Keep label visible
            lda #WHITE
            sta COLRAM + (TRACK2_ROW * 40)
            rts

; ----------------------------------------------------------------------------
; Flash Track 3
; ----------------------------------------------------------------------------
; Highlights track 3 in blue

flash_track3:
            ldx #0
            lda #BLUE
-           sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne -
            ; Keep label visible
            lda #WHITE
            sta COLRAM + (TRACK3_ROW * 40)
            rts

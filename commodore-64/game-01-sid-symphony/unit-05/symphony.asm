; ============================================================================
; SID Symphony - Unit 5: Screen Layout
; ============================================================================
; A prettier game screen with:
; - Decorative title
; - Key labels on each track (X, C, V)
; - Coloured hit zones
; - Score and streak display
; ============================================================================

* = $0801
                !byte $0c, $08, $0a, $00, $9e
                !text "2064"
                !byte $00, $00, $00

* = $0810

; ----------------------------------------------------------------------------
; Screen memory
; ----------------------------------------------------------------------------
SCREEN          = $0400
COLOUR          = $d800
BORDER_COLOUR   = $d020
BACKGROUND      = $d021

SCREEN_WIDTH    = 40

; Track positions (rows)
TRACK1_ROW      = 9
TRACK2_ROW      = 13
TRACK3_ROW      = 17

; Layout
KEY_COL         = 1                 ; Column for key label
HIT_START       = 3                 ; Hit zone starts here
HIT_END         = 7                 ; Hit zone ends here (exclusive)
TRACK_START     = 7                 ; Track line starts here

; Characters (screen codes, not PETSCII!)
BLOCK_CHAR      = $a0               ; Solid block (reverse space)
TRACK_CHAR      = $43               ; Horizontal line (screen code)
KEY_BRACKET_L   = $1b               ; [ in screen code
KEY_BRACKET_R   = $1d               ; ] in screen code

; Colours
COL_BLACK       = 0
COL_WHITE       = 1
COL_RED         = 2
COL_CYAN        = 3
COL_GREEN       = 5
COL_YELLOW      = 7
COL_LIGHT_BLUE  = 14
COL_GREY        = 11
COL_DARK_GREY   = 12

; Zero page
screen_ptr      = $fb
colour_ptr      = $fd

; ============================================================================
; Program entry
; ============================================================================
start:
                jsr clear_screen
                jsr draw_header
                jsr draw_tracks
                jsr draw_footer

forever:        jmp forever

; ----------------------------------------------------------------------------
; Clear screen
; ----------------------------------------------------------------------------
clear_screen:
                lda #COL_BLACK
                sta BORDER_COLOUR
                sta BACKGROUND

                ldx #0
-               lda #$20
                sta SCREEN,x
                sta SCREEN+$100,x
                sta SCREEN+$200,x
                sta SCREEN+$2e8,x
                lda #COL_BLACK
                sta COLOUR,x
                sta COLOUR+$100,x
                sta COLOUR+$200,x
                sta COLOUR+$2e8,x
                inx
                bne -
                rts

; ----------------------------------------------------------------------------
; Draw decorative header
; ----------------------------------------------------------------------------
draw_header:
                ; Top line decoration (row 0)
                ldx #0
-               lda #$43            ; Horizontal line (screen code)
                sta SCREEN,x
                lda #COL_DARK_GREY
                sta COLOUR,x
                inx
                cpx #40
                bne -

                ; Title "SID SYMPHONY" centred (row 2)
                ldx #0
-               lda title_text,x
                beq +
                sta SCREEN + 2*40 + 13,x
                lda #COL_CYAN
                sta COLOUR + 2*40 + 13,x
                inx
                bne -

                ; Subtitle (row 4)
+               ldx #0
-               lda subtitle_text,x
                beq +
                sta SCREEN + 4*40 + 12,x
                lda #COL_GREY
                sta COLOUR + 4*40 + 12,x
                inx
                bne -

                ; Score label and value (row 6)
+               ldx #0
-               lda score_text,x
                beq +
                sta SCREEN + 6*40 + 2,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 2,x
                inx
                bne -

                ; Initial score "000000"
+               ldx #0
-               lda #$30
                sta SCREEN + 6*40 + 9,x
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 9,x
                inx
                cpx #6
                bne -

                ; Streak label (row 6, right side)
                ldx #0
-               lda streak_text,x
                beq +
                sta SCREEN + 6*40 + 26,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 26,x
                inx
                bne -

                ; Initial streak "00"
+               lda #$30
                sta SCREEN + 6*40 + 34
                sta SCREEN + 6*40 + 35
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 34
                sta COLOUR + 6*40 + 35
                rts

title_text:     !scr "sid symphony"
                !byte 0
subtitle_text:  !scr "press the keys!"
                !byte 0
score_text:     !scr "score:"
                !byte 0
streak_text:    !scr "streak:"
                !byte 0

; ----------------------------------------------------------------------------
; Draw the three tracks with key labels
; ----------------------------------------------------------------------------
draw_tracks:
                ; Track 1: X key, cyan
                lda #TRACK1_ROW
                ldx #$18            ; X in screen code
                ldy #COL_CYAN
                jsr draw_single_track

                ; Track 2: C key, green
                lda #TRACK2_ROW
                ldx #$03            ; C in screen code
                ldy #COL_GREEN
                jsr draw_single_track

                ; Track 3: V key, yellow
                lda #TRACK3_ROW
                ldx #$16            ; V in screen code
                ldy #COL_YELLOW
                jsr draw_single_track

                rts

; Draw one track. A=row, X=key char, Y=colour
draw_single_track:
                sta temp_row
                stx temp_key
                sty temp_colour

                ; Calculate screen address for this row
                lda temp_row
                jsr calc_row_addr

                ; Draw key label "[X]"
                ldy #KEY_COL
                lda #KEY_BRACKET_L
                sta (screen_ptr),y
                lda #COL_WHITE
                sta (colour_ptr),y

                iny
                lda temp_key
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y

                iny
                lda #KEY_BRACKET_R
                sta (screen_ptr),y
                lda #COL_WHITE
                sta (colour_ptr),y

                ; Draw hit zone (solid blocks)
                ldy #HIT_START
-               lda #BLOCK_CHAR
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y
                iny
                cpy #HIT_END
                bne -

                ; Draw track line
                ldy #TRACK_START
-               lda #TRACK_CHAR
                sta (screen_ptr),y
                lda #COL_DARK_GREY
                sta (colour_ptr),y
                iny
                cpy #SCREEN_WIDTH
                bne -

                rts

; Calculate row address into screen_ptr and colour_ptr
; A = row number (0-24)
calc_row_addr:
                ; Multiply row by 40 = row * 8 + row * 32
                ; Must use 16-bit arithmetic (row 17 * 40 = 680)
                sta temp_row

                ; Start with row in 16-bit temp
                sta temp_lo
                lda #0
                sta temp_hi

                ; Shift left 3 times: row * 8
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi         ; temp = row * 8

                ; Save row * 8
                lda temp_lo
                sta save_lo
                lda temp_hi
                sta save_hi

                ; Shift left 2 more times: row * 32
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi         ; temp = row * 32

                ; Add row * 8 to get row * 40
                clc
                lda save_lo
                adc temp_lo
                sta temp_lo
                lda save_hi
                adc temp_hi
                sta temp_hi         ; temp = row * 40

                ; Add screen base ($0400)
                clc
                lda temp_lo
                adc #<SCREEN
                sta screen_ptr
                lda temp_hi
                adc #>SCREEN
                sta screen_ptr+1

                ; Add colour base ($D800)
                clc
                lda temp_lo
                adc #<COLOUR
                sta colour_ptr
                lda temp_hi
                adc #>COLOUR
                sta colour_ptr+1

                rts

temp_row:       !byte 0
temp_key:       !byte 0
temp_colour:    !byte 0
temp_lo:        !byte 0
temp_hi:        !byte 0
save_lo:        !byte 0
save_hi:        !byte 0

; ----------------------------------------------------------------------------
; Draw footer with instructions
; ----------------------------------------------------------------------------
draw_footer:
                ; Bottom decoration line (row 22)
                ldx #0
-               lda #$43            ; Horizontal line (screen code)
                sta SCREEN + 22*40,x
                lda #COL_DARK_GREY
                sta COLOUR + 22*40,x
                inx
                cpx #40
                bne -

                ; Instructions (row 24)
                ldx #0
-               lda footer_text,x
                beq +
                sta SCREEN + 24*40 + 6,x
                lda #COL_GREY
                sta COLOUR + 24*40 + 6,x
                inx
                bne -
+               rts

footer_text:    !scr "hit notes as they reach ["
                !byte $a0
                !scr "]"
                !byte 0

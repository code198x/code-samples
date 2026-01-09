; ============================================================================
; SID Symphony - Unit 7: The Game Loop
; ============================================================================
; Proper game architecture with:
; - Initialisation routine (runs once)
; - Main loop (runs every frame)
; - Raster synchronisation for consistent 50fps timing
; - Frame and beat counters
; - Q key to exit cleanly
; ============================================================================

* = $0801
                !byte $0c, $08, $0a, $00, $9e
                !text "2064"
                !byte $00, $00, $00

* = $0810

; ----------------------------------------------------------------------------
; Hardware registers
; ----------------------------------------------------------------------------
SCREEN          = $0400
COLOUR          = $d800
BORDER_COLOUR   = $d020
BACKGROUND      = $d021
RASTER          = $d012         ; Current raster line
CHAR_ROM        = $d000
CHAR_RAM        = $3000
VIC_MEMSETUP    = $d018

; Keyboard
KEYBOARD_COLUMN = $dc00         ; CIA1 Port A - column select
KEYBOARD_ROW    = $dc01         ; CIA1 Port B - row read

SCREEN_WIDTH    = 40

; Track positions
TRACK1_ROW      = 9
TRACK2_ROW      = 13
TRACK3_ROW      = 17

; Layout
KEY_COL         = 1
HIT_START       = 3
HIT_END         = 7
TRACK_START     = 7

; Characters
NOTE_CHAR       = 128
TRACK_CHAR      = 129
HITZONE_CHAR    = 130
KEY_BRACKET_L   = $1b
KEY_BRACKET_R   = $1d

; Colours
COL_BLACK       = 0
COL_WHITE       = 1
COL_CYAN        = 3
COL_GREEN       = 5
COL_YELLOW      = 7
COL_GREY        = 11
COL_DARK_GREY   = 12

; Timing
FRAMES_PER_BEAT = 12            ; 50/12 ≈ 4 beats per second

; Zero page
screen_ptr      = $fb
colour_ptr      = $fd

; ============================================================================
; Program entry
; ============================================================================
start:
                jsr init            ; One-time setup

main_loop:
                jsr wait_raster     ; Sync to frame
                jsr update_counters ; Update timing
                jsr update_display  ; Visual feedback
                jsr check_quit      ; Check for Q key
                jmp main_loop       ; Loop forever (until Q)

; ============================================================================
; Initialisation - runs once at startup
; ============================================================================
init:
                jsr setup_charset
                jsr clear_screen
                jsr draw_header
                jsr draw_tracks
                jsr draw_footer

                ; Initialise game state
                lda #0
                sta frame_counter
                sta beat_counter
                sta last_raster

                rts

; ----------------------------------------------------------------------------
; Wait for raster to reach line 250 (bottom of visible area)
; This gives us consistent 50fps timing on PAL
; ----------------------------------------------------------------------------
wait_raster:
                ; Wait for raster to leave line 250 first
                ; (in case we're still on it from last frame)
-               lda RASTER
                cmp #250
                beq -

                ; Now wait for raster to reach line 250
-               lda RASTER
                cmp #250
                bne -

                rts

; ----------------------------------------------------------------------------
; Update frame and beat counters
; ----------------------------------------------------------------------------
update_counters:
                inc frame_counter

                ; Check if we've reached a new beat
                lda frame_counter
                cmp #FRAMES_PER_BEAT
                bne +

                ; New beat!
                lda #0
                sta frame_counter
                inc beat_counter

                ; Wrap beat counter at 99
                lda beat_counter
                cmp #100
                bcc +
                lda #0
                sta beat_counter

+               rts

; ----------------------------------------------------------------------------
; Update display - subtle border flash on beat, update counter
; ----------------------------------------------------------------------------
update_display:
                ; Brief border flash on each beat (when frame_counter = 0)
                lda frame_counter
                bne .no_flash

                ; Flash dark grey (subtle)
                lda #COL_DARK_GREY
                sta BORDER_COLOUR
                jmp .update_counter

.no_flash:
                ; Return to black after just 1 frame
                cmp #1
                bne .update_counter
                lda #COL_BLACK
                sta BORDER_COLOUR

.update_counter:
                ; Update beat counter as two decimal digits (00-99)
                ; Display at row 6, columns 19-20
                lda beat_counter

                ; Divide by 10 to get tens digit
                ldx #0
-               cmp #10
                bcc .got_digits
                sbc #10
                inx
                jmp -

.got_digits:
                ; X = tens digit, A = units digit
                pha                 ; Save units
                txa
                ora #$30            ; Convert tens to ASCII
                sta SCREEN + 6*40 + 19
                pla
                ora #$30            ; Convert units to ASCII
                sta SCREEN + 6*40 + 20

                rts

; ----------------------------------------------------------------------------
; Check for Q key to quit
; ----------------------------------------------------------------------------
check_quit:
                ; Q key is in column 7, row 6 of keyboard matrix
                ; Select column 7 (bit 7 = 0, others = 1)
                lda #%01111111
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #%01000000      ; Check bit 6 (row where Q is)
                bne +               ; If bit is set, Q not pressed

                ; Q pressed - exit to BASIC cleanly
                ; Restore default character set
                lda #$14
                sta VIC_MEMSETUP

                ; Reset colours
                lda #14             ; Light blue
                sta BORDER_COLOUR
                lda #6              ; Blue
                sta BACKGROUND

                ; Clear screen by calling KERNAL routine
                lda #147            ; Clear screen PETSCII code
                jsr $ffd2           ; CHROUT - output character

                ; Return to BASIC
                jmp $a474           ; BASIC warm start

+               rts

; ============================================================================
; Character set setup (from Unit 6)
; ============================================================================
setup_charset:
                sei
                lda $01
                pha
                and #%11111011
                sta $01

                ldx #0
-               lda CHAR_ROM,x
                sta CHAR_RAM,x
                lda CHAR_ROM+$100,x
                sta CHAR_RAM+$100,x
                lda CHAR_ROM+$200,x
                sta CHAR_RAM+$200,x
                lda CHAR_ROM+$300,x
                sta CHAR_RAM+$300,x
                lda CHAR_ROM+$400,x
                sta CHAR_RAM+$400,x
                lda CHAR_ROM+$500,x
                sta CHAR_RAM+$500,x
                lda CHAR_ROM+$600,x
                sta CHAR_RAM+$600,x
                lda CHAR_ROM+$700,x
                sta CHAR_RAM+$700,x
                inx
                bne -

                pla
                sta $01
                cli

                ldx #0
-               lda note_char_data,x
                sta CHAR_RAM + (NOTE_CHAR * 8),x
                inx
                cpx #8
                bne -

                ldx #0
-               lda track_char_data,x
                sta CHAR_RAM + (TRACK_CHAR * 8),x
                inx
                cpx #8
                bne -

                ldx #0
-               lda hitzone_char_data,x
                sta CHAR_RAM + (HITZONE_CHAR * 8),x
                inx
                cpx #8
                bne -

                lda #$1c
                sta VIC_MEMSETUP
                rts

note_char_data:
                !byte %00111100, %01111110, %11111111, %11111111
                !byte %11111111, %11111111, %01111110, %00111100

track_char_data:
                !byte %00000000, %00000000, %00000000, %11111111
                !byte %11111111, %00000000, %00000000, %00000000

hitzone_char_data:
                !byte %11111111, %11111111, %11111111, %11111111
                !byte %11111111, %11111111, %11111111, %11111111

; ============================================================================
; Screen drawing routines (from previous units)
; ============================================================================
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

draw_header:
                ldx #0
-               lda #TRACK_CHAR
                sta SCREEN,x
                lda #COL_DARK_GREY
                sta COLOUR,x
                inx
                cpx #40
                bne -

                ldx #0
-               lda title_text,x
                beq +
                sta SCREEN + 2*40 + 13,x
                lda #COL_CYAN
                sta COLOUR + 2*40 + 13,x
                inx
                bne -

+               ldx #0
-               lda subtitle_text,x
                beq +
                sta SCREEN + 4*40 + 12,x
                lda #COL_GREY
                sta COLOUR + 4*40 + 12,x
                inx
                bne -

+               ldx #0
-               lda score_text,x
                beq +
                sta SCREEN + 6*40 + 2,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 2,x
                inx
                bne -

+               ldx #0
-               lda #$30
                sta SCREEN + 6*40 + 9,x
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 9,x
                inx
                cpx #6
                bne -

                ; Beat counter label
                ldx #0
-               lda beat_text,x
                beq +
                sta SCREEN + 6*40 + 17,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 17,x
                inx
                bne -

+               ; Initial "00" for beat counter
                lda #$30
                sta SCREEN + 6*40 + 19
                sta SCREEN + 6*40 + 20
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 19
                sta COLOUR + 6*40 + 20

                ldx #0
-               lda streak_text,x
                beq +
                sta SCREEN + 6*40 + 26,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 26,x
                inx
                bne -

+               lda #$30
                sta SCREEN + 6*40 + 34
                sta SCREEN + 6*40 + 35
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 34
                sta COLOUR + 6*40 + 35
                rts

title_text:     !scr "sid symphony"
                !byte 0
subtitle_text:  !scr "press q to quit"
                !byte 0
score_text:     !scr "score:"
                !byte 0
beat_text:      !scr "b:"
                !byte 0
streak_text:    !scr "streak:"
                !byte 0

draw_tracks:
                lda #TRACK1_ROW
                ldx #$18
                ldy #COL_CYAN
                jsr draw_single_track

                lda #TRACK2_ROW
                ldx #$03
                ldy #COL_GREEN
                jsr draw_single_track

                lda #TRACK3_ROW
                ldx #$16
                ldy #COL_YELLOW
                jsr draw_single_track
                rts

draw_single_track:
                sta temp_row
                stx temp_key
                sty temp_colour

                lda temp_row
                jsr calc_row_addr

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

                ldy #HIT_START
-               lda #HITZONE_CHAR
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y
                iny
                cpy #HIT_END
                bne -

                ldy #TRACK_START
-               lda #TRACK_CHAR
                sta (screen_ptr),y
                lda #COL_DARK_GREY
                sta (colour_ptr),y
                iny
                cpy #SCREEN_WIDTH
                bne -
                rts

calc_row_addr:
                sta temp_row
                sta temp_lo
                lda #0
                sta temp_hi

                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi

                lda temp_lo
                sta save_lo
                lda temp_hi
                sta save_hi

                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi

                clc
                lda save_lo
                adc temp_lo
                sta temp_lo
                lda save_hi
                adc temp_hi
                sta temp_hi

                clc
                lda temp_lo
                adc #<SCREEN
                sta screen_ptr
                lda temp_hi
                adc #>SCREEN
                sta screen_ptr+1

                clc
                lda temp_lo
                adc #<COLOUR
                sta colour_ptr
                lda temp_hi
                adc #>COLOUR
                sta colour_ptr+1
                rts

draw_footer:
                ldx #0
-               lda #TRACK_CHAR
                sta SCREEN + 22*40,x
                lda #COL_DARK_GREY
                sta COLOUR + 22*40,x
                inx
                cpx #40
                bne -

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
                !byte HITZONE_CHAR
                !scr "]"
                !byte 0

; ============================================================================
; Variables
; ============================================================================
temp_row:       !byte 0
temp_key:       !byte 0
temp_colour:    !byte 0
temp_lo:        !byte 0
temp_hi:        !byte 0
save_lo:        !byte 0
save_hi:        !byte 0

frame_counter:  !byte 0         ; Counts 0 to FRAMES_PER_BEAT-1
beat_counter:   !byte 0         ; Counts beats (0-255, wraps)
last_raster:    !byte 0         ; For debugging

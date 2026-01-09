; ============================================================================
; SID Symphony - Unit 6: Custom Characters
; ============================================================================
; Building on Unit 5's screen layout, we now add:
; - Custom character set copied to RAM
; - Note character (filled circle)
; - Custom track line
; - Hit zone marker
; ============================================================================

* = $0801
                !byte $0c, $08, $0a, $00, $9e
                !text "2064"
                !byte $00, $00, $00

* = $0810

; ----------------------------------------------------------------------------
; Memory map
; ----------------------------------------------------------------------------
SCREEN          = $0400
COLOUR          = $d800
BORDER_COLOUR   = $d020
BACKGROUND      = $d021

; Character memory - we'll put our custom set at $3000
CHAR_ROM        = $d000         ; ROM character set
CHAR_RAM        = $3000         ; Our custom characters
VIC_BANK        = $dd00         ; CIA2 for VIC bank selection
VIC_MEMSETUP    = $d018         ; VIC memory setup register

SCREEN_WIDTH    = 40

; Track positions (rows)
TRACK1_ROW      = 9
TRACK2_ROW      = 13
TRACK3_ROW      = 17

; Layout
KEY_COL         = 1
HIT_START       = 3
HIT_END         = 7
TRACK_START     = 7

; Custom character codes (we'll define these)
NOTE_CHAR       = 128           ; Our custom note (first char in our custom area)
TRACK_CHAR      = 129           ; Custom track line
HITZONE_CHAR    = 130           ; Hit zone marker

; Standard characters (screen codes)
KEY_BRACKET_L   = $1b           ; [
KEY_BRACKET_R   = $1d           ; ]

; Colours
COL_BLACK       = 0
COL_WHITE       = 1
COL_CYAN        = 3
COL_GREEN       = 5
COL_YELLOW      = 7
COL_GREY        = 11
COL_DARK_GREY   = 12

; Zero page
screen_ptr      = $fb
colour_ptr      = $fd

; ============================================================================
; Program entry
; ============================================================================
start:
                jsr setup_charset
                jsr clear_screen
                jsr draw_header
                jsr draw_tracks
                jsr draw_footer
                jsr draw_sample_notes

forever:        jmp forever

; ----------------------------------------------------------------------------
; Copy ROM charset to RAM and add custom characters
; ----------------------------------------------------------------------------
setup_charset:
                ; First, we need to make the character ROM visible
                ; It's normally hidden under I/O at $D000
                sei                 ; Disable interrupts
                lda $01             ; Get processor port
                pha                 ; Save it
                and #%11111011      ; Clear bit 2 (CHAREN)
                sta $01             ; Now ROM is visible at $D000

                ; Copy 2KB of character data (256 chars * 8 bytes)
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

                ; Restore I/O visibility
                pla
                sta $01
                cli

                ; Now define our custom characters
                ; Character 128 = Note (filled circle)
                ldx #0
-               lda note_char_data,x
                sta CHAR_RAM + (NOTE_CHAR * 8),x
                inx
                cpx #8
                bne -

                ; Character 129 = Track line (thin horizontal)
                ldx #0
-               lda track_char_data,x
                sta CHAR_RAM + (TRACK_CHAR * 8),x
                inx
                cpx #8
                bne -

                ; Character 130 = Hit zone marker
                ldx #0
-               lda hitzone_char_data,x
                sta CHAR_RAM + (HITZONE_CHAR * 8),x
                inx
                cpx #8
                bne -

                ; Point VIC to our character set at $3000
                ; $D018: bits 1-3 = char memory, bits 4-7 = screen memory
                ; Screen at $0400 = %0001 (value 1)
                ; Chars at $3000 = %110 (value 6)
                ; Combined: (1 << 4) | (6 << 1) = $10 | $0C = $1C
                lda #$1c
                sta VIC_MEMSETUP

                rts

; Custom character data (8 bytes each)
note_char_data:
                !byte %00111100     ; ..####..
                !byte %01111110     ; .######.
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %01111110     ; .######.
                !byte %00111100     ; ..####..

track_char_data:
                !byte %00000000     ; ........
                !byte %00000000     ; ........
                !byte %00000000     ; ........
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %00000000     ; ........
                !byte %00000000     ; ........
                !byte %00000000     ; ........

hitzone_char_data:
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########
                !byte %11111111     ; ########

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
; Draw header
; ----------------------------------------------------------------------------
draw_header:
                ; Top line decoration (row 0)
                ldx #0
-               lda #TRACK_CHAR
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

                ; Score label (row 6)
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

                ; Streak label
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
subtitle_text:  !scr "press the keys!"
                !byte 0
score_text:     !scr "score:"
                !byte 0
streak_text:    !scr "streak:"
                !byte 0

; ----------------------------------------------------------------------------
; Draw tracks with custom characters
; ----------------------------------------------------------------------------
draw_tracks:
                lda #TRACK1_ROW
                ldx #$18            ; X in screen code
                ldy #COL_CYAN
                jsr draw_single_track

                lda #TRACK2_ROW
                ldx #$03            ; C in screen code
                ldy #COL_GREEN
                jsr draw_single_track

                lda #TRACK3_ROW
                ldx #$16            ; V in screen code
                ldy #COL_YELLOW
                jsr draw_single_track

                rts

draw_single_track:
                sta temp_row
                stx temp_key
                sty temp_colour

                lda temp_row
                jsr calc_row_addr

                ; Key label "[X]"
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

                ; Hit zone using custom character
                ldy #HIT_START
-               lda #HITZONE_CHAR
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y
                iny
                cpy #HIT_END
                bne -

                ; Track line using custom character
                ldy #TRACK_START
-               lda #TRACK_CHAR
                sta (screen_ptr),y
                lda #COL_DARK_GREY
                sta (colour_ptr),y
                iny
                cpy #SCREEN_WIDTH
                bne -

                rts

; ----------------------------------------------------------------------------
; Calculate row address
; ----------------------------------------------------------------------------
calc_row_addr:
                sta temp_row
                sta temp_lo
                lda #0
                sta temp_hi

                ; row * 8
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

                ; row * 32
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi

                ; row * 40
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

temp_row:       !byte 0
temp_key:       !byte 0
temp_colour:    !byte 0
temp_lo:        !byte 0
temp_hi:        !byte 0
save_lo:        !byte 0
save_hi:        !byte 0

; ----------------------------------------------------------------------------
; Draw footer
; ----------------------------------------------------------------------------
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

; ----------------------------------------------------------------------------
; Draw sample notes to show custom character
; ----------------------------------------------------------------------------
draw_sample_notes:
                ; Show a note on each track to demonstrate the custom char
                ; Track 1, column 20
                lda #NOTE_CHAR
                sta SCREEN + TRACK1_ROW * 40 + 20
                lda #COL_CYAN
                sta COLOUR + TRACK1_ROW * 40 + 20

                ; Track 2, column 25
                lda #NOTE_CHAR
                sta SCREEN + TRACK2_ROW * 40 + 25
                lda #COL_GREEN
                sta COLOUR + TRACK2_ROW * 40 + 25

                ; Track 3, column 15
                lda #NOTE_CHAR
                sta SCREEN + TRACK3_ROW * 40 + 15
                lda #COL_YELLOW
                sta COLOUR + TRACK3_ROW * 40 + 15

                rts

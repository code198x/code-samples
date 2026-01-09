; ============================================================================
; SID Symphony - Unit 8: Note Data Structure
; ============================================================================
; Building on the game loop, we now add:
; - Song data format (beat, track, note)
; - A simple test song
; - Display current song position
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
RASTER          = $d012
CHAR_ROM        = $d000
CHAR_RAM        = $3000
VIC_MEMSETUP    = $d018
KEYBOARD_COLUMN = $dc00
KEYBOARD_ROW    = $dc01

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
FRAMES_PER_BEAT = 12            ; ~4 beats per second

; Song data constants
END_MARKER      = $ff           ; Marks end of song data

; Zero page
screen_ptr      = $fb
colour_ptr      = $fd

; ============================================================================
; Program entry
; ============================================================================
start:
                jsr init

main_loop:
                jsr wait_raster
                jsr update_counters
                jsr update_song_display
                jsr check_quit
                jmp main_loop

; ============================================================================
; Initialisation
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
                sta song_position  ; Index into song data

                rts

; ----------------------------------------------------------------------------
; Update counters and check for new beat
; ----------------------------------------------------------------------------
update_counters:
                inc frame_counter

                lda frame_counter
                cmp #FRAMES_PER_BEAT
                bne +

                lda #0
                sta frame_counter
                inc beat_counter

                ; Wrap at 99
                lda beat_counter
                cmp #100
                bcc +
                lda #0
                sta beat_counter

+               rts

; ----------------------------------------------------------------------------
; Update song position display
; Shows current beat and next note in song
; ----------------------------------------------------------------------------
update_song_display:
                ; Show beat counter (row 6, columns 19-20)
                lda beat_counter
                jsr display_two_digits
                sta SCREEN + 6*40 + 20
                stx SCREEN + 6*40 + 19

                ; Show song position (row 6, columns 34-35)
                lda song_position
                jsr display_two_digits
                sta SCREEN + 6*40 + 35
                stx SCREEN + 6*40 + 34

                ; Check if current beat matches next song event
                ldx song_position
                lda song_beats,x
                cmp #END_MARKER
                beq .no_flash       ; End of song

                cmp beat_counter
                bne .no_flash

                ; Match! Flash border to show note would trigger
                lda #COL_CYAN
                sta BORDER_COLOUR

                ; Advance to next song event
                inc song_position
                jmp .done

.no_flash:
                ; Return border to black
                lda #COL_BLACK
                sta BORDER_COLOUR

.done:
                rts

; Convert A to two decimal digits
; Returns: X = tens digit (screen code), A = units digit (screen code)
display_two_digits:
                ldx #0
-               cmp #10
                bcc .convert
                sbc #10
                inx
                jmp -
.convert:
                ora #$30            ; Units to screen code
                pha
                txa
                ora #$30            ; Tens to screen code
                tax
                pla
                rts

; ----------------------------------------------------------------------------
; Wait for raster
; ----------------------------------------------------------------------------
wait_raster:
-               lda RASTER
                cmp #250
                beq -
-               lda RASTER
                cmp #250
                bne -
                rts

; ----------------------------------------------------------------------------
; Check for Q key
; ----------------------------------------------------------------------------
check_quit:
                lda #%01111111
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #%01000000
                bne +

                lda #$14
                sta VIC_MEMSETUP
                lda #14
                sta BORDER_COLOUR
                lda #6
                sta BACKGROUND
                lda #147
                jsr $ffd2
                jmp $a474
+               rts

; ============================================================================
; Song data - parallel arrays
; ============================================================================
; Each note is defined by three bytes:
;   1. Beat number (0-254, $FF = end)
;   2. Track (1, 2, or 3)
;   3. Note value (for SID frequency)
;
; Using parallel arrays is efficient for 6502:
; - All beats together for quick comparison
; - Track data loaded only when needed

; Test song: 16 notes over 32 beats
; A simple pattern that alternates between tracks

song_beats:
                !byte 0             ; Note 0 on beat 0
                !byte 2             ; Note 1 on beat 2
                !byte 4             ; Note 2 on beat 4
                !byte 6             ; Note 3 on beat 6
                !byte 8             ; Note 4 on beat 8
                !byte 10            ; Note 5 on beat 10
                !byte 12            ; Note 6 on beat 12
                !byte 14            ; Note 7 on beat 14
                !byte 16            ; Note 8 on beat 16
                !byte 18            ; Note 9 on beat 18
                !byte 20            ; Note 10 on beat 20
                !byte 22            ; Note 11 on beat 22
                !byte 24            ; Note 12 on beat 24
                !byte 26            ; Note 13 on beat 26
                !byte 28            ; Note 14 on beat 28
                !byte 30            ; Note 15 on beat 30
                !byte END_MARKER    ; End of song

song_tracks:
                !byte 1             ; Track 1 (X key)
                !byte 2             ; Track 2 (C key)
                !byte 3             ; Track 3 (V key)
                !byte 2             ; Track 2
                !byte 1             ; Track 1
                !byte 3             ; Track 3
                !byte 2             ; Track 2
                !byte 1             ; Track 1
                !byte 3             ; Track 3
                !byte 1             ; Track 1
                !byte 2             ; Track 2
                !byte 3             ; Track 3
                !byte 1             ; Track 1
                !byte 2             ; Track 2
                !byte 3             ; Track 3
                !byte 1             ; Track 1

; Note values (SID frequency high bytes for simple notes)
; These are high bytes only - the low byte is set to 0 for simplicity
; Full values: C4=$1167, D4=$1389, E4=$15ed, F4=$173b, G4=$1a13, A4=$1d45, B4=$20da, C5=$22ce
song_notes:
                !byte $11           ; C4
                !byte $13           ; D4
                !byte $15           ; E4
                !byte $17           ; F4
                !byte $1a           ; G4
                !byte $1d           ; A4
                !byte $20           ; B4
                !byte $22           ; C5
                !byte $22           ; C5
                !byte $20           ; B4
                !byte $1d           ; A4
                !byte $1a           ; G4
                !byte $17           ; F4
                !byte $15           ; E4
                !byte $13           ; D4
                !byte $11           ; C4

; ============================================================================
; Character set and screen drawing (from previous units)
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

                ldx #0
-               lda beat_text,x
                beq +
                sta SCREEN + 6*40 + 17,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 17,x
                inx
                bne -

+               lda #$30
                sta SCREEN + 6*40 + 19
                sta SCREEN + 6*40 + 20
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 19
                sta COLOUR + 6*40 + 20

                ; Song position label
                ldx #0
-               lda pos_text,x
                beq +
                sta SCREEN + 6*40 + 29,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 29,x
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
pos_text:       !scr "pos:"
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

frame_counter:  !byte 0
beat_counter:   !byte 0
song_position:  !byte 0         ; Index into song arrays

; ============================================================================
; SID Symphony - Unit 9: Spawning Notes
; ============================================================================
; Building on the song data, we now:
; - Track active notes in memory (up to 8)
; - Spawn notes at the right edge when song data triggers
; - Draw notes on screen (they don't move yet)
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

; Track positions (rows)
TRACK1_ROW      = 9
TRACK2_ROW      = 13
TRACK3_ROW      = 17

; Layout
KEY_COL         = 1
HIT_START       = 3
HIT_END         = 7
TRACK_START     = 7
SPAWN_COLUMN    = 39            ; Notes spawn at right edge

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
FRAMES_PER_BEAT = 12

; Notes
MAX_NOTES       = 8             ; Maximum active notes
NOTE_INACTIVE   = 0
NOTE_ACTIVE     = 1

; Song data
END_MARKER      = $ff

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
                jsr check_spawn_notes
                jsr draw_notes
                jsr update_display
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
                sta song_position

                ; Clear all active notes
                ldx #0
-               sta note_active,x
                inx
                cpx #MAX_NOTES
                bne -

                rts

; ----------------------------------------------------------------------------
; Update counters
; ----------------------------------------------------------------------------
update_counters:
                inc frame_counter

                lda frame_counter
                cmp #FRAMES_PER_BEAT
                bne +

                lda #0
                sta frame_counter
                inc beat_counter

                lda beat_counter
                cmp #100
                bcc +
                lda #0
                sta beat_counter

+               rts

; ----------------------------------------------------------------------------
; Check if we need to spawn a note this beat
; ----------------------------------------------------------------------------
check_spawn_notes:
                ; Only check on new beat (frame_counter = 0)
                lda frame_counter
                bne .no_spawn

                ; Check if current beat matches next song event
                ldx song_position
                lda song_beats,x
                cmp #END_MARKER
                beq .no_spawn       ; End of song

                cmp beat_counter
                bne .no_spawn       ; Not time yet

                ; Time to spawn! Get track and note
                lda song_tracks,x
                sta spawn_track
                lda song_notes,x
                sta spawn_note_val

                ; Advance song position
                inc song_position

                ; Spawn the note
                jsr spawn_note

.no_spawn:      rts

; ----------------------------------------------------------------------------
; Spawn a new note - find free slot and create it
; Input: spawn_track (1-3), spawn_note_val
; ----------------------------------------------------------------------------
spawn_note:
                ; Find a free slot in active notes
                ldx #0
.find_slot:
                lda note_active,x
                beq .found_slot     ; Found inactive slot
                inx
                cpx #MAX_NOTES
                bne .find_slot
                rts                 ; No free slots, skip this note

.found_slot:
                ; Activate this slot
                lda #NOTE_ACTIVE
                sta note_active,x

                ; Set position to right edge
                lda #SPAWN_COLUMN
                sta note_x,x

                ; Set track
                lda spawn_track
                sta note_track,x

                ; Set note value (for later sound)
                lda spawn_note_val
                sta note_value,x

                ; Flash border to show spawn
                lda #COL_WHITE
                sta BORDER_COLOUR

                rts

; ----------------------------------------------------------------------------
; Draw all active notes
; ----------------------------------------------------------------------------
draw_notes:
                ldx #0

.draw_loop:
                lda note_active,x
                beq .next_note      ; Skip inactive

                ; Get screen row for this track
                lda note_track,x
                cmp #1
                bne .not_track1
                lda #TRACK1_ROW
                jmp .got_row
.not_track1:
                cmp #2
                bne .not_track2
                lda #TRACK2_ROW
                jmp .got_row
.not_track2:
                lda #TRACK3_ROW

.got_row:
                ; Calculate screen address
                stx temp_note_idx   ; Save note index
                jsr calc_row_addr

                ; Get column (note X position)
                ldx temp_note_idx
                ldy note_x,x

                ; Draw note character
                lda #NOTE_CHAR
                sta (screen_ptr),y

                ; Set colour based on track
                lda note_track,x
                cmp #1
                bne .not_cyan
                lda #COL_CYAN
                jmp .set_colour
.not_cyan:
                cmp #2
                bne .not_green
                lda #COL_GREEN
                jmp .set_colour
.not_green:
                lda #COL_YELLOW

.set_colour:
                sta (colour_ptr),y

.next_note:
                inx
                cpx #MAX_NOTES
                bne .draw_loop

                ; Reset border
                lda #COL_BLACK
                sta BORDER_COLOUR

                rts

; ----------------------------------------------------------------------------
; Update display
; ----------------------------------------------------------------------------
update_display:
                ; Beat counter
                lda beat_counter
                jsr display_two_digits
                sta SCREEN + 6*40 + 20
                stx SCREEN + 6*40 + 19

                ; Song position
                lda song_position
                jsr display_two_digits
                sta SCREEN + 6*40 + 35
                stx SCREEN + 6*40 + 34

                rts

display_two_digits:
                ldx #0
-               cmp #10
                bcc .convert
                sbc #10
                inx
                jmp -
.convert:
                ora #$30
                pha
                txa
                ora #$30
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
; Song data
; ============================================================================
song_beats:
                !byte 0, 2, 4, 6, 8, 10, 12, 14
                !byte 16, 18, 20, 22, 24, 26, 28, 30
                !byte END_MARKER

song_tracks:
                !byte 1, 2, 3, 2, 1, 3, 2, 1
                !byte 3, 1, 2, 3, 1, 2, 3, 1

song_notes:
                !byte $11, $13, $15, $16, $18, $1b, $1d, $22
                !byte $22, $1d, $1b, $18, $16, $15, $13, $11

; ============================================================================
; Character set setup (from previous units)
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
; Screen drawing (from previous units)
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
song_position:  !byte 0

; Spawn temporaries
spawn_track:    !byte 0
spawn_note_val: !byte 0
temp_note_idx:  !byte 0

; Active notes array (8 notes max)
note_active:    !byte 0, 0, 0, 0, 0, 0, 0, 0   ; 0=inactive, 1=active
note_x:         !byte 0, 0, 0, 0, 0, 0, 0, 0   ; X position (column)
note_track:     !byte 0, 0, 0, 0, 0, 0, 0, 0   ; Track (1, 2, or 3)
note_value:     !byte 0, 0, 0, 0, 0, 0, 0, 0   ; SID note value

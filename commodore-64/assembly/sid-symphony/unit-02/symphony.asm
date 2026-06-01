; ============================================================================
; SID SYMPHONY - Unit 2: Notes Appear
; ============================================================================
; Notes scroll from right to left across three tracks. When they reach the
; hit zone, press the matching key to play the sound. A simple test pattern
; loops continuously so you can practice timing.
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

; Note settings
NOTE_CHAR   = $57               ; Character for note (filled dot/ball)
TRACK_CHAR  = $2D               ; Minus character for track line
MAX_NOTES   = 8                 ; Maximum notes on screen at once
NOTE_SPAWN_COL = 37             ; Where notes appear (right side)

; Timing
FRAMES_PER_BEAT = 25            ; ~120 BPM at 50Hz (PAL)

; Zero page pointers
ZP_PTR      = $FB               ; General purpose pointer
ZP_PTR_HI   = $FC

; ----------------------------------------------------------------------------
; Variables (in low memory)
; ----------------------------------------------------------------------------

frame_count = $02               ; Frame counter (0-255)
beat_count  = $03               ; Current beat in song (0-255)
song_pos    = $04               ; Position in song data (word)
song_pos_hi = $05
temp_track  = $06               ; Temporary storage for track number

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
            jsr init_notes      ; Clear note arrays

            ; Initialize song position
            lda #<song_data
            sta song_pos
            lda #>song_data
            sta song_pos_hi

            ; Initialize counters
            lda #0
            sta frame_count
            sta beat_count

main_loop:
            ; Wait for raster (smooth timing)
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            ; Update frame counter
            inc frame_count
            lda frame_count
            cmp #FRAMES_PER_BEAT
            bcc no_new_beat

            ; New beat!
            lda #0
            sta frame_count
            jsr check_spawn_note
            inc beat_count

no_new_beat:
            ; Move all notes left
            jsr update_notes

            ; Reset track colours to default
            jsr reset_track_colours

            ; Check keyboard and play sounds
            jsr check_keys

            jmp main_loop

; ----------------------------------------------------------------------------
; Initialize Notes
; ----------------------------------------------------------------------------

init_notes:
            ldx #MAX_NOTES-1
            lda #0
init_notes_loop:
            sta note_track,x
            sta note_col,x
            dex
            bpl init_notes_loop
            rts

; ----------------------------------------------------------------------------
; Check Spawn Note
; ----------------------------------------------------------------------------
; Song data is in beat order. Process all entries matching current beat,
; then return. Entries are (beat, track) pairs ending with $FF.

check_spawn_note:
            ldy #0

spawn_check_loop:
            ; Read beat number for current entry
            lda (song_pos),y
            cmp #$FF
            beq spawn_restart_song

            ; If entry beat > current beat, we're done for this beat
            cmp beat_count
            beq spawn_match         ; Equal - spawn this note
            bcs spawn_done          ; Greater - done for now (entries are ordered)

            ; Entry beat < current beat - shouldn't happen, but skip it
            jmp spawn_advance

spawn_match:
            ; Get track number (next byte)
            iny
            lda (song_pos),y
            jsr spawn_note
            dey                     ; Reset Y for next iteration

spawn_advance:
            ; Move song_pos forward by 2 bytes
            lda song_pos
            clc
            adc #2
            sta song_pos
            lda song_pos_hi
            adc #0
            sta song_pos_hi
            jmp spawn_check_loop

spawn_done:
            rts

spawn_restart_song:
            lda #<song_data
            sta song_pos
            lda #>song_data
            sta song_pos_hi
            lda #0
            sta beat_count
            rts

; ----------------------------------------------------------------------------
; Spawn Note
; ----------------------------------------------------------------------------
; Input: A = track number (1-3)

spawn_note:
            sta temp_track

            ldx #0
spawn_find_slot:
            lda note_track,x
            beq spawn_found_slot
            inx
            cpx #MAX_NOTES
            bne spawn_find_slot
            rts                 ; No empty slot

spawn_found_slot:
            lda temp_track
            sta note_track,x
            lda #NOTE_SPAWN_COL
            sta note_col,x
            jsr draw_note
            rts

; ----------------------------------------------------------------------------
; Update Notes
; ----------------------------------------------------------------------------

update_notes:
            ldx #0

update_loop:
            lda note_track,x
            beq update_next

            jsr erase_note

            dec note_col,x
            lda note_col,x
            cmp #1
            bcc update_deactivate

            jsr draw_note
            jmp update_next

update_deactivate:
            lda #0
            sta note_track,x

update_next:
            inx
            cpx #MAX_NOTES
            bne update_loop
            rts

; ----------------------------------------------------------------------------
; Draw Note
; ----------------------------------------------------------------------------
; Input: X = note index

draw_note:
            lda note_track,x
            cmp #1
            beq draw_note_t1
            cmp #2
            beq draw_note_t2
            cmp #3
            beq draw_note_t3
            rts

draw_note_t1:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK1_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK1_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            ldy #0
            lda #NOTE_CHAR
            sta (ZP_PTR),y

            lda note_col,x
            clc
            adc #<(COLRAM + TRACK1_ROW * 40)
            sta ZP_PTR
            lda #>(COLRAM + TRACK1_ROW * 40)
            adc #0
            sta ZP_PTR_HI
            lda #LIGHT_RED
            sta (ZP_PTR),y
            rts

draw_note_t2:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK2_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK2_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            ldy #0
            lda #NOTE_CHAR
            sta (ZP_PTR),y

            lda note_col,x
            clc
            adc #<(COLRAM + TRACK2_ROW * 40)
            sta ZP_PTR
            lda #>(COLRAM + TRACK2_ROW * 40)
            adc #0
            sta ZP_PTR_HI
            lda #LIGHT_GREEN
            sta (ZP_PTR),y
            rts

draw_note_t3:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK3_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK3_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            ldy #0
            lda #NOTE_CHAR
            sta (ZP_PTR),y

            lda note_col,x
            clc
            adc #<(COLRAM + TRACK3_ROW * 40)
            sta ZP_PTR
            lda #>(COLRAM + TRACK3_ROW * 40)
            adc #0
            sta ZP_PTR_HI
            lda #LIGHT_BLUE
            sta (ZP_PTR),y
            rts

; ----------------------------------------------------------------------------
; Erase Note
; ----------------------------------------------------------------------------
; Input: X = note index

erase_note:
            lda note_track,x
            cmp #1
            beq erase_note_t1
            cmp #2
            beq erase_note_t2
            cmp #3
            beq erase_note_t3
            rts

erase_note_t1:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK1_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK1_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            ldy #0
            lda #TRACK_CHAR
            sta (ZP_PTR),y

            lda note_col,x
            clc
            adc #<(COLRAM + TRACK1_ROW * 40)
            sta ZP_PTR
            lda #>(COLRAM + TRACK1_ROW * 40)
            adc #0
            sta ZP_PTR_HI
            lda #GREY
            sta (ZP_PTR),y
            rts

erase_note_t2:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK2_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK2_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            ldy #0
            lda #TRACK_CHAR
            sta (ZP_PTR),y

            lda note_col,x
            clc
            adc #<(COLRAM + TRACK2_ROW * 40)
            sta ZP_PTR
            lda #>(COLRAM + TRACK2_ROW * 40)
            adc #0
            sta ZP_PTR_HI
            lda #GREY
            sta (ZP_PTR),y
            rts

erase_note_t3:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK3_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK3_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            ldy #0
            lda #TRACK_CHAR
            sta (ZP_PTR),y

            lda note_col,x
            clc
            adc #<(COLRAM + TRACK3_ROW * 40)
            sta ZP_PTR
            lda #>(COLRAM + TRACK3_ROW * 40)
            adc #0
            sta ZP_PTR_HI
            lda #GREY
            sta (ZP_PTR),y
            rts

; ----------------------------------------------------------------------------
; Initialize Screen
; ----------------------------------------------------------------------------

init_screen:
            lda #BLACK
            sta BORDER
            sta BGCOL

            ldx #0
            lda #$20
clr_screen:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clr_screen

            ldx #0
            lda #GREY
clr_colour:
            sta COLRAM,x
            sta COLRAM+$100,x
            sta COLRAM+$200,x
            sta COLRAM+$2E8,x
            inx
            bne clr_colour

            jsr draw_tracks
            jsr draw_hit_zones
            jsr draw_labels

            rts

; ----------------------------------------------------------------------------
; Draw Tracks
; ----------------------------------------------------------------------------

draw_tracks:
            ldx #0
            lda #TRACK_CHAR
draw_t1:
            sta SCREEN + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne draw_t1

            ldx #0
draw_t2:
            sta SCREEN + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne draw_t2

            ldx #0
draw_t3:
            sta SCREEN + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne draw_t3

            rts

; ----------------------------------------------------------------------------
; Draw Hit Zones
; ----------------------------------------------------------------------------

draw_hit_zones:
            lda #$7D            ; Pipe character

            sta SCREEN + (TRACK1_ROW * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK1_ROW-1) * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK1_ROW+1) * 40) + HIT_ZONE_COL

            sta SCREEN + (TRACK2_ROW * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK2_ROW-1) * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK2_ROW+1) * 40) + HIT_ZONE_COL

            sta SCREEN + (TRACK3_ROW * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK3_ROW-1) * 40) + HIT_ZONE_COL
            sta SCREEN + ((TRACK3_ROW+1) * 40) + HIT_ZONE_COL

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

draw_labels:
            ldx #0
draw_title:
            lda title_text,x
            beq draw_title_done
            sta SCREEN + 13,x
            lda #WHITE
            sta COLRAM + 13,x
            inx
            bne draw_title
draw_title_done:

            lda #$1A            ; Z
            sta SCREEN + (TRACK1_ROW * 40)
            lda #LIGHT_RED
            sta COLRAM + (TRACK1_ROW * 40)

            lda #$18            ; X
            sta SCREEN + (TRACK2_ROW * 40)
            lda #LIGHT_GREEN
            sta COLRAM + (TRACK2_ROW * 40)

            lda #$03            ; C
            sta SCREEN + (TRACK3_ROW * 40)
            lda #LIGHT_BLUE
            sta COLRAM + (TRACK3_ROW * 40)

            ldx #0
draw_instr:
            lda instr_text,x
            beq draw_instr_done
            sta SCREEN + (23 * 40) + 3,x
            lda #GREY
            sta COLRAM + (23 * 40) + 3,x
            inx
            bne draw_instr
draw_instr_done:

            rts

title_text:
            !scr "sid symphony"
            !byte 0

instr_text:
            !scr "hit notes when they reach |"
            !byte 0

; ----------------------------------------------------------------------------
; Initialize SID
; ----------------------------------------------------------------------------

init_sid:
            ldx #$18
            lda #0
clear_sid:
            sta SID,x
            dex
            bpl clear_sid

            lda #$0F
            sta SID_VOLUME

            ; Voice 1 - High pitch, sawtooth
            lda #$00
            sta SID_V1_FREQ_LO
            lda #$1C
            sta SID_V1_FREQ_HI
            lda #$09
            sta SID_V1_AD
            lda #$00
            sta SID_V1_SR

            ; Voice 2 - Mid pitch, pulse
            lda #$00
            sta SID_V2_FREQ_LO
            lda #$0E
            sta SID_V2_FREQ_HI
            lda #$08
            sta SID_V2_PWHI
            lda #$09
            sta SID_V2_AD
            lda #$00
            sta SID_V2_SR

            ; Voice 3 - Low pitch, triangle
            lda #$00
            sta SID_V3_FREQ_LO
            lda #$07
            sta SID_V3_FREQ_HI
            lda #$09
            sta SID_V3_AD
            lda #$00
            sta SID_V3_SR

            rts

; ----------------------------------------------------------------------------
; Reset Track Colours
; ----------------------------------------------------------------------------

reset_track_colours:
            ldx #0
            lda #GREY
reset_t1:
            sta COLRAM + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne reset_t1

            ldx #0
reset_t2:
            sta COLRAM + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne reset_t2

            ldx #0
reset_t3:
            sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne reset_t3

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

            ; Redraw note colours
            jsr redraw_all_notes

            rts

; ----------------------------------------------------------------------------
; Redraw All Notes
; ----------------------------------------------------------------------------

redraw_all_notes:
            ldx #0
redraw_loop:
            lda note_track,x
            beq redraw_next
            jsr draw_note
redraw_next:
            inx
            cpx #MAX_NOTES
            bne redraw_loop
            rts

; ----------------------------------------------------------------------------
; Check Keys
; ----------------------------------------------------------------------------

check_keys:
            lda #$FD
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            bne check_x_key
            jsr play_voice1
            jsr flash_track1

check_x_key:
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$80
            bne check_c_key
            jsr play_voice2
            jsr flash_track2

check_c_key:
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            bne check_keys_done
            jsr play_voice3
            jsr flash_track3

check_keys_done:
            lda #$FF
            sta CIA1_PRA
            rts

; ----------------------------------------------------------------------------
; Play Voices
; ----------------------------------------------------------------------------

play_voice1:
            lda #$21
            sta SID_V1_CTRL
            rts

play_voice2:
            lda #$41
            sta SID_V2_CTRL
            rts

play_voice3:
            lda #$11
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Flash Tracks
; ----------------------------------------------------------------------------

flash_track1:
            ldx #0
            lda #RED
flash_t1_loop:
            sta COLRAM + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne flash_t1_loop
            lda #WHITE
            sta COLRAM + (TRACK1_ROW * 40)
            rts

flash_track2:
            ldx #0
            lda #GREEN
flash_t2_loop:
            sta COLRAM + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne flash_t2_loop
            lda #WHITE
            sta COLRAM + (TRACK2_ROW * 40)
            rts

flash_track3:
            ldx #0
            lda #BLUE
flash_t3_loop:
            sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne flash_t3_loop
            lda #WHITE
            sta COLRAM + (TRACK3_ROW * 40)
            rts

; ----------------------------------------------------------------------------
; Song Data
; ----------------------------------------------------------------------------
; Format: beat, track (1-3)
; $FF marks end of song

song_data:
            ; Simple test pattern - 4 bars at 120 BPM
            ; Bar 1
            !byte 0, 1
            !byte 2, 2
            !byte 4, 3
            !byte 6, 1

            ; Bar 2
            !byte 8, 2
            !byte 10, 3
            !byte 12, 1
            !byte 14, 2

            ; Bar 3
            !byte 16, 3
            !byte 18, 1
            !byte 20, 2
            !byte 22, 3

            ; Bar 4 - faster pattern
            !byte 24, 1
            !byte 25, 2
            !byte 26, 3
            !byte 28, 1
            !byte 29, 2
            !byte 30, 3

            !byte $FF           ; End marker

; ----------------------------------------------------------------------------
; Note Arrays
; ----------------------------------------------------------------------------

note_track:
            !fill MAX_NOTES, 0

note_col:
            !fill MAX_NOTES, 0

; ============================================================================
; SID SYMPHONY - Unit 3: Making It Your Own
; ============================================================================
; Customise the game to make it yours. Change the SID voices, pick your own
; colours, experiment with waveforms and ADSR. Learn the internals by
; modifying them and hearing/seeing the results.
;
; Controls: Z = Track 1 (high), X = Track 2 (mid), C = Track 3 (low)
; ============================================================================

; ============================================================================
; CUSTOMISATION SECTION - Change these values and reassemble!
; ============================================================================

; --- SID Voice Settings ---
; Waveforms: $11=triangle, $21=sawtooth, $41=pulse, $81=noise
VOICE1_WAVE = $21               ; Sawtooth - bright, buzzy
VOICE2_WAVE = $41               ; Pulse - hollow, reedy
VOICE3_WAVE = $11               ; Triangle - soft, mellow

; Frequencies (higher = higher pitch)
; Common notes: $07=C3, $0E=C4, $1C=C5, $38=C6
VOICE1_FREQ = $1C               ; High pitch (C5)
VOICE2_FREQ = $0E               ; Mid pitch (C4)
VOICE3_FREQ = $07               ; Low pitch (C3)

; ADSR - Attack/Decay/Sustain/Release
; Attack: 0-15 (0=2ms, 15=8s)   Decay: 0-15 (0=6ms, 15=24s)
; Sustain: 0-15 (volume level)  Release: 0-15 (0=6ms, 15=24s)
VOICE_AD    = $09               ; Attack=0 (instant), Decay=9 (medium)
VOICE_SR    = $00               ; Sustain=0 (none), Release=0 (instant)

; Pulse width (only affects pulse wave, $41)
PULSE_WIDTH = $08               ; $08 = 50% duty cycle (square wave)

; --- Visual Settings ---
; Colours: 0=black, 1=white, 2=red, 3=cyan, 4=purple, 5=green
;          6=blue, 7=yellow, 8=orange, 9=brown, 10=light red
;          11=dark grey, 12=grey, 13=light green, 14=light blue, 15=light grey

BORDER_COL  = 6                 ; Blue border
BG_COL      = 0                 ; Black background

TRACK1_NOTE_COL = 10            ; Light red notes on track 1
TRACK2_NOTE_COL = 13            ; Light green notes on track 2
TRACK3_NOTE_COL = 14            ; Light blue notes on track 3

TRACK_LINE_COL = 11             ; Dark grey track lines
HIT_ZONE_COL = 7                ; Yellow hit zone

; Track flash colours (when key pressed)
FLASH1_COL  = 2                 ; Red flash for track 1
FLASH2_COL  = 5                 ; Green flash for track 2
FLASH3_COL  = 6                 ; Blue flash for track 3

; ============================================================================
; END OF CUSTOMISATION - Code below uses the settings above
; ============================================================================

; ----------------------------------------------------------------------------
; Memory Addresses
; ----------------------------------------------------------------------------

SCREEN      = $0400
COLRAM      = $D800
BORDER      = $D020
BGCOL       = $D021

; SID registers
SID         = $D400
SID_V1_FREQ_LO = $D400
SID_V1_FREQ_HI = $D401
SID_V1_PWLO = $D402
SID_V1_PWHI = $D403
SID_V1_CTRL = $D404
SID_V1_AD   = $D405
SID_V1_SR   = $D406

SID_V2_FREQ_LO = $D407
SID_V2_FREQ_HI = $D408
SID_V2_PWLO = $D409
SID_V2_PWHI = $D40A
SID_V2_CTRL = $D40B
SID_V2_AD   = $D40C
SID_V2_SR   = $D40D

SID_V3_FREQ_LO = $D40E
SID_V3_FREQ_HI = $D40F
SID_V3_PWLO = $D410
SID_V3_PWHI = $D411
SID_V3_CTRL = $D412
SID_V3_AD   = $D413
SID_V3_SR   = $D414

SID_VOLUME  = $D418

; CIA keyboard
CIA1_PRA    = $DC00
CIA1_PRB    = $DC01

; Track positions
TRACK1_ROW  = 8
TRACK2_ROW  = 12
TRACK3_ROW  = 16

; Hit zone column
HIT_ZONE_COLUMN = 3

; Note settings
NOTE_CHAR   = $57               ; Filled dot character
TRACK_CHAR  = $2D               ; Minus character
MAX_NOTES   = 8
NOTE_SPAWN_COL = 37

; Timing
FRAMES_PER_BEAT = 25

; Zero page
ZP_PTR      = $FB
ZP_PTR_HI   = $FC

; Variables
frame_count = $02
beat_count  = $03
song_pos    = $04
song_pos_hi = $05
temp_track  = $06

; ----------------------------------------------------------------------------
; BASIC Stub
; ----------------------------------------------------------------------------

            * = $0801

            !byte $0C, $08
            !byte $0A, $00
            !byte $9E
            !text "2064"
            !byte $00
            !byte $00, $00

; ----------------------------------------------------------------------------
; Main Program
; ----------------------------------------------------------------------------

            * = $0810

start:
            jsr init_screen
            jsr init_sid
            jsr init_notes

            lda #<song_data
            sta song_pos
            lda #>song_data
            sta song_pos_hi

            lda #0
            sta frame_count
            sta beat_count

main_loop:
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            inc frame_count
            lda frame_count
            cmp #FRAMES_PER_BEAT
            bcc no_new_beat

            lda #0
            sta frame_count
            jsr check_spawn_note
            inc beat_count

no_new_beat:
            jsr update_notes
            jsr reset_track_colours
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

check_spawn_note:
            ldy #0

spawn_check_loop:
            lda (song_pos),y
            cmp #$FF
            beq spawn_restart_song

            cmp beat_count
            beq spawn_match
            bcs spawn_done

            jmp spawn_advance

spawn_match:
            iny
            lda (song_pos),y
            jsr spawn_note
            dey

spawn_advance:
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

spawn_note:
            sta temp_track

            ldx #0
spawn_find_slot:
            lda note_track,x
            beq spawn_found_slot
            inx
            cpx #MAX_NOTES
            bne spawn_find_slot
            rts

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
            lda #TRACK1_NOTE_COL
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
            lda #TRACK2_NOTE_COL
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
            lda #TRACK3_NOTE_COL
            sta (ZP_PTR),y
            rts

; ----------------------------------------------------------------------------
; Erase Note
; ----------------------------------------------------------------------------

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
            lda #TRACK_LINE_COL
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
            lda #TRACK_LINE_COL
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
            lda #TRACK_LINE_COL
            sta (ZP_PTR),y
            rts

; ----------------------------------------------------------------------------
; Initialize Screen
; ----------------------------------------------------------------------------

init_screen:
            lda #BORDER_COL
            sta BORDER
            lda #BG_COL
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
            lda #TRACK_LINE_COL
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
            lda #$7D

            sta SCREEN + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK1_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK1_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta SCREEN + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK2_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK2_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta SCREEN + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK3_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK3_ROW+1) * 40) + HIT_ZONE_COLUMN

            lda #HIT_ZONE_COL
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK1_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK1_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK2_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK2_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK3_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK3_ROW+1) * 40) + HIT_ZONE_COLUMN

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
            lda #1              ; White
            sta COLRAM + 13,x
            inx
            bne draw_title
draw_title_done:

            lda #$1A            ; Z
            sta SCREEN + (TRACK1_ROW * 40)
            lda #TRACK1_NOTE_COL
            sta COLRAM + (TRACK1_ROW * 40)

            lda #$18            ; X
            sta SCREEN + (TRACK2_ROW * 40)
            lda #TRACK2_NOTE_COL
            sta COLRAM + (TRACK2_ROW * 40)

            lda #$03            ; C
            sta SCREEN + (TRACK3_ROW * 40)
            lda #TRACK3_NOTE_COL
            sta COLRAM + (TRACK3_ROW * 40)

            ldx #0
draw_instr:
            lda instr_text,x
            beq draw_instr_done
            sta SCREEN + (23 * 40) + 8,x
            lda #TRACK_LINE_COL
            sta COLRAM + (23 * 40) + 8,x
            inx
            bne draw_instr
draw_instr_done:

            rts

title_text:
            !scr "sid symphony"
            !byte 0

instr_text:
            !scr "customise me!"
            !byte 0

; ----------------------------------------------------------------------------
; Initialize SID - Uses customisation constants
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

            ; Voice 1 - uses VOICE1_* constants
            lda #$00
            sta SID_V1_FREQ_LO
            lda #VOICE1_FREQ
            sta SID_V1_FREQ_HI
            lda #PULSE_WIDTH
            sta SID_V1_PWHI
            lda #VOICE_AD
            sta SID_V1_AD
            lda #VOICE_SR
            sta SID_V1_SR

            ; Voice 2 - uses VOICE2_* constants
            lda #$00
            sta SID_V2_FREQ_LO
            lda #VOICE2_FREQ
            sta SID_V2_FREQ_HI
            lda #PULSE_WIDTH
            sta SID_V2_PWHI
            lda #VOICE_AD
            sta SID_V2_AD
            lda #VOICE_SR
            sta SID_V2_SR

            ; Voice 3 - uses VOICE3_* constants
            lda #$00
            sta SID_V3_FREQ_LO
            lda #VOICE3_FREQ
            sta SID_V3_FREQ_HI
            lda #PULSE_WIDTH
            sta SID_V3_PWHI
            lda #VOICE_AD
            sta SID_V3_AD
            lda #VOICE_SR
            sta SID_V3_SR

            rts

; ----------------------------------------------------------------------------
; Reset Track Colours
; ----------------------------------------------------------------------------

reset_track_colours:
            ldx #0
            lda #TRACK_LINE_COL
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
            lda #TRACK1_NOTE_COL
            sta COLRAM + (TRACK1_ROW * 40)
            lda #TRACK2_NOTE_COL
            sta COLRAM + (TRACK2_ROW * 40)
            lda #TRACK3_NOTE_COL
            sta COLRAM + (TRACK3_ROW * 40)

            ; Restore hit zone colours
            lda #HIT_ZONE_COL
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN

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
; Play Voices - Uses customisation waveforms
; ----------------------------------------------------------------------------

play_voice1:
            lda #VOICE1_WAVE
            ora #$01            ; Add gate bit
            sta SID_V1_CTRL
            rts

play_voice2:
            lda #VOICE2_WAVE
            ora #$01
            sta SID_V2_CTRL
            rts

play_voice3:
            lda #VOICE3_WAVE
            ora #$01
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Flash Tracks - Uses customisation colours
; ----------------------------------------------------------------------------

flash_track1:
            ldx #0
            lda #FLASH1_COL
flash_t1_loop:
            sta COLRAM + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne flash_t1_loop
            lda #1              ; White label
            sta COLRAM + (TRACK1_ROW * 40)
            rts

flash_track2:
            ldx #0
            lda #FLASH2_COL
flash_t2_loop:
            sta COLRAM + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne flash_t2_loop
            lda #1
            sta COLRAM + (TRACK2_ROW * 40)
            rts

flash_track3:
            ldx #0
            lda #FLASH3_COL
flash_t3_loop:
            sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne flash_t3_loop
            lda #1
            sta COLRAM + (TRACK3_ROW * 40)
            rts

; ----------------------------------------------------------------------------
; Song Data
; ----------------------------------------------------------------------------

song_data:
            !byte 0, 1
            !byte 2, 2
            !byte 4, 3
            !byte 6, 1

            !byte 8, 2
            !byte 10, 3
            !byte 12, 1
            !byte 14, 2

            !byte 16, 3
            !byte 18, 1
            !byte 20, 2
            !byte 22, 3

            !byte 24, 1
            !byte 25, 2
            !byte 26, 3
            !byte 28, 1
            !byte 29, 2
            !byte 30, 3

            !byte $FF

; ----------------------------------------------------------------------------
; Note Arrays
; ----------------------------------------------------------------------------

note_track:
            !fill MAX_NOTES, 0

note_col:
            !fill MAX_NOTES, 0

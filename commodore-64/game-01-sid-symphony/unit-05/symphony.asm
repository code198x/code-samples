; ============================================================================
; SID SYMPHONY - Unit 5: Hit Detection
; ============================================================================
; Detect when keypresses match notes in the hit zone. Press the right key at
; the right time to hit notes and hear the SID play. Wrong timing does nothing.
;
; Controls: Z = Track 1 (high), X = Track 2 (mid), C = Track 3 (low)
; ============================================================================

; ============================================================================
; CUSTOMISATION SECTION
; ============================================================================

; SID Voice Settings
VOICE1_WAVE = $21               ; Sawtooth
VOICE2_WAVE = $41               ; Pulse
VOICE3_WAVE = $11               ; Triangle

VOICE1_FREQ = $1C               ; High pitch
VOICE2_FREQ = $0E               ; Mid pitch
VOICE3_FREQ = $07               ; Low pitch

VOICE_AD    = $09               ; Attack=0, Decay=9
VOICE_SR    = $00               ; Sustain=0, Release=0
PULSE_WIDTH = $08               ; 50% duty cycle

; Visual Settings
BORDER_COL  = 0                 ; Black border
BG_COL      = 0                 ; Black background

TRACK1_NOTE_COL = 10            ; Light red
TRACK2_NOTE_COL = 13            ; Light green
TRACK3_NOTE_COL = 14            ; Light blue

TRACK_LINE_COL = 11             ; Dark grey
HIT_ZONE_COL = 7                ; Yellow

FLASH1_COL  = 2                 ; Red
FLASH2_COL  = 5                 ; Green
FLASH3_COL  = 6                 ; Blue

HIT_COL     = 1                 ; White - flash on successful hit

; ============================================================================
; HIT DETECTION SETTINGS
; ============================================================================

; Hit zone boundaries (column positions)
HIT_ZONE_MIN = 2                ; Left edge of hit zone
HIT_ZONE_MAX = 5                ; Right edge of hit zone
HIT_ZONE_CENTRE = 3             ; Perfect hit position

; ============================================================================
; MEMORY MAP
; ============================================================================

SCREEN      = $0400             ; Screen memory
COLRAM      = $D800             ; Colour RAM
BORDER      = $D020             ; Border colour
BGCOL       = $D021             ; Background colour
CHARPTR     = $D018             ; Character memory pointer

CHARSET     = $3000             ; Custom character set location

; SID registers
SID         = $D400
SID_V1_FREQ_LO = $D400
SID_V1_FREQ_HI = $D401
SID_V1_PWHI = $D403
SID_V1_CTRL = $D404
SID_V1_AD   = $D405
SID_V1_SR   = $D406

SID_V2_FREQ_LO = $D407
SID_V2_FREQ_HI = $D408
SID_V2_PWHI = $D40A
SID_V2_CTRL = $D40B
SID_V2_AD   = $D40C
SID_V2_SR   = $D40D

SID_V3_FREQ_LO = $D40E
SID_V3_FREQ_HI = $D40F
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

; Hit zone
HIT_ZONE_COLUMN = 3

; Custom character codes
CHAR_NOTE   = 128               ; Filled arrow/circle for notes
CHAR_TRACK  = 129               ; Thin horizontal line for tracks
CHAR_HITZONE = 130              ; Vertical bar for hit zone
CHAR_SPACE  = 32                ; Space

; Note settings
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
key_pressed = $07               ; Which track key was pressed (0=none)

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
            jsr copy_charset    ; Copy ROM charset and add custom chars
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
; Copy Character Set from ROM to RAM
; ----------------------------------------------------------------------------

copy_charset:
            sei

            lda $01
            pha
            and #$FB
            sta $01

            ldx #0
copy_loop:
            lda $D000,x
            sta CHARSET,x
            lda $D100,x
            sta CHARSET+$100,x
            lda $D200,x
            sta CHARSET+$200,x
            lda $D300,x
            sta CHARSET+$300,x
            lda $D400,x
            sta CHARSET+$400,x
            lda $D500,x
            sta CHARSET+$500,x
            lda $D600,x
            sta CHARSET+$600,x
            lda $D700,x
            sta CHARSET+$700,x
            inx
            bne copy_loop

            pla
            sta $01

            cli

            jsr define_custom_chars

            lda #$1C
            sta CHARPTR

            rts

; ----------------------------------------------------------------------------
; Define Custom Characters
; ----------------------------------------------------------------------------

define_custom_chars:
            ; Character 128: Note (filled chevron pointing left)
            lda #%00000110
            sta CHARSET + (CHAR_NOTE * 8) + 0
            lda #%00011110
            sta CHARSET + (CHAR_NOTE * 8) + 1
            lda #%01111110
            sta CHARSET + (CHAR_NOTE * 8) + 2
            lda #%11111110
            sta CHARSET + (CHAR_NOTE * 8) + 3
            lda #%11111110
            sta CHARSET + (CHAR_NOTE * 8) + 4
            lda #%01111110
            sta CHARSET + (CHAR_NOTE * 8) + 5
            lda #%00011110
            sta CHARSET + (CHAR_NOTE * 8) + 6
            lda #%00000110
            sta CHARSET + (CHAR_NOTE * 8) + 7

            ; Character 129: Track line (centered horizontal line)
            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 0
            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 1
            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 2
            lda #%11111111
            sta CHARSET + (CHAR_TRACK * 8) + 3
            lda #%11111111
            sta CHARSET + (CHAR_TRACK * 8) + 4
            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 5
            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 6
            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 7

            ; Character 130: Hit zone (vertical bars)
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 0
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 1
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 2
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 3
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 4
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 5
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 6
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 7

            rts

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
            lda #CHAR_NOTE
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
            lda #CHAR_NOTE
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
            lda #CHAR_NOTE
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
; Erase Note - Restores track line character
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
            lda #CHAR_TRACK
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
            lda #CHAR_TRACK
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
            lda #CHAR_TRACK
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
            lda #CHAR_SPACE
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
            lda #CHAR_TRACK
            ldx #0
draw_t1:
            sta SCREEN + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne draw_t1

            lda #CHAR_TRACK
            ldx #0
draw_t2:
            sta SCREEN + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne draw_t2

            lda #CHAR_TRACK
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
            lda #CHAR_HITZONE

            sta SCREEN + ((TRACK1_ROW-2) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK1_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK1_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta SCREEN + ((TRACK2_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK2_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta SCREEN + ((TRACK3_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK3_ROW+1) * 40) + HIT_ZONE_COLUMN
            sta SCREEN + ((TRACK3_ROW+2) * 40) + HIT_ZONE_COLUMN

            lda #HIT_ZONE_COL
            sta COLRAM + ((TRACK1_ROW-2) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK1_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK1_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta COLRAM + ((TRACK2_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK2_ROW+1) * 40) + HIT_ZONE_COLUMN

            sta COLRAM + ((TRACK3_ROW-1) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK3_ROW+1) * 40) + HIT_ZONE_COLUMN
            sta COLRAM + ((TRACK3_ROW+2) * 40) + HIT_ZONE_COLUMN

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
            lda #1
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
            sta SCREEN + (23 * 40) + 6,x
            lda #TRACK_LINE_COL
            sta COLRAM + (23 * 40) + 6,x
            inx
            bne draw_instr
draw_instr_done:

            rts

title_text:
            !scr "sid symphony"
            !byte 0

instr_text:
            !scr "hit detection active"
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

            lda #TRACK1_NOTE_COL
            sta COLRAM + (TRACK1_ROW * 40)
            lda #TRACK2_NOTE_COL
            sta COLRAM + (TRACK2_ROW * 40)
            lda #TRACK3_NOTE_COL
            sta COLRAM + (TRACK3_ROW * 40)

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
; Check Keys - Now with hit detection
; ----------------------------------------------------------------------------
; Checks if a key is pressed and if there's a matching note in the hit zone.
; Only plays sound and removes note on a successful hit.

check_keys:
            ; Check Z key (track 1)
            lda #$FD
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            bne check_x_key

            ; Z pressed - check for hit on track 1
            lda #1
            sta key_pressed
            jsr check_hit
            bcc check_x_key     ; No hit - don't play sound
            jsr play_voice1
            jsr flash_track1_hit

check_x_key:
            ; Check X key (track 2)
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$80
            bne check_c_key

            ; X pressed - check for hit on track 2
            lda #2
            sta key_pressed
            jsr check_hit
            bcc check_c_key     ; No hit - don't play sound
            jsr play_voice2
            jsr flash_track2_hit

check_c_key:
            ; Check C key (track 3)
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            bne check_keys_done

            ; C pressed - check for hit on track 3
            lda #3
            sta key_pressed
            jsr check_hit
            bcc check_keys_done ; No hit - don't play sound
            jsr play_voice3
            jsr flash_track3_hit

check_keys_done:
            lda #$FF
            sta CIA1_PRA
            rts

; ----------------------------------------------------------------------------
; Check Hit - Find a note in the hit zone for the pressed track
; ----------------------------------------------------------------------------
; Input: key_pressed = track number (1-3)
; Output: Carry set if hit found, X = note index
;         Carry clear if no hit
; Side effect: Removes hit note from play

check_hit:
            ldx #0

check_hit_loop:
            ; Check if this note slot is active
            lda note_track,x
            beq check_hit_next  ; Empty slot - skip

            ; Check if note is on the pressed track
            cmp key_pressed
            bne check_hit_next  ; Wrong track - skip

            ; Check if note is in the hit zone
            lda note_col,x
            cmp #HIT_ZONE_MIN
            bcc check_hit_next  ; Too far left - skip
            cmp #HIT_ZONE_MAX+1
            bcs check_hit_next  ; Too far right - skip

            ; HIT! Note is in zone on correct track
            ; Erase the note from screen
            jsr erase_note

            ; Deactivate the note
            lda #0
            sta note_track,x

            ; Return with carry set (hit found)
            sec
            rts

check_hit_next:
            inx
            cpx #MAX_NOTES
            bne check_hit_loop

            ; No hit found - return with carry clear
            clc
            rts

; ----------------------------------------------------------------------------
; Play Voices
; ----------------------------------------------------------------------------

play_voice1:
            lda #VOICE1_WAVE
            ora #$01
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
; Flash Tracks on Hit - White flash for successful hits
; ----------------------------------------------------------------------------

flash_track1_hit:
            ldx #0
            lda #HIT_COL        ; White for hits
flash_t1h_loop:
            sta COLRAM + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne flash_t1h_loop
            lda #1
            sta COLRAM + (TRACK1_ROW * 40)
            rts

flash_track2_hit:
            ldx #0
            lda #HIT_COL
flash_t2h_loop:
            sta COLRAM + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne flash_t2h_loop
            lda #1
            sta COLRAM + (TRACK2_ROW * 40)
            rts

flash_track3_hit:
            ldx #0
            lda #HIT_COL
flash_t3h_loop:
            sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne flash_t3h_loop
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

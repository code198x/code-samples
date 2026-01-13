; ============================================================================
; SID SYMPHONY - Unit 8: Health System
; ============================================================================
; A health meter that grows on hits and shrinks on misses. The game can be
; lost. Stakes make success meaningful.
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

; Miss sound settings
MISS_FREQ   = $08               ; Low rumble
MISS_WAVE   = $81               ; Noise waveform
MISS_AD     = $00               ; Instant attack, no decay
MISS_SR     = $90               ; High sustain, fast release

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
PERFECT_COL = 1                 ; White - perfect hit border flash
GOOD_COL    = 7                 ; Yellow - good hit border flash
MISS_COL    = 2                 ; Red - miss border flash

HEALTH_COL  = 5                 ; Green for health bar

; ============================================================================
; SCORING SETTINGS
; ============================================================================

PERFECT_SCORE = 100
GOOD_SCORE    = 50

; ============================================================================
; HEALTH SETTINGS
; ============================================================================

HEALTH_MAX    = 64              ; Maximum health
HEALTH_START  = 32              ; Starting health (half)
HEALTH_PERFECT = 4              ; Health gained on perfect hit
HEALTH_GOOD   = 2               ; Health gained on good hit
HEALTH_MISS   = 8               ; Health lost on miss

; ============================================================================
; HIT DETECTION SETTINGS
; ============================================================================

HIT_ZONE_MIN = 2
HIT_ZONE_MAX = 5
HIT_ZONE_CENTRE = 3

; ============================================================================
; MEMORY MAP
; ============================================================================

SCREEN      = $0400
COLRAM      = $D800
BORDER      = $D020
BGCOL       = $D021
CHARPTR     = $D018

CHARSET     = $3000

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

; Health bar position
HEALTH_ROW  = 23

; Hit zone
HIT_ZONE_COLUMN = 3

; Custom character codes
CHAR_NOTE   = 128
CHAR_TRACK  = 129
CHAR_HITZONE = 130
CHAR_SPACE  = 32
CHAR_BAR_FULL = 131
CHAR_BAR_EMPTY = 132

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
key_pressed = $07
hit_quality = $08
border_flash = $09
miss_track  = $0A
game_over   = $0B               ; Non-zero when game ended

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
            jsr copy_charset
            jsr init_screen
            jsr init_sid
            jsr init_notes
            jsr init_score
            jsr init_health

            lda #<song_data
            sta song_pos
            lda #>song_data
            sta song_pos_hi

            lda #0
            sta frame_count
            sta beat_count
            sta border_flash
            sta game_over

main_loop:
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            ; Check if game is over
            lda game_over
            bne main_loop       ; Freeze if game over

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
            jsr update_border_flash
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
            ; Note character - diamond shape
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

            ; Track character - horizontal line
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

            ; Hit zone character - vertical bars
            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 0
            sta CHARSET + (CHAR_HITZONE * 8) + 1
            sta CHARSET + (CHAR_HITZONE * 8) + 2
            sta CHARSET + (CHAR_HITZONE * 8) + 3
            sta CHARSET + (CHAR_HITZONE * 8) + 4
            sta CHARSET + (CHAR_HITZONE * 8) + 5
            sta CHARSET + (CHAR_HITZONE * 8) + 6
            sta CHARSET + (CHAR_HITZONE * 8) + 7

            ; Health bar full - solid block
            lda #%11111111
            sta CHARSET + (CHAR_BAR_FULL * 8) + 0
            sta CHARSET + (CHAR_BAR_FULL * 8) + 1
            sta CHARSET + (CHAR_BAR_FULL * 8) + 2
            sta CHARSET + (CHAR_BAR_FULL * 8) + 3
            sta CHARSET + (CHAR_BAR_FULL * 8) + 4
            sta CHARSET + (CHAR_BAR_FULL * 8) + 5
            sta CHARSET + (CHAR_BAR_FULL * 8) + 6
            sta CHARSET + (CHAR_BAR_FULL * 8) + 7

            ; Health bar empty - outline
            lda #%11111111
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 0
            lda #%10000001
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 1
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 2
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 3
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 4
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 5
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 6
            lda #%11111111
            sta CHARSET + (CHAR_BAR_EMPTY * 8) + 7

            rts

; ----------------------------------------------------------------------------
; Initialize Health
; ----------------------------------------------------------------------------

init_health:
            lda #HEALTH_START
            sta health
            jsr display_health
            rts

; ----------------------------------------------------------------------------
; Initialize Score
; ----------------------------------------------------------------------------

init_score:
            lda #0
            sta score_lo
            sta score_hi
            sta miss_count
            jsr display_score
            jsr display_misses
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
            bcc update_miss

            jsr draw_note
            jmp update_next

update_miss:
            lda note_track,x
            sta miss_track
            lda #0
            sta note_track,x
            jsr handle_miss

update_next:
            inx
            cpx #MAX_NOTES
            bne update_loop
            rts

; ----------------------------------------------------------------------------
; Handle Miss
; ----------------------------------------------------------------------------

handle_miss:
            inc miss_count

            jsr play_miss_sound

            lda #MISS_COL
            sta BORDER
            lda #8
            sta border_flash

            jsr display_misses

            ; Decrease health
            jsr decrease_health

            rts

; ----------------------------------------------------------------------------
; Decrease Health - Subtract HEALTH_MISS, clamp at 0
; ----------------------------------------------------------------------------

decrease_health:
            lda health
            sec
            sbc #HEALTH_MISS
            bcc health_zero     ; Underflow - set to 0
            sta health
            jsr display_health
            jsr check_game_over
            rts

health_zero:
            lda #0
            sta health
            jsr display_health
            jsr check_game_over
            rts

; ----------------------------------------------------------------------------
; Increase Health - Add amount, clamp at HEALTH_MAX
; Input: A = amount to add
; ----------------------------------------------------------------------------

increase_health:
            clc
            adc health
            cmp #HEALTH_MAX
            bcc health_ok
            lda #HEALTH_MAX     ; Clamp to max
health_ok:
            sta health
            jsr display_health
            rts

; ----------------------------------------------------------------------------
; Check Game Over
; ----------------------------------------------------------------------------

check_game_over:
            lda health
            bne not_game_over

            ; Game over!
            lda #1
            sta game_over

            ; Display game over message
            jsr show_game_over

not_game_over:
            rts

; ----------------------------------------------------------------------------
; Show Game Over
; ----------------------------------------------------------------------------

show_game_over:
            ; Display "GAME OVER" in centre of screen
            ldx #0
game_over_loop:
            lda game_over_text,x
            beq game_over_done
            sta SCREEN + (12 * 40) + 15,x
            lda #2              ; Red
            sta COLRAM + (12 * 40) + 15,x
            inx
            jmp game_over_loop
game_over_done:

            ; Flash border red
            lda #2
            sta BORDER

            rts

game_over_text:
            !scr "game over"
            !byte 0

; ----------------------------------------------------------------------------
; Display Health - 8 character bar
; ----------------------------------------------------------------------------

display_health:
            ; Health ranges 0-64, displayed as 8 characters
            ; Each character represents 8 health points

            lda health
            lsr                 ; Divide by 8
            lsr
            lsr
            sta temp_health     ; Full bars to draw

            ; Draw full bars
            ldx #0
            lda temp_health
            beq draw_empty_bars

draw_full_bars:
            lda #CHAR_BAR_FULL
            sta SCREEN + (HEALTH_ROW * 40) + 16,x
            lda #HEALTH_COL
            sta COLRAM + (HEALTH_ROW * 40) + 16,x
            inx
            cpx temp_health
            bne draw_full_bars

            ; Draw empty bars for remainder
draw_empty_bars:
            cpx #8
            beq health_done
            lda #CHAR_BAR_EMPTY
            sta SCREEN + (HEALTH_ROW * 40) + 16,x
            lda #11             ; Dark grey
            sta COLRAM + (HEALTH_ROW * 40) + 16,x
            inx
            jmp draw_empty_bars

health_done:
            rts

temp_health: !byte 0

; ----------------------------------------------------------------------------
; Play Miss Sound
; ----------------------------------------------------------------------------

play_miss_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #MISS_FREQ
            sta SID_V3_FREQ_HI
            lda #MISS_AD
            sta SID_V3_AD
            lda #MISS_SR
            sta SID_V3_SR
            lda #MISS_WAVE
            ora #$01
            sta SID_V3_CTRL
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
            ; Draw "SCORE:" label
            ldx #0
draw_score_label:
            lda score_label,x
            beq draw_score_label_done
            sta SCREEN + 1,x
            lda #1
            sta COLRAM + 1,x
            inx
            bne draw_score_label
draw_score_label_done:

            ; Draw "MISS:" label
            ldx #0
draw_miss_label:
            lda miss_label,x
            beq draw_miss_label_done
            sta SCREEN + 15,x
            lda #2
            sta COLRAM + 15,x
            inx
            bne draw_miss_label
draw_miss_label_done:

            ; Draw title
            ldx #0
draw_title:
            lda title_text,x
            beq draw_title_done
            sta SCREEN + 27,x
            lda #1
            sta COLRAM + 27,x
            inx
            bne draw_title
draw_title_done:

            ; Draw "HEALTH:" label
            ldx #0
draw_health_label:
            lda health_label,x
            beq draw_health_label_done
            sta SCREEN + (HEALTH_ROW * 40) + 8,x
            lda #5              ; Green
            sta COLRAM + (HEALTH_ROW * 40) + 8,x
            inx
            bne draw_health_label
draw_health_label_done:

            ; Track labels
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

            rts

score_label:
            !scr "score:"
            !byte 0

miss_label:
            !scr "miss:"
            !byte 0

title_text:
            !scr "sid symphony"
            !byte 0

health_label:
            !scr "health:"
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
; Update Border Flash
; ----------------------------------------------------------------------------

update_border_flash:
            lda border_flash
            beq flash_done
            dec border_flash
            bne flash_done
            lda #BORDER_COL
            sta BORDER
flash_done:
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

            lda #1
            sta key_pressed
            jsr check_hit
            bcc check_x_key
            jsr play_voice1
            jsr flash_track1_hit
            jsr award_points

check_x_key:
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$80
            bne check_c_key

            lda #2
            sta key_pressed
            jsr check_hit
            bcc check_c_key
            jsr play_voice2
            jsr flash_track2_hit
            jsr award_points

check_c_key:
            lda #$FB
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            bne check_keys_done

            lda #3
            sta key_pressed
            jsr check_hit
            bcc check_keys_done
            jsr play_voice3
            jsr flash_track3_hit
            jsr award_points

check_keys_done:
            lda #$FF
            sta CIA1_PRA
            rts

; ----------------------------------------------------------------------------
; Check Hit
; ----------------------------------------------------------------------------

check_hit:
            ldx #0

check_hit_loop:
            lda note_track,x
            beq check_hit_next

            cmp key_pressed
            bne check_hit_next

            lda note_col,x
            cmp #HIT_ZONE_MIN
            bcc check_hit_next
            cmp #HIT_ZONE_MAX+1
            bcs check_hit_next

            cmp #HIT_ZONE_CENTRE
            bcc hit_good
            cmp #HIT_ZONE_CENTRE+2
            bcs hit_good

            lda #2
            sta hit_quality
            jmp hit_found

hit_good:
            lda #1
            sta hit_quality

hit_found:
            jsr erase_note
            lda #0
            sta note_track,x
            sec
            rts

check_hit_next:
            inx
            cpx #MAX_NOTES
            bne check_hit_loop

            lda #0
            sta hit_quality
            clc
            rts

; ----------------------------------------------------------------------------
; Award Points
; ----------------------------------------------------------------------------

award_points:
            lda hit_quality
            cmp #2
            beq award_perfect

            lda score_lo
            clc
            adc #GOOD_SCORE
            sta score_lo
            lda score_hi
            adc #0
            sta score_hi

            lda #GOOD_COL
            sta BORDER
            lda #4
            sta border_flash

            ; Increase health for good hit
            lda #HEALTH_GOOD
            jsr increase_health

            jmp award_done

award_perfect:
            lda score_lo
            clc
            adc #PERFECT_SCORE
            sta score_lo
            lda score_hi
            adc #0
            sta score_hi

            lda #PERFECT_COL
            sta BORDER
            lda #6
            sta border_flash

            ; Increase health for perfect hit
            lda #HEALTH_PERFECT
            jsr increase_health

award_done:
            jsr display_score
            rts

; ----------------------------------------------------------------------------
; Display Score
; ----------------------------------------------------------------------------

display_score:
            lda score_lo
            sta work_lo
            lda score_hi
            sta work_hi

            ldx #0
div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc done_10000
            sta work_hi
            sty work_lo
            inx
            jmp div_10000
done_10000:
            txa
            ora #$30
            sta SCREEN + 8

            ldx #0
div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc done_1000
            sta work_hi
            sty work_lo
            inx
            jmp div_1000
done_1000:
            txa
            ora #$30
            sta SCREEN + 9

            ldx #0
div_100:
            lda work_lo
            sec
            sbc #100
            bcc done_100
            sta work_lo
            inx
            jmp div_100
done_100:
            txa
            ora #$30
            sta SCREEN + 10

            ldx #0
div_10:
            lda work_lo
            sec
            sbc #10
            bcc done_10
            sta work_lo
            inx
            jmp div_10
done_10:
            txa
            ora #$30
            sta SCREEN + 11

            lda work_lo
            ora #$30
            sta SCREEN + 12

            lda #7
            sta COLRAM + 8
            sta COLRAM + 9
            sta COLRAM + 10
            sta COLRAM + 11
            sta COLRAM + 12

            rts

; ----------------------------------------------------------------------------
; Display Misses
; ----------------------------------------------------------------------------

display_misses:
            lda miss_count

            ldx #0
miss_div_10:
            cmp #10
            bcc miss_done_10
            sec
            sbc #10
            inx
            jmp miss_div_10
miss_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + 21
            pla
            ora #$30
            sta SCREEN + 22

            lda #2
            sta COLRAM + 21
            sta COLRAM + 22

            rts

work_lo:    !byte 0
work_hi:    !byte 0

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
; Flash Tracks on Hit
; ----------------------------------------------------------------------------

flash_track1_hit:
            ldx #0
            lda #HIT_COL
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

; ----------------------------------------------------------------------------
; Game Variables
; ----------------------------------------------------------------------------

score_lo:   !byte 0
score_hi:   !byte 0
miss_count: !byte 0
health:     !byte 0

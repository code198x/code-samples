; ============================================================================
; SID SYMPHONY - Unit 15: Sound Polish
; ============================================================================
; Distinct sounds for hit qualities. Perfect hits sound bright and satisfying.
; Good hits are positive but lesser. Miss sounds are harsh. Menu sounds click.
;
; Controls: Z = Track 1 (high), X = Track 2 (mid), C = Track 3 (low)
;           Fire = Start game from title screen
; ============================================================================

; ============================================================================
; CUSTOMISATION SECTION
; ============================================================================

; SID Voice Settings (for note playback)
VOICE1_WAVE = $21               ; Sawtooth for track 1
VOICE2_WAVE = $41               ; Pulse for track 2
VOICE3_WAVE = $11               ; Triangle for track 3

VOICE1_FREQ = $1C
VOICE2_FREQ = $0E
VOICE3_FREQ = $07

VOICE_AD    = $09               ; Attack=0, Decay=9
VOICE_SR    = $00               ; Sustain=0, Release=0
PULSE_WIDTH = $08

; Perfect hit sound - bright and satisfying
PERFECT_SFX_FREQ  = $30         ; Higher pitch
PERFECT_SFX_WAVE  = $21         ; Sawtooth (bright)
PERFECT_SFX_AD    = $08         ; Fast attack, medium decay
PERFECT_SFX_SR    = $00         ; No sustain

; Good hit sound - positive but lesser
GOOD_SFX_FREQ     = $20         ; Lower pitch than perfect
GOOD_SFX_WAVE     = $11         ; Triangle (softer)
GOOD_SFX_AD       = $0A         ; Slightly slower decay
GOOD_SFX_SR       = $00         ; No sustain

; Miss sound settings - harsh buzz
MISS_FREQ   = $08
MISS_WAVE   = $81               ; Noise
MISS_AD     = $00               ; Instant attack
MISS_SR     = $A0               ; Quick sustain, fast release

; Menu sound settings
MENU_SELECT_FREQ  = $18         ; Menu click pitch
MENU_SELECT_WAVE  = $41         ; Pulse for click
MENU_SELECT_AD    = $00         ; Instant
MENU_SELECT_SR    = $80         ; Very short

; Visual Settings
BORDER_COL  = 0
BG_COL      = 0

TRACK1_NOTE_COL = 10
TRACK2_NOTE_COL = 13
TRACK3_NOTE_COL = 14

TRACK_LINE_COL = 11
HIT_ZONE_COL = 7

HIT_COL     = 1
PERFECT_COL = 1
GOOD_COL    = 7
MISS_COL    = 2

HEALTH_COL  = 5
PROGRESS_COL = 3
COMBO_COL   = 13

; Title screen colours
TITLE_COL   = 1                 ; White for title
SUBTITLE_COL = 11               ; Grey for subtitle

; ============================================================================
; SCORING SETTINGS
; ============================================================================

PERFECT_SCORE = 100
GOOD_SCORE    = 50

; ============================================================================
; COMBO SETTINGS
; ============================================================================

COMBO_TIER_2  = 10
COMBO_TIER_3  = 25
COMBO_TIER_4  = 50

; ============================================================================
; HEALTH SETTINGS
; ============================================================================

HEALTH_MAX    = 64
HEALTH_START  = 32
HEALTH_PERFECT = 4
HEALTH_GOOD   = 2
HEALTH_MISS   = 8

; ============================================================================
; HIT DETECTION SETTINGS
; ============================================================================

HIT_ZONE_MIN = 2
HIT_ZONE_MAX = 5
HIT_ZONE_CENTRE = 3

; ============================================================================
; SONG SETTINGS
; ============================================================================

SONG_LENGTH   = 64
PROGRESS_WIDTH = 16

; ============================================================================
; GAME STATES
; ============================================================================

STATE_TITLE   = 0
STATE_PLAYING = 1
STATE_RESULTS = 2
STATE_GAMEOVER = 3

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

; CIA keyboard and joystick
CIA1_PRA    = $DC00
CIA1_PRB    = $DC01

; Track positions
TRACK1_ROW  = 8
TRACK2_ROW  = 12
TRACK3_ROW  = 16

; HUD positions
HEALTH_ROW  = 23
PROGRESS_ROW = 24

; Combo display position
COMBO_ROW   = 2

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
END_DELAY_FRAMES = 75

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
game_state  = $0B
hit_note_freq = $0C
song_beat   = $0D
song_ended  = $0E
end_delay   = $0F

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
            jsr init_sid
            jsr show_title

            ; Start in TITLE state
            lda #STATE_TITLE
            sta game_state

main_loop:
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            lda game_state
            cmp #STATE_TITLE
            beq do_title
            cmp #STATE_PLAYING
            beq do_playing
            cmp #STATE_RESULTS
            beq do_results
            jmp do_gameover

do_title:
            jsr update_title
            jmp main_loop

do_playing:
            jsr update_playing
            jmp main_loop

do_results:
            jsr update_results
            jmp main_loop

do_gameover:
            jsr update_gameover
            jmp main_loop

; ----------------------------------------------------------------------------
; Show Title Screen
; ----------------------------------------------------------------------------

show_title:
            ; Clear screen
            lda #BORDER_COL
            sta BORDER
            lda #BG_COL
            sta BGCOL

            ldx #0
            lda #CHAR_SPACE
clear_title:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_title

            ; Draw big title "SID SYMPHONY"
            ldx #0
draw_title_text:
            lda title_big,x
            beq draw_title_done
            sta SCREEN + (8 * 40) + 14,x
            lda #TITLE_COL
            sta COLRAM + (8 * 40) + 14,x
            inx
            jmp draw_title_text
draw_title_done:

            ; Draw subtitle "A RHYTHM GAME"
            ldx #0
draw_subtitle:
            lda subtitle_text,x
            beq draw_subtitle_done
            sta SCREEN + (10 * 40) + 13,x
            lda #SUBTITLE_COL
            sta COLRAM + (10 * 40) + 13,x
            inx
            jmp draw_subtitle
draw_subtitle_done:

            ; Draw controls
            ldx #0
draw_controls:
            lda controls_text,x
            beq draw_controls_done
            sta SCREEN + (14 * 40) + 11,x
            lda #11
            sta COLRAM + (14 * 40) + 11,x
            inx
            jmp draw_controls
draw_controls_done:

            ; Draw track info
            ldx #0
draw_track_info:
            lda track_info,x
            beq draw_track_done
            sta SCREEN + (16 * 40) + 9,x
            lda #11
            sta COLRAM + (16 * 40) + 9,x
            inx
            jmp draw_track_info
draw_track_done:

            ; Draw "PRESS FIRE TO START"
            ldx #0
draw_press_fire:
            lda press_fire_text,x
            beq draw_press_done
            sta SCREEN + (20 * 40) + 10,x
            lda #7              ; Yellow
            sta COLRAM + (20 * 40) + 10,x
            inx
            jmp draw_press_fire
draw_press_done:

            rts

title_big:
            !scr "sid symphony"
            !byte 0

subtitle_text:
            !scr "a rhythm game"
            !byte 0

controls_text:
            !scr "controls: z / x / c"
            !byte 0

track_info:
            !scr "hit notes as they reach"
            !byte 0

press_fire_text:
            !scr "press fire to start"
            !byte 0

; ----------------------------------------------------------------------------
; Update Title State
; ----------------------------------------------------------------------------

update_title:
            ; Check for fire button (joystick port 2)
            lda CIA1_PRA
            and #$10            ; Bit 4 = fire
            beq fire_pressed

            ; Also check space bar as alternative
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Space
            beq fire_pressed

            ; No input - stay on title
            lda #$FF
            sta CIA1_PRA
            rts

fire_pressed:
            lda #$FF
            sta CIA1_PRA

            ; Play menu select sound
            jsr play_menu_select

            ; Start the game!
            jsr init_game
            lda #STATE_PLAYING
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Play Menu Select Sound
; ----------------------------------------------------------------------------

play_menu_select:
            lda #0
            sta SID_V3_FREQ_LO
            lda #MENU_SELECT_FREQ
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWHI
            lda #MENU_SELECT_AD
            sta SID_V3_AD
            lda #MENU_SELECT_SR
            sta SID_V3_SR
            lda #MENU_SELECT_WAVE
            ora #$01            ; Gate on
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Initialize Game (called when starting from title)
; ----------------------------------------------------------------------------

init_game:
            jsr init_screen
            jsr init_notes
            jsr init_score
            jsr init_health
            jsr init_combo
            jsr init_song

            rts

; ----------------------------------------------------------------------------
; Initialize Combo
; ----------------------------------------------------------------------------

init_combo:
            lda #0
            sta combo
            sta max_combo
            jsr display_combo
            rts

; ----------------------------------------------------------------------------
; Update Playing State
; ----------------------------------------------------------------------------

update_playing:
            inc frame_count
            lda frame_count
            cmp #FRAMES_PER_BEAT
            bcc no_new_beat

            lda #0
            sta frame_count
            jsr advance_song
            jsr check_spawn_note

no_new_beat:
            jsr update_notes
            jsr reset_track_colours
            jsr update_border_flash
            jsr check_keys
            jsr check_song_end

            rts

; ----------------------------------------------------------------------------
; Update Results State
; ----------------------------------------------------------------------------

update_results:
            ; Check for fire to return to title
            lda CIA1_PRA
            and #$10
            beq results_fire

            ; Also check space bar
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq results_fire

            lda #$FF
            sta CIA1_PRA
            rts

results_fire:
            lda #$FF
            sta CIA1_PRA

            ; Play menu select sound
            jsr play_menu_select

            ; Return to title screen
            jsr show_title
            lda #STATE_TITLE
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Update Game Over State
; ----------------------------------------------------------------------------

update_gameover:
            ; Check for fire to return to title
            lda CIA1_PRA
            and #$10
            beq gameover_fire

            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq gameover_fire

            lda #$FF
            sta CIA1_PRA
            rts

gameover_fire:
            lda #$FF
            sta CIA1_PRA

            ; Play menu select sound
            jsr play_menu_select

            ; Return to title screen
            jsr show_title
            lda #STATE_TITLE
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Check Song End
; ----------------------------------------------------------------------------

check_song_end:
            lda song_ended
            beq song_not_ended

            ldx #0
check_notes_clear:
            lda note_track,x
            bne notes_still_active
            inx
            cpx #MAX_NOTES
            bne check_notes_clear

            dec end_delay
            bne song_not_ended

            jsr show_results
            lda #STATE_RESULTS
            sta game_state

notes_still_active:
song_not_ended:
            rts

; ----------------------------------------------------------------------------
; Initialize Song
; ----------------------------------------------------------------------------

init_song:
            lda #<song_data
            sta song_pos
            lda #>song_data
            sta song_pos_hi

            lda #0
            sta frame_count
            sta beat_count
            sta song_beat
            sta border_flash
            sta song_ended

            lda #END_DELAY_FRAMES
            sta end_delay

            jsr display_progress
            rts

; ----------------------------------------------------------------------------
; Advance Song
; ----------------------------------------------------------------------------

advance_song:
            lda song_ended
            bne advance_done

            inc beat_count
            inc song_beat

            lda song_beat
            cmp #SONG_LENGTH
            bcc song_continues

            lda #1
            sta song_ended

song_continues:
            jsr display_progress

advance_done:
            rts

; ----------------------------------------------------------------------------
; Display Progress
; ----------------------------------------------------------------------------

display_progress:
            lda song_beat
            lsr
            lsr
            sta temp_progress

            ldx #0
            lda temp_progress
            beq draw_empty_progress

draw_full_progress:
            lda #CHAR_BAR_FULL
            sta SCREEN + (PROGRESS_ROW * 40) + 12,x
            lda #PROGRESS_COL
            sta COLRAM + (PROGRESS_ROW * 40) + 12,x
            inx
            cpx temp_progress
            bne draw_full_progress

draw_empty_progress:
            cpx #PROGRESS_WIDTH
            beq progress_done
            lda #CHAR_BAR_EMPTY
            sta SCREEN + (PROGRESS_ROW * 40) + 12,x
            lda #11
            sta COLRAM + (PROGRESS_ROW * 40) + 12,x
            inx
            jmp draw_empty_progress

progress_done:
            rts

temp_progress: !byte 0

; ----------------------------------------------------------------------------
; Get Multiplier
; ----------------------------------------------------------------------------

get_multiplier:
            lda combo
            cmp #COMBO_TIER_4
            bcs mult_4x
            cmp #COMBO_TIER_3
            bcs mult_3x
            cmp #COMBO_TIER_2
            bcs mult_2x

            lda #1
            rts

mult_2x:
            lda #2
            rts

mult_3x:
            lda #3
            rts

mult_4x:
            lda #4
            rts

; ----------------------------------------------------------------------------
; Display Combo
; ----------------------------------------------------------------------------

display_combo:
            ldx #0
draw_combo_label:
            lda combo_label,x
            beq draw_combo_value
            sta SCREEN + (COMBO_ROW * 40) + 12,x
            lda #11
            sta COLRAM + (COMBO_ROW * 40) + 12,x
            inx
            jmp draw_combo_label

draw_combo_value:
            lda combo

            ldx #0
combo_div_100:
            cmp #100
            bcc combo_done_100
            sec
            sbc #100
            inx
            jmp combo_div_100
combo_done_100:
            pha
            txa
            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 18
            pla

            ldx #0
combo_div_10:
            cmp #10
            bcc combo_done_10
            sec
            sbc #10
            inx
            jmp combo_div_10
combo_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 19
            pla

            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 20

            jsr get_multiplier
            cmp #4
            beq combo_col_4x
            cmp #3
            beq combo_col_3x
            cmp #2
            beq combo_col_2x

            lda #11
            jmp set_combo_col

combo_col_2x:
            lda #7
            jmp set_combo_col

combo_col_3x:
            lda #5
            jmp set_combo_col

combo_col_4x:
            lda #1

set_combo_col:
            sta COLRAM + (COMBO_ROW * 40) + 18
            sta COLRAM + (COMBO_ROW * 40) + 19
            sta COLRAM + (COMBO_ROW * 40) + 20

            jsr get_multiplier
            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 22
            lda #$18
            sta SCREEN + (COMBO_ROW * 40) + 23

            jsr get_multiplier
            cmp #4
            beq mult_col_4x
            cmp #3
            beq mult_col_3x
            cmp #2
            beq mult_col_2x

            lda #11
            jmp set_mult_col

mult_col_2x:
            lda #7
            jmp set_mult_col

mult_col_3x:
            lda #5
            jmp set_mult_col

mult_col_4x:
            lda #1

set_mult_col:
            sta COLRAM + (COMBO_ROW * 40) + 22
            sta COLRAM + (COMBO_ROW * 40) + 23

            rts

combo_label:
            !scr "combo:"
            !byte 0

; ----------------------------------------------------------------------------
; Increment Combo
; ----------------------------------------------------------------------------

increment_combo:
            inc combo

            lda combo
            cmp max_combo
            bcc combo_not_max
            sta max_combo
combo_not_max:

            jsr display_combo
            rts

; ----------------------------------------------------------------------------
; Break Combo
; ----------------------------------------------------------------------------

break_combo:
            lda combo
            beq combo_already_zero

            lda #0
            sta combo
            jsr display_combo

combo_already_zero:
            rts

; ----------------------------------------------------------------------------
; Show Results Screen
; ----------------------------------------------------------------------------

show_results:
            ldx #0
            lda #CHAR_SPACE
clear_for_results:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_for_results

            ldx #0
draw_results_title:
            lda results_title,x
            beq draw_results_title_done
            sta SCREEN + (3 * 40) + 14,x
            lda #1
            sta COLRAM + (3 * 40) + 14,x
            inx
            jmp draw_results_title
draw_results_title_done:

            ldx #0
draw_final_score_label:
            lda final_score_label,x
            beq draw_final_score_done
            sta SCREEN + (6 * 40) + 10,x
            lda #7
            sta COLRAM + (6 * 40) + 10,x
            inx
            jmp draw_final_score_label
draw_final_score_done:
            jsr display_final_score

            ldx #0
draw_perfects_label:
            lda perfects_label,x
            beq draw_perfects_done
            sta SCREEN + (8 * 40) + 10,x
            lda #1
            sta COLRAM + (8 * 40) + 10,x
            inx
            jmp draw_perfects_label
draw_perfects_done:
            lda perfect_count
            jsr display_stat_at_8

            ldx #0
draw_goods_label:
            lda goods_label,x
            beq draw_goods_done
            sta SCREEN + (9 * 40) + 10,x
            lda #7
            sta COLRAM + (9 * 40) + 10,x
            inx
            jmp draw_goods_label
draw_goods_done:
            lda good_count
            jsr display_stat_at_9

            ldx #0
draw_misses_label:
            lda misses_label,x
            beq draw_misses_done
            sta SCREEN + (10 * 40) + 10,x
            lda #2
            sta COLRAM + (10 * 40) + 10,x
            inx
            jmp draw_misses_label
draw_misses_done:
            lda miss_count
            jsr display_stat_at_10

            ldx #0
draw_max_combo_label:
            lda max_combo_label,x
            beq draw_max_combo_done
            sta SCREEN + (12 * 40) + 10,x
            lda #13
            sta COLRAM + (12 * 40) + 10,x
            inx
            jmp draw_max_combo_label
draw_max_combo_done:
            lda max_combo
            jsr display_stat_at_12

            ldx #0
draw_accuracy_label:
            lda accuracy_label,x
            beq draw_accuracy_done
            sta SCREEN + (14 * 40) + 10,x
            lda #5
            sta COLRAM + (14 * 40) + 10,x
            inx
            jmp draw_accuracy_label
draw_accuracy_done:
            jsr calculate_accuracy
            jsr display_accuracy

            ldx #0
draw_press_key:
            lda press_fire_results,x
            beq draw_press_key_done
            sta SCREEN + (18 * 40) + 9,x
            lda #7
            sta COLRAM + (18 * 40) + 9,x
            inx
            jmp draw_press_key
draw_press_key_done:

            lda #5
            sta BORDER

            rts

results_title:
            !scr "song complete!"
            !byte 0

final_score_label:
            !scr "final score:"
            !byte 0

perfects_label:
            !scr "perfects:"
            !byte 0

goods_label:
            !scr "goods:"
            !byte 0

misses_label:
            !scr "misses:"
            !byte 0

max_combo_label:
            !scr "max combo:"
            !byte 0

accuracy_label:
            !scr "accuracy:"
            !byte 0

press_fire_results:
            !scr "press fire for title"
            !byte 0

; ----------------------------------------------------------------------------
; Display Final Score
; ----------------------------------------------------------------------------

display_final_score:
            lda score_lo
            sta work_lo
            lda score_hi
            sta work_hi

            ldx #0
fs_div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc fs_done_10000
            sta work_hi
            sty work_lo
            inx
            jmp fs_div_10000
fs_done_10000:
            txa
            ora #$30
            sta SCREEN + (6 * 40) + 23

            ldx #0
fs_div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc fs_done_1000
            sta work_hi
            sty work_lo
            inx
            jmp fs_div_1000
fs_done_1000:
            txa
            ora #$30
            sta SCREEN + (6 * 40) + 24

            ldx #0
fs_div_100:
            lda work_lo
            sec
            sbc #100
            bcc fs_done_100
            sta work_lo
            inx
            jmp fs_div_100
fs_done_100:
            txa
            ora #$30
            sta SCREEN + (6 * 40) + 25

            ldx #0
fs_div_10:
            lda work_lo
            sec
            sbc #10
            bcc fs_done_10
            sta work_lo
            inx
            jmp fs_div_10
fs_done_10:
            txa
            ora #$30
            sta SCREEN + (6 * 40) + 26

            lda work_lo
            ora #$30
            sta SCREEN + (6 * 40) + 27

            lda #7
            sta COLRAM + (6 * 40) + 23
            sta COLRAM + (6 * 40) + 24
            sta COLRAM + (6 * 40) + 25
            sta COLRAM + (6 * 40) + 26
            sta COLRAM + (6 * 40) + 27

            rts

; ----------------------------------------------------------------------------
; Display Stats
; ----------------------------------------------------------------------------

display_stat_at_8:
            ldx #0
stat8_div:
            cmp #10
            bcc stat8_done
            sec
            sbc #10
            inx
            jmp stat8_div
stat8_done:
            pha
            txa
            ora #$30
            sta SCREEN + (8 * 40) + 23
            pla
            ora #$30
            sta SCREEN + (8 * 40) + 24
            lda #1
            sta COLRAM + (8 * 40) + 23
            sta COLRAM + (8 * 40) + 24
            rts

display_stat_at_9:
            ldx #0
stat9_div:
            cmp #10
            bcc stat9_done
            sec
            sbc #10
            inx
            jmp stat9_div
stat9_done:
            pha
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 23
            pla
            ora #$30
            sta SCREEN + (9 * 40) + 24
            lda #7
            sta COLRAM + (9 * 40) + 23
            sta COLRAM + (9 * 40) + 24
            rts

display_stat_at_10:
            ldx #0
stat10_div:
            cmp #10
            bcc stat10_done
            sec
            sbc #10
            inx
            jmp stat10_div
stat10_done:
            pha
            txa
            ora #$30
            sta SCREEN + (10 * 40) + 23
            pla
            ora #$30
            sta SCREEN + (10 * 40) + 24
            lda #2
            sta COLRAM + (10 * 40) + 23
            sta COLRAM + (10 * 40) + 24
            rts

display_stat_at_12:
            ldx #0
stat12_div:
            cmp #10
            bcc stat12_done
            sec
            sbc #10
            inx
            jmp stat12_div
stat12_done:
            pha
            txa
            ora #$30
            sta SCREEN + (12 * 40) + 23
            pla
            ora #$30
            sta SCREEN + (12 * 40) + 24
            lda #13
            sta COLRAM + (12 * 40) + 23
            sta COLRAM + (12 * 40) + 24
            rts

; ----------------------------------------------------------------------------
; Calculate Accuracy
; ----------------------------------------------------------------------------

calculate_accuracy:
            lda perfect_count
            clc
            adc good_count
            sta total_hits

            clc
            adc miss_count
            sta total_notes

            beq accuracy_zero

            lda total_hits
            sta dividend_lo
            lda #0
            sta dividend_hi

            ldx #100
mult_loop:
            dex
            beq mult_done
            lda dividend_lo
            clc
            adc total_hits
            sta dividend_lo
            lda dividend_hi
            adc #0
            sta dividend_hi
            jmp mult_loop
mult_done:

            lda #0
            sta accuracy
div_loop:
            lda dividend_lo
            sec
            sbc total_notes
            tay
            lda dividend_hi
            sbc #0
            bcc div_done
            sta dividend_hi
            sty dividend_lo
            inc accuracy
            jmp div_loop
div_done:
            rts

accuracy_zero:
            lda #0
            sta accuracy
            rts

total_hits:   !byte 0
total_notes:  !byte 0
dividend_lo:  !byte 0
dividend_hi:  !byte 0
accuracy:     !byte 0

; ----------------------------------------------------------------------------
; Display Accuracy
; ----------------------------------------------------------------------------

display_accuracy:
            lda accuracy

            ldx #0
acc_div_100:
            cmp #100
            bcc acc_done_100
            sec
            sbc #100
            inx
            jmp acc_div_100
acc_done_100:
            pha
            txa
            ora #$30
            sta SCREEN + (14 * 40) + 23
            pla

            ldx #0
acc_div_10:
            cmp #10
            bcc acc_done_10
            sec
            sbc #10
            inx
            jmp acc_div_10
acc_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (14 * 40) + 24
            pla

            ora #$30
            sta SCREEN + (14 * 40) + 25

            lda #$25
            sta SCREEN + (14 * 40) + 26

            lda #5
            sta COLRAM + (14 * 40) + 23
            sta COLRAM + (14 * 40) + 24
            sta COLRAM + (14 * 40) + 25
            sta COLRAM + (14 * 40) + 26

            rts

; ----------------------------------------------------------------------------
; Copy Character Set
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

            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 0
            sta CHARSET + (CHAR_TRACK * 8) + 1
            sta CHARSET + (CHAR_TRACK * 8) + 2
            lda #%11111111
            sta CHARSET + (CHAR_TRACK * 8) + 3
            sta CHARSET + (CHAR_TRACK * 8) + 4
            lda #%00000000
            sta CHARSET + (CHAR_TRACK * 8) + 5
            sta CHARSET + (CHAR_TRACK * 8) + 6
            sta CHARSET + (CHAR_TRACK * 8) + 7

            lda #%01100110
            sta CHARSET + (CHAR_HITZONE * 8) + 0
            sta CHARSET + (CHAR_HITZONE * 8) + 1
            sta CHARSET + (CHAR_HITZONE * 8) + 2
            sta CHARSET + (CHAR_HITZONE * 8) + 3
            sta CHARSET + (CHAR_HITZONE * 8) + 4
            sta CHARSET + (CHAR_HITZONE * 8) + 5
            sta CHARSET + (CHAR_HITZONE * 8) + 6
            sta CHARSET + (CHAR_HITZONE * 8) + 7

            lda #%11111111
            sta CHARSET + (CHAR_BAR_FULL * 8) + 0
            sta CHARSET + (CHAR_BAR_FULL * 8) + 1
            sta CHARSET + (CHAR_BAR_FULL * 8) + 2
            sta CHARSET + (CHAR_BAR_FULL * 8) + 3
            sta CHARSET + (CHAR_BAR_FULL * 8) + 4
            sta CHARSET + (CHAR_BAR_FULL * 8) + 5
            sta CHARSET + (CHAR_BAR_FULL * 8) + 6
            sta CHARSET + (CHAR_BAR_FULL * 8) + 7

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
            sta perfect_count
            sta good_count
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
            sta note_freq,x
            dex
            bpl init_notes_loop
            rts

; ----------------------------------------------------------------------------
; Check Spawn Note
; ----------------------------------------------------------------------------

check_spawn_note:
            lda song_ended
            bne spawn_done_early

            ldy #0

spawn_check_loop:
            lda (song_pos),y
            cmp #$FF
            beq spawn_song_end

            cmp beat_count
            beq spawn_match
            bcs spawn_done_early

            jmp spawn_advance

spawn_match:
            iny
            lda (song_pos),y
            sta temp_track
            iny
            lda (song_pos),y
            pha
            lda temp_track
            jsr spawn_note_with_freq
            pla
            dey
            dey

spawn_advance:
            lda song_pos
            clc
            adc #3
            sta song_pos
            lda song_pos_hi
            adc #0
            sta song_pos_hi
            jmp spawn_check_loop

spawn_song_end:
            lda #1
            sta song_ended

spawn_done_early:
            rts

; ----------------------------------------------------------------------------
; Spawn Note With Frequency
; ----------------------------------------------------------------------------

spawn_note_with_freq:
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

            tsx
            lda $0103,x
            sta note_freq,x

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
            jsr decrease_health
            jsr break_combo

            rts

; ----------------------------------------------------------------------------
; Decrease Health
; ----------------------------------------------------------------------------

decrease_health:
            lda health
            sec
            sbc #HEALTH_MISS
            bcc health_zero
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
; Increase Health
; ----------------------------------------------------------------------------

increase_health:
            clc
            adc health
            cmp #HEALTH_MAX
            bcc health_ok
            lda #HEALTH_MAX
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

            lda #STATE_GAMEOVER
            sta game_state
            jsr show_game_over

not_game_over:
            rts

; ----------------------------------------------------------------------------
; Show Game Over
; ----------------------------------------------------------------------------

show_game_over:
            ; Clear screen for game over display
            ldx #0
            lda #CHAR_SPACE
clear_gameover:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_gameover

            ; Draw "GAME OVER" in red
            ldx #0
game_over_loop:
            lda game_over_text,x
            beq game_over_text_done
            sta SCREEN + (6 * 40) + 15,x
            lda #2                  ; Red for failure
            sta COLRAM + (6 * 40) + 15,x
            inx
            jmp game_over_loop
game_over_text_done:

            ; Draw "HEALTH DEPLETED"
            ldx #0
draw_depleted:
            lda depleted_text,x
            beq draw_depleted_done
            sta SCREEN + (8 * 40) + 12,x
            lda #10                 ; Light red
            sta COLRAM + (8 * 40) + 12,x
            inx
            jmp draw_depleted
draw_depleted_done:

            ; Show score achieved
            ldx #0
draw_go_score_label:
            lda go_score_label,x
            beq draw_go_score_done
            sta SCREEN + (12 * 40) + 11,x
            lda #7
            sta COLRAM + (12 * 40) + 11,x
            inx
            jmp draw_go_score_label
draw_go_score_done:
            jsr display_gameover_score

            ; Show notes hit
            ldx #0
draw_go_notes_label:
            lda go_notes_label,x
            beq draw_go_notes_done
            sta SCREEN + (14 * 40) + 11,x
            lda #11
            sta COLRAM + (14 * 40) + 11,x
            inx
            jmp draw_go_notes_label
draw_go_notes_done:
            lda perfect_count
            clc
            adc good_count
            jsr display_go_stat

            ; "PRESS FIRE FOR TITLE"
            ldx #0
game_over_press:
            lda press_fire_gameover,x
            beq game_over_done
            sta SCREEN + (18 * 40) + 10,x
            lda #7                  ; Yellow for action
            sta COLRAM + (18 * 40) + 10,x
            inx
            jmp game_over_press

game_over_done:
            lda #2                  ; Red border
            sta BORDER
            rts

game_over_text:
            !scr "game over"
            !byte 0

depleted_text:
            !scr "health depleted"
            !byte 0

go_score_label:
            !scr "score achieved:"
            !byte 0

go_notes_label:
            !scr "notes hit:"
            !byte 0

press_fire_gameover:
            !scr "press fire for title"
            !byte 0

; Display gameover score (row 12)
display_gameover_score:
            lda score_lo
            sta work_lo
            lda score_hi
            sta work_hi

            ldx #0
go_div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc go_done_10000
            sta work_hi
            sty work_lo
            inx
            jmp go_div_10000
go_done_10000:
            txa
            ora #$30
            sta SCREEN + (12 * 40) + 27

            ldx #0
go_div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc go_done_1000
            sta work_hi
            sty work_lo
            inx
            jmp go_div_1000
go_done_1000:
            txa
            ora #$30
            sta SCREEN + (12 * 40) + 28

            ldx #0
go_div_100:
            lda work_lo
            sec
            sbc #100
            bcc go_done_100
            sta work_lo
            inx
            jmp go_div_100
go_done_100:
            txa
            ora #$30
            sta SCREEN + (12 * 40) + 29

            ldx #0
go_div_10:
            lda work_lo
            sec
            sbc #10
            bcc go_done_10
            sta work_lo
            inx
            jmp go_div_10
go_done_10:
            txa
            ora #$30
            sta SCREEN + (12 * 40) + 30

            lda work_lo
            ora #$30
            sta SCREEN + (12 * 40) + 31

            lda #7
            sta COLRAM + (12 * 40) + 27
            sta COLRAM + (12 * 40) + 28
            sta COLRAM + (12 * 40) + 29
            sta COLRAM + (12 * 40) + 30
            sta COLRAM + (12 * 40) + 31
            rts

; Display notes hit stat at row 14
display_go_stat:
            ldx #0
go_stat_div:
            cmp #10
            bcc go_stat_done
            sec
            sbc #10
            inx
            jmp go_stat_div
go_stat_done:
            pha
            txa
            ora #$30
            sta SCREEN + (14 * 40) + 27
            pla
            ora #$30
            sta SCREEN + (14 * 40) + 28
            lda #11
            sta COLRAM + (14 * 40) + 27
            sta COLRAM + (14 * 40) + 28
            rts

; ----------------------------------------------------------------------------
; Display Health
; ----------------------------------------------------------------------------

display_health:
            lda health
            lsr
            lsr
            lsr
            sta temp_health

            ldx #0
            lda temp_health
            beq draw_empty_bars

draw_full_bars:
            lda #CHAR_BAR_FULL
            sta SCREEN + (HEALTH_ROW * 40) + 12,x
            lda #HEALTH_COL
            sta COLRAM + (HEALTH_ROW * 40) + 12,x
            inx
            cpx temp_health
            bne draw_full_bars

draw_empty_bars:
            cpx #8
            beq health_done
            lda #CHAR_BAR_EMPTY
            sta SCREEN + (HEALTH_ROW * 40) + 12,x
            lda #11
            sta COLRAM + (HEALTH_ROW * 40) + 12,x
            inx
            jmp draw_empty_bars

health_done:
            rts

temp_health: !byte 0

; ============================================================================
; POLISHED SOUND EFFECTS
; ============================================================================

; ----------------------------------------------------------------------------
; Play Perfect Hit Sound - Bright, high, satisfying
; ----------------------------------------------------------------------------

play_perfect_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #PERFECT_SFX_FREQ
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWHI
            lda #PERFECT_SFX_AD
            sta SID_V3_AD
            lda #PERFECT_SFX_SR
            sta SID_V3_SR
            lda #PERFECT_SFX_WAVE
            ora #$01            ; Gate on
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Play Good Hit Sound - Positive but lesser
; ----------------------------------------------------------------------------

play_good_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #GOOD_SFX_FREQ
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWHI
            lda #GOOD_SFX_AD
            sta SID_V3_AD
            lda #GOOD_SFX_SR
            sta SID_V3_SR
            lda #GOOD_SFX_WAVE
            ora #$01            ; Gate on
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Play Miss Sound - Harsh buzz
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
            ora #$01            ; Gate on
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
draw_score_label:
            lda score_label,x
            beq draw_score_label_done
            sta SCREEN + 1,x
            lda #1
            sta COLRAM + 1,x
            inx
            bne draw_score_label
draw_score_label_done:

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

            ldx #0
draw_title_game:
            lda title_game,x
            beq draw_title_game_done
            sta SCREEN + 27,x
            lda #1
            sta COLRAM + 27,x
            inx
            bne draw_title_game
draw_title_game_done:

            ldx #0
draw_health_label:
            lda health_label,x
            beq draw_health_label_done
            sta SCREEN + (HEALTH_ROW * 40) + 4,x
            lda #5
            sta COLRAM + (HEALTH_ROW * 40) + 4,x
            inx
            bne draw_health_label
draw_health_label_done:

            ldx #0
draw_progress_label:
            lda progress_label,x
            beq draw_progress_label_done
            sta SCREEN + (PROGRESS_ROW * 40) + 4,x
            lda #3
            sta COLRAM + (PROGRESS_ROW * 40) + 4,x
            inx
            bne draw_progress_label
draw_progress_label_done:

            lda #$1A
            sta SCREEN + (TRACK1_ROW * 40)
            lda #TRACK1_NOTE_COL
            sta COLRAM + (TRACK1_ROW * 40)

            lda #$18
            sta SCREEN + (TRACK2_ROW * 40)
            lda #TRACK2_NOTE_COL
            sta COLRAM + (TRACK2_ROW * 40)

            lda #$03
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

title_game:
            !scr "sid symphony"
            !byte 0

health_label:
            !scr "health:"
            !byte 0

progress_label:
            !scr "song:"
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
            jsr play_voice1_note
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
            jsr play_voice2_note
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
            jsr play_voice3_note
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

            lda note_freq,x
            sta hit_note_freq

            lda note_col,x
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
            jsr increment_combo

            lda hit_quality
            cmp #2
            beq award_perfect

            ; Good hit
            lda #GOOD_SCORE
            jsr apply_multiplier
            jsr add_score

            inc good_count

            ; Play good sound effect
            jsr play_good_sound

            lda #GOOD_COL
            sta BORDER
            lda #4
            sta border_flash

            lda #HEALTH_GOOD
            jsr increase_health

            jmp award_done

award_perfect:
            ; Perfect hit
            lda #PERFECT_SCORE
            jsr apply_multiplier
            jsr add_score

            inc perfect_count

            ; Play perfect sound effect
            jsr play_perfect_sound

            lda #PERFECT_COL
            sta BORDER
            lda #6
            sta border_flash

            lda #HEALTH_PERFECT
            jsr increase_health

award_done:
            jsr display_score
            rts

; ----------------------------------------------------------------------------
; Apply Multiplier
; ----------------------------------------------------------------------------

apply_multiplier:
            sta base_score
            jsr get_multiplier
            sta current_mult

            lda base_score
            sta score_add_lo
            lda #0
            sta score_add_hi

            lda current_mult
            cmp #1
            beq mult_done_apply

            dec current_mult
mult_add_loop:
            lda score_add_lo
            clc
            adc base_score
            sta score_add_lo
            lda score_add_hi
            adc #0
            sta score_add_hi
            dec current_mult
            bne mult_add_loop

mult_done_apply:
            rts

base_score:    !byte 0
current_mult:  !byte 0
score_add_lo:  !byte 0
score_add_hi:  !byte 0

; ----------------------------------------------------------------------------
; Add Score
; ----------------------------------------------------------------------------

add_score:
            lda score_lo
            clc
            adc score_add_lo
            sta score_lo
            lda score_hi
            adc score_add_hi
            sta score_hi
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
; Play Voices (for note playback)
; ----------------------------------------------------------------------------

play_voice1_note:
            lda #0
            sta SID_V1_FREQ_LO
            lda hit_note_freq
            sta SID_V1_FREQ_HI
            lda #VOICE1_WAVE
            ora #$01
            sta SID_V1_CTRL
            rts

play_voice2_note:
            lda #0
            sta SID_V2_FREQ_LO
            lda hit_note_freq
            sta SID_V2_FREQ_HI
            lda #VOICE2_WAVE
            ora #$01
            sta SID_V2_CTRL
            rts

play_voice3_note:
            lda #0
            sta SID_V3_FREQ_LO
            lda hit_note_freq
            sta SID_V3_FREQ_HI
            lda #VOICE3_WAVE
            ora #$01
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Flash Tracks
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

; ============================================================================
; SONG DATA
; ============================================================================

song_data:
            !byte 0, 1, $47
            !byte 2, 2, $2C
            !byte 4, 3, $11

            !byte 8, 1, $3B
            !byte 10, 2, $27
            !byte 12, 3, $13

            !byte 16, 1, $35
            !byte 17, 2, $2C
            !byte 18, 1, $3B
            !byte 20, 3, $16

            !byte 24, 1, $47
            !byte 26, 2, $35
            !byte 28, 3, $11

            !byte 32, 2, $2F
            !byte 34, 1, $4F
            !byte 36, 3, $17

            !byte 40, 1, $58
            !byte 42, 2, $2C
            !byte 44, 3, $11
            !byte 46, 2, $27

            !byte 48, 1, $6A
            !byte 49, 2, $35
            !byte 50, 1, $58
            !byte 52, 3, $1A
            !byte 54, 2, $2F

            !byte 56, 1, $47
            !byte 58, 2, $2C
            !byte 60, 3, $11
            !byte 62, 1, $35

            !byte $FF

; ----------------------------------------------------------------------------
; Note Arrays
; ----------------------------------------------------------------------------

note_track:
            !fill MAX_NOTES, 0

note_col:
            !fill MAX_NOTES, 0

note_freq:
            !fill MAX_NOTES, 0

; ----------------------------------------------------------------------------
; Game Variables
; ----------------------------------------------------------------------------

score_lo:     !byte 0
score_hi:     !byte 0
miss_count:   !byte 0
perfect_count: !byte 0
good_count:   !byte 0
health:       !byte 0
combo:        !byte 0
max_combo:    !byte 0

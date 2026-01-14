; ============================================================================
; SID SYMPHONY - Unit 17: Song Selection Screen
; ============================================================================
; Adding a menu system to select songs. Currently only one song, but the
; structure is ready for multiple songs in the next unit.
;
; New concepts: Menu state, cursor tracking, key repeat delay
;
; Controls: Z = Track 1, X = Track 2, C = Track 3
;           Up/Down = Menu navigation
;           Fire/Space = Start game / Select
; ============================================================================

; ============================================================================
; CUSTOMISATION SECTION
; ============================================================================

; Screenshot mode - set to 1 to skip title and show menu immediately
; Used for automated screenshot capture. Override with: acme -DSCREENSHOT_MODE=1
!ifndef SCREENSHOT_MODE { SCREENSHOT_MODE = 0 }

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

MENU_MOVE_FREQ    = $10         ; Lower pitch for cursor move
MENU_MOVE_WAVE    = $11         ; Triangle (soft)
MENU_MOVE_AD      = $00         ; Instant
MENU_MOVE_SR      = $40         ; Very short

; Visual Settings
BORDER_COL  = 0
BG_COL      = 0

TRACK1_NOTE_COL = 10            ; Light red for high track
TRACK2_NOTE_COL = 13            ; Light green for mid track
TRACK3_NOTE_COL = 14            ; Light blue for low track

TRACK_LINE_COL = 11             ; Grey for track lines
HIT_ZONE_COL = 7                ; Yellow for hit zone

HIT_COL     = 1
PERFECT_COL = 1                 ; White flash for perfect
GOOD_COL    = 7                 ; Yellow flash for good
MISS_COL    = 2                 ; Red flash for miss

HEALTH_COL  = 5                 ; Green for health bar
PROGRESS_COL = 3                ; Cyan for progress bar
COMBO_COL   = 13                ; Light green for combo

; Title screen colours
TITLE_COL   = 1                 ; White for title
SUBTITLE_COL = 11               ; Grey for subtitle
MENU_COL    = 7                 ; Yellow for menu items
CURSOR_COL  = 1                 ; White for cursor

; ============================================================================
; SCORING SETTINGS (BALANCED)
; ============================================================================

PERFECT_SCORE = 100             ; Perfect hit value
GOOD_SCORE    = 50              ; Good hit value

; ============================================================================
; COMBO SETTINGS (BALANCED)
; ============================================================================

COMBO_TIER_2  = 10              ; 2x multiplier at 10 hits
COMBO_TIER_3  = 25              ; 3x multiplier at 25 hits
COMBO_TIER_4  = 50              ; 4x multiplier at 50 hits

; ============================================================================
; HEALTH SETTINGS (BALANCED FOR FAIRNESS)
; ============================================================================

HEALTH_MAX    = 64              ; Maximum health
HEALTH_START  = 32              ; Start at half health
HEALTH_PERFECT = 4              ; Gain 4 for perfect
HEALTH_GOOD   = 2               ; Gain 2 for good
HEALTH_MISS   = 8               ; Lose 8 for miss (forgiving)

; ============================================================================
; HIT DETECTION SETTINGS (BALANCED TIMING WINDOWS)
; ============================================================================

HIT_ZONE_MIN = 2                ; Earliest hit column
HIT_ZONE_MAX = 5                ; Latest hit column
HIT_ZONE_CENTRE = 3             ; Perfect timing column

; ============================================================================
; SONG SETTINGS
; ============================================================================

SONG_LENGTH   = 64              ; 64 beats at 120 BPM = ~32 seconds
PROGRESS_WIDTH = 16             ; Progress bar width

; ============================================================================
; MENU SETTINGS
; ============================================================================

NUM_SONGS     = 1               ; Currently only 1 song
KEY_DELAY     = 10              ; Frames between key repeats

; ============================================================================
; GAME STATES
; ============================================================================

STATE_TITLE   = 0               ; Title screen
STATE_MENU    = 1               ; Song selection menu (NEW!)
STATE_PLAYING = 2               ; Gameplay
STATE_RESULTS = 3               ; Success results
STATE_GAMEOVER = 4              ; Failure game over

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

; Track positions (balanced spacing)
TRACK1_ROW  = 8                 ; High track
TRACK2_ROW  = 12                ; Mid track
TRACK3_ROW  = 16                ; Low track

; HUD positions
HEALTH_ROW  = 23                ; Health bar row
PROGRESS_ROW = 24               ; Progress bar row

; Combo display position
COMBO_ROW   = 2                 ; Combo display row

; Hit zone
HIT_ZONE_COLUMN = 3             ; Where notes are hit

; Custom character codes
CHAR_NOTE   = 128
CHAR_TRACK  = 129
CHAR_HITZONE = 130
CHAR_SPACE  = 32
CHAR_BAR_FULL = 131
CHAR_BAR_EMPTY = 132
CHAR_CURSOR = 62                ; > character for menu cursor

; Note settings
MAX_NOTES   = 8                 ; Maximum simultaneous notes
NOTE_SPAWN_COL = 37             ; Where notes appear

; Timing
FRAMES_PER_BEAT = 25            ; 50fps / 25 = 2 beats per second = 120 BPM
END_DELAY_FRAMES = 75           ; 1.5 seconds after song ends

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
cursor_pos  = $10               ; Menu cursor position (NEW!)
key_delay_count = $11           ; Key repeat delay counter (NEW!)
selected_song = $12             ; Which song to play (NEW!)

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

!if SCREENSHOT_MODE = 1 {
            ; Screenshot mode: skip title, go to menu
            jsr show_menu
            lda #STATE_MENU
            sta game_state
} else {
            ; Normal mode: show title screen
            jsr show_title
            lda #STATE_TITLE
            sta game_state
}

main_loop:
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            lda game_state
            cmp #STATE_TITLE
            beq do_title
            cmp #STATE_MENU
            beq do_menu
            cmp #STATE_PLAYING
            beq do_playing
            cmp #STATE_RESULTS
            beq do_results
            jmp do_gameover

do_title:
            jsr update_title
            jmp main_loop

do_menu:
            jsr update_menu
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
            beq title_fire_pressed

            ; Also check space bar as alternative
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Space
            beq title_fire_pressed

            ; No input - stay on title
            lda #$FF
            sta CIA1_PRA
            rts

title_fire_pressed:
            lda #$FF
            sta CIA1_PRA

            ; Play menu select sound
            jsr play_menu_select

            ; Go to song selection menu
            jsr show_menu
            lda #STATE_MENU
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Show Song Selection Menu
; ----------------------------------------------------------------------------

show_menu:
            ; Clear screen
            ldx #0
            lda #CHAR_SPACE
clear_menu:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_menu

            ; Initialise cursor
            lda #0
            sta cursor_pos
            sta key_delay_count

            ; Draw menu title
            ldx #0
draw_menu_title:
            lda menu_title,x
            beq draw_menu_title_done
            sta SCREEN + (4 * 40) + 12,x
            lda #TITLE_COL
            sta COLRAM + (4 * 40) + 12,x
            inx
            jmp draw_menu_title
draw_menu_title_done:

            ; Draw instructions
            ldx #0
draw_menu_instr:
            lda menu_instructions,x
            beq draw_menu_instr_done
            sta SCREEN + (22 * 40) + 8,x
            lda #SUBTITLE_COL
            sta COLRAM + (22 * 40) + 8,x
            inx
            jmp draw_menu_instr
draw_menu_instr_done:

            ; Draw song list
            jsr draw_song_list

            rts

menu_title:
            !scr "select a song"
            !byte 0

menu_instructions:
            !scr "up/down to select, fire to play"
            !byte 0

; ----------------------------------------------------------------------------
; Draw Song List
; ----------------------------------------------------------------------------

draw_song_list:
            ; Draw each song entry
            ; For now, just one song

            ; Song 1
            ldx #0
draw_song1:
            lda song1_name,x
            beq draw_song1_done
            sta SCREEN + (10 * 40) + 14,x
            lda #MENU_COL
            sta COLRAM + (10 * 40) + 14,x
            inx
            jmp draw_song1
draw_song1_done:

            ; Draw cursor at current position
            jsr draw_cursor
            rts

; Song names
song1_name:
            !scr "first steps"
            !byte 0

; ----------------------------------------------------------------------------
; Draw Menu Cursor
; ----------------------------------------------------------------------------

draw_cursor:
            ; Clear all potential cursor positions
            lda #CHAR_SPACE
            sta SCREEN + (10 * 40) + 12
            ; (Room for more songs later)

            ; Draw cursor at current position
            lda cursor_pos
            asl                 ; Multiply by 2 (rows per song)
            clc
            adc #10             ; Start row
            tax

            ; Calculate screen position
            ; Row X * 40 = screen offset
            lda #0
            sta ZP_PTR
            lda #0
            sta ZP_PTR_HI

            ; Multiply row by 40
cursor_row_mult:
            cpx #0
            beq cursor_row_done
            lda ZP_PTR
            clc
            adc #40
            sta ZP_PTR
            lda ZP_PTR_HI
            adc #0
            sta ZP_PTR_HI
            dex
            jmp cursor_row_mult

cursor_row_done:
            ; Add column offset (12)
            lda ZP_PTR
            clc
            adc #12
            sta ZP_PTR
            lda ZP_PTR_HI
            adc #0
            sta ZP_PTR_HI

            ; Add screen base
            lda ZP_PTR
            clc
            adc #<SCREEN
            sta ZP_PTR
            lda ZP_PTR_HI
            adc #>SCREEN
            sta ZP_PTR_HI

            ; Draw cursor character
            lda #CHAR_CURSOR
            ldy #0
            sta (ZP_PTR),y

            ; Set cursor colour
            lda ZP_PTR
            sec
            sbc #<SCREEN
            clc
            adc #<COLRAM
            sta ZP_PTR
            lda ZP_PTR_HI
            sbc #>SCREEN
            adc #>COLRAM
            sta ZP_PTR_HI

            lda #CURSOR_COL
            sta (ZP_PTR),y

            rts

; ----------------------------------------------------------------------------
; Update Menu State
; ----------------------------------------------------------------------------

update_menu:
            ; Handle key delay
            lda key_delay_count
            beq menu_check_input
            dec key_delay_count
            jmp menu_check_fire

menu_check_input:
            ; Check joystick up (or W key)
            lda CIA1_PRA
            and #$01            ; Bit 0 = up
            beq menu_up_pressed

            ; Check joystick down (or S key)
            lda CIA1_PRA
            and #$02            ; Bit 1 = down
            beq menu_down_pressed

            jmp menu_check_fire

menu_up_pressed:
            lda cursor_pos
            beq menu_set_delay  ; Already at top
            dec cursor_pos
            jsr play_menu_move
            jsr draw_cursor
            jmp menu_set_delay

menu_down_pressed:
            lda cursor_pos
            cmp #NUM_SONGS-1
            bcs menu_set_delay  ; Already at bottom
            inc cursor_pos
            jsr play_menu_move
            jsr draw_cursor
            jmp menu_set_delay

menu_set_delay:
            lda #KEY_DELAY
            sta key_delay_count

menu_check_fire:
            ; Check for fire button
            lda CIA1_PRA
            and #$10
            beq menu_fire_pressed

            ; Check space bar
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq menu_fire_pressed

            lda #$FF
            sta CIA1_PRA
            rts

menu_fire_pressed:
            lda #$FF
            sta CIA1_PRA

            ; Play select sound
            jsr play_menu_select

            ; Store selected song
            lda cursor_pos
            sta selected_song

            ; Transition to game
            jsr transition_to_game
            rts

; ----------------------------------------------------------------------------
; Transition to Game
; ----------------------------------------------------------------------------

transition_to_game:
            ; Set up the selected song (for now, only song 0)
            ; In future units, this will load different song data

            ; Initialise game
            jsr init_game
            lda #STATE_PLAYING
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Play Menu Move Sound
; ----------------------------------------------------------------------------

play_menu_move:
            lda #0
            sta SID_V3_FREQ_LO
            lda #MENU_MOVE_FREQ
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWHI
            lda #MENU_MOVE_AD
            sta SID_V3_AD
            lda #MENU_MOVE_SR
            sta SID_V3_SR
            lda #MENU_MOVE_WAVE
            ora #$01            ; Gate on
            sta SID_V3_CTRL
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
; Initialize Game (called when starting from menu)
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
            ; Check for fire to return to menu
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

            jsr play_menu_select

            ; Return to menu (not title)
            jsr show_menu
            lda #STATE_MENU
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Update Game Over State
; ----------------------------------------------------------------------------

update_gameover:
            ; Check for fire to return to menu
            lda CIA1_PRA
            and #$10
            beq gameover_fire

            ; Also check space bar
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

            jsr play_menu_select

            ; Return to menu (not title)
            jsr show_menu
            lda #STATE_MENU
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Initialize Screen (Gameplay)
; ----------------------------------------------------------------------------

init_screen:
            ; Enable custom charset
            lda #$1C            ; Character ROM at $3000
            sta CHARPTR

            ; Set colours
            lda #BORDER_COL
            sta BORDER
            lda #BG_COL
            sta BGCOL

            ; Clear screen
            ldx #0
            lda #CHAR_SPACE
clear_screen:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_screen

            ; Draw tracks
            ldx #0
draw_tracks:
            lda #CHAR_TRACK
            sta SCREEN + (TRACK1_ROW * 40),x
            sta SCREEN + (TRACK2_ROW * 40),x
            sta SCREEN + (TRACK3_ROW * 40),x
            lda #TRACK_LINE_COL
            sta COLRAM + (TRACK1_ROW * 40),x
            sta COLRAM + (TRACK2_ROW * 40),x
            sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne draw_tracks

            ; Draw hit zones
            lda #CHAR_HITZONE
            sta SCREEN + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta SCREEN + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN
            lda #HIT_ZONE_COL
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN

            ; Draw track labels
            lda #$31            ; "1"
            sta SCREEN + (TRACK1_ROW * 40)
            lda #$32            ; "2"
            sta SCREEN + (TRACK2_ROW * 40)
            lda #$33            ; "3"
            sta SCREEN + (TRACK3_ROW * 40)
            lda #1
            sta COLRAM + (TRACK1_ROW * 40)
            sta COLRAM + (TRACK2_ROW * 40)
            sta COLRAM + (TRACK3_ROW * 40)

            ; Draw HUD labels
            ldx #0
draw_score_label:
            lda score_label,x
            beq draw_miss_label_start
            sta SCREEN,x
            lda #7
            sta COLRAM,x
            inx
            jmp draw_score_label

draw_miss_label_start:
            ldx #0
draw_miss_label:
            lda miss_label,x
            beq draw_combo_label_start
            sta SCREEN + 14,x
            lda #2
            sta COLRAM + 14,x
            inx
            jmp draw_miss_label

draw_combo_label_start:
            ldx #0
draw_combo_label:
            lda combo_label,x
            beq draw_health_label_start
            sta SCREEN + (COMBO_ROW * 40) + 27,x
            lda #COMBO_COL
            sta COLRAM + (COMBO_ROW * 40) + 27,x
            inx
            jmp draw_combo_label

draw_health_label_start:
            ldx #0
draw_health_label:
            lda health_label,x
            beq draw_progress_label_start
            sta SCREEN + (HEALTH_ROW * 40),x
            lda #HEALTH_COL
            sta COLRAM + (HEALTH_ROW * 40),x
            inx
            jmp draw_health_label

draw_progress_label_start:
            ldx #0
draw_progress_label:
            lda progress_label,x
            beq labels_done
            sta SCREEN + (PROGRESS_ROW * 40),x
            lda #PROGRESS_COL
            sta COLRAM + (PROGRESS_ROW * 40),x
            inx
            jmp draw_progress_label

labels_done:
            ; Draw song name on gameplay screen
            ldx #0
draw_song_name:
            lda selected_song
            ; For now only song 0
            lda song1_name,x
            beq draw_song_name_done
            sta SCREEN + 28,x
            lda #11
            sta COLRAM + 28,x
            inx
            jmp draw_song_name
draw_song_name_done:

            rts

score_label:
            !scr "score:"
            !byte 0
miss_label:
            !scr "miss:"
            !byte 0
combo_label:
            !scr "combo:"
            !byte 0
health_label:
            !scr "health:"
            !byte 0
progress_label:
            !scr "song:"
            !byte 0

; ----------------------------------------------------------------------------
; Initialize Notes
; ----------------------------------------------------------------------------

init_notes:
            ldx #0
            lda #0
clear_notes:
            sta note_track,x
            sta note_col,x
            sta note_freq,x
            inx
            cpx #MAX_NOTES
            bne clear_notes
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
; Initialize Health
; ----------------------------------------------------------------------------

init_health:
            lda #HEALTH_START
            sta health
            jsr display_health
            rts

; ----------------------------------------------------------------------------
; Initialize Song
; ----------------------------------------------------------------------------

init_song:
            lda #0
            sta frame_count
            sta beat_count
            sta song_beat
            sta song_ended

            ; Point to song data (for now, only one song)
            lda #<song_data
            sta song_pos
            lda #>song_data
            sta song_pos_hi

            jsr display_progress
            rts

; ----------------------------------------------------------------------------
; Initialize SID
; ----------------------------------------------------------------------------

init_sid:
            ; Clear SID
            ldx #$18
            lda #0
clear_sid:
            sta SID,x
            dex
            bpl clear_sid

            ; Set volume
            lda #$0F
            sta SID_VOLUME

            ; Set pulse widths
            lda #PULSE_WIDTH
            sta SID_V1_PWHI
            sta SID_V2_PWHI
            sta SID_V3_PWHI

            ; Set ADSR for all voices
            lda #VOICE_AD
            sta SID_V1_AD
            sta SID_V2_AD
            sta SID_V3_AD

            lda #VOICE_SR
            sta SID_V1_SR
            sta SID_V2_SR
            sta SID_V3_SR

            rts

; ----------------------------------------------------------------------------
; Copy Custom Charset
; ----------------------------------------------------------------------------

copy_charset:
            ; Copy default ROM charset to RAM first
            sei
            lda #$33
            sta $01

            ldx #0
copy_rom_chars:
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
            bne copy_rom_chars

            lda #$37
            sta $01
            cli

            ; Now add custom characters

            ; Character 128 - Note (solid circle)
            lda #%00111100
            sta CHARSET + (128 * 8) + 0
            lda #%01111110
            sta CHARSET + (128 * 8) + 1
            lda #%11111111
            sta CHARSET + (128 * 8) + 2
            lda #%11111111
            sta CHARSET + (128 * 8) + 3
            lda #%11111111
            sta CHARSET + (128 * 8) + 4
            lda #%11111111
            sta CHARSET + (128 * 8) + 5
            lda #%01111110
            sta CHARSET + (128 * 8) + 6
            lda #%00111100
            sta CHARSET + (128 * 8) + 7

            ; Character 129 - Track line (dashes)
            lda #%00000000
            sta CHARSET + (129 * 8) + 0
            lda #%00000000
            sta CHARSET + (129 * 8) + 1
            lda #%00000000
            sta CHARSET + (129 * 8) + 2
            lda #%11001100
            sta CHARSET + (129 * 8) + 3
            lda #%11001100
            sta CHARSET + (129 * 8) + 4
            lda #%00000000
            sta CHARSET + (129 * 8) + 5
            lda #%00000000
            sta CHARSET + (129 * 8) + 6
            lda #%00000000
            sta CHARSET + (129 * 8) + 7

            ; Character 130 - Hit zone (vertical bars)
            lda #%10000001
            sta CHARSET + (130 * 8) + 0
            lda #%10000001
            sta CHARSET + (130 * 8) + 1
            lda #%10000001
            sta CHARSET + (130 * 8) + 2
            lda #%10000001
            sta CHARSET + (130 * 8) + 3
            lda #%10000001
            sta CHARSET + (130 * 8) + 4
            lda #%10000001
            sta CHARSET + (130 * 8) + 5
            lda #%10000001
            sta CHARSET + (130 * 8) + 6
            lda #%10000001
            sta CHARSET + (130 * 8) + 7

            ; Character 131 - Bar full (solid block)
            lda #%11111111
            sta CHARSET + (131 * 8) + 0
            sta CHARSET + (131 * 8) + 1
            sta CHARSET + (131 * 8) + 2
            sta CHARSET + (131 * 8) + 3
            sta CHARSET + (131 * 8) + 4
            sta CHARSET + (131 * 8) + 5
            sta CHARSET + (131 * 8) + 6
            sta CHARSET + (131 * 8) + 7

            ; Character 132 - Bar empty (hollow block)
            lda #%11111111
            sta CHARSET + (132 * 8) + 0
            lda #%10000001
            sta CHARSET + (132 * 8) + 1
            sta CHARSET + (132 * 8) + 2
            sta CHARSET + (132 * 8) + 3
            sta CHARSET + (132 * 8) + 4
            sta CHARSET + (132 * 8) + 5
            sta CHARSET + (132 * 8) + 6
            lda #%11111111
            sta CHARSET + (132 * 8) + 7

            rts

; ----------------------------------------------------------------------------
; Advance Song
; ----------------------------------------------------------------------------

advance_song:
            inc song_beat
            jsr display_progress
            rts

; ----------------------------------------------------------------------------
; Check Spawn Note
; ----------------------------------------------------------------------------

check_spawn_note:
            ; Check if song has ended
            lda song_ended
            bne spawn_done

            ; Get pointer to current position in song
            lda song_pos
            sta ZP_PTR
            lda song_pos_hi
            sta ZP_PTR_HI

            ; Read beat number
            ldy #0
            lda (ZP_PTR),y

            ; Check for end marker
            cmp #$FF
            beq song_end_marker

            ; Check if this beat matches
            cmp song_beat
            bne spawn_done

            ; Spawn this note
            iny
            lda (ZP_PTR),y      ; Track
            sta temp_track
            iny
            lda (ZP_PTR),y      ; Frequency

            ; Find free note slot
            ldx #0
find_slot:
            lda note_track,x
            beq found_slot
            inx
            cpx #MAX_NOTES
            bne find_slot
            jmp advance_song_ptr  ; No free slot, skip note

found_slot:
            lda temp_track
            sta note_track,x
            lda #NOTE_SPAWN_COL
            sta note_col,x
            ldy #2
            lda (ZP_PTR),y
            sta note_freq,x
            jsr draw_note

advance_song_ptr:
            ; Move to next note in song
            lda song_pos
            clc
            adc #3
            sta song_pos
            lda song_pos_hi
            adc #0
            sta song_pos_hi

            ; Check if there are more notes on this beat
            jmp check_spawn_note

song_end_marker:
            lda #1
            sta song_ended
spawn_done:
            rts

; ----------------------------------------------------------------------------
; Update Notes
; ----------------------------------------------------------------------------

update_notes:
            ldx #0
update_notes_loop:
            lda note_track,x
            beq update_next_note

            ; Erase at old position
            jsr erase_note

            ; Move note left
            dec note_col,x

            ; Check if past hit zone (missed)
            lda note_col,x
            cmp #HIT_ZONE_MIN
            bcs note_still_active

            ; Note was missed
            lda note_track,x
            sta miss_track
            lda #0
            sta note_track,x
            jsr handle_miss
            jmp update_next_note

note_still_active:
            jsr draw_note

update_next_note:
            inx
            cpx #MAX_NOTES
            bne update_notes_loop
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
            jmp draw_note_t3

draw_note_t1:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK1_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK1_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            lda #CHAR_NOTE
            ldy #0
            sta (ZP_PTR),y

            ; Set colour
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

            lda #CHAR_NOTE
            ldy #0
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

            lda #CHAR_NOTE
            ldy #0
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
            jmp erase_note_t3

erase_note_t1:
            lda note_col,x
            clc
            adc #<(SCREEN + TRACK1_ROW * 40)
            sta ZP_PTR
            lda #>(SCREEN + TRACK1_ROW * 40)
            adc #0
            sta ZP_PTR_HI

            lda #CHAR_TRACK
            ldy #0
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

            lda #CHAR_TRACK
            ldy #0
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

            lda #CHAR_TRACK
            ldy #0
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
; Handle Miss
; ----------------------------------------------------------------------------

handle_miss:
            jsr play_miss_sound
            jsr break_combo

            ; Decrease health
            lda #HEALTH_MISS
            jsr decrease_health

            ; Flash border red
            lda #MISS_COL
            sta BORDER
            lda #8
            sta border_flash

            ; Flash the track where miss happened
            lda miss_track
            cmp #1
            beq flash_miss_t1
            cmp #2
            beq flash_miss_t2
            jmp flash_miss_t3

flash_miss_t1:
            ldx #0
            lda #MISS_COL
flash_m1_loop:
            sta COLRAM + (TRACK1_ROW * 40),x
            inx
            cpx #38
            bne flash_m1_loop
            rts

flash_miss_t2:
            ldx #0
            lda #MISS_COL
flash_m2_loop:
            sta COLRAM + (TRACK2_ROW * 40),x
            inx
            cpx #38
            bne flash_m2_loop
            rts

flash_miss_t3:
            ldx #0
            lda #MISS_COL
flash_m3_loop:
            sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne flash_m3_loop
            rts

; ----------------------------------------------------------------------------
; Play Miss Sound
; ----------------------------------------------------------------------------

play_miss_sound:
            inc miss_count
            jsr display_misses

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
; Play Perfect Sound
; ----------------------------------------------------------------------------

play_perfect_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #PERFECT_SFX_FREQ
            sta SID_V3_FREQ_HI
            lda #PERFECT_SFX_AD
            sta SID_V3_AD
            lda #PERFECT_SFX_SR
            sta SID_V3_SR
            lda #PERFECT_SFX_WAVE
            ora #$01
            sta SID_V3_CTRL
            rts

; ----------------------------------------------------------------------------
; Play Good Sound
; ----------------------------------------------------------------------------

play_good_sound:
            lda #0
            sta SID_V3_FREQ_LO
            lda #GOOD_SFX_FREQ
            sta SID_V3_FREQ_HI
            lda #GOOD_SFX_AD
            sta SID_V3_AD
            lda #GOOD_SFX_SR
            sta SID_V3_SR
            lda #GOOD_SFX_WAVE
            ora #$01
            sta SID_V3_CTRL
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
; Decrease Health
; ----------------------------------------------------------------------------

decrease_health:
            sta temp_track
            lda health
            sec
            sbc temp_track
            bcs health_not_zero
            lda #0
health_not_zero:
            sta health
            jsr display_health

            ; Check for game over
            lda health
            bne no_game_over
            jsr show_gameover
            lda #STATE_GAMEOVER
            sta game_state
no_game_over:
            rts

; ----------------------------------------------------------------------------
; Display Health Bar
; ----------------------------------------------------------------------------

display_health:
            ; Calculate filled blocks (health / 4 = blocks, max 16)
            lda health
            lsr
            lsr
            sta temp_track

            ldx #0
draw_health_bar:
            cpx temp_track
            bcs draw_empty_health
            lda #CHAR_BAR_FULL
            jmp store_health_char
draw_empty_health:
            lda #CHAR_BAR_EMPTY
store_health_char:
            sta SCREEN + (HEALTH_ROW * 40) + 8,x
            lda #HEALTH_COL
            sta COLRAM + (HEALTH_ROW * 40) + 8,x
            inx
            cpx #16
            bne draw_health_bar
            rts

; ----------------------------------------------------------------------------
; Display Progress Bar
; ----------------------------------------------------------------------------

display_progress:
            ; Calculate progress (song_beat / 4)
            lda song_beat
            lsr
            lsr
            sta temp_track

            ldx #0
draw_progress_bar:
            cpx temp_track
            bcs draw_empty_progress
            lda #CHAR_BAR_FULL
            jmp store_progress_char
draw_empty_progress:
            lda #CHAR_BAR_EMPTY
store_progress_char:
            sta SCREEN + (PROGRESS_ROW * 40) + 8,x
            lda #PROGRESS_COL
            sta COLRAM + (PROGRESS_ROW * 40) + 8,x
            inx
            cpx #PROGRESS_WIDTH
            bne draw_progress_bar
            rts

; ----------------------------------------------------------------------------
; Combo System
; ----------------------------------------------------------------------------

increment_combo:
            inc combo
            lda combo
            cmp max_combo
            bcc combo_no_max
            sta max_combo
combo_no_max:
            jsr display_combo
            rts

break_combo:
            lda #0
            sta combo
            jsr display_combo
            rts

display_combo:
            ; Display combo count
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
            sta SCREEN + (COMBO_ROW * 40) + 34

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
            sta SCREEN + (COMBO_ROW * 40) + 35

            pla
            ora #$30
            sta SCREEN + (COMBO_ROW * 40) + 36

            ; Colour based on multiplier
            jsr get_multiplier
            cmp #1
            beq combo_col_1x
            cmp #2
            beq combo_col_2x
            cmp #3
            beq combo_col_3x
            jmp combo_col_4x

combo_col_1x:
            lda #11             ; Grey
            jmp set_combo_col
combo_col_2x:
            lda #7              ; Yellow
            jmp set_combo_col
combo_col_3x:
            lda #5              ; Green
            jmp set_combo_col
combo_col_4x:
            lda #1              ; White

set_combo_col:
            sta COLRAM + (COMBO_ROW * 40) + 34
            sta COLRAM + (COMBO_ROW * 40) + 35
            sta COLRAM + (COMBO_ROW * 40) + 36
            rts

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
; Reset Track Colours
; ----------------------------------------------------------------------------

reset_track_colours:
            ldx #1              ; Start at column 1 (skip label)
reset_col_loop:
            lda #TRACK_LINE_COL
            sta COLRAM + (TRACK1_ROW * 40),x
            sta COLRAM + (TRACK2_ROW * 40),x
            sta COLRAM + (TRACK3_ROW * 40),x
            inx
            cpx #38
            bne reset_col_loop

            ; Restore hit zone colours
            lda #HIT_ZONE_COL
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN

            ; Redraw notes with correct colours
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
; Check Song End
; ----------------------------------------------------------------------------

check_song_end:
            lda song_ended
            beq not_ended

            ; Check if all notes cleared
            ldx #0
check_notes_clear:
            lda note_track,x
            bne not_ended
            inx
            cpx #MAX_NOTES
            bne check_notes_clear

            ; Add delay before results
            inc end_delay
            lda end_delay
            cmp #END_DELAY_FRAMES
            bcc not_ended

            ; Show results
            jsr show_results
            lda #STATE_RESULTS
            sta game_state

not_ended:
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

; ----------------------------------------------------------------------------
; Show Results Screen
; ----------------------------------------------------------------------------

show_results:
            ; Clear screen
            ldx #0
            lda #CHAR_SPACE
clear_results:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_results

            ; Draw "SONG COMPLETE!"
            ldx #0
draw_complete:
            lda complete_text,x
            beq draw_results_score
            sta SCREEN + (5 * 40) + 13,x
            lda #5
            sta COLRAM + (5 * 40) + 13,x
            inx
            jmp draw_complete

draw_results_score:
            ; Draw score label
            ldx #0
draw_rs_label:
            lda results_score_label,x
            beq draw_rs_value
            sta SCREEN + (9 * 40) + 12,x
            lda #7
            sta COLRAM + (9 * 40) + 12,x
            inx
            jmp draw_rs_label

draw_rs_value:
            ; Draw score value
            lda score_lo
            sta work_lo
            lda score_hi
            sta work_hi

            ldx #0
rs_div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc rs_done_10000
            sta work_hi
            sty work_lo
            inx
            jmp rs_div_10000
rs_done_10000:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 23

            ldx #0
rs_div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc rs_done_1000
            sta work_hi
            sty work_lo
            inx
            jmp rs_div_1000
rs_done_1000:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 24

            ldx #0
rs_div_100:
            lda work_lo
            sec
            sbc #100
            bcc rs_done_100
            sta work_lo
            inx
            jmp rs_div_100
rs_done_100:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 25

            ldx #0
rs_div_10:
            lda work_lo
            sec
            sbc #10
            bcc rs_done_10
            sta work_lo
            inx
            jmp rs_div_10
rs_done_10:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 26

            lda work_lo
            ora #$30
            sta SCREEN + (9 * 40) + 27

            lda #7
            sta COLRAM + (9 * 40) + 23
            sta COLRAM + (9 * 40) + 24
            sta COLRAM + (9 * 40) + 25
            sta COLRAM + (9 * 40) + 26
            sta COLRAM + (9 * 40) + 27

            ; Draw perfect count
            ldx #0
draw_perfect_label:
            lda perfect_label,x
            beq draw_perfect_value
            sta SCREEN + (11 * 40) + 12,x
            lda #1
            sta COLRAM + (11 * 40) + 12,x
            inx
            jmp draw_perfect_label

draw_perfect_value:
            lda perfect_count
            ldx #0
pv_div_10:
            cmp #10
            bcc pv_done_10
            sec
            sbc #10
            inx
            jmp pv_div_10
pv_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (11 * 40) + 23
            pla
            ora #$30
            sta SCREEN + (11 * 40) + 24
            lda #1
            sta COLRAM + (11 * 40) + 23
            sta COLRAM + (11 * 40) + 24

            ; Draw good count
            ldx #0
draw_good_label:
            lda good_label,x
            beq draw_good_value
            sta SCREEN + (12 * 40) + 12,x
            lda #7
            sta COLRAM + (12 * 40) + 12,x
            inx
            jmp draw_good_label

draw_good_value:
            lda good_count
            ldx #0
gv_div_10:
            cmp #10
            bcc gv_done_10
            sec
            sbc #10
            inx
            jmp gv_div_10
gv_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (12 * 40) + 23
            pla
            ora #$30
            sta SCREEN + (12 * 40) + 24
            lda #7
            sta COLRAM + (12 * 40) + 23
            sta COLRAM + (12 * 40) + 24

            ; Draw miss count
            ldx #0
draw_miss_label_r:
            lda miss_label_r,x
            beq draw_miss_value
            sta SCREEN + (13 * 40) + 12,x
            lda #2
            sta COLRAM + (13 * 40) + 12,x
            inx
            jmp draw_miss_label_r

draw_miss_value:
            lda miss_count
            ldx #0
mv_div_10:
            cmp #10
            bcc mv_done_10
            sec
            sbc #10
            inx
            jmp mv_div_10
mv_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (13 * 40) + 23
            pla
            ora #$30
            sta SCREEN + (13 * 40) + 24
            lda #2
            sta COLRAM + (13 * 40) + 23
            sta COLRAM + (13 * 40) + 24

            ; Draw max combo
            ldx #0
draw_maxc_label:
            lda maxcombo_label,x
            beq draw_maxc_value
            sta SCREEN + (15 * 40) + 12,x
            lda #COMBO_COL
            sta COLRAM + (15 * 40) + 12,x
            inx
            jmp draw_maxc_label

draw_maxc_value:
            lda max_combo
            ldx #0
mc_div_100:
            cmp #100
            bcc mc_done_100
            sec
            sbc #100
            inx
            jmp mc_div_100
mc_done_100:
            pha
            txa
            ora #$30
            sta SCREEN + (15 * 40) + 23

            pla
            ldx #0
mc_div_10:
            cmp #10
            bcc mc_done_10
            sec
            sbc #10
            inx
            jmp mc_div_10
mc_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (15 * 40) + 24
            pla
            ora #$30
            sta SCREEN + (15 * 40) + 25
            lda #COMBO_COL
            sta COLRAM + (15 * 40) + 23
            sta COLRAM + (15 * 40) + 24
            sta COLRAM + (15 * 40) + 25

            ; Draw "PRESS FIRE"
            ldx #0
draw_return:
            lda return_text,x
            beq results_done
            sta SCREEN + (20 * 40) + 10,x
            lda #11
            sta COLRAM + (20 * 40) + 10,x
            inx
            jmp draw_return

results_done:
            rts

complete_text:
            !scr "song complete!"
            !byte 0

results_score_label:
            !scr "final score:"
            !byte 0

perfect_label:
            !scr "perfect:"
            !byte 0

good_label:
            !scr "good:"
            !byte 0

miss_label_r:
            !scr "misses:"
            !byte 0

maxcombo_label:
            !scr "max combo:"
            !byte 0

return_text:
            !scr "press fire to continue"
            !byte 0

; ----------------------------------------------------------------------------
; Show Game Over Screen
; ----------------------------------------------------------------------------

show_gameover:
            ; Clear screen
            ldx #0
            lda #CHAR_SPACE
clear_gameover:
            sta SCREEN,x
            sta SCREEN+$100,x
            sta SCREEN+$200,x
            sta SCREEN+$2E8,x
            inx
            bne clear_gameover

            ; Draw "GAME OVER"
            ldx #0
draw_gameover_text:
            lda gameover_text,x
            beq draw_gameover_score
            sta SCREEN + (8 * 40) + 15,x
            lda #2
            sta COLRAM + (8 * 40) + 15,x
            inx
            jmp draw_gameover_text

draw_gameover_score:
            ; Draw score
            ldx #0
draw_go_score_label:
            lda gameover_score,x
            beq draw_go_score_value
            sta SCREEN + (12 * 40) + 12,x
            lda #7
            sta COLRAM + (12 * 40) + 12,x
            inx
            jmp draw_go_score_label

draw_go_score_value:
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
            sta SCREEN + (12 * 40) + 23

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
            sta SCREEN + (12 * 40) + 24

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
            sta SCREEN + (12 * 40) + 25

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
            sta SCREEN + (12 * 40) + 26

            lda work_lo
            ora #$30
            sta SCREEN + (12 * 40) + 27

            lda #7
            sta COLRAM + (12 * 40) + 23
            sta COLRAM + (12 * 40) + 24
            sta COLRAM + (12 * 40) + 25
            sta COLRAM + (12 * 40) + 26
            sta COLRAM + (12 * 40) + 27

            ; Draw retry message
            ldx #0
draw_retry:
            lda retry_text,x
            beq gameover_done
            sta SCREEN + (18 * 40) + 10,x
            lda #11
            sta COLRAM + (18 * 40) + 10,x
            inx
            jmp draw_retry

gameover_done:
            rts

gameover_text:
            !scr "game over"
            !byte 0

gameover_score:
            !scr "your score:"
            !byte 0

retry_text:
            !scr "press fire to continue"
            !byte 0

; ============================================================================
; SONG DATA - First Song: "First Steps"
; ============================================================================
; Format: beat, track (1-3), SID frequency high byte
; ============================================================================

song_data:
            ; Opening - gentle introduction
            !byte 0, 1, $47          ; Beat 0: Track 1, high note
            !byte 2, 2, $2C          ; Beat 2: Track 2, mid note
            !byte 4, 3, $11          ; Beat 4: Track 3, low note

            ; Build - add more notes
            !byte 8, 1, $3B
            !byte 10, 2, $27
            !byte 12, 3, $13

            ; Complexity - overlapping patterns
            !byte 16, 1, $35
            !byte 17, 2, $2C
            !byte 18, 1, $3B
            !byte 20, 3, $16

            ; Theme repeats
            !byte 24, 1, $47
            !byte 26, 2, $35
            !byte 28, 3, $11

            ; Variation
            !byte 32, 2, $2F
            !byte 34, 1, $4F
            !byte 36, 3, $17

            ; Building intensity
            !byte 40, 1, $58
            !byte 42, 2, $2C
            !byte 44, 3, $11
            !byte 46, 2, $27

            ; Climax section
            !byte 48, 1, $6A
            !byte 49, 2, $35
            !byte 50, 1, $58
            !byte 52, 3, $1A
            !byte 54, 2, $2F

            ; Resolution
            !byte 56, 1, $47
            !byte 58, 2, $2C
            !byte 60, 3, $11
            !byte 62, 1, $35

            !byte $FF               ; End marker

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

; ============================================================================
; END OF SID SYMPHONY - UNIT 17
; ============================================================================

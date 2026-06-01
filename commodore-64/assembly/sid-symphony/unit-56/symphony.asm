; ============================================================================
; SID SYMPHONY - Unit 56: Loading Screen
; ============================================================================
; This unit explores loading screens - the visual display shown while a game
; loads from tape or disk. We explain the concept without implementing it,
; as our game runs directly from memory in the emulator.
;
; CONCEPTS COVERED:
; - Why loading screens exist (tape/disk wait times)
; - IRQ-driven loaders that show graphics while loading
; - Turbo loader integration techniques
; - Professional polish: music during loading
;
; OUR APPROACH:
; - Game runs from memory (no loading wait)
; - Educational: understand the technique for distribution
; - Future: could add loading screen for .d64 disk image release
;
; Controls: Z = Track 1, X = Track 2, C = Track 3
;           Up/Down = Song selection, Left/Right = Difficulty
;           P = Pause during gameplay, O = Options from menu
;           Fire/Space = Start game
; ============================================================================

; ============================================================================
; CUSTOMISATION SECTION
; ============================================================================

; Screenshot mode - set to 1 to skip title and show menu immediately
; Used for automated screenshot capture. Override with: acme -DSCREENSHOT_MODE=1
!ifndef SCREENSHOT_MODE { SCREENSHOT_MODE = 0 }

; Video mode - set to 1 to skip title AND auto-start gameplay on first song
; Used for automated video capture. Override with: acme -DVIDEO_MODE=1
!ifndef VIDEO_MODE { VIDEO_MODE = 0 }

; Pause screenshot mode - set to 1 to show pause screen for screenshots
; Used for Unit 47 screenshot. Override with: acme -DPAUSE_SCREENSHOT_MODE=1
!ifndef PAUSE_SCREENSHOT_MODE { PAUSE_SCREENSHOT_MODE = 0 }

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

; Menu back sound (Unit 43)
MENU_BACK_FREQ    = $08         ; Lower pitch for back
MENU_BACK_WAVE    = $11         ; Triangle (soft)
MENU_BACK_AD      = $00         ; Instant
MENU_BACK_SR      = $40         ; Very short

; Game over stinger (Unit 43)
GAMEOVER_FREQ     = $06         ; Low, somber
GAMEOVER_WAVE     = $11         ; Triangle
GAMEOVER_AD       = $09         ; Slow attack
GAMEOVER_SR       = $A0         ; Long release

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
EASY_COL    = 5                 ; Green for Easy
NORMAL_COL  = 7                 ; Yellow for Normal
HARD_COL    = 2                 ; Red for Hard

; ============================================================================
; SCORING SETTINGS (BALANCED)
; ============================================================================

PERFECT_SCORE = 100             ; Perfect hit value
GOOD_SCORE    = 50              ; Good hit value

; Streak bonuses (awarded every N consecutive perfects)
STREAK_THRESHOLD = 5            ; Perfect streak bonus every 5 perfects
STREAK_BONUS  = 50              ; Bonus points per streak milestone

; Section completion bonuses (25%, 50%, 75%, 100%)
SECTION_BONUS = 100             ; Bonus per section completed

; Full combo bonus (no misses)
FULL_COMBO_BONUS = 200          ; Bonus if no misses entire song

; Performance grade thresholds (based on accuracy percentage)
; Accuracy = (perfect_count * 100 + good_count * 50) / total_notes
GRADE_S_THRESHOLD = 95          ; 95%+ perfect rate = S rank
GRADE_A_THRESHOLD = 85          ; 85%+ = A rank
GRADE_B_THRESHOLD = 70          ; 70%+ = B rank
GRADE_C_THRESHOLD = 50          ; 50%+ = C rank
                                ; Below 50% = D rank

; ============================================================================
; COMBO SETTINGS (BALANCED)
; ============================================================================

COMBO_TIER_2  = 10              ; 2x multiplier at 10 hits
COMBO_TIER_3  = 25              ; 3x multiplier at 25 hits
COMBO_TIER_4  = 50              ; 4x multiplier at 50 hits

; Combo border colours (escalating intensity)
COMBO_BORDER_0 = 0              ; Black - no combo
COMBO_BORDER_1 = 11             ; Dark grey - building
COMBO_BORDER_2 = 5              ; Green - 2x (tier 2)
COMBO_BORDER_3 = 7              ; Yellow - 3x (tier 3)
COMBO_BORDER_4 = 2              ; Red - 4x (tier 4 / fire!)

; ============================================================================
; HEALTH SETTINGS (BASE VALUES - MODIFIED BY DIFFICULTY)
; ============================================================================

HEALTH_MAX    = 64              ; Maximum health
HEALTH_START  = 32              ; Start at half health
HEALTH_PERFECT = 4              ; Gain 4 for perfect
HEALTH_GOOD   = 2               ; Gain 2 for good

; Health loss per difficulty
HEALTH_MISS_EASY   = 4          ; Forgiving
HEALTH_MISS_NORMAL = 8          ; Balanced
HEALTH_MISS_HARD   = 12         ; Punishing

; ============================================================================
; HIT DETECTION SETTINGS (BASE - MODIFIED BY DIFFICULTY)
; ============================================================================

; Hit zone column range (where notes can be hit)
HIT_ZONE_START = 2              ; Leftmost hittable column
HIT_ZONE_END   = 6              ; Rightmost hittable column

; Perfect timing column (centre of hit zone)
PERFECT_COL_POS = 4

; Beat marker position (visual rhythm indicator)
HIT_ROW        = 20             ; Row for beat marker display

; Timing windows per difficulty (columns from perfect)
; Easy: Perfect ±2, Good ±4
; Normal: Perfect ±1, Good ±2
; Hard: Perfect ±0, Good ±1

PERFECT_WINDOW_EASY   = 2
PERFECT_WINDOW_NORMAL = 1
PERFECT_WINDOW_HARD   = 0

GOOD_WINDOW_EASY      = 4
GOOD_WINDOW_NORMAL    = 2
GOOD_WINDOW_HARD      = 1

; ============================================================================
; DIFFICULTY SETTINGS
; ============================================================================

DIFF_EASY   = 0
DIFF_NORMAL = 1
DIFF_HARD   = 2

; ============================================================================
; SONG SETTINGS
; ============================================================================

PROGRESS_WIDTH = 16             ; Progress bar width

; Per-song tempo (frames per beat)
TEMPO_SONG1   = 25              ; 120 BPM
TEMPO_SONG2   = 23              ; 130 BPM
TEMPO_SONG3   = 20              ; 150 BPM
TEMPO_SONG4   = 24              ; 125 BPM (syncopated feel)
TEMPO_SONG5   = 22              ; 136 BPM (chord-focused)
TEMPO_SONG6   = 23              ; 130 BPM (balanced for mixed techniques)

; Per-song length (beats)
LENGTH_SONG1  = 64
LENGTH_SONG2  = 64
LENGTH_SONG3  = 64
LENGTH_SONG4  = 64
LENGTH_SONG5  = 64
LENGTH_SONG6  = 64

; ============================================================================
; MENU SETTINGS
; ============================================================================

NUM_SONGS     = 6
KEY_DELAY     = 10              ; Frames between key repeats

; ============================================================================
; PRACTICE MODE SETTINGS
; ============================================================================

; Speed multipliers (stored as frame adjustment)
; Higher value = slower (more frames per beat)
SPEED_HALF    = 2               ; 0.5x speed (double frames)
SPEED_3QRTR   = 1               ; 0.75x speed (4/3 frames, approx +1)
SPEED_NORMAL  = 0               ; 1.0x speed (no adjustment)

NUM_SPEEDS    = 3

PRACTICE_COL  = 3               ; Cyan for practice mode indicator

; ============================================================================
; GAME STATES
; ============================================================================

STATE_TITLE   = 0               ; Title screen
STATE_MENU    = 1               ; Song selection menu
STATE_PLAYING = 2               ; Gameplay
STATE_RESULTS = 3               ; Success results
STATE_GAMEOVER = 4              ; Failure game over
STATE_ATTRACT = 5               ; Attract mode / demo
STATE_OPTIONS = 6               ; Options screen (Unit 46)

; Attract mode settings
IDLE_THRESHOLD = 250            ; Frames before attract (5 seconds at 50fps)

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
SID_V3_PWLO = $D410
SID_V3_PWHI = $D411
SID_V3_CTRL = $D412
SID_V3_AD   = $D413
SID_V3_SR   = $D414

SID_FILT_LO = $D415             ; Filter cutoff low (Unit 41)
SID_FILT_HI = $D416             ; Filter cutoff high
SID_RESON   = $D417             ; Resonance + filter routing
SID_VOLUME  = $D418             ; Mode/Volume

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
HIT_ZONE_COLUMN = 3             ; Where notes are hit (visual)

; Custom character codes
CHAR_NOTE   = 128
CHAR_TRACK  = 129
CHAR_HITZONE = 130
CHAR_SPACE  = 32
CHAR_BAR_FULL = 131
CHAR_BAR_EMPTY = 132
CHAR_CURSOR = 62                ; > character for menu cursor
CHAR_ARROW_L = 60               ; < for difficulty
CHAR_ARROW_R = 62               ; > for difficulty

; Logo characters (for title screen design)
CHAR_LOGO_TL = 133              ; Top-left corner
CHAR_LOGO_TR = 134              ; Top-right corner
CHAR_LOGO_BL = 135              ; Bottom-left corner
CHAR_LOGO_BR = 136              ; Bottom-right corner
CHAR_LOGO_H  = 137              ; Horizontal bar
CHAR_LOGO_V  = 138              ; Vertical bar
CHAR_LOGO_FULL = 139            ; Full block
CHAR_LOGO_HALF_T = 140          ; Half block top
CHAR_LOGO_HALF_B = 141          ; Half block bottom
CHAR_LOGO_DOT = 142             ; Centre dot (for decorative)

; Note settings
MAX_NOTES   = 8                 ; Maximum simultaneous notes
NOTE_SPAWN_COL = 37             ; Where notes appear

; Timing
END_DELAY_FRAMES = 75           ; 1.5 seconds after song ends

; Zero page
ZP_PTR      = $FB
ZP_PTR_HI   = $FC
ZP_TEMP     = $FD               ; Temporary calculation

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
cursor_pos  = $10               ; Menu cursor position
key_delay_count = $11           ; Key repeat delay counter
selected_song = $12             ; Which song to play
frames_per_beat = $13           ; Current song's tempo
song_length = $14               ; Current song's length
difficulty  = $15               ; 0=Easy, 1=Normal, 2=Hard
perfect_window = $16            ; Current perfect timing window
good_window = $17               ; Current good timing window
health_miss_amt = $18           ; Health loss on miss
practice_mode = $19             ; 0=Normal play, 1=Practice mode
speed_setting = $1A             ; 0=0.5x, 1=0.75x, 2=1.0x
bg_flash      = $1B             ; Background flash countdown (visual polish)
beat_pulse    = $1C             ; Beat marker pulse state
endless_mode  = $1D             ; 0=Normal (song ends), 1=Endless (loops)
loop_count    = $1E             ; Number of loops completed in endless mode
perfect_streak = $1F            ; Current consecutive perfect hits
best_streak   = $20             ; Best perfect streak this song
section_bonus = $21             ; Accumulated section bonus points
notes_hit     = $22             ; Total notes hit (for accuracy calc)
current_grade = $23             ; Current performance grade letter (screen code)
current_grade_col = $24         ; Colour for current grade
title_anim_frame = $25          ; Title screen animation frame counter
idle_timer       = $26          ; Frames since last input (for attract mode)
attract_note_idx = $27          ; Demo playback note index
attract_timer    = $28          ; Demo timing counter
perfect_effect   = $29          ; Perfect hit effect countdown
perfect_track    = $2A          ; Which track showed last perfect (1-3)
good_effect      = $2B          ; Good hit effect countdown
good_track       = $2C          ; Which track showed last good (1-3)
miss_effect      = $2D          ; Miss effect countdown
; miss_track is already defined earlier at $0A
screen_shake     = $2E          ; Screen shake countdown
bg_cycle         = $2F          ; Background colour cycle counter (Unit 40)
bg_intensity     = $30          ; Background intensity level (0-3, based on combo)
voice_callout    = $31          ; Voice callout countdown (Unit 41)
voice_freq_hi    = $32          ; Current voice frequency high byte
voice_freq_lo    = $33          ; Current voice frequency low byte
last_milestone   = $34          ; Last milestone reached (prevents re-trigger)
filter_sweep     = $35          ; Perfect hit filter sweep countdown (Unit 42)
base_filter      = $36          ; Base filter cutoff (varies with combo/health)
jingle_playing   = $37          ; Currently playing jingle (0=none, 1=victory, 2=gameover)
jingle_pos       = $38          ; Position in jingle data
jingle_timer     = $39          ; Frames until next note
results_phase    = $3A          ; Results animation phase (Unit 44)
results_timer    = $3B          ; Timer for current phase
display_score_lo = $3C          ; Currently displayed score (animating up)
display_score_hi = $3D          ; High byte of displayed score
new_high_score   = $3E          ; Flag: 1 = achieved new high score
grade_flash      = $3F          ; Grade flash animation counter

; Unit 45: High Score Table Variables
name_entry_mode  = $40          ; 1 = currently entering name
name_cursor      = $41          ; Current letter position (0-2)
name_char_0      = $42          ; First letter of name
name_char_1      = $43          ; Second letter
name_char_2      = $44          ; Third letter
name_flash       = $45          ; Flash timer for current letter
hs_table_rank    = $46          ; Rank achieved (0-4, or $FF if not in top 5)
hs_temp          = $47          ; Temp storage for table operations

; Unit 46: Options Screen Variables
options_cursor   = $48          ; Options menu cursor position (0-3)
sound_test_idx   = $49          ; Current sound in sound test (0-8)
options_state    = $4A          ; 0=menu, 1=sound test, 2=stats

; Unit 47: Pause Functionality Variables
game_paused      = $4B          ; 1 = game is paused
pause_cursor     = $4C          ; Pause menu cursor (0=Resume, 1=Restart, 2=Quit)
countdown_value  = $4D          ; Resume countdown (3, 2, 1, 0)
countdown_timer  = $4E          ; Frames remaining for current countdown number

; Unit 50: Shared Temporary Workspace
; These variables can be reused by any routine that doesn't call other routines
; using them. Saves allocating separate temps for each routine.
temp_a           = $50          ; General purpose temp A
temp_b           = $51          ; General purpose temp B
temp_c           = $52          ; General purpose temp C
work_lo          = $53          ; 16-bit workspace low byte
work_hi          = $54          ; 16-bit workspace high byte

; Zero page summary (Unit 50):
; $02-$4E: Game state variables (77 bytes)
; $50-$54: Shared workspace (5 bytes)
; $FB-$FD: Pointer/temp workspace (3 bytes)
; Total used: 85 bytes of 254 available (33%)

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

            ; Start with Normal difficulty
            lda #DIFF_NORMAL
            sta difficulty

            ; Practice mode off, normal speed
            lda #0
            sta practice_mode
            lda #NUM_SPEEDS-1       ; Start at 1.0x (normal speed)
            sta speed_setting

!if PAUSE_SCREENSHOT_MODE = 1 {
            ; Pause screenshot mode: start game and immediately pause
            jsr show_menu
            jsr menu_fire_pressed
            ; Now in STATE_PLAYING - pause immediately
            jsr pause_game
            ; State is STATE_PLAYING with game_paused = 1
} else {
  !if VIDEO_MODE = 1 {
            ; Video mode: skip title, start first song immediately
            ; Initialize menu (sets cursor_pos = 0 for first song)
            jsr show_menu
            ; Trigger fire pressed to start the game
            jsr menu_fire_pressed
            ; State is now STATE_PLAYING
  } else {
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
  }
}

; ============================================================================
; MAIN LOOP - Raster Timing (Unit 52)
; ============================================================================
; The VIC-II draws the screen line by line, 50 times per second (PAL).
; The current line being drawn is in $D012 (raster register).
;
; PAL screen layout:
; Lines 0-50:     Top border (not visible on most TVs)
; Lines 51-250:   Visible screen area (200 lines)
; Lines 251-311:  Bottom border and vertical blank
;
; We sync to line 255 ($FF) because:
; 1. It's in the bottom border - safe to update screen memory
; 2. All visible content has been drawn this frame
; 3. We have until line 50 next frame before visible drawing starts
;
; This gives us the entire vertical blank period (~4,500 cycles) plus
; the top border period for time-critical updates.
;
; POLLING vs INTERRUPTS:
; - Polling (our approach): Simple, predictable, sufficient for our needs
; - Interrupts: More complex, but frees CPU during wait period
;
; For a rhythm game with 16% CPU usage, polling is the right choice.
; ============================================================================

main_loop:
            ; Unit 52: Wait for raster line 255 (bottom border)
            ; This ensures all screen updates happen during vertical blank
            lda #$FF
wait_raster:
            cmp $D012               ; Compare with current raster line
            bne wait_raster         ; Loop until we hit line 255

            ; Unit 51: State dispatch - most common states checked first
            lda game_state
            cmp #STATE_TITLE
            beq do_title
            cmp #STATE_MENU
            beq do_menu
            cmp #STATE_PLAYING
            beq do_playing
            cmp #STATE_RESULTS
            beq do_results
            cmp #STATE_ATTRACT
            beq do_attract
            cmp #STATE_OPTIONS
            beq do_options
            jmp do_gameover

do_title:
            jsr update_title
            jmp main_loop

do_attract:
            jsr update_attract
            jmp main_loop

do_options:
            jsr update_options
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

            ; ----------------------------------------
            ; Draw decorative top border (row 2)
            ; ----------------------------------------
            ldx #0
draw_top_border:
            lda logo_top_border,x
            beq draw_top_done
            sta SCREEN + (2 * 40) + 10,x
            lda #6              ; Blue
            sta COLRAM + (2 * 40) + 10,x
            inx
            jmp draw_top_border
draw_top_done:

            ; ----------------------------------------
            ; Draw logo row 1 (row 4) - using block chars
            ; ----------------------------------------
            ldx #0
draw_logo_row1:
            lda logo_row1,x
            beq draw_logo1_done
            sta SCREEN + (4 * 40) + 12,x
            lda #14             ; Light blue
            sta COLRAM + (4 * 40) + 12,x
            inx
            jmp draw_logo_row1
draw_logo1_done:

            ; ----------------------------------------
            ; Draw logo row 2 (row 5)
            ; ----------------------------------------
            ldx #0
draw_logo_row2:
            lda logo_row2,x
            beq draw_logo2_done
            sta SCREEN + (5 * 40) + 12,x
            lda #14             ; Light blue
            sta COLRAM + (5 * 40) + 12,x
            inx
            jmp draw_logo_row2
draw_logo2_done:

            ; ----------------------------------------
            ; Draw logo row 3 (row 6)
            ; ----------------------------------------
            ldx #0
draw_logo_row3:
            lda logo_row3,x
            beq draw_logo3_done
            sta SCREEN + (6 * 40) + 12,x
            lda #6              ; Blue
            sta COLRAM + (6 * 40) + 12,x
            inx
            jmp draw_logo_row3
draw_logo3_done:

            ; ----------------------------------------
            ; Draw "SYMPHONY" text (row 8)
            ; ----------------------------------------
            ldx #0
draw_symphony:
            lda symphony_text,x
            beq draw_symphony_done
            sta SCREEN + (8 * 40) + 14,x
            lda #1              ; White
            sta COLRAM + (8 * 40) + 14,x
            inx
            jmp draw_symphony
draw_symphony_done:

            ; ----------------------------------------
            ; Draw decorative separator (row 10)
            ; ----------------------------------------
            ldx #0
draw_separator:
            lda separator_text,x
            beq draw_sep_done
            sta SCREEN + (10 * 40) + 10,x
            lda #11             ; Dark grey
            sta COLRAM + (10 * 40) + 10,x
            inx
            jmp draw_separator
draw_sep_done:

            ; ----------------------------------------
            ; Draw "A RHYTHM GAME" subtitle (row 12)
            ; ----------------------------------------
            ldx #0
draw_subtitle:
            lda subtitle_text,x
            beq draw_subtitle_done
            sta SCREEN + (12 * 40) + 13,x
            lda #SUBTITLE_COL
            sta COLRAM + (12 * 40) + 13,x
            inx
            jmp draw_subtitle
draw_subtitle_done:

            ; ----------------------------------------
            ; Draw controls info (row 15)
            ; ----------------------------------------
            ldx #0
draw_controls:
            lda controls_text,x
            beq draw_controls_done
            sta SCREEN + (15 * 40) + 10,x
            lda #11             ; Dark grey
            sta COLRAM + (15 * 40) + 10,x
            inx
            jmp draw_controls
draw_controls_done:

            ; ----------------------------------------
            ; Draw track keys (row 17)
            ; ----------------------------------------
            ldx #0
draw_track_keys:
            lda track_keys_text,x
            beq draw_keys_done
            sta SCREEN + (17 * 40) + 8,x
            lda #15             ; Light grey
            sta COLRAM + (17 * 40) + 8,x
            inx
            jmp draw_track_keys
draw_keys_done:

            ; ----------------------------------------
            ; Draw "PRESS FIRE TO START" (row 21)
            ; ----------------------------------------
            ldx #0
draw_press_fire:
            lda press_fire_text,x
            beq draw_press_done
            sta SCREEN + (21 * 40) + 10,x
            lda #7              ; Yellow
            sta COLRAM + (21 * 40) + 10,x
            inx
            jmp draw_press_fire
draw_press_done:

            ; ----------------------------------------
            ; Draw version (row 24)
            ; ----------------------------------------
            ldx #0
draw_version:
            lda version_text,x
            beq draw_version_done
            sta SCREEN + (24 * 40) + 14,x
            lda #11             ; Dark grey
            sta COLRAM + (24 * 40) + 14,x
            inx
            jmp draw_version
draw_version_done:

            rts

; Logo data using custom block characters
; Creates a stylized "SID" in large block letters

logo_top_border:
            !byte CHAR_LOGO_TL, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_TR
            !byte 0

logo_row1:
            ; S       I       D
            !byte CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE
            !byte 0

logo_row2:
            ; S       I       D
            !byte CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_SPACE, CHAR_LOGO_FULL, CHAR_SPACE, CHAR_SPACE
            !byte CHAR_LOGO_FULL, CHAR_SPACE, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE
            !byte 0

logo_row3:
            ; S       I       D
            !byte CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_LOGO_FULL, CHAR_SPACE
            !byte CHAR_SPACE, CHAR_SPACE, CHAR_SPACE, CHAR_SPACE
            !byte 0

symphony_text:
            !scr "s y m p h o n y"
            !byte 0

separator_text:
            !byte CHAR_LOGO_DOT, CHAR_SPACE, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H, CHAR_LOGO_H
            !byte CHAR_LOGO_H, CHAR_LOGO_H, CHAR_SPACE, CHAR_LOGO_DOT
            !byte 0

subtitle_text:
            !scr "a rhythm game"
            !byte 0

controls_text:
            !scr "controls: z / x / c"
            !byte 0

track_keys_text:
            !scr "hit notes as they pass the zone"
            !byte 0

press_fire_text:
            !scr "press fire to start"
            !byte 0

version_text:
            !scr "phase 4 v0.8"
            !byte 0

; ----------------------------------------------------------------------------
; Update Title State
; ----------------------------------------------------------------------------

update_title:
            ; ----------------------------------------
            ; Animate title screen
            ; ----------------------------------------
            jsr animate_title

            ; ----------------------------------------
            ; Check for input
            ; ----------------------------------------

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

            ; No input - increment idle timer
            lda #$FF
            sta CIA1_PRA

            ; Increment idle timer and check threshold
            inc idle_timer
            lda idle_timer
            cmp #IDLE_THRESHOLD
            bcc title_no_attract

            ; Idle threshold reached - start attract mode
            jsr show_attract
            lda #STATE_ATTRACT
            sta game_state

title_no_attract:
            rts

title_fire_pressed:
            ; Reset idle timer on any input
            lda #0
            sta idle_timer
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
; Animate Title Screen
; ----------------------------------------------------------------------------
; Called every frame while on title. Creates visual polish:
; - Logo colour cycles through blues
; - "PRESS FIRE" pulses between yellow and white
; ----------------------------------------------------------------------------

animate_title:
            ; Increment animation frame
            inc title_anim_frame

            ; ----------------------------------------
            ; Logo colour cycling (every 8 frames)
            ; ----------------------------------------
            lda title_anim_frame
            and #$18            ; Check bits 3-4 (cycle every 8-24 frames)
            lsr
            lsr
            lsr                 ; Now 0, 1, 2, or 3
            tax
            lda logo_colours,x

            ; Apply to logo row 1 (row 4)
            ldx #15
anim_logo1:
            sta COLRAM + (4 * 40) + 12,x
            dex
            bpl anim_logo1

            ; Apply to logo row 2 (row 5)
            ldx #15
anim_logo2:
            sta COLRAM + (5 * 40) + 12,x
            dex
            bpl anim_logo2

            ; ----------------------------------------
            ; "PRESS FIRE" colour pulse (every 16 frames)
            ; ----------------------------------------
            lda title_anim_frame
            and #$10            ; Toggle every 16 frames
            beq press_fire_yellow
            lda #1              ; White
            jmp set_press_fire_col
press_fire_yellow:
            lda #7              ; Yellow
set_press_fire_col:
            ldx #18             ; Length of "press fire to start"
anim_press_fire:
            sta COLRAM + (21 * 40) + 10,x
            dex
            bpl anim_press_fire

            rts

; Logo colour cycle table (blues and cyan)
logo_colours:
            !byte 14            ; Light blue
            !byte 6             ; Blue
            !byte 3             ; Cyan
            !byte 14            ; Light blue

; ----------------------------------------------------------------------------
; Attract Mode
; ----------------------------------------------------------------------------
; Auto-plays a demo when the title screen is idle for too long.
; Demonstrates the game to entice players. Any input returns to title.
; ----------------------------------------------------------------------------

show_attract:
            ; Set up for demo playback
            lda #0
            sta attract_note_idx
            sta attract_timer
            sta score_lo
            sta score_hi
            sta combo
            sta miss_count
            sta notes_hit

            ; Use song 1 (easiest) for demo
            lda #0
            sta selected_song
            sta song_pos
            sta song_pos_hi
            sta frame_count

            ; Initialise health for display
            lda #HEALTH_START
            sta health

            ; Set up screen (clear, draw tracks, hit zones)
            jsr init_screen

            ; Initialise notes array
            jsr init_notes

            ; Show demo overlay message at top
            ldx #0
draw_demo_text:
            lda demo_overlay_text,x
            beq draw_demo_done
            sta SCREEN + (0 * 40) + 16,x
            lda #7              ; Yellow
            sta COLRAM + (0 * 40) + 16,x
            inx
            jmp draw_demo_text
draw_demo_done:

            ; Show "PRESS ANY KEY" message
            ldx #0
draw_press_any:
            lda press_any_text,x
            beq draw_press_any_done
            sta SCREEN + (24 * 40) + 11,x
            lda #1              ; White (flashing later)
            sta COLRAM + (24 * 40) + 11,x
            inx
            jmp draw_press_any
draw_press_any_done:

            rts

; ----------------------------------------------------------------------------
; Update Attract Mode
; ----------------------------------------------------------------------------
; Runs demo playback and checks for any input to exit.
; ----------------------------------------------------------------------------

update_attract:
            ; ----------------------------------------
            ; Check for any input to exit attract mode
            ; ----------------------------------------

            ; Check joystick (any direction or fire)
            lda CIA1_PRA
            and #$1F            ; Check all joystick bits
            cmp #$1F            ; All released?
            bne attract_exit

            ; Check common keys (space, return, F-keys)
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10            ; Space
            beq attract_exit

            lda #$FF
            sta CIA1_PRA

            ; ----------------------------------------
            ; Animate "PRESS ANY KEY" text
            ; ----------------------------------------
            inc title_anim_frame
            lda title_anim_frame
            and #$10
            beq attract_white
            lda #7              ; Yellow
            jmp attract_set_press
attract_white:
            lda #1              ; White
attract_set_press:
            ldx #16             ; "press any key" length
attract_press_loop:
            sta COLRAM + (24 * 40) + 11,x
            dex
            bpl attract_press_loop

            ; ----------------------------------------
            ; Run demo playback
            ; ----------------------------------------
            jsr demo_playback

            rts

attract_exit:
            lda #$FF
            sta CIA1_PRA

            ; Reset idle timer
            lda #0
            sta idle_timer
            sta title_anim_frame

            ; Return to title screen
            jsr show_title
            lda #STATE_TITLE
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Demo Playback
; ----------------------------------------------------------------------------
; Simulates gameplay using pre-recorded note patterns.
; Notes move horizontally from right (column 37) to left (hit zone at column 2-6).
; Auto-hits notes when they reach the hit zone.
; ----------------------------------------------------------------------------

demo_playback:
            ; Increment demo timer
            inc attract_timer

            ; Check if time to spawn a demo note (every 16 frames)
            lda attract_timer
            and #$0F
            bne demo_update_notes

            ; Spawn note from demo pattern
            ldx attract_note_idx
            cpx #DEMO_PATTERN_LEN
            bcc demo_spawn_note

            ; Pattern complete - restart
            lda #0
            sta attract_note_idx
            tax

demo_spawn_note:
            lda demo_pattern,x
            beq demo_no_spawn   ; 0 = no note this beat

            ; Find free note slot
            ldy #0
demo_find_slot:
            lda note_track,y
            beq demo_use_slot   ; 0 = empty slot
            iny
            cpy #MAX_NOTES
            bcc demo_find_slot
            jmp demo_no_spawn   ; No free slots

demo_use_slot:
            ; Set track from demo pattern (1, 2, or 3)
            lda demo_pattern,x
            sta note_track,y

            ; Start at right edge
            lda #NOTE_SPAWN_COL
            sta note_col,y

            ; Draw the new note
            tya
            pha
            txa
            pha
            tya
            tax
            jsr draw_note
            pla
            tax
            pla
            tay

demo_no_spawn:
            inc attract_note_idx

demo_update_notes:
            ; Update all active notes (move left, check for hit zone)
            ldx #0
demo_note_loop:
            lda note_track,x
            beq demo_next_note  ; Skip empty slots

            ; Erase note at current position
            jsr erase_note

            ; Move note left
            dec note_col,x

            ; Check if note reached hit zone (column 2-6)
            lda note_col,x
            cmp #HIT_ZONE_START
            bcs demo_draw_note  ; Not at hit zone yet

            ; Note reached hit zone - auto-hit it!
            ; Remove the note
            lda #0
            sta note_track,x

            ; Flash border briefly for feedback
            lda #1              ; White
            sta $D020

            ; Increment score
            inc score_lo

            jmp demo_next_note

demo_draw_note:
            ; Draw note at new position
            jsr draw_note

demo_next_note:
            inx
            cpx #MAX_NOTES
            bcc demo_note_loop

            ; Reset border colour
            lda #BORDER_COL
            sta $D020

            rts

; Demo pattern - which track (1, 2, or 3) to spawn note on, 0 = no note
; Simple pattern that demonstrates all 3 tracks
demo_pattern:
            !byte 1, 0, 2, 0    ; Track 1, pause, Track 2, pause
            !byte 3, 0, 1, 0    ; Track 3, pause, Track 1, pause
            !byte 1, 2, 0, 0    ; Two quick notes (tracks 1 and 2)
            !byte 2, 3, 0, 0    ; Two more quick (tracks 2 and 3)
            !byte 1, 0, 0, 0    ; Single notes with space
            !byte 2, 0, 0, 0
            !byte 3, 0, 0, 0
            !byte 1, 0, 0, 0
            !byte 1, 2, 3, 0    ; Rapid fire all 3 tracks
            !byte 0, 0, 0, 0    ; Pause
            !byte 2, 0, 3, 0    ; Alternate pattern
            !byte 1, 0, 2, 0

DEMO_PATTERN_LEN = * - demo_pattern

; Attract mode overlay texts
demo_overlay_text:
            !scr "- demo -"
            !byte 0

press_any_text:
            !scr "press any key"
            !byte 0

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
            sta SCREEN + (3 * 40) + 12,x
            lda #TITLE_COL
            sta COLRAM + (3 * 40) + 12,x
            inx
            jmp draw_menu_title
draw_menu_title_done:

            ; Draw song list
            jsr draw_song_list

            ; Draw difficulty section
            jsr draw_difficulty

            ; Draw practice mode section
            jsr draw_practice_mode

            ; Draw instructions on row 24 (below Endless on row 23)
            ldx #0
draw_menu_instr:
            lda menu_instructions,x
            beq draw_menu_instr_done
            sta SCREEN + (24 * 40) + 1,x
            lda #SUBTITLE_COL
            sta COLRAM + (24 * 40) + 1,x
            inx
            jmp draw_menu_instr
draw_menu_instr_done:

            rts

menu_title:
            !scr "select a song"
            !byte 0

menu_instructions:
            !scr "up/down:song  left/right:difficulty"
            !byte 0

practice_instructions:
            !scr "p:practice  +/-:speed"
            !byte 0

; ----------------------------------------------------------------------------
; Draw Song List
; ----------------------------------------------------------------------------

draw_song_list:
            ; Song 1: "First Steps" (120 BPM)
            ldx #0
draw_song1:
            lda song1_name,x
            beq draw_song1_done
            sta SCREEN + (8 * 40) + 14,x
            lda #MENU_COL
            sta COLRAM + (8 * 40) + 14,x
            inx
            jmp draw_song1
draw_song1_done:

            ; Song 1 tempo info
            ldx #0
draw_tempo1:
            lda song1_tempo_text,x
            beq draw_tempo1_done
            sta SCREEN + (8 * 40) + 27,x
            lda #SUBTITLE_COL
            sta COLRAM + (8 * 40) + 27,x
            inx
            jmp draw_tempo1
draw_tempo1_done:

            ; Song 2: "Upbeat Groove" (130 BPM)
            ldx #0
draw_song2:
            lda song2_name,x
            beq draw_song2_done
            sta SCREEN + (10 * 40) + 14,x
            lda #MENU_COL
            sta COLRAM + (10 * 40) + 14,x
            inx
            jmp draw_song2
draw_song2_done:

            ; Song 2 tempo info
            ldx #0
draw_tempo2:
            lda song2_tempo_text,x
            beq draw_tempo2_done
            sta SCREEN + (10 * 40) + 27,x
            lda #SUBTITLE_COL
            sta COLRAM + (10 * 40) + 27,x
            inx
            jmp draw_tempo2
draw_tempo2_done:

            ; Song 3: "Speed Rush" (150 BPM)
            ldx #0
draw_song3:
            lda song3_name,x
            beq draw_song3_done
            sta SCREEN + (12 * 40) + 14,x
            lda #MENU_COL
            sta COLRAM + (12 * 40) + 14,x
            inx
            jmp draw_song3
draw_song3_done:

            ; Song 3 tempo info
            ldx #0
draw_tempo3:
            lda song3_tempo_text,x
            beq draw_tempo3_done
            sta SCREEN + (12 * 40) + 27,x
            lda #SUBTITLE_COL
            sta COLRAM + (12 * 40) + 27,x
            inx
            jmp draw_tempo3
draw_tempo3_done:

            ; Song 4: "Off-Beat" (125 BPM)
            ldx #0
draw_song4:
            lda song4_name,x
            beq draw_song4_done
            sta SCREEN + (14 * 40) + 14,x
            lda #MENU_COL
            sta COLRAM + (14 * 40) + 14,x
            inx
            jmp draw_song4
draw_song4_done:

            ; Song 4 tempo info
            ldx #0
draw_tempo4:
            lda song4_tempo_text,x
            beq draw_tempo4_done
            sta SCREEN + (14 * 40) + 27,x
            lda #SUBTITLE_COL
            sta COLRAM + (14 * 40) + 27,x
            inx
            jmp draw_tempo4
draw_tempo4_done:

            ; Song 5: "Chordstorm" (136 BPM)
            ldx #0
draw_song5:
            lda song5_name,x
            beq draw_song5_done
            sta SCREEN + (16 * 40) + 14,x
            lda #MENU_COL
            sta COLRAM + (16 * 40) + 14,x
            inx
            jmp draw_song5
draw_song5_done:

            ; Song 5 tempo info
            ldx #0
draw_tempo5:
            lda song5_tempo_text,x
            beq draw_tempo5_done
            sta SCREEN + (16 * 40) + 27,x
            lda #SUBTITLE_COL
            sta COLRAM + (16 * 40) + 27,x
            inx
            jmp draw_tempo5
draw_tempo5_done:

            ; Song 6: "Fusion" (130 BPM)
            ldx #0
draw_song6:
            lda song6_name,x
            beq draw_song6_done
            sta SCREEN + (18 * 40) + 14,x
            lda #MENU_COL
            sta COLRAM + (18 * 40) + 14,x
            inx
            jmp draw_song6
draw_song6_done:

            ; Song 6 tempo info
            ldx #0
draw_tempo6:
            lda song6_tempo_text,x
            beq draw_tempo6_done
            sta SCREEN + (18 * 40) + 27,x
            lda #SUBTITLE_COL
            sta COLRAM + (18 * 40) + 27,x
            inx
            jmp draw_tempo6
draw_tempo6_done:

            ; Draw cursor at current position
            jsr draw_cursor
            rts

; Song names and info
song1_name:
            !scr "first steps"
            !byte 0

song1_tempo_text:
            !scr "(120 bpm)"
            !byte 0

song2_name:
            !scr "upbeat groove"
            !byte 0

song2_tempo_text:
            !scr "(130 bpm)"
            !byte 0

song3_name:
            !scr "speed rush"
            !byte 0

song3_tempo_text:
            !scr "(150 bpm)"
            !byte 0

song4_name:
            !scr "off-beat"
            !byte 0

song4_tempo_text:
            !scr "(125 bpm)"
            !byte 0

song5_name:
            !scr "chordstorm"
            !byte 0

song5_tempo_text:
            !scr "(136 bpm)"
            !byte 0

song6_name:
            !scr "fusion"
            !byte 0

song6_tempo_text:
            !scr "(130 bpm)"
            !byte 0

; ----------------------------------------------------------------------------
; Draw Difficulty Selection
; ----------------------------------------------------------------------------

draw_difficulty:
            ; Draw "DIFFICULTY:" label
            ldx #0
draw_diff_label:
            lda diff_label,x
            beq draw_diff_label_done
            sta SCREEN + (20 * 40) + 10,x
            lda #TITLE_COL
            sta COLRAM + (20 * 40) + 10,x
            inx
            jmp draw_diff_label
draw_diff_label_done:

            ; Draw arrows
            lda #CHAR_ARROW_L
            sta SCREEN + (20 * 40) + 22
            lda #SUBTITLE_COL
            sta COLRAM + (20 * 40) + 22

            lda #CHAR_ARROW_R
            sta SCREEN + (20 * 40) + 30
            lda #SUBTITLE_COL
            sta COLRAM + (20 * 40) + 30

            ; Draw current difficulty
            jsr draw_current_difficulty

            rts

diff_label:
            !scr "difficulty:"
            !byte 0

; ----------------------------------------------------------------------------
; Draw Current Difficulty Name
; ----------------------------------------------------------------------------

draw_current_difficulty:
            ; Clear difficulty name area
            lda #CHAR_SPACE
            sta SCREEN + (20 * 40) + 24
            sta SCREEN + (20 * 40) + 25
            sta SCREEN + (20 * 40) + 26
            sta SCREEN + (20 * 40) + 27
            sta SCREEN + (20 * 40) + 28

            lda difficulty
            cmp #DIFF_EASY
            beq draw_diff_easy
            cmp #DIFF_NORMAL
            beq draw_diff_normal
            jmp draw_diff_hard

draw_diff_easy:
            ldx #0
draw_easy_text:
            lda easy_text,x
            beq draw_diff_done
            sta SCREEN + (20 * 40) + 24,x
            lda #EASY_COL
            sta COLRAM + (20 * 40) + 24,x
            inx
            jmp draw_easy_text

draw_diff_normal:
            ldx #0
draw_normal_text:
            lda normal_text,x
            beq draw_diff_done
            sta SCREEN + (20 * 40) + 24,x
            lda #NORMAL_COL
            sta COLRAM + (20 * 40) + 24,x
            inx
            jmp draw_normal_text

draw_diff_hard:
            ldx #0
draw_hard_text:
            lda hard_text,x
            beq draw_diff_done
            sta SCREEN + (20 * 40) + 24,x
            lda #HARD_COL
            sta COLRAM + (20 * 40) + 24,x
            inx
            jmp draw_hard_text

draw_diff_done:
            rts

easy_text:
            !scr "easy"
            !byte 0

normal_text:
            !scr "normal"
            !byte 0

hard_text:
            !scr "hard"
            !byte 0

; ----------------------------------------------------------------------------
; Draw Practice Mode Section
; ----------------------------------------------------------------------------

draw_practice_mode:
            ; Draw "PRACTICE:" label
            ldx #0
draw_prac_label:
            lda prac_label,x
            beq draw_prac_label_done
            sta SCREEN + (21 * 40) + 12,x
            lda #TITLE_COL
            sta COLRAM + (21 * 40) + 12,x
            inx
            jmp draw_prac_label
draw_prac_label_done:

            ; Draw current state
            jsr draw_practice_state

            ; Draw speed section
            ldx #0
draw_speed_label:
            lda speed_label,x
            beq draw_speed_label_done
            sta SCREEN + (22 * 40) + 14,x
            lda #TITLE_COL
            sta COLRAM + (22 * 40) + 14,x
            inx
            jmp draw_speed_label
draw_speed_label_done:

            jsr draw_speed_state

            ; Draw endless section
            ldx #0
draw_endless_label:
            lda endless_label,x
            beq draw_endless_label_done
            sta SCREEN + (23 * 40) + 13,x
            lda #TITLE_COL
            sta COLRAM + (23 * 40) + 13,x
            inx
            jmp draw_endless_label
draw_endless_label_done:

            jsr draw_endless_state
            rts

prac_label:
            !scr "practice:"
            !byte 0

speed_label:
            !scr "speed:"
            !byte 0

endless_label:
            !scr "endless:"
            !byte 0

; Draw ON/OFF based on practice_mode
draw_practice_state:
            lda practice_mode
            beq draw_prac_off
            ; Draw ON
            lda #'o'
            sta SCREEN + (21 * 40) + 22
            lda #'n'
            sta SCREEN + (21 * 40) + 23
            lda #CHAR_SPACE
            sta SCREEN + (21 * 40) + 24
            lda #PRACTICE_COL
            sta COLRAM + (21 * 40) + 22
            sta COLRAM + (21 * 40) + 23
            rts

draw_prac_off:
            ; Draw OFF
            lda #'o'
            sta SCREEN + (21 * 40) + 22
            lda #'f'
            sta SCREEN + (21 * 40) + 23
            lda #'f'
            sta SCREEN + (21 * 40) + 24
            lda #SUBTITLE_COL
            sta COLRAM + (21 * 40) + 22
            sta COLRAM + (21 * 40) + 23
            sta COLRAM + (21 * 40) + 24
            rts

; Draw speed (0.5x / 0.75x / 1.0x)
draw_speed_state:
            ; Clear speed area
            lda #CHAR_SPACE
            sta SCREEN + (22 * 40) + 21
            sta SCREEN + (22 * 40) + 22
            sta SCREEN + (22 * 40) + 23
            sta SCREEN + (22 * 40) + 24
            sta SCREEN + (22 * 40) + 25

            lda speed_setting
            beq draw_speed_half
            cmp #1
            beq draw_speed_3qrtr
            jmp draw_speed_normal

draw_speed_half:
            ldx #0
draw_half_text:
            lda half_text,x
            beq draw_speed_done
            sta SCREEN + (22 * 40) + 21,x
            lda #EASY_COL           ; Green - slowest
            sta COLRAM + (22 * 40) + 21,x
            inx
            jmp draw_half_text

draw_speed_3qrtr:
            ldx #0
draw_3qrtr_text:
            lda qrtr_text,x
            beq draw_speed_done
            sta SCREEN + (22 * 40) + 21,x
            lda #NORMAL_COL         ; Yellow - medium
            sta COLRAM + (22 * 40) + 21,x
            inx
            jmp draw_3qrtr_text

draw_speed_normal:
            ldx #0
draw_normal_speed_text:
            lda full_text,x
            beq draw_speed_done
            sta SCREEN + (22 * 40) + 21,x
            lda #TITLE_COL          ; White - full speed
            sta COLRAM + (22 * 40) + 21,x
            inx
            jmp draw_normal_speed_text

draw_speed_done:
            rts

half_text:
            !scr "0.5x"
            !byte 0

qrtr_text:
            !scr "0.75x"
            !byte 0

full_text:
            !scr "1.0x"
            !byte 0

; ----------------------------------------------------------------------------
; Draw Endless Mode State
; ----------------------------------------------------------------------------

draw_endless_state:
            lda endless_mode
            beq draw_endless_off
            ; Draw ON in cyan
            lda #'o'
            sta SCREEN + (23 * 40) + 22
            lda #'n'
            sta SCREEN + (23 * 40) + 23
            lda #CHAR_SPACE
            sta SCREEN + (23 * 40) + 24
            lda #3                  ; Cyan
            sta COLRAM + (23 * 40) + 22
            sta COLRAM + (23 * 40) + 23
            rts

draw_endless_off:
            ; Draw OFF in grey
            lda #'o'
            sta SCREEN + (23 * 40) + 22
            lda #'f'
            sta SCREEN + (23 * 40) + 23
            lda #'f'
            sta SCREEN + (23 * 40) + 24
            lda #SUBTITLE_COL
            sta COLRAM + (23 * 40) + 22
            sta COLRAM + (23 * 40) + 23
            sta COLRAM + (23 * 40) + 24
            rts

; ----------------------------------------------------------------------------
; Draw Menu Cursor
; ----------------------------------------------------------------------------

draw_cursor:
            ; Clear all cursor positions
            lda #CHAR_SPACE
            sta SCREEN + (8 * 40) + 12
            sta SCREEN + (10 * 40) + 12
            sta SCREEN + (12 * 40) + 12
            sta SCREEN + (14 * 40) + 12
            sta SCREEN + (16 * 40) + 12
            sta SCREEN + (18 * 40) + 12

            ; Draw cursor at current position
            lda cursor_pos
            beq cursor_song1
            cmp #1
            beq cursor_song2
            cmp #2
            beq cursor_song3
            cmp #3
            beq cursor_song4
            cmp #4
            beq cursor_song5
            jmp cursor_song6

cursor_song1:
            lda #CHAR_CURSOR
            sta SCREEN + (8 * 40) + 12
            lda #CURSOR_COL
            sta COLRAM + (8 * 40) + 12
            rts

cursor_song2:
            lda #CHAR_CURSOR
            sta SCREEN + (10 * 40) + 12
            lda #CURSOR_COL
            sta COLRAM + (10 * 40) + 12
            rts

cursor_song3:
            lda #CHAR_CURSOR
            sta SCREEN + (12 * 40) + 12
            lda #CURSOR_COL
            sta COLRAM + (12 * 40) + 12
            rts

cursor_song4:
            lda #CHAR_CURSOR
            sta SCREEN + (14 * 40) + 12
            lda #CURSOR_COL
            sta COLRAM + (14 * 40) + 12
            rts

cursor_song5:
            lda #CHAR_CURSOR
            sta SCREEN + (16 * 40) + 12
            lda #CURSOR_COL
            sta COLRAM + (16 * 40) + 12
            rts

cursor_song6:
            lda #CHAR_CURSOR
            sta SCREEN + (18 * 40) + 12
            lda #CURSOR_COL
            sta COLRAM + (18 * 40) + 12
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
            ; Check joystick up
            lda CIA1_PRA
            and #$01            ; Bit 0 = up
            beq menu_up_pressed

            ; Check joystick down
            lda CIA1_PRA
            and #$02            ; Bit 1 = down
            beq menu_down_pressed

            ; Check joystick left (difficulty)
            lda CIA1_PRA
            and #$04            ; Bit 2 = left
            beq menu_left_pressed

            ; Check joystick right (difficulty)
            lda CIA1_PRA
            and #$08            ; Bit 3 = right
            beq menu_right_pressed

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

menu_left_pressed:
            lda difficulty
            beq menu_set_delay  ; Already at Easy
            dec difficulty
            jsr play_menu_move
            jsr draw_current_difficulty
            jmp menu_set_delay

menu_right_pressed:
            lda difficulty
            cmp #DIFF_HARD
            bcs menu_set_delay  ; Already at Hard
            inc difficulty
            jsr play_menu_move
            jsr draw_current_difficulty
            jmp menu_set_delay

menu_set_delay:
            lda #KEY_DELAY
            sta key_delay_count

menu_check_keys:
            ; Check P key for practice toggle (row 1, column 5)
            lda #$FD                ; Row 1
            sta CIA1_PRA
            lda CIA1_PRB
            and #$20                ; Column 5 = P
            beq menu_p_pressed

            ; Check + key (row 0, column 0 = plus on keyboard)
            lda #$FE                ; Row 0
            sta CIA1_PRA
            lda CIA1_PRB
            and #$01                ; Column 0 = +
            beq menu_plus_pressed

            ; Check - key (row 5, column 3)
            lda #$DF                ; Row 5
            sta CIA1_PRA
            lda CIA1_PRB
            and #$08                ; Column 3 = -
            beq menu_minus_pressed

            ; Check E key for endless toggle (row 1, column 6)
            lda #$FD                ; Row 1
            sta CIA1_PRA
            lda CIA1_PRB
            and #$40                ; Column 6 = E
            beq menu_e_pressed

            ; Check O key for options (row 4, column 6) - Unit 46
            lda #$EF                ; Row 4
            sta CIA1_PRA
            lda CIA1_PRB
            and #$40                ; Column 6 = O
            beq menu_o_pressed

            jmp menu_check_fire

menu_o_pressed:
            ; Go to options screen (Unit 46)
            jsr play_menu_select
            jsr show_options
            lda #STATE_OPTIONS
            sta game_state
            rts

menu_e_pressed:
            ; Toggle endless mode
            lda endless_mode
            eor #1
            sta endless_mode
            jsr play_menu_move
            jsr draw_endless_state
            lda #KEY_DELAY
            sta key_delay_count
            jmp menu_check_fire

menu_p_pressed:
            ; Toggle practice mode
            lda practice_mode
            eor #1
            sta practice_mode
            jsr play_menu_move
            jsr draw_practice_state
            lda #KEY_DELAY
            sta key_delay_count
            jmp menu_check_fire

menu_plus_pressed:
            ; Increase speed (towards 1.0x)
            lda speed_setting
            cmp #NUM_SPEEDS-1
            bcs menu_check_fire     ; Already at max
            inc speed_setting
            jsr play_menu_move
            jsr draw_speed_state
            lda #KEY_DELAY
            sta key_delay_count
            jmp menu_check_fire

menu_minus_pressed:
            ; Decrease speed (towards 0.5x)
            lda speed_setting
            beq menu_check_fire     ; Already at min
            dec speed_setting
            jsr play_menu_move
            jsr draw_speed_state
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

            ; Set difficulty parameters
            jsr set_difficulty_params

            ; Transition to game
            jsr transition_to_game
            rts

; ----------------------------------------------------------------------------
; Set Difficulty Parameters
; ----------------------------------------------------------------------------

set_difficulty_params:
            lda difficulty
            cmp #DIFF_EASY
            beq set_diff_easy
            cmp #DIFF_NORMAL
            beq set_diff_normal
            jmp set_diff_hard

set_diff_easy:
            lda #PERFECT_WINDOW_EASY
            sta perfect_window
            lda #GOOD_WINDOW_EASY
            sta good_window
            lda #HEALTH_MISS_EASY
            sta health_miss_amt
            rts

set_diff_normal:
            lda #PERFECT_WINDOW_NORMAL
            sta perfect_window
            lda #GOOD_WINDOW_NORMAL
            sta good_window
            lda #HEALTH_MISS_NORMAL
            sta health_miss_amt
            rts

set_diff_hard:
            lda #PERFECT_WINDOW_HARD
            sta perfect_window
            lda #GOOD_WINDOW_HARD
            sta good_window
            lda #HEALTH_MISS_HARD
            sta health_miss_amt
            rts

; ----------------------------------------------------------------------------
; Transition to Game
; ----------------------------------------------------------------------------

transition_to_game:
            ; Set up tempo based on song selection
            lda selected_song
            beq setup_song1
            cmp #1
            beq setup_song2
            cmp #2
            bne +
            jmp setup_song3
+           cmp #3
            bne ++
            jmp setup_song4
++          cmp #4
            bne +++
            jmp setup_song5
+++         jmp setup_song6

setup_song1:
            lda #TEMPO_SONG1
            sta frames_per_beat
            lda #LENGTH_SONG1
            sta song_length

            ; Select difficulty variant for Song 1
            lda difficulty
            cmp #DIFF_EASY
            beq load_s1_easy
            cmp #DIFF_NORMAL
            beq load_s1_normal
            jmp load_s1_hard

load_s1_easy:
            lda #<song1_easy
            sta song_data_ptr
            lda #>song1_easy
            sta song_data_ptr+1
            jmp start_game

load_s1_normal:
            lda #<song1_normal
            sta song_data_ptr
            lda #>song1_normal
            sta song_data_ptr+1
            jmp start_game

load_s1_hard:
            lda #<song1_hard
            sta song_data_ptr
            lda #>song1_hard
            sta song_data_ptr+1
            jmp start_game

setup_song2:
            lda #TEMPO_SONG2
            sta frames_per_beat
            lda #LENGTH_SONG2
            sta song_length

            ; Select difficulty variant for Song 2
            lda difficulty
            cmp #DIFF_EASY
            beq load_s2_easy
            cmp #DIFF_NORMAL
            beq load_s2_normal
            jmp load_s2_hard

load_s2_easy:
            lda #<song2_easy
            sta song_data_ptr
            lda #>song2_easy
            sta song_data_ptr+1
            jmp start_game

load_s2_normal:
            lda #<song2_normal
            sta song_data_ptr
            lda #>song2_normal
            sta song_data_ptr+1
            jmp start_game

load_s2_hard:
            lda #<song2_hard
            sta song_data_ptr
            lda #>song2_hard
            sta song_data_ptr+1
            jmp start_game

setup_song3:
            lda #TEMPO_SONG3
            sta frames_per_beat
            lda #LENGTH_SONG3
            sta song_length

            ; Select difficulty variant for Song 3
            lda difficulty
            cmp #DIFF_EASY
            beq load_s3_easy
            cmp #DIFF_NORMAL
            beq load_s3_normal
            jmp load_s3_hard

load_s3_easy:
            lda #<song3_easy
            sta song_data_ptr
            lda #>song3_easy
            sta song_data_ptr+1
            jmp start_game

load_s3_normal:
            lda #<song3_normal
            sta song_data_ptr
            lda #>song3_normal
            sta song_data_ptr+1
            jmp start_game

load_s3_hard:
            lda #<song3_hard
            sta song_data_ptr
            lda #>song3_hard
            sta song_data_ptr+1
            jmp start_game

setup_song4:
            lda #TEMPO_SONG4
            sta frames_per_beat
            lda #LENGTH_SONG4
            sta song_length

            ; Select difficulty variant for Song 4
            lda difficulty
            cmp #DIFF_EASY
            beq load_s4_easy
            cmp #DIFF_NORMAL
            beq load_s4_normal
            jmp load_s4_hard

load_s4_easy:
            lda #<song4_easy
            sta song_data_ptr
            lda #>song4_easy
            sta song_data_ptr+1
            jmp start_game

load_s4_normal:
            lda #<song4_normal
            sta song_data_ptr
            lda #>song4_normal
            sta song_data_ptr+1
            jmp start_game

load_s4_hard:
            lda #<song4_hard
            sta song_data_ptr
            lda #>song4_hard
            sta song_data_ptr+1
            jmp start_game

setup_song5:
            lda #TEMPO_SONG5
            sta frames_per_beat
            lda #LENGTH_SONG5
            sta song_length

            ; Select difficulty variant for Song 5
            lda difficulty
            cmp #DIFF_EASY
            beq load_s5_easy
            cmp #DIFF_NORMAL
            beq load_s5_normal
            jmp load_s5_hard

load_s5_easy:
            lda #<song5_easy
            sta song_data_ptr
            lda #>song5_easy
            sta song_data_ptr+1
            jmp start_game

load_s5_normal:
            lda #<song5_normal
            sta song_data_ptr
            lda #>song5_normal
            sta song_data_ptr+1
            jmp start_game

load_s5_hard:
            lda #<song5_hard
            sta song_data_ptr
            lda #>song5_hard
            sta song_data_ptr+1
            jmp start_game

setup_song6:
            lda #TEMPO_SONG6
            sta frames_per_beat
            lda #LENGTH_SONG6
            sta song_length

            ; Select difficulty variant for Song 6
            lda difficulty
            cmp #DIFF_EASY
            beq load_s6_easy
            cmp #DIFF_NORMAL
            beq load_s6_normal
            jmp load_s6_hard

load_s6_easy:
            lda #<song6_easy
            sta song_data_ptr
            lda #>song6_easy
            sta song_data_ptr+1
            jmp start_game

load_s6_normal:
            lda #<song6_normal
            sta song_data_ptr
            lda #>song6_normal
            sta song_data_ptr+1
            jmp start_game

load_s6_hard:
            lda #<song6_hard
            sta song_data_ptr
            lda #>song6_hard
            sta song_data_ptr+1

start_game:
            ; Apply speed modifier to tempo
            jsr apply_speed_modifier

            ; Initialise game
            jsr init_game
            lda #STATE_PLAYING
            sta game_state
            rts

; Apply speed modifier to frames_per_beat
apply_speed_modifier:
            lda speed_setting
            beq speed_half_tempo    ; 0 = 0.5x
            cmp #1
            beq speed_3qrtr_tempo   ; 1 = 0.75x
            rts                     ; 2 = 1.0x, no change

speed_half_tempo:
            ; 0.5x speed = double frames_per_beat
            asl frames_per_beat
            rts

speed_3qrtr_tempo:
            ; 0.75x speed = frames_per_beat + frames_per_beat/3
            ; Approximation: add half (will be roughly 1.5x, close to 0.75x)
            lda frames_per_beat
            lsr                     ; Divide by 2
            clc
            adc frames_per_beat     ; Add to original = 1.5x frames
            sta frames_per_beat
            rts

; Song data pointers
song_data_ptr:
            !word 0

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
; Initialize Game
; ----------------------------------------------------------------------------

init_game:
            jsr init_screen
            jsr init_notes
            jsr init_score
            jsr init_health
            jsr init_combo
            jsr init_song

            ; Initialize visual effect variables
            lda #0
            sta bg_flash
            sta beat_pulse
            sta perfect_effect
            sta perfect_track
            sta good_effect
            sta good_track
            sta miss_effect
            sta miss_track
            sta screen_shake
            sta bg_cycle
            sta bg_intensity
            sta voice_callout
            sta voice_freq_hi
            sta voice_freq_lo
            sta last_milestone
            sta filter_sweep
            lda #$40                ; Default mid-range filter
            sta base_filter
            lda #0
            sta jingle_playing
            sta jingle_pos
            sta jingle_timer
            sta results_phase
            sta results_timer
            sta display_score_lo
            sta display_score_hi
            sta new_high_score
            sta grade_flash

            ; Initialize advanced scoring variables
            sta perfect_streak
            sta best_streak
            sta section_bonus
            sta notes_hit

            ; Initialize endless mode loop counter
            lda #1                  ; Start at loop 1
            sta loop_count

            ; Display loop count if in endless mode
            lda endless_mode
            beq init_game_done
            jsr display_loop_count

init_game_done:
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
            ; Check if game is paused (Unit 47)
            lda game_paused
            beq up_not_paused
            jmp update_paused
up_not_paused:

            ; Check for P key to pause (row 1, column 5)
            lda #$FD                ; Row 1
            sta CIA1_PRA
            lda CIA1_PRB
            and #$20                ; Column 5 = P
            bne up_no_pause_key
            ; P pressed - pause the game
            jsr pause_game
            lda #$FF
            sta CIA1_PRA
            rts
up_no_pause_key:
            lda #$FF
            sta CIA1_PRA

            inc frame_count
            lda frame_count
            cmp frames_per_beat
            bcc no_new_beat

            lda #0
            sta frame_count
            jsr advance_song
            jsr check_section_bonus ; Check for section completion bonus
            jsr check_spawn_note

            ; Trigger beat pulse on every new beat
            lda #8                  ; Pulse duration (frames)
            sta beat_pulse

no_new_beat:
            jsr update_notes
            jsr reset_track_colours
            jsr update_border_flash
            jsr check_keys
            jsr check_song_end

            rts

; ----------------------------------------------------------------------------
; Update Results State (Unit 44 - Animated)
; ----------------------------------------------------------------------------

update_results:
            ; Update animations
            jsr update_results_animation

            ; Check for fire to return to menu (only after animations done)
            ; Phase 4 = skip name entry, done
            ; Phase 6 = name entry complete, done
            lda results_phase
            cmp #4
            beq results_check_input
            cmp #6
            beq results_check_input
            jmp results_no_input    ; Still animating

results_check_input:

            lda CIA1_PRA
            and #$10
            beq results_fire

            ; Also check space bar
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq results_fire

results_no_input:
            lda #$FF
            sta CIA1_PRA
            rts

results_fire:
            lda #$FF
            sta CIA1_PRA

            jsr play_menu_select

            ; Return to menu
            jsr show_menu
            lda #STATE_MENU
            sta game_state
            rts

; ----------------------------------------------------------------------------
; Update Results Animation (Unit 44)
; ----------------------------------------------------------------------------
; Phase 0: Wait for initial delay
; Phase 1: Score count-up animation
; Phase 2: Grade reveal
; Phase 3: High score flash (if applicable)
; Phase 4: Done - waiting for input
; ----------------------------------------------------------------------------

update_results_animation:
            lda results_phase
            cmp #0
            beq results_phase_0
            cmp #1
            beq results_phase_1
            cmp #2
            bne check_phase_3
            jmp results_phase_2
check_phase_3:
            cmp #3
            bne check_phase_5
            jmp results_phase_3
check_phase_5:
            cmp #5
            bne results_anim_done
            jmp results_phase_5
results_anim_done:
            ; Phase 4 or 6+ = done
            rts

results_phase_5:
            ; Name entry mode (Unit 45)
            jsr update_name_entry
            jsr draw_name_entry     ; Update display
            ; Check if entry complete
            lda name_entry_mode
            bne phase_5_wait        ; Still entering
            ; Done - move to phase 6
            lda #6
            sta results_phase
phase_5_wait:
            rts

results_phase_0:
            ; Initial delay before starting
            dec results_timer
            bne phase_0_done
            ; Start score count-up
            lda #1
            sta results_phase
            lda #2                  ; Count up speed (frames per increment)
            sta results_timer
phase_0_done:
            rts

results_phase_1:
            ; Score count-up animation
            dec results_timer
            bne phase_1_done

            ; Reset timer
            lda #2
            sta results_timer

            ; Increment display score toward actual score
            lda display_score_lo
            clc
            adc #100                ; Count up by 100 per tick
            sta display_score_lo
            lda display_score_hi
            adc #0
            sta display_score_hi

            ; Check if we've reached actual score
            lda display_score_hi
            cmp score_hi
            bcc phase_1_update      ; Not there yet
            bne phase_1_reached     ; Over, clamp it
            lda display_score_lo
            cmp score_lo
            bcc phase_1_update      ; Not there yet

phase_1_reached:
            ; Clamp to actual score
            lda score_lo
            sta display_score_lo
            lda score_hi
            sta display_score_hi
            ; Move to phase 2
            lda #2
            sta results_phase
            lda #30                 ; Delay before grade reveal
            sta results_timer

phase_1_update:
            ; Update displayed score
            jsr update_displayed_score
phase_1_done:
            rts

results_phase_2:
            ; Grade reveal - flash the grade letter
            dec results_timer
            bne phase_2_flash

            ; Done flashing, move to phase 3
            lda #3
            sta results_phase
            lda new_high_score
            beq skip_hs_flash       ; No song high score, but check leaderboard
            lda #60                 ; Flash duration for "NEW HIGH SCORE!"
            sta results_timer
            jmp phase_2_done

skip_hs_flash:
            ; Skip high score flash, but go to phase 3 to check leaderboard
            lda #1                  ; 1 frame (immediate check)
            sta results_timer
            jmp phase_2_done

phase_2_flash:
            ; Flash grade colour
            lda results_timer
            and #$04                ; Every 4 frames
            beq phase_2_col_normal
            lda #1                  ; White flash
            jmp phase_2_set_col
phase_2_col_normal:
            lda current_grade_col
phase_2_set_col:
            sta COLRAM + (7 * 40) + 22
phase_2_done:
            rts

results_phase_3:
            ; High score flash
            dec results_timer
            bne phase_3_flash
            ; Done - check if qualified for leaderboard (Unit 45)
            jsr check_hs_table
            lda hs_table_rank
            cmp #$FF
            beq phase_3_no_entry    ; Not in top 5
            ; Qualified! Start name entry
            jsr start_name_entry
            jsr draw_name_entry
            lda #5
            sta results_phase
            rts
phase_3_no_entry:
            lda #6
            sta results_phase
            rts

phase_3_flash:
            ; Flash "NEW HIGH SCORE!" text
            lda results_timer
            and #$04
            beq phase_3_dim
            lda #1                  ; White
            jmp phase_3_set_col
phase_3_dim:
            lda #7                  ; Yellow
phase_3_set_col:
            ldx #14
phase_3_loop:
            sta COLRAM + (11 * 40) + 10,x
            dex
            bpl phase_3_loop
            rts

; Update the displayed score on screen
update_displayed_score:
            lda display_score_lo
            sta work_lo
            lda display_score_hi
            sta work_hi

            ldx #0
uds_div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc uds_done_10000
            sta work_hi
            sty work_lo
            inx
            jmp uds_div_10000
uds_done_10000:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 23

            ldx #0
uds_div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc uds_done_1000
            sta work_hi
            sty work_lo
            inx
            jmp uds_div_1000
uds_done_1000:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 24

            ldx #0
uds_div_100:
            lda work_lo
            sec
            sbc #100
            bcc uds_done_100
            sta work_lo
            inx
            jmp uds_div_100
uds_done_100:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 25

            ldx #0
uds_div_10:
            lda work_lo
            sec
            sbc #10
            bcc uds_done_10
            sta work_lo
            inx
            jmp uds_div_10
uds_done_10:
            txa
            ora #$30
            sta SCREEN + (9 * 40) + 26

            lda work_lo
            ora #$30
            sta SCREEN + (9 * 40) + 27
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

            ; Return to menu
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
            ; Draw song name based on selection
            lda selected_song
            beq draw_name_song1
            jmp draw_name_song2

draw_name_song1:
            ldx #0
draw_sn1:
            lda song1_name,x
            beq draw_difficulty_hud
            sta SCREEN + 28,x
            lda #11
            sta COLRAM + 28,x
            inx
            jmp draw_sn1

draw_name_song2:
            ldx #0
draw_sn2:
            lda song2_name,x
            beq draw_difficulty_hud
            sta SCREEN + 26,x
            lda #11
            sta COLRAM + 26,x
            inx
            jmp draw_sn2

draw_difficulty_hud:
            ; Show difficulty on gameplay HUD
            lda difficulty
            cmp #DIFF_EASY
            beq draw_hud_easy
            cmp #DIFF_NORMAL
            beq draw_hud_normal
            jmp draw_hud_hard

draw_hud_easy:
            ldx #0
draw_hud_e:
            lda easy_text,x
            beq draw_song_name_done
            sta SCREEN + (COMBO_ROW * 40),x
            lda #EASY_COL
            sta COLRAM + (COMBO_ROW * 40),x
            inx
            jmp draw_hud_e

draw_hud_normal:
            ldx #0
draw_hud_n:
            lda normal_text,x
            beq draw_song_name_done
            sta SCREEN + (COMBO_ROW * 40),x
            lda #NORMAL_COL
            sta COLRAM + (COMBO_ROW * 40),x
            inx
            jmp draw_hud_n

draw_hud_hard:
            ldx #0
draw_hud_h:
            lda hard_text,x
            beq draw_song_name_done
            sta SCREEN + (COMBO_ROW * 40),x
            lda #HARD_COL
            sta COLRAM + (COMBO_ROW * 40),x
            inx
            jmp draw_hud_h

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

            ; Point to selected song data
            lda song_data_ptr
            sta song_pos
            lda song_data_ptr+1
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

            ; ----------------------------------------
            ; Logo characters for title screen
            ; ----------------------------------------

            ; Character 133 - Top-left corner
            lda #%11111111
            sta CHARSET + (133 * 8) + 0
            sta CHARSET + (133 * 8) + 1
            lda #%11000000
            sta CHARSET + (133 * 8) + 2
            sta CHARSET + (133 * 8) + 3
            sta CHARSET + (133 * 8) + 4
            sta CHARSET + (133 * 8) + 5
            sta CHARSET + (133 * 8) + 6
            sta CHARSET + (133 * 8) + 7

            ; Character 134 - Top-right corner
            lda #%11111111
            sta CHARSET + (134 * 8) + 0
            sta CHARSET + (134 * 8) + 1
            lda #%00000011
            sta CHARSET + (134 * 8) + 2
            sta CHARSET + (134 * 8) + 3
            sta CHARSET + (134 * 8) + 4
            sta CHARSET + (134 * 8) + 5
            sta CHARSET + (134 * 8) + 6
            sta CHARSET + (134 * 8) + 7

            ; Character 135 - Bottom-left corner
            lda #%11000000
            sta CHARSET + (135 * 8) + 0
            sta CHARSET + (135 * 8) + 1
            sta CHARSET + (135 * 8) + 2
            sta CHARSET + (135 * 8) + 3
            sta CHARSET + (135 * 8) + 4
            sta CHARSET + (135 * 8) + 5
            lda #%11111111
            sta CHARSET + (135 * 8) + 6
            sta CHARSET + (135 * 8) + 7

            ; Character 136 - Bottom-right corner
            lda #%00000011
            sta CHARSET + (136 * 8) + 0
            sta CHARSET + (136 * 8) + 1
            sta CHARSET + (136 * 8) + 2
            sta CHARSET + (136 * 8) + 3
            sta CHARSET + (136 * 8) + 4
            sta CHARSET + (136 * 8) + 5
            lda #%11111111
            sta CHARSET + (136 * 8) + 6
            sta CHARSET + (136 * 8) + 7

            ; Character 137 - Horizontal bar (top/bottom)
            lda #%11111111
            sta CHARSET + (137 * 8) + 0
            sta CHARSET + (137 * 8) + 1
            lda #%00000000
            sta CHARSET + (137 * 8) + 2
            sta CHARSET + (137 * 8) + 3
            sta CHARSET + (137 * 8) + 4
            sta CHARSET + (137 * 8) + 5
            lda #%11111111
            sta CHARSET + (137 * 8) + 6
            sta CHARSET + (137 * 8) + 7

            ; Character 138 - Vertical bar (left/right side)
            lda #%11000011
            sta CHARSET + (138 * 8) + 0
            sta CHARSET + (138 * 8) + 1
            sta CHARSET + (138 * 8) + 2
            sta CHARSET + (138 * 8) + 3
            sta CHARSET + (138 * 8) + 4
            sta CHARSET + (138 * 8) + 5
            sta CHARSET + (138 * 8) + 6
            sta CHARSET + (138 * 8) + 7

            ; Character 139 - Full block (for logo fill)
            lda #%11111111
            sta CHARSET + (139 * 8) + 0
            sta CHARSET + (139 * 8) + 1
            sta CHARSET + (139 * 8) + 2
            sta CHARSET + (139 * 8) + 3
            sta CHARSET + (139 * 8) + 4
            sta CHARSET + (139 * 8) + 5
            sta CHARSET + (139 * 8) + 6
            sta CHARSET + (139 * 8) + 7

            ; Character 140 - Half block top
            lda #%11111111
            sta CHARSET + (140 * 8) + 0
            sta CHARSET + (140 * 8) + 1
            sta CHARSET + (140 * 8) + 2
            sta CHARSET + (140 * 8) + 3
            lda #%00000000
            sta CHARSET + (140 * 8) + 4
            sta CHARSET + (140 * 8) + 5
            sta CHARSET + (140 * 8) + 6
            sta CHARSET + (140 * 8) + 7

            ; Character 141 - Half block bottom
            lda #%00000000
            sta CHARSET + (141 * 8) + 0
            sta CHARSET + (141 * 8) + 1
            sta CHARSET + (141 * 8) + 2
            sta CHARSET + (141 * 8) + 3
            lda #%11111111
            sta CHARSET + (141 * 8) + 4
            sta CHARSET + (141 * 8) + 5
            sta CHARSET + (141 * 8) + 6
            sta CHARSET + (141 * 8) + 7

            ; Character 142 - Centre dot (decorative)
            lda #%00000000
            sta CHARSET + (142 * 8) + 0
            sta CHARSET + (142 * 8) + 1
            lda #%00011000
            sta CHARSET + (142 * 8) + 2
            lda #%00111100
            sta CHARSET + (142 * 8) + 3
            sta CHARSET + (142 * 8) + 4
            lda #%00011000
            sta CHARSET + (142 * 8) + 5
            lda #%00000000
            sta CHARSET + (142 * 8) + 6
            sta CHARSET + (142 * 8) + 7

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
            cmp #HIT_ZONE_START
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

            ; In practice mode, don't decrease health
            lda practice_mode
            bne skip_health_loss

            ; Decrease health (using difficulty-adjusted amount)
            lda health_miss_amt
            jsr decrease_health

skip_health_loss:
            ; Flash border red
            lda #MISS_COL
            sta BORDER
            lda #8
            sta border_flash

            ; Trigger "MISS" text effect (Unit 39)
            lda #6                  ; Very brief - don't compound frustration
            sta miss_effect
            ; miss_track is already set before handle_miss is called

            ; Trigger screen shake (Unit 39)
            lda #2                  ; Just 2 frames of shake
            sta screen_shake

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
            jsr play_gameover_stinger   ; Unit 43
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

            ; Check for combo milestones (Unit 41)
            jsr check_milestone

            rts

break_combo:
            lda #0
            sta combo
            jsr display_combo
            jsr reset_milestone     ; Allow milestones to trigger again (Unit 41)
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
            ldx #COMBO_BORDER_1 ; Dark grey border
            jmp set_combo_col
combo_col_2x:
            lda #7              ; Yellow
            ldx #COMBO_BORDER_2 ; Green border
            jmp set_combo_col
combo_col_3x:
            lda #5              ; Green
            ldx #COMBO_BORDER_3 ; Yellow border
            jmp set_combo_col
combo_col_4x:
            lda #1              ; White
            ldx #COMBO_BORDER_4 ; Red border (fire!)

set_combo_col:
            sta COLRAM + (COMBO_ROW * 40) + 34
            sta COLRAM + (COMBO_ROW * 40) + 35
            sta COLRAM + (COMBO_ROW * 40) + 36

            ; Update border colour for visual feedback
            lda combo
            beq reset_border    ; No combo = black border
            stx BORDER          ; Set border to tier colour
            rts

reset_border:
            lda #COMBO_BORDER_0
            sta BORDER
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
            beq border_flash_done
            dec border_flash
            bne border_flash_done
            lda #BORDER_COL
            sta BORDER
border_flash_done:

            ; Update background flash (perfect hit effect)
            lda bg_flash
            beq bg_flash_done
            dec bg_flash
            bne bg_flash_done
            ; Reset background to default
            lda #6                  ; Blue background
            sta BGCOL
bg_flash_done:

            ; Update beat pulse marker
            jsr update_beat_marker

            ; Update perfect hit text effect (Unit 37)
            jsr update_perfect_effect

            ; Update good hit text effect (Unit 38)
            jsr update_good_effect

            ; Update miss effect (Unit 39)
            jsr update_miss_effect
            jsr update_screen_shake

            ; Update background visuals (Unit 40)
            jsr update_background

            ; Update voice callout (Unit 41)
            jsr update_voice_callout

            ; Update game filter (Unit 42)
            jsr update_game_filter
            jsr update_filter_sweep

            ; Update jingle playback (Unit 43)
            jsr update_jingle

            rts

; ----------------------------------------------------------------------------
; Update Beat Marker
; ----------------------------------------------------------------------------
; Shows a pulsing indicator that helps players feel the rhythm.
; Pulses bright on downbeat, fades through the beat.
; Also pulses the hit zone colours for visual timing cues.

update_beat_marker:
            lda beat_pulse
            beq beat_marker_dim

            ; Pulse is active - show bright marker
            dec beat_pulse
            lda beat_pulse
            lsr                     ; Divide by 2 for colour selection
            and #$03                ; Keep in range 0-3
            tax
            lda beat_colours,x
            sta COLRAM + (HIT_ROW * 40) + 19  ; Centre of hit zone
            lda #$51                ; Filled circle character
            sta SCREEN + (HIT_ROW * 40) + 19

            ; ----------------------------------------
            ; Pulse hit zone colours (new in Unit 36)
            ; ----------------------------------------
            lda beat_pulse
            lsr
            and #$03
            tax
            lda hitzone_pulse_cols,x
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN

            rts

beat_marker_dim:
            ; Show dim marker when not pulsing
            lda #11                 ; Dark grey
            sta COLRAM + (HIT_ROW * 40) + 19
            lda #$57                ; Empty circle character
            sta SCREEN + (HIT_ROW * 40) + 19

            ; Reset hit zone to normal colour
            lda #HIT_ZONE_COL       ; Yellow (7)
            sta COLRAM + (TRACK1_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK2_ROW * 40) + HIT_ZONE_COLUMN
            sta COLRAM + (TRACK3_ROW * 40) + HIT_ZONE_COLUMN

            rts

beat_colours:
            !byte 1                 ; White (brightest)
            !byte 7                 ; Yellow
            !byte 5                 ; Green
            !byte 11                ; Dark grey (dimmest)

; Hit zone pulse colours - bright to normal
hitzone_pulse_cols:
            !byte 1                 ; White (brightest on beat)
            !byte 13                ; Light green
            !byte 7                 ; Yellow
            !byte 7                 ; Yellow (normal)

; ----------------------------------------------------------------------------
; Update Perfect Hit Effect (Unit 37)
; ----------------------------------------------------------------------------
; Shows "PERFECT!" text briefly at the hit track position.
; Creates layered celebration feedback for perfect timing.
; ----------------------------------------------------------------------------

update_perfect_effect:
            lda perfect_effect
            beq clear_perfect_text      ; Effect ended, clear text

            dec perfect_effect

            ; Show "PERFECT!" text near the hit track
            lda perfect_track
            cmp #1
            beq perfect_track1
            cmp #2
            beq perfect_track2
            jmp perfect_track3

perfect_track1:
            ldx #0
perfect_draw_t1:
            lda perfect_text,x
            beq perfect_draw_done
            sta SCREEN + (TRACK1_ROW * 40) + 8,x
            lda perfect_effect
            lsr
            and #$03
            tay
            lda perfect_colours,y
            sta COLRAM + (TRACK1_ROW * 40) + 8,x
            inx
            jmp perfect_draw_t1

perfect_track2:
            ldx #0
perfect_draw_t2:
            lda perfect_text,x
            beq perfect_draw_done
            sta SCREEN + (TRACK2_ROW * 40) + 8,x
            lda perfect_effect
            lsr
            and #$03
            tay
            lda perfect_colours,y
            sta COLRAM + (TRACK2_ROW * 40) + 8,x
            inx
            jmp perfect_draw_t2

perfect_track3:
            ldx #0
perfect_draw_t3:
            lda perfect_text,x
            beq perfect_draw_done
            sta SCREEN + (TRACK3_ROW * 40) + 8,x
            lda perfect_effect
            lsr
            and #$03
            tay
            lda perfect_colours,y
            sta COLRAM + (TRACK3_ROW * 40) + 8,x
            inx
            jmp perfect_draw_t3

perfect_draw_done:
            rts

clear_perfect_text:
            ; Clear "PERFECT!" text from all tracks (may have switched tracks)
            ldx #7
clear_perfect_loop:
            lda #CHAR_SPACE
            sta SCREEN + (TRACK1_ROW * 40) + 8,x
            sta SCREEN + (TRACK2_ROW * 40) + 8,x
            sta SCREEN + (TRACK3_ROW * 40) + 8,x
            dex
            bpl clear_perfect_loop
            rts

; "PERFECT!" text (8 characters)
perfect_text:
            !scr "perfect!"
            !byte 0

; Colour cycle for perfect text (bright to normal)
perfect_colours:
            !byte 1                 ; White
            !byte 7                 ; Yellow
            !byte 13                ; Light green
            !byte 5                 ; Green

; ----------------------------------------------------------------------------
; Update Good Hit Effect (Unit 38)
; ----------------------------------------------------------------------------
; Shows "GOOD" text briefly at the hit track position.
; Uses cooler colours (greens/cyans) to distinguish from perfect.
; ----------------------------------------------------------------------------

update_good_effect:
            lda good_effect
            beq clear_good_text         ; Effect ended, clear text

            dec good_effect

            ; Show "GOOD" text near the hit track
            lda good_track
            cmp #1
            beq good_track1
            cmp #2
            beq good_track2
            jmp good_track3

good_track1:
            ldx #0
good_draw_t1:
            lda good_text,x
            beq good_draw_done
            sta SCREEN + (TRACK1_ROW * 40) + 8,x
            lda good_effect
            lsr
            and #$03
            tay
            lda good_colours,y
            sta COLRAM + (TRACK1_ROW * 40) + 8,x
            inx
            jmp good_draw_t1

good_track2:
            ldx #0
good_draw_t2:
            lda good_text,x
            beq good_draw_done
            sta SCREEN + (TRACK2_ROW * 40) + 8,x
            lda good_effect
            lsr
            and #$03
            tay
            lda good_colours,y
            sta COLRAM + (TRACK2_ROW * 40) + 8,x
            inx
            jmp good_draw_t2

good_track3:
            ldx #0
good_draw_t3:
            lda good_text,x
            beq good_draw_done
            sta SCREEN + (TRACK3_ROW * 40) + 8,x
            lda good_effect
            lsr
            and #$03
            tay
            lda good_colours,y
            sta COLRAM + (TRACK3_ROW * 40) + 8,x
            inx
            jmp good_draw_t3

good_draw_done:
            rts

clear_good_text:
            ; Clear "GOOD" text from all tracks
            ldx #3                  ; 4 characters
clear_good_loop:
            lda #CHAR_SPACE
            sta SCREEN + (TRACK1_ROW * 40) + 8,x
            sta SCREEN + (TRACK2_ROW * 40) + 8,x
            sta SCREEN + (TRACK3_ROW * 40) + 8,x
            dex
            bpl clear_good_loop
            rts

; "GOOD" text (4 characters)
good_text:
            !scr "good"
            !byte 0

; Colour cycle for good text (cooler colours than perfect)
good_colours:
            !byte 3                 ; Cyan
            !byte 13                ; Light green
            !byte 5                 ; Green
            !byte 11                ; Dark grey

; ----------------------------------------------------------------------------
; Update Miss Effect (Unit 39)
; ----------------------------------------------------------------------------
; Shows "MISS" text briefly at the missed track position.
; Uses red colour scheme for negative feedback.
; Intentionally brief to avoid compounding player frustration.
; ----------------------------------------------------------------------------

update_miss_effect:
            lda miss_effect
            beq clear_miss_text         ; Effect ended, clear text

            dec miss_effect

            ; Show "MISS" text near the missed track
            lda miss_track
            cmp #1
            beq miss_track1
            cmp #2
            beq miss_track2
            jmp miss_track3

miss_track1:
            ldx #0
miss_draw_t1:
            lda miss_text,x
            beq miss_draw_done
            sta SCREEN + (TRACK1_ROW * 40) + 8,x
            lda #2                  ; Red
            sta COLRAM + (TRACK1_ROW * 40) + 8,x
            inx
            jmp miss_draw_t1

miss_track2:
            ldx #0
miss_draw_t2:
            lda miss_text,x
            beq miss_draw_done
            sta SCREEN + (TRACK2_ROW * 40) + 8,x
            lda #2                  ; Red
            sta COLRAM + (TRACK2_ROW * 40) + 8,x
            inx
            jmp miss_draw_t2

miss_track3:
            ldx #0
miss_draw_t3:
            lda miss_text,x
            beq miss_draw_done
            sta SCREEN + (TRACK3_ROW * 40) + 8,x
            lda #2                  ; Red
            sta COLRAM + (TRACK3_ROW * 40) + 8,x
            inx
            jmp miss_draw_t3

miss_draw_done:
            rts

clear_miss_text:
            ; Clear "MISS" text from all tracks
            ldx #3                  ; 4 characters
clear_miss_loop:
            lda #CHAR_SPACE
            sta SCREEN + (TRACK1_ROW * 40) + 8,x
            sta SCREEN + (TRACK2_ROW * 40) + 8,x
            sta SCREEN + (TRACK3_ROW * 40) + 8,x
            dex
            bpl clear_miss_loop
            rts

; "MISS" text (4 characters)
miss_text:
            !scr "miss"
            !byte 0

; ----------------------------------------------------------------------------
; Update Screen Shake (Unit 39)
; ----------------------------------------------------------------------------
; Brief horizontal shake on miss. Uses VIC-II fine scroll register.
; Effect is very short (1-2 frames) to avoid motion sickness.
; ----------------------------------------------------------------------------

update_screen_shake:
            lda screen_shake
            beq shake_done

            dec screen_shake

            ; Apply horizontal offset using VIC-II fine scroll
            ; $D016 bit 0-2 control fine X scroll (0-7)
            lda $D016
            and #$F8            ; Clear scroll bits
            ora #$02            ; Offset by 2 pixels
            sta $D016

            rts

shake_done:
            ; Reset scroll to normal
            lda $D016
            and #$F8            ; Clear scroll bits
            sta $D016
            rts

; ----------------------------------------------------------------------------
; Update Background Visuals (Unit 40)
; ----------------------------------------------------------------------------
; Subtle colour cycling during gameplay. Intensity increases with combo.
; Only updates when bg_flash is not active (don't override hit effects).
; ----------------------------------------------------------------------------

update_background:
            ; Skip if bg_flash is active (hit effect in progress)
            lda bg_flash
            bne bg_skip_cycle

            ; Increment cycle counter (slow cycling)
            inc bg_cycle
            lda bg_cycle
            and #$0F                ; Only update every 16 frames
            bne bg_skip_cycle

            ; Calculate intensity based on combo multiplier
            jsr get_multiplier      ; Returns 1-4 in A
            sta bg_intensity        ; 1-4 based on combo

            ; Get base colour from cycle position
            lda bg_cycle
            lsr
            lsr
            lsr
            lsr                     ; Divide by 16 for slow cycle
            and #$03                ; 4 colours in sequence
            tax

            ; Choose colour table based on intensity
            lda bg_intensity
            cmp #4
            bcs bg_use_bright
            cmp #3
            bcs bg_use_medium
            cmp #2
            bcs bg_use_subtle
            ; Fall through to darkest

bg_use_darkest:
            lda bg_colours_dark,x
            jmp bg_set_colour

bg_use_subtle:
            lda bg_colours_subtle,x
            jmp bg_set_colour

bg_use_medium:
            lda bg_colours_medium,x
            jmp bg_set_colour

bg_use_bright:
            lda bg_colours_bright,x

bg_set_colour:
            sta BGCOL

bg_skip_cycle:
            rts

; Background colour tables (4 colours each, cycling through dark tones)
; Darkest - barely visible movement (1x combo)
bg_colours_dark:
            !byte 0                 ; Black
            !byte 0                 ; Black
            !byte 11                ; Dark grey
            !byte 0                 ; Black

; Subtle - hints of colour (2x combo)
bg_colours_subtle:
            !byte 0                 ; Black
            !byte 11                ; Dark grey
            !byte 6                 ; Blue
            !byte 11                ; Dark grey

; Medium - visible colour shifts (3x combo)
bg_colours_medium:
            !byte 11                ; Dark grey
            !byte 6                 ; Blue
            !byte 9                 ; Brown
            !byte 6                 ; Blue

; Bright - dramatic cycling (4x combo)
bg_colours_bright:
            !byte 6                 ; Blue
            !byte 4                 ; Purple
            !byte 2                 ; Red
            !byte 6                 ; Blue

; ----------------------------------------------------------------------------
; Voice Callout System (Unit 41)
; ----------------------------------------------------------------------------
; Creates voice-like "wow" sounds on combo milestones using SID filters.
; Uses voice 3 for callouts to avoid interrupting note playback.
; ----------------------------------------------------------------------------

; Milestone thresholds
MILESTONE_1 = 10                ; "Nice!" at 10 combo
MILESTONE_2 = 25                ; "Great!" at 25 combo
MILESTONE_3 = 50                ; "Amazing!" at 50 combo

check_milestone:
            lda combo

            ; Check 50 combo milestone
            cmp #MILESTONE_3
            bne check_25
            lda last_milestone
            cmp #MILESTONE_3
            bne do_milestone_50
            rts                     ; Already triggered
do_milestone_50:
            lda #MILESTONE_3
            sta last_milestone
            lda #$40                ; High pitch start
            sta voice_freq_hi
            lda #$00
            sta voice_freq_lo
            lda #30                 ; Longest duration
            jmp start_callout

check_25:
            cmp #MILESTONE_2
            bne check_10
            lda last_milestone
            cmp #MILESTONE_2
            bne do_milestone_25
            rts                     ; Already triggered
do_milestone_25:
            lda #MILESTONE_2
            sta last_milestone
            lda #$30                ; Medium pitch start
            sta voice_freq_hi
            lda #$00
            sta voice_freq_lo
            lda #24                 ; Medium duration
            jmp start_callout

check_10:
            lda combo
            cmp #MILESTONE_1
            bne milestone_done
            lda last_milestone
            cmp #MILESTONE_1
            bne do_milestone_10
            rts                     ; Already triggered
do_milestone_10:
            lda #MILESTONE_1
            sta last_milestone
            lda #$20                ; Lower pitch start
            sta voice_freq_hi
            lda #$00
            sta voice_freq_lo
            lda #18                 ; Shorter duration

start_callout:
            sta voice_callout

            ; Configure voice 3 for callout (doesn't interfere with note sounds)
            ; Use pulse wave with filter for vocal quality
            lda voice_freq_lo
            sta SID_V3_FREQ_LO
            lda voice_freq_hi
            sta SID_V3_FREQ_HI
            lda #$08                ; Pulse width for voice quality
            sta SID_V3_PWLO
            lda #$04
            sta SID_V3_PWHI
            lda #$00                ; Instant attack
            sta SID_V3_AD
            lda #$F8                ; Long sustain, slow release
            sta SID_V3_SR

            ; Enable filter on voice 3
            lda #$44                ; Filter voice 3, resonance 4
            sta SID_RESON
            lda #$00
            sta SID_FILT_LO
            lda #$70                ; High cutoff for bright start
            sta SID_FILT_HI
            lda #$1F                ; Low-pass filter, volume 15
            sta SID_VOLUME

            ; Gate on with pulse wave
            lda #$41                ; Pulse wave, gate on
            sta SID_V3_CTRL

milestone_done:
            rts

update_voice_callout:
            lda voice_callout
            beq callout_done

            dec voice_callout
            beq callout_end

            ; Descending pitch creates "wow" effect
            lda voice_freq_hi
            sec
            sbc #$02                ; Pitch descends
            bcc skip_freq_update    ; Prevent underflow
            sta voice_freq_hi
            sta SID_V3_FREQ_HI

            ; Use low byte of frequency as proxy for filter sweep
            ; (SID filter regs are write-only, can't read them back)
            lda voice_freq_hi
            sta SID_FILT_HI         ; Filter follows pitch

skip_freq_update:
            jmp callout_done

callout_end:
            ; Gate off - release voice 3
            lda #$40                ; Pulse wave, gate off
            sta SID_V3_CTRL

            ; Restore normal filter/volume settings
            lda #$00
            sta SID_RESON           ; No filter routing
            lda #$0F                ; Volume 15, no filter
            sta SID_VOLUME

callout_done:
            rts

reset_milestone:
            ; Called when combo breaks to allow re-triggering
            lda #0
            sta last_milestone
            rts

; ----------------------------------------------------------------------------
; Game Filter System (Unit 42)
; ----------------------------------------------------------------------------
; Dynamic filter cutoff based on combo and health. High combos = brighter,
; low health = muffled. Filter sweep on perfect hits adds momentary brightness.
; ----------------------------------------------------------------------------

update_game_filter:
            ; Skip if voice callout is active (it manages its own filter)
            lda voice_callout
            bne filter_skip

            ; Calculate base filter from combo multiplier
            jsr get_multiplier      ; Returns 1-4 in A
            asl                     ; x2
            asl                     ; x4
            asl                     ; x8
            asl                     ; x16
            clc
            adc #$20                ; Base minimum $20
            sta base_filter         ; $20-$60 based on combo

            ; Reduce filter if health is low (danger feedback)
            lda health
            cmp #30                 ; Low health threshold
            bcs filter_apply
            ; Health is low - muffle the sound
            lda base_filter
            sec
            sbc #$20                ; Reduce cutoff
            bcs filter_store
            lda #$10                ; Minimum cutoff
filter_store:
            sta base_filter

filter_apply:
            ; Apply base filter (routes voices 1+2 through filter)
            lda #$13                ; Filter voices 1+2, resonance 1
            sta SID_RESON
            lda #$00
            sta SID_FILT_LO
            lda base_filter
            sta SID_FILT_HI
            lda #$1F                ; Low-pass filter, volume 15
            sta SID_VOLUME

filter_skip:
            rts

update_filter_sweep:
            lda filter_sweep
            beq sweep_done

            dec filter_sweep

            ; Boost filter cutoff temporarily
            lda base_filter
            clc
            adc #$30                ; Add brightness boost
            bcc sweep_apply
            lda #$FF                ; Cap at maximum
sweep_apply:
            sta SID_FILT_HI

sweep_done:
            rts

; ----------------------------------------------------------------------------
; Sound Effects Layer (Unit 43)
; ----------------------------------------------------------------------------
; Complete sound effects for all game events: victory, game over, menu back.
; Jingles play short melodic sequences using voice 3.
; ----------------------------------------------------------------------------

; Play victory jingle - ascending triumphant notes
play_victory_jingle:
            ; Stop any current note sounds
            lda #$00
            sta SID_V3_CTRL

            ; Start victory sequence
            lda #1                  ; Jingle type 1 = victory
            sta jingle_playing
            lda #0
            sta jingle_pos
            lda #1                  ; Start immediately
            sta jingle_timer
            rts

; Play game over stinger - single low somber note
play_gameover_stinger:
            ; Configure voice 3 for somber tone
            lda #GAMEOVER_FREQ
            sta SID_V3_FREQ_LO
            lda #$03                ; Low frequency
            sta SID_V3_FREQ_HI
            lda #$08
            sta SID_V3_PWLO
            lda #$04
            sta SID_V3_PWHI
            lda #GAMEOVER_AD
            sta SID_V3_AD
            lda #GAMEOVER_SR
            sta SID_V3_SR
            lda #GAMEOVER_WAVE
            ora #$01                ; Gate on
            sta SID_V3_CTRL
            rts

; Play menu back sound
play_menu_back:
            lda #MENU_BACK_FREQ
            sta SID_V3_FREQ_LO
            lda #$00
            sta SID_V3_FREQ_HI
            lda #MENU_BACK_AD
            sta SID_V3_AD
            lda #MENU_BACK_SR
            sta SID_V3_SR
            lda #MENU_BACK_WAVE
            ora #$01                ; Gate on
            sta SID_V3_CTRL
            rts

; Update jingle playback - called each frame
update_jingle:
            lda jingle_playing
            beq jingle_done

            ; Decrement timer
            dec jingle_timer
            bne jingle_done

            ; Time for next note
            lda jingle_playing
            cmp #1
            beq update_victory_jingle

            ; Unknown jingle - stop
            lda #0
            sta jingle_playing
            jmp jingle_done

update_victory_jingle:
            ; Get note from victory sequence
            ldx jingle_pos
            lda victory_notes,x
            beq victory_end         ; 0 = end of sequence

            ; Play this note
            sta SID_V3_FREQ_HI
            lda #$00
            sta SID_V3_FREQ_LO
            lda #$08
            sta SID_V3_PWLO
            lda #$04
            sta SID_V3_PWHI
            lda #$08                ; Quick attack, medium decay
            sta SID_V3_AD
            lda #$50                ; Short sustain
            sta SID_V3_SR
            lda #$41                ; Pulse, gate on
            sta SID_V3_CTRL

            ; Set duration for this note
            lda victory_durations,x
            sta jingle_timer

            ; Advance position
            inc jingle_pos
            jmp jingle_done

victory_end:
            ; Jingle finished
            lda #$40                ; Gate off
            sta SID_V3_CTRL
            lda #0
            sta jingle_playing

jingle_done:
            rts

; Victory jingle note data (freq high bytes, ascending)
victory_notes:
            !byte $10               ; C
            !byte $14               ; E
            !byte $18               ; G
            !byte $20               ; C (octave up)
            !byte $28               ; E (held)
            !byte 0                 ; End marker

; Victory jingle durations (frames per note)
victory_durations:
            !byte 6                 ; Quick
            !byte 6
            !byte 6
            !byte 8                 ; Slightly longer
            !byte 12                ; Hold final note

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
; Check Hit (with difficulty-adjusted timing windows)
; ----------------------------------------------------------------------------

check_hit:
            ldx #0

check_hit_loop:
            lda note_track,x
            beq check_hit_next

            cmp key_pressed
            bne check_hit_next

            ; Check if note is in hittable range
            lda note_col,x
            cmp #HIT_ZONE_START
            bcc check_hit_next
            cmp #HIT_ZONE_END+1
            bcs check_hit_next

            ; Note is hittable - determine quality based on distance from perfect
            lda note_freq,x
            sta hit_note_freq

            ; Calculate distance from perfect column
            lda note_col,x
            sec
            sbc #PERFECT_COL_POS
            bcs dist_positive
            ; Negative distance - make it positive
            eor #$FF
            clc
            adc #1
dist_positive:
            ; A now contains absolute distance from perfect

            ; Check if within perfect window
            cmp perfect_window
            bcc hit_is_perfect
            beq hit_is_perfect

            ; Check if within good window
            cmp good_window
            bcc hit_is_good
            beq hit_is_good

            ; Outside good window but in hit zone - still counts as good
            jmp hit_is_good

hit_is_perfect:
            lda #2
            sta hit_quality
            jmp hit_found

hit_is_good:
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

            ; Check for endless mode
            lda endless_mode
            beq end_song_normal

            ; Endless mode - loop the song
            inc loop_count
            jsr display_loop_count
            jsr init_song           ; Reset song position
            lda #0
            sta end_delay
            sta song_ended
            rts

end_song_normal:
            ; Show results
            jsr show_results
            jsr play_victory_jingle     ; Unit 43
            lda #STATE_RESULTS
            sta game_state

not_ended:
            rts

; ----------------------------------------------------------------------------
; Display Loop Count (for Endless Mode)
; ----------------------------------------------------------------------------

display_loop_count:
            ; Display "LOOP X" in top right during endless mode
            ; Position: row 1, column 32
            lda #'l'
            sta SCREEN + (1 * 40) + 32
            lda #'o'
            sta SCREEN + (1 * 40) + 33
            sta SCREEN + (1 * 40) + 34
            lda #'p'
            sta SCREEN + (1 * 40) + 35
            lda #CHAR_SPACE
            sta SCREEN + (1 * 40) + 36

            ; Display loop number (max 9 displayed)
            lda loop_count
            cmp #10
            bcc display_loop_digit
            lda #9                  ; Cap display at 9
display_loop_digit:
            clc
            adc #$30                ; Convert to ASCII digit
            sta SCREEN + (1 * 40) + 37

            ; Colour the loop display cyan
            lda #3                  ; Cyan
            sta COLRAM + (1 * 40) + 32
            sta COLRAM + (1 * 40) + 33
            sta COLRAM + (1 * 40) + 34
            sta COLRAM + (1 * 40) + 35
            sta COLRAM + (1 * 40) + 37
            rts

; ----------------------------------------------------------------------------
; Award Points
; ----------------------------------------------------------------------------

award_points:
            jsr increment_combo
            inc notes_hit           ; Track total hits for accuracy

            lda hit_quality
            cmp #2
            beq award_perfect

            ; Good hit - resets perfect streak
            lda #0
            sta perfect_streak

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

            ; Trigger "GOOD" text effect (Unit 38)
            lda #8                  ; Shorter duration than perfect
            sta good_effect
            lda key_pressed
            sta good_track

            jmp award_done

award_perfect:
            ; Perfect hit - increment streak
            inc perfect_streak

            ; Check for streak bonus (every STREAK_THRESHOLD perfects)
            lda perfect_streak
            cmp #STREAK_THRESHOLD
            bne no_streak_bonus
            ; Award streak bonus
            lda #STREAK_BONUS
            jsr add_score
            lda #0
            sta perfect_streak      ; Reset for next milestone
            ; Flash border cyan for streak bonus
            lda #3                  ; Cyan
            sta BORDER
no_streak_bonus:

            ; Update best streak
            lda perfect_streak
            cmp best_streak
            bcc skip_best_update
            sta best_streak
skip_best_update:

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

            ; Screen flash effect for perfect hits
            lda #0                  ; Black background flash
            sta BGCOL
            lda #3                  ; Flash duration
            sta bg_flash

            ; Trigger "PERFECT!" text effect (Unit 37)
            lda #12                 ; Effect duration (frames)
            sta perfect_effect
            lda key_pressed         ; Which track was hit
            sta perfect_track

            ; Trigger filter sweep effect (Unit 42)
            lda #8                  ; Brief brightness boost
            sta filter_sweep

            lda #HEALTH_PERFECT
            jsr increase_health

award_done:
            jsr display_score
            rts

; ----------------------------------------------------------------------------
; Check Section Bonus
; ----------------------------------------------------------------------------
; Awards bonus at 25%, 50%, 75% of song completion

check_section_bonus:
            ; Calculate section thresholds based on song_length
            ; 25% = song_length / 4
            ; 50% = song_length / 2
            ; 75% = song_length * 3 / 4

            ; Check 25% (song_length / 4)
            lda song_length
            lsr
            lsr                     ; A = song_length / 4
            cmp song_beat
            bne check_50

            ; Award 25% section bonus
            lda section_bonus
            and #$01                ; Check if already awarded
            bne section_done
            lda section_bonus
            ora #$01                ; Mark 25% as awarded
            sta section_bonus
            jsr award_section_bonus
            rts

check_50:
            ; Check 50% (song_length / 2)
            lda song_length
            lsr                     ; A = song_length / 2
            cmp song_beat
            bne check_75

            ; Award 50% section bonus
            lda section_bonus
            and #$02
            bne section_done
            lda section_bonus
            ora #$02
            sta section_bonus
            jsr award_section_bonus
            rts

check_75:
            ; Check 75% (song_length - song_length/4)
            lda song_length
            lsr
            lsr
            sta ZP_TEMP             ; song_length / 4
            lda song_length
            sec
            sbc ZP_TEMP             ; song_length - song_length/4
            cmp song_beat
            bne section_done

            ; Award 75% section bonus
            lda section_bonus
            and #$04
            bne section_done
            lda section_bonus
            ora #$04
            sta section_bonus
            jsr award_section_bonus

section_done:
            rts

award_section_bonus:
            ; Add section bonus to score
            lda #SECTION_BONUS
            jsr add_score
            jsr display_score

            ; Flash border purple for section bonus
            lda #4                  ; Purple
            sta BORDER
            lda #8
            sta border_flash
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
; Check and Update High Score
; ----------------------------------------------------------------------------
; Compares current score against high score for current song/difficulty.
; Sets new_high_score flag if current score is higher and updates table.

check_high_score:
            ; Clear new high score flag
            lda #0
            sta new_high_score

            ; Calculate table index: (selected_song * 3 + difficulty) * 2
            lda selected_song
            asl                     ; × 2
            clc
            adc selected_song       ; × 3
            clc
            adc difficulty          ; + difficulty
            asl                     ; × 2 (for 2-byte entries)
            tax                     ; X = table index

            ; Compare current score with high score
            ; First compare high bytes
            lda score_hi
            cmp high_scores+1,x     ; Compare high byte
            bcc hs_not_higher       ; Current < high, not new record
            bne hs_is_higher        ; Current > high, new record

            ; High bytes equal, compare low bytes
            lda score_lo
            cmp high_scores,x       ; Compare low byte
            bcc hs_not_higher       ; Current < high
            beq hs_not_higher       ; Current = high (not strictly greater)

hs_is_higher:
            ; New high score! Update table
            lda score_lo
            sta high_scores,x
            lda score_hi
            sta high_scores+1,x

            ; Set flag
            lda #1
            sta new_high_score

hs_not_higher:
            rts

; Get high score for current song/difficulty into work_lo/work_hi
get_high_score:
            ; Calculate table index: (selected_song * 3 + difficulty) * 2
            lda selected_song
            asl
            clc
            adc selected_song
            clc
            adc difficulty
            asl
            tax

            lda high_scores,x
            sta work_lo
            lda high_scores+1,x
            sta work_hi
            rts

; ----------------------------------------------------------------------------
; High Score Table Routines (Unit 45)
; ----------------------------------------------------------------------------

; Check if score qualifies for global leaderboard
; Sets hs_table_rank to 0-4 if qualified, $FF if not
check_hs_table:
            lda #0
            sta hs_table_rank
            ldx #0                  ; Start at entry 0

.check_loop:
            ; Compare score_hi with entry's high byte (offset +4 in 5-byte entry)
            lda score_hi
            cmp hs_table+4,x
            bcc .try_next           ; score < entry
            bne .found_rank         ; score > entry

            ; High bytes equal, compare low bytes
            lda score_lo
            cmp hs_table+3,x
            bcc .try_next           ; score < entry
            beq .try_next           ; score = entry (not strictly greater)

.found_rank:
            ; Score beats this entry
            rts

.try_next:
            ; Move to next entry
            txa
            clc
            adc #HS_ENTRY_SIZE
            tax
            inc hs_table_rank
            lda hs_table_rank
            cmp #HS_TABLE_SIZE
            bcc .check_loop

            ; Didn't qualify
            lda #$FF
            sta hs_table_rank
            rts

; Insert score into high score table at hs_table_rank position
; Call after name entry is complete
insert_hs_entry:
            lda hs_table_rank
            cmp #$FF
            beq .insert_done        ; Not in table

            ; Shift entries down from position 4 to hs_table_rank+1
            ; Work backwards from entry 4
            ldx #(HS_TABLE_SIZE - 2) ; Start at entry 3 (will copy to 4)

.shift_loop:
            cpx hs_table_rank
            bcc .do_insert          ; Past insertion point

            ; Copy entry X to entry X+1
            txa
            asl                     ; ×2
            asl                     ; ×4
            clc
            adc hs_table_rank       ; Add rank once more for ×5
            ; Actually need ×5, let me recalculate
            ; X × 5 = X × 4 + X
            stx hs_temp
            txa
            asl                     ; ×2
            asl                     ; ×4
            clc
            adc hs_temp             ; ×5
            tax                     ; X = source offset

            ; Copy 5 bytes from X to X+5
            ldy #0
.copy_byte:
            lda hs_table,x
            sta hs_table+5,x
            inx
            iny
            cpy #5
            bne .copy_byte

            ; Move to previous entry
            ldx hs_temp
            dex
            bpl .shift_loop

.do_insert:
            ; Calculate insertion offset
            lda hs_table_rank
            asl                     ; ×2
            asl                     ; ×4
            clc
            adc hs_table_rank       ; ×5
            tax

            ; Store name
            lda name_char_0
            sta hs_table,x
            lda name_char_1
            sta hs_table+1,x
            lda name_char_2
            sta hs_table+2,x
            ; Store score
            lda score_lo
            sta hs_table+3,x
            lda score_hi
            sta hs_table+4,x

.insert_done:
            rts

; Initialize name entry mode
start_name_entry:
            lda #1
            sta name_entry_mode
            lda #0
            sta name_cursor
            lda #'A'                ; Default starting letter
            sta name_char_0
            sta name_char_1
            sta name_char_2
            lda #15
            sta name_flash
            rts

; Update name entry input
; Called each frame during name entry
update_name_entry:
            lda name_entry_mode
            beq .entry_done

            ; Update flash timer
            dec name_flash
            bpl .flash_ok
            lda #15
            sta name_flash
.flash_ok:

            ; Read joystick
            lda $DC00
            sta work_lo             ; Save for comparison

            ; Check up (increment letter)
            and #$01
            bne .check_down
            jsr name_letter_up
            jmp .check_fire

.check_down:
            lda work_lo
            and #$02
            bne .check_left
            jsr name_letter_down
            jmp .check_fire

.check_left:
            lda work_lo
            and #$04
            bne .check_right
            ; Move cursor left
            lda name_cursor
            beq .check_fire         ; Already at left
            dec name_cursor
            lda #10                 ; Brief delay
            sta name_flash
            jmp .check_fire

.check_right:
            lda work_lo
            and #$08
            bne .check_fire
            ; Move cursor right
            lda name_cursor
            cmp #2
            bcs .check_fire         ; Already at right
            inc name_cursor
            lda #10
            sta name_flash

.check_fire:
            lda work_lo
            and #$10
            bne .entry_done         ; Fire not pressed

            ; Fire pressed - confirm entry
            lda #0
            sta name_entry_mode
            jsr insert_hs_entry
            jsr play_menu_select    ; Confirmation sound

.entry_done:
            rts

; Increment current letter
name_letter_up:
            ldx name_cursor
            lda name_char_0,x
            clc
            adc #1
            cmp #'Z'+1
            bcc .store_up
            lda #'A'                ; Wrap to A
.store_up:
            sta name_char_0,x
            lda #8
            sta name_flash
            jsr play_menu_move
            rts

; Decrement current letter
name_letter_down:
            ldx name_cursor
            lda name_char_0,x
            sec
            sbc #1
            cmp #'A'
            bcs .store_down
            lda #'Z'                ; Wrap to Z
.store_down:
            sta name_char_0,x
            lda #8
            sta name_flash
            jsr play_menu_move
            rts

; Draw name entry UI on results screen
draw_name_entry:
            ; Draw "ENTER NAME:" label at row 15
            ldx #0
.label_loop:
            lda enter_name_text,x
            beq .draw_letters
            sta SCREEN + (15 * 40) + 13,x
            lda #1                  ; White
            sta COLRAM + (15 * 40) + 13,x
            inx
            bne .label_loop

.draw_letters:
            ; Draw the three letters at row 16
            lda name_char_0
            sta SCREEN + (16 * 40) + 18
            lda name_char_1
            sta SCREEN + (16 * 40) + 19
            lda name_char_2
            sta SCREEN + (16 * 40) + 20

            ; Colour based on cursor position and flash
            lda #7                  ; Yellow
            sta COLRAM + (16 * 40) + 18
            sta COLRAM + (16 * 40) + 19
            sta COLRAM + (16 * 40) + 20

            ; Flash current letter
            lda name_flash
            and #$08
            beq .no_flash
            ldx name_cursor
            lda #1                  ; White
            sta COLRAM + (16 * 40) + 18,x
.no_flash:
            rts

; Draw high score table on screen
; Shows top 5 scores with rank, name, and score
draw_hs_table:
            ; Draw header "HIGH SCORES" at row 3
            ldx #0
.header_loop:
            lda hs_header_text,x
            beq .draw_entries
            sta SCREEN + (3 * 40) + 14,x
            lda #3                  ; Cyan
            sta COLRAM + (3 * 40) + 14,x
            inx
            bne .header_loop

.draw_entries:
            ; Draw 5 entries starting at row 5
            lda #0
            sta hs_temp             ; Entry counter
            lda #<(SCREEN + (5 * 40) + 10)
            sta ZP_PTR
            lda #>(SCREEN + (5 * 40) + 10)
            sta ZP_PTR_HI

.entry_loop:
            ; Draw rank (1-5)
            lda hs_temp
            clc
            adc #'1'                ; Convert to ASCII '1'-'5'
            ldy #0
            sta (ZP_PTR),y
            iny
            lda #'.'
            sta (ZP_PTR),y
            iny
            lda #' '
            sta (ZP_PTR),y

            ; Draw name (3 characters)
            lda hs_temp
            asl                     ; ×2
            asl                     ; ×4
            clc
            adc hs_temp             ; ×5
            tax                     ; X = table offset

            ldy #3
            lda hs_table,x
            sta (ZP_PTR),y
            iny
            lda hs_table+1,x
            sta (ZP_PTR),y
            iny
            lda hs_table+2,x
            sta (ZP_PTR),y

            ; Draw score (5 digits)
            lda hs_table+3,x
            sta work_lo
            lda hs_table+4,x
            sta work_hi

            ; Position for score: offset 8 from start
            ldy #8
            jsr draw_score_at_ptr

            ; Move to next row (add 40 to pointer)
            lda ZP_PTR
            clc
            adc #40
            sta ZP_PTR
            bcc .no_carry
            inc ZP_PTR_HI
.no_carry:

            ; Next entry
            inc hs_temp
            lda hs_temp
            cmp #5
            bcc .entry_loop

            ; Colour the table
            ldx #0
.colour_loop:
            lda #1                  ; White
            sta COLRAM + (5 * 40) + 10,x
            sta COLRAM + (6 * 40) + 10,x
            sta COLRAM + (7 * 40) + 10,x
            sta COLRAM + (8 * 40) + 10,x
            sta COLRAM + (9 * 40) + 10,x
            inx
            cpx #20
            bne .colour_loop

            rts

; Draw score from work_lo/work_hi at (ZP_PTR),y
draw_score_at_ptr:
            ; Convert 16-bit score to 5 decimal digits
            ; Uses subtraction method

            ; 10000s digit
            lda #0
            sta hs_temp
.sub_10000:
            lda work_lo
            sec
            sbc #<10000
            tax
            lda work_hi
            sbc #>10000
            bcc .done_10000
            sta work_hi
            stx work_lo
            inc hs_temp
            jmp .sub_10000
.done_10000:
            lda hs_temp
            clc
            adc #'0'
            sta (ZP_PTR),y
            iny

            ; 1000s digit
            lda #0
            sta hs_temp
.sub_1000:
            lda work_lo
            sec
            sbc #<1000
            tax
            lda work_hi
            sbc #>1000
            bcc .done_1000
            sta work_hi
            stx work_lo
            inc hs_temp
            jmp .sub_1000
.done_1000:
            lda hs_temp
            clc
            adc #'0'
            sta (ZP_PTR),y
            iny

            ; 100s digit
            lda #0
            sta hs_temp
.sub_100:
            lda work_lo
            sec
            sbc #100
            bcc .done_100
            sta work_lo
            inc hs_temp
            jmp .sub_100
.done_100:
            lda hs_temp
            clc
            adc #'0'
            sta (ZP_PTR),y
            iny

            ; 10s digit
            lda #0
            sta hs_temp
.sub_10:
            lda work_lo
            sec
            sbc #10
            bcc .done_10
            sta work_lo
            inc hs_temp
            jmp .sub_10
.done_10:
            lda hs_temp
            clc
            adc #'0'
            sta (ZP_PTR),y
            iny

            ; 1s digit
            lda work_lo
            clc
            adc #'0'
            sta (ZP_PTR),y

            rts

enter_name_text:
            !text "ENTER NAME:"
            !byte 0

hs_header_text:
            !text "HIGH SCORES"
            !byte 0

; ----------------------------------------------------------------------------
; Options Screen Routines (Unit 46)
; ----------------------------------------------------------------------------

; Show the options screen
show_options:
            ; Clear screen
            jsr clear_screen

            ; Set colours
            lda #6                  ; Blue
            sta $D020
            sta $D021

            ; Draw title "OPTIONS" at row 2
            ldx #0
.opt_title:
            lda options_title,x
            beq .draw_menu_items
            sta SCREEN + (2 * 40) + 16,x
            lda #3                  ; Cyan
            sta COLRAM + (2 * 40) + 16,x
            inx
            bne .opt_title

.draw_menu_items:
            ; Draw menu items
            ldx #0
.item1:
            lda opt_sound_test,x
            beq .item2_start
            sta SCREEN + (6 * 40) + 12,x
            inx
            bne .item1

.item2_start:
            ldx #0
.item2:
            lda opt_high_scores,x
            beq .item3_start
            sta SCREEN + (8 * 40) + 12,x
            inx
            bne .item2

.item3_start:
            ldx #0
.item3:
            lda opt_stats,x
            beq .item4_start
            sta SCREEN + (10 * 40) + 12,x
            inx
            bne .item3

.item4_start:
            ldx #0
.item4:
            lda opt_back,x
            beq .draw_hint
            sta SCREEN + (14 * 40) + 12,x
            inx
            bne .item4

.draw_hint:
            ; Draw hint at bottom
            ldx #0
.hint:
            lda opt_hint,x
            beq .init_done
            sta SCREEN + (23 * 40) + 8,x
            lda #11                 ; Grey
            sta COLRAM + (23 * 40) + 8,x
            inx
            bne .hint

.init_done:
            ; Colour menu items white
            ldx #16
.col_items:
            lda #1                  ; White
            sta COLRAM + (6 * 40) + 12,x
            sta COLRAM + (8 * 40) + 12,x
            sta COLRAM + (10 * 40) + 12,x
            sta COLRAM + (14 * 40) + 12,x
            dex
            bpl .col_items

            ; Initialize cursor
            lda #0
            sta options_cursor
            sta options_state
            jsr draw_options_cursor
            rts

; Update options screen
update_options:
            lda options_state
            cmp #1
            bne uo_not_st
            jmp update_sound_test
uo_not_st:
            cmp #2
            bne uo_menu_state
            jmp update_stats_view
uo_menu_state:

            ; State 0: Menu navigation
            ; Handle key delay
            lda key_delay_count
            beq uo_check_input
            dec key_delay_count
            jmp uo_check_fire

uo_check_input:
            ; Check joystick up
            lda CIA1_PRA
            and #$01
            beq uo_up_pressed

            ; Check joystick down
            lda CIA1_PRA
            and #$02
            beq uo_down_pressed

            jmp uo_check_fire

uo_up_pressed:
            lda options_cursor
            beq uo_set_delay        ; Already at top
            dec options_cursor
            jsr play_menu_move
            jsr draw_options_cursor
            jmp uo_set_delay

uo_down_pressed:
            lda options_cursor
            cmp #3
            bcs uo_set_delay        ; Already at bottom (4 items: 0-3)
            inc options_cursor
            jsr play_menu_move
            jsr draw_options_cursor
            jmp uo_set_delay

uo_set_delay:
            lda #KEY_DELAY
            sta key_delay_count

uo_check_fire:
            ; Check fire button
            lda CIA1_PRA
            and #$10
            beq uo_fire_pressed

            ; Check space bar
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq uo_fire_pressed

            lda #$FF
            sta CIA1_PRA
            rts

uo_fire_pressed:
            lda #$FF
            sta CIA1_PRA
            jsr play_menu_select

            ; Handle selection based on cursor
            lda options_cursor
            cmp #0
            beq uo_select_sound_test
            cmp #1
            beq uo_select_high_scores
            cmp #2
            beq uo_select_stats
            ; Default: Back
            jmp uo_go_back

uo_select_sound_test:
            lda #0
            sta sound_test_idx
            lda #1
            sta options_state
            jsr show_sound_test_ui
            rts

uo_select_high_scores:
            jsr clear_screen
            jsr draw_hs_table
            ; Draw "FIRE TO RETURN" hint
            ldx #0
uo_hs_hint:
            lda fire_return_text,x
            beq uo_hs_wait
            sta SCREEN + (20 * 40) + 12,x
            lda #11
            sta COLRAM + (20 * 40) + 12,x
            inx
            bne uo_hs_hint
uo_hs_wait:
            lda #2
            sta options_state       ; Use state 2 for HS view
            rts

uo_select_stats:
            jsr show_stats_screen
            lda #2
            sta options_state
            rts

uo_go_back:
            ; Return to menu
            jsr show_menu
            lda #STATE_MENU
            sta game_state
            rts

; Update sound test sub-state
update_sound_test:
            ; Check left/right for sound selection
            lda key_delay_count
            beq ust_check
            dec key_delay_count
            jmp ust_fire

ust_check:
            lda CIA1_PRA
            and #$04                ; Left
            beq ust_prev
            lda CIA1_PRA
            and #$08                ; Right
            beq ust_next
            jmp ust_fire

ust_prev:
            lda sound_test_idx
            beq ust_delay
            dec sound_test_idx
            jsr play_menu_move
            jsr draw_sound_test_name
            jmp ust_delay

ust_next:
            lda sound_test_idx
            cmp #8                  ; 9 sounds (0-8)
            bcs ust_delay
            inc sound_test_idx
            jsr play_menu_move
            jsr draw_sound_test_name
            jmp ust_delay

ust_delay:
            lda #KEY_DELAY
            sta key_delay_count

ust_fire:
            ; Fire plays the sound
            lda CIA1_PRA
            and #$10
            beq ust_play

            ; Check for back (down or B key)
            lda CIA1_PRA
            and #$02
            beq ust_back

            lda #$FF
            sta CIA1_PRA
            rts

ust_play:
            lda #$FF
            sta CIA1_PRA
            ; Play selected sound
            ldx sound_test_idx
            jsr play_test_sound
            lda #10
            sta key_delay_count
            rts

ust_back:
            lda #$FF
            sta CIA1_PRA
            ; Return to options menu
            jsr show_options
            rts

; Update stats/HS view - just wait for fire
update_stats_view:
            lda CIA1_PRA
            and #$10
            beq usv_back
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq usv_back
            lda #$FF
            sta CIA1_PRA
            rts

usv_back:
            lda #$FF
            sta CIA1_PRA
            jsr play_menu_back
            jsr show_options
            rts

; Draw options cursor
draw_options_cursor:
            ; Clear old cursor positions
            lda #' '
            sta SCREEN + (6 * 40) + 10
            sta SCREEN + (8 * 40) + 10
            sta SCREEN + (10 * 40) + 10
            sta SCREEN + (14 * 40) + 10

            ; Draw cursor at current position
            lda options_cursor
            cmp #0
            bne doc_not_0
            lda #'>'
            sta SCREEN + (6 * 40) + 10
            rts
doc_not_0:
            cmp #1
            bne doc_not_1
            lda #'>'
            sta SCREEN + (8 * 40) + 10
            rts
doc_not_1:
            cmp #2
            bne doc_not_2
            lda #'>'
            sta SCREEN + (10 * 40) + 10
            rts
doc_not_2:
            lda #'>'
            sta SCREEN + (14 * 40) + 10
            rts

; Show sound test UI
show_sound_test_ui:
            ; Clear middle area
            ldx #0
            lda #' '
.clear_mid:
            sta SCREEN + (6 * 40),x
            sta SCREEN + (7 * 40),x
            sta SCREEN + (8 * 40),x
            sta SCREEN + (9 * 40),x
            sta SCREEN + (10 * 40),x
            inx
            cpx #40
            bne .clear_mid

            ; Draw "SOUND TEST" header
            ldx #0
.st_hdr:
            lda sound_test_hdr,x
            beq .st_nav
            sta SCREEN + (6 * 40) + 15,x
            lda #7                  ; Yellow
            sta COLRAM + (6 * 40) + 15,x
            inx
            bne .st_hdr

.st_nav:
            ; Draw navigation hint
            ldx #0
.st_nav_loop:
            lda sound_test_nav,x
            beq .st_name
            sta SCREEN + (10 * 40) + 8,x
            lda #11                 ; Grey
            sta COLRAM + (10 * 40) + 8,x
            inx
            bne .st_nav_loop

.st_name:
            jsr draw_sound_test_name
            rts

; Draw current sound name
draw_sound_test_name:
            ; Clear name area
            ldx #16
            lda #' '
.clear_name:
            sta SCREEN + (8 * 40) + 12,x
            dex
            bpl .clear_name

            ; Get sound name pointer
            lda sound_test_idx
            asl                     ; ×2 for word offset
            tax
            lda sound_names_lo,x
            sta ZP_PTR
            lda sound_names_hi,x
            sta ZP_PTR_HI

            ; Draw name
            ldy #0
.draw_name:
            lda (ZP_PTR),y
            beq .name_done
            sta SCREEN + (8 * 40) + 14,y
            lda #1                  ; White
            sta COLRAM + (8 * 40) + 14,y
            iny
            cpy #12
            bne .draw_name
.name_done:
            rts

; Play test sound based on index
play_test_sound:
            cpx #0
            bne pts_not_0
            jmp play_menu_move
pts_not_0:
            cpx #1
            bne pts_not_1
            jmp play_menu_select
pts_not_1:
            cpx #2
            bne pts_not_2
            jmp play_menu_back
pts_not_2:
            cpx #3
            bne pts_not_3
            jmp play_good_sound      ; Note hit
pts_not_3:
            cpx #4
            bne pts_not_4
            jmp play_perfect_sound   ; Perfect hit
pts_not_4:
            cpx #5
            bne pts_not_5
            jmp play_miss_sound      ; Miss
pts_not_5:
            cpx #6
            bne pts_not_6
            jmp play_victory_jingle
pts_not_6:
            cpx #7
            bne pts_not_7
            jmp play_gameover_stinger
pts_not_7:
            ; Index 8 = milestone callout
            lda #$30
            sta voice_freq_hi
            lda #$00
            sta voice_freq_lo
            lda #24
            jmp start_callout

; Show statistics screen
show_stats_screen:
            jsr clear_screen

            ; Draw title
            ldx #0
.stats_title:
            lda stats_title_text,x
            beq .draw_labels
            sta SCREEN + (2 * 40) + 14,x
            lda #3                  ; Cyan
            sta COLRAM + (2 * 40) + 14,x
            inx
            bne .stats_title

.draw_labels:
            ; For now, just show placeholder
            ; (Full stats tracking would need persistent counters)
            ldx #0
.games_lbl:
            lda stats_games,x
            beq .notes_lbl
            sta SCREEN + (6 * 40) + 8,x
            lda #1
            sta COLRAM + (6 * 40) + 8,x
            inx
            bne .games_lbl

.notes_lbl:
            ldx #0
.notes_loop:
            lda stats_notes,x
            beq .combo_lbl
            sta SCREEN + (8 * 40) + 8,x
            lda #1
            sta COLRAM + (8 * 40) + 8,x
            inx
            bne .notes_loop

.combo_lbl:
            ldx #0
.combo_loop:
            lda stats_combo,x
            beq .hint_lbl
            sta SCREEN + (10 * 40) + 8,x
            lda #1
            sta COLRAM + (10 * 40) + 8,x
            inx
            bne .combo_loop

.hint_lbl:
            ldx #0
.hint_loop:
            lda fire_return_text,x
            beq .stats_done
            sta SCREEN + (20 * 40) + 12,x
            lda #11
            sta COLRAM + (20 * 40) + 12,x
            inx
            bne .hint_loop

.stats_done:
            rts

; Options screen text data
options_title:
            !text "OPTIONS"
            !byte 0

opt_sound_test:
            !text "SOUND TEST"
            !byte 0

opt_high_scores:
            !text "HIGH SCORES"
            !byte 0

opt_stats:
            !text "STATISTICS"
            !byte 0

opt_back:
            !text "BACK TO MENU"
            !byte 0

opt_hint:
            !text "UP/DOWN: SELECT  FIRE: CONFIRM"
            !byte 0

fire_return_text:
            !text "FIRE TO RETURN"
            !byte 0

sound_test_hdr:
            !text "SOUND TEST"
            !byte 0

sound_test_nav:
            !text "LEFT/RIGHT: SELECT  FIRE: PLAY"
            !byte 0

stats_title_text:
            !text "STATISTICS"
            !byte 0

stats_games:
            !text "GAMES PLAYED: ---"
            !byte 0

stats_notes:
            !text "NOTES HIT: ---"
            !byte 0

stats_combo:
            !text "BEST COMBO: ---"
            !byte 0

; Sound names table
sound_names_lo:
            !byte <snd_name_0, <snd_name_1, <snd_name_2, <snd_name_3
            !byte <snd_name_4, <snd_name_5, <snd_name_6, <snd_name_7
            !byte <snd_name_8

sound_names_hi:
            !byte >snd_name_0, >snd_name_1, >snd_name_2, >snd_name_3
            !byte >snd_name_4, >snd_name_5, >snd_name_6, >snd_name_7
            !byte >snd_name_8

snd_name_0: !text "MENU MOVE"
            !byte 0
snd_name_1: !text "MENU SELECT"
            !byte 0
snd_name_2: !text "MENU BACK"
            !byte 0
snd_name_3: !text "NOTE HIT"
            !byte 0
snd_name_4: !text "PERFECT HIT"
            !byte 0
snd_name_5: !text "MISS"
            !byte 0
snd_name_6: !text "VICTORY"
            !byte 0
snd_name_7: !text "GAME OVER"
            !byte 0
snd_name_8: !text "MILESTONE"
            !byte 0

; ----------------------------------------------------------------------------
; Pause Functionality (Unit 47)
; ----------------------------------------------------------------------------

; Pause the game
pause_game:
            lda #1
            sta game_paused
            lda #0
            sta pause_cursor

            ; Silence SID
            lda #0
            sta SID_VOLUME

            ; Draw pause overlay
            jsr draw_pause_overlay
            jsr play_menu_select
            rts

; Update while paused
update_paused:
            ; Handle countdown if active
            lda countdown_value
            beq up_pause_menu
            jmp update_countdown

up_pause_menu:
            ; Handle pause menu input
            lda key_delay_count
            beq up_check_pause_input
            dec key_delay_count
            rts

up_check_pause_input:
            ; Check joystick up
            lda CIA1_PRA
            and #$01
            beq up_pause_up

            ; Check joystick down
            lda CIA1_PRA
            and #$02
            beq up_pause_down

            ; Check fire
            lda CIA1_PRA
            and #$10
            beq up_pause_fire

            ; Check space
            lda #$7F
            sta CIA1_PRA
            lda CIA1_PRB
            and #$10
            beq up_pause_fire

            lda #$FF
            sta CIA1_PRA
            rts

up_pause_up:
            lda pause_cursor
            beq up_pause_delay
            dec pause_cursor
            jsr play_menu_move
            jsr draw_pause_cursor
            jmp up_pause_delay

up_pause_down:
            lda pause_cursor
            cmp #2
            bcs up_pause_delay
            inc pause_cursor
            jsr play_menu_move
            jsr draw_pause_cursor
            jmp up_pause_delay

up_pause_delay:
            lda #KEY_DELAY
            sta key_delay_count
            rts

up_pause_fire:
            lda #$FF
            sta CIA1_PRA
            jsr play_menu_select

            lda pause_cursor
            cmp #0
            beq up_do_resume
            cmp #1
            beq up_do_restart
            ; Quit
            jmp up_do_quit

up_do_resume:
            ; Start countdown
            lda #3
            sta countdown_value
            lda #50                 ; 1 second per number
            sta countdown_timer
            jsr draw_countdown
            rts

up_do_restart:
            ; Restart the song
            lda #0
            sta game_paused
            ; Restore volume
            lda #$0F
            sta SID_VOLUME
            ; Re-init gameplay
            jsr init_game
            rts

up_do_quit:
            ; Return to menu
            lda #0
            sta game_paused
            ; Restore volume
            lda #$0F
            sta SID_VOLUME
            ; Silence all voices
            jsr init_sid
            ; Go to menu
            jsr show_menu
            lda #STATE_MENU
            sta game_state
            rts

; Update countdown
update_countdown:
            dec countdown_timer
            bne uc_not_done

            ; Timer reached zero - decrement countdown value
            dec countdown_value
            lda countdown_value
            beq uc_resume           ; Countdown complete

            ; Draw new number
            lda #50
            sta countdown_timer
            jsr draw_countdown
            jsr play_menu_move
            rts

uc_not_done:
            rts

uc_resume:
            ; Countdown complete - resume gameplay
            lda #0
            sta game_paused
            ; Restore volume
            lda #$0F
            sta SID_VOLUME
            ; Clear the pause overlay
            jsr clear_pause_overlay
            rts

; Draw pause overlay
draw_pause_overlay:
            ; Draw semi-transparent overlay effect by darkening screen
            ; Just draw the pause menu text for now

            ; Draw "PAUSED" at row 8
            ldx #0
dpo_title:
            lda pause_title_text,x
            beq dpo_items
            sta SCREEN + (8 * 40) + 17,x
            lda #1                  ; White
            sta COLRAM + (8 * 40) + 17,x
            inx
            bne dpo_title

dpo_items:
            ; Draw menu items
            ldx #0
dpo_resume:
            lda pause_resume_text,x
            beq dpo_restart_start
            sta SCREEN + (12 * 40) + 15,x
            lda #7                  ; Yellow
            sta COLRAM + (12 * 40) + 15,x
            inx
            bne dpo_resume

dpo_restart_start:
            ldx #0
dpo_restart:
            lda pause_restart_text,x
            beq dpo_quit_start
            sta SCREEN + (14 * 40) + 15,x
            lda #7
            sta COLRAM + (14 * 40) + 15,x
            inx
            bne dpo_restart

dpo_quit_start:
            ldx #0
dpo_quit:
            lda pause_quit_text,x
            beq dpo_cursor
            sta SCREEN + (16 * 40) + 15,x
            lda #7
            sta COLRAM + (16 * 40) + 15,x
            inx
            bne dpo_quit

dpo_cursor:
            jsr draw_pause_cursor
            rts

; Draw pause cursor
draw_pause_cursor:
            ; Clear old cursor positions
            lda #' '
            sta SCREEN + (12 * 40) + 13
            sta SCREEN + (14 * 40) + 13
            sta SCREEN + (16 * 40) + 13

            ; Draw cursor at current position
            lda pause_cursor
            cmp #0
            bne dpc_not_0
            lda #'>'
            sta SCREEN + (12 * 40) + 13
            rts
dpc_not_0:
            cmp #1
            bne dpc_not_1
            lda #'>'
            sta SCREEN + (14 * 40) + 13
            rts
dpc_not_1:
            lda #'>'
            sta SCREEN + (16 * 40) + 13
            rts

; Draw countdown number
draw_countdown:
            ; Clear pause menu area
            ldx #10
            lda #' '
dcn_clear:
            sta SCREEN + (12 * 40) + 13,x
            sta SCREEN + (14 * 40) + 13,x
            sta SCREEN + (16 * 40) + 13,x
            dex
            bpl dcn_clear

            ; Draw countdown number (big, centered)
            lda countdown_value
            clc
            adc #'0'
            sta SCREEN + (13 * 40) + 19
            sta SCREEN + (13 * 40) + 20
            lda #1                  ; White
            sta COLRAM + (13 * 40) + 19
            sta COLRAM + (13 * 40) + 20
            rts

; Clear pause overlay
clear_pause_overlay:
            ; Clear the pause text areas
            ldx #10
            lda #' '
cpo_clear:
            sta SCREEN + (8 * 40) + 15,x
            sta SCREEN + (12 * 40) + 13,x
            sta SCREEN + (13 * 40) + 17,x
            sta SCREEN + (14 * 40) + 13,x
            sta SCREEN + (16 * 40) + 13,x
            dex
            bpl cpo_clear
            rts

; Pause text data
pause_title_text:
            !scr "paused"
            !byte 0

pause_resume_text:
            !scr "resume"
            !byte 0

pause_restart_text:
            !scr "restart"
            !byte 0

pause_quit_text:
            !scr "quit"
            !byte 0

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

; Unit 50: work_lo/work_hi moved to zero page ($53-$54) for faster access
; Old storage removed - saves 2 bytes and all accesses are now 1 cycle faster

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
; Calculate Performance Grade
; ----------------------------------------------------------------------------
; Calculates grade based on perfect hit percentage
; Sets current_grade (screen code) and current_grade_col (colour)

calculate_grade:
            ; Calculate perfect percentage: (perfect_count * 100) / total_notes
            ; For simplicity, use perfect_count vs notes_hit ratio
            ; notes_hit = perfect_count + good_count
            ; We want: perfect_count / notes_hit * 100

            ; If no notes hit, give D grade
            lda notes_hit
            bne calc_grade_continue
            lda #'d'                ; Screen code for D
            sta current_grade
            lda #2                  ; Red
            sta current_grade_col
            rts

calc_grade_continue:
            ; Calculate percentage: perfect_count * 100 / notes_hit
            ; Use 8-bit approximation for simplicity

            ; First multiply perfect_count by 100
            lda perfect_count
            sta work_lo
            lda #0
            sta work_hi

            ; Multiply by 100 (64 + 32 + 4 = 100)
            ; work = perfect * 64
            asl work_lo
            rol work_hi             ; *2
            asl work_lo
            rol work_hi             ; *4
            asl work_lo
            rol work_hi             ; *8
            asl work_lo
            rol work_hi             ; *16
            asl work_lo
            rol work_hi             ; *32
            asl work_lo
            rol work_hi             ; *64

            ; Save *64 result
            lda work_lo
            sta ZP_TEMP
            lda work_hi
            pha                     ; Save high byte of *64

            ; Get *32 (shift right from *64)
            lsr work_hi
            ror work_lo             ; *32 in work

            ; Add *64 + *32 = *96
            lda ZP_TEMP
            clc
            adc work_lo
            sta work_lo
            pla
            adc work_hi
            sta work_hi             ; work = perfect * 96

            ; Add *4 to get *100
            lda perfect_count
            asl
            asl                     ; A = perfect * 4
            clc
            adc work_lo
            sta work_lo
            lda #0
            adc work_hi
            sta work_hi             ; work = perfect * 100

            ; Now divide by notes_hit
            ; Simple repeated subtraction for small values
            lda #0
            sta ZP_TEMP             ; Quotient (percentage)

grade_div_loop:
            ; Check if work >= notes_hit
            lda work_hi
            bne grade_can_sub       ; High byte nonzero, can subtract
            lda work_lo
            cmp notes_hit
            bcc grade_div_done      ; work < notes_hit, done
grade_can_sub:
            ; Subtract notes_hit from work
            lda work_lo
            sec
            sbc notes_hit
            sta work_lo
            lda work_hi
            sbc #0
            sta work_hi
            inc ZP_TEMP             ; Increment percentage
            lda ZP_TEMP
            cmp #101                ; Cap at 100%
            bcc grade_div_loop
grade_div_done:
            ; ZP_TEMP now contains percentage (0-100)
            ; Determine grade based on thresholds
            lda ZP_TEMP
            cmp #GRADE_S_THRESHOLD
            bcs grade_is_s
            cmp #GRADE_A_THRESHOLD
            bcs grade_is_a
            cmp #GRADE_B_THRESHOLD
            bcs grade_is_b
            cmp #GRADE_C_THRESHOLD
            bcs grade_is_c
            ; Below C threshold = D
            lda #'d'
            sta current_grade
            lda #2                  ; Red
            sta current_grade_col
            rts

grade_is_s:
            lda #'s'
            sta current_grade
            lda #7                  ; Yellow
            sta current_grade_col
            rts

grade_is_a:
            lda #'a'
            sta current_grade
            lda #5                  ; Green
            sta current_grade_col
            rts

grade_is_b:
            lda #'b'
            sta current_grade
            lda #3                  ; Cyan
            sta current_grade_col
            rts

grade_is_c:
            lda #'c'
            sta current_grade
            lda #15                 ; Light grey
            sta current_grade_col
            rts

; ----------------------------------------------------------------------------
; Show Results Screen
; ----------------------------------------------------------------------------

show_results:
            ; Check for full combo bonus (no misses)
            lda miss_count
            bne skip_full_combo
            ; Award full combo bonus!
            lda #FULL_COMBO_BONUS
            jsr add_score
skip_full_combo:

            ; Check if we beat the high score
            jsr check_high_score

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
            beq draw_grade
            sta SCREEN + (5 * 40) + 13,x
            lda #5
            sta COLRAM + (5 * 40) + 13,x
            inx
            jmp draw_complete

draw_grade:
            ; Calculate and display performance grade
            jsr calculate_grade
            ; Display grade label
            ldx #0
draw_grade_label:
            lda grade_label,x
            beq draw_grade_letter
            sta SCREEN + (7 * 40) + 14,x
            lda #7
            sta COLRAM + (7 * 40) + 14,x
            inx
            jmp draw_grade_label

draw_grade_letter:
            ; Grade letter is in A register from calculate_grade
            lda current_grade
            sta SCREEN + (7 * 40) + 22
            ; Colour based on grade
            ldx current_grade_col
            stx COLRAM + (7 * 40) + 22

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
            ; Draw initial score as 00000 (Unit 44 - will animate up)
            lda #$30                ; ASCII '0'
            sta SCREEN + (9 * 40) + 23
            sta SCREEN + (9 * 40) + 24
            sta SCREEN + (9 * 40) + 25
            sta SCREEN + (9 * 40) + 26
            sta SCREEN + (9 * 40) + 27
            lda #7
            sta COLRAM + (9 * 40) + 23
            sta COLRAM + (9 * 40) + 24
            sta COLRAM + (9 * 40) + 25
            sta COLRAM + (9 * 40) + 26
            sta COLRAM + (9 * 40) + 27
            jmp draw_perfect_label

            ; (Original division code preserved but skipped - kept for reference)
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

            ; Check if this was a new high score
            lda new_high_score
            beq res_show_prev_hs

            ; Draw "NEW HIGH SCORE!" in bright cyan
            ldx #0
res_draw_new_hs:
            lda new_hs_text,x
            bne +                   ; Branch over jump if not zero
            jmp res_draw_return     ; Far jump when zero
+           sta SCREEN + (17 * 40) + 12,x
            lda #3                  ; Cyan
            sta COLRAM + (17 * 40) + 12,x
            inx
            jmp res_draw_new_hs

res_show_prev_hs:
            ; Draw "HIGH SCORE:" label
            ldx #0
res_draw_hs_label:
            lda high_score_text,x
            beq res_draw_hs_value
            sta SCREEN + (17 * 40) + 12,x
            lda #11                 ; Dark grey
            sta COLRAM + (17 * 40) + 12,x
            inx
            jmp res_draw_hs_label

res_draw_hs_value:
            ; Get high score for current song/difficulty
            jsr get_high_score

            ; Display 5-digit high score
            ldx #0
res_hs_div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc res_hs_done_10000
            sta work_hi
            sty work_lo
            inx
            jmp res_hs_div_10000
res_hs_done_10000:
            txa
            ora #$30
            sta SCREEN + (17 * 40) + 24

            ldx #0
res_hs_div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc res_hs_done_1000
            sta work_hi
            sty work_lo
            inx
            jmp res_hs_div_1000
res_hs_done_1000:
            txa
            ora #$30
            sta SCREEN + (17 * 40) + 25

            ldx #0
res_hs_div_100:
            lda work_lo
            sec
            sbc #100
            bcc res_hs_done_100
            sta work_lo
            inx
            jmp res_hs_div_100
res_hs_done_100:
            txa
            ora #$30
            sta SCREEN + (17 * 40) + 26

            ldx #0
res_hs_div_10:
            lda work_lo
            sec
            sbc #10
            bcc res_hs_done_10
            sta work_lo
            inx
            jmp res_hs_div_10
res_hs_done_10:
            txa
            ora #$30
            sta SCREEN + (17 * 40) + 27

            lda work_lo
            ora #$30
            sta SCREEN + (17 * 40) + 28

            ; Colour high score digits
            lda #11
            sta COLRAM + (17 * 40) + 24
            sta COLRAM + (17 * 40) + 25
            sta COLRAM + (17 * 40) + 26
            sta COLRAM + (17 * 40) + 27
            sta COLRAM + (17 * 40) + 28

            ; Draw best streak on row 19
            ldx #0
draw_streak_label:
            lda streak_label,x
            beq draw_streak_value
            sta SCREEN + (19 * 40) + 12,x
            lda #3                  ; Cyan
            sta COLRAM + (19 * 40) + 12,x
            inx
            jmp draw_streak_label

draw_streak_value:
            ; Display best_streak as 2-digit number
            lda best_streak
            ldx #0
streak_div_10:
            cmp #10
            bcc streak_done_10
            sec
            sbc #10
            inx
            jmp streak_div_10
streak_done_10:
            pha
            txa
            ora #$30
            sta SCREEN + (19 * 40) + 25
            pla
            ora #$30
            sta SCREEN + (19 * 40) + 26
            lda #3
            sta COLRAM + (19 * 40) + 25
            sta COLRAM + (19 * 40) + 26

res_draw_return:
            ; Draw "PRESS FIRE" on row 21
            ldx #0
draw_return:
            lda return_text,x
            beq results_done
            sta SCREEN + (21 * 40) + 10,x
            lda #11
            sta COLRAM + (21 * 40) + 10,x
            inx
            jmp draw_return

results_done:
            ; Initialize animation state (Unit 44)
            lda #0
            sta results_phase       ; Start at phase 0
            sta display_score_lo    ; Start display at 0
            sta display_score_hi
            sta name_entry_mode     ; Not in name entry mode (Unit 45)
            lda #$FF
            sta hs_table_rank       ; No rank yet (Unit 45)
            lda #30                 ; Initial delay (half second)
            sta results_timer
            lda #30
            sta grade_flash         ; Grade flash duration
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

grade_label:
            !scr "grade:"
            !byte 0

streak_label:
            !scr "best streak:"
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
            ; Check if we beat the high score
            jsr check_high_score

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

            ; Check if this was a new high score
            lda new_high_score
            beq draw_prev_high

            ; Draw "NEW HIGH SCORE!" in bright cyan
            ldx #0
draw_new_hs:
            lda new_hs_text,x
            bne +                   ; Branch over jump if not zero
            jmp go_draw_retry       ; Far jump when zero
+           sta SCREEN + (14 * 40) + 12,x
            lda #3                  ; Cyan
            sta COLRAM + (14 * 40) + 12,x
            inx
            jmp draw_new_hs

draw_prev_high:
            ; Draw "HIGH SCORE:" label
            ldx #0
draw_hs_label:
            lda high_score_text,x
            beq draw_hs_value
            sta SCREEN + (14 * 40) + 12,x
            lda #11                 ; Dark grey
            sta COLRAM + (14 * 40) + 12,x
            inx
            jmp draw_hs_label

draw_hs_value:
            ; Get current high score into work_lo/work_hi
            jsr get_high_score

            ; Draw 5-digit high score value
            ldx #0
hs_div_10000:
            lda work_lo
            sec
            sbc #<10000
            tay
            lda work_hi
            sbc #>10000
            bcc hs_done_10000
            sta work_hi
            sty work_lo
            inx
            jmp hs_div_10000
hs_done_10000:
            txa
            ora #$30
            sta SCREEN + (14 * 40) + 24

            ldx #0
hs_div_1000:
            lda work_lo
            sec
            sbc #<1000
            tay
            lda work_hi
            sbc #>1000
            bcc hs_done_1000
            sta work_hi
            sty work_lo
            inx
            jmp hs_div_1000
hs_done_1000:
            txa
            ora #$30
            sta SCREEN + (14 * 40) + 25

            ldx #0
hs_div_100:
            lda work_lo
            sec
            sbc #100
            bcc hs_done_100
            sta work_lo
            inx
            jmp hs_div_100
hs_done_100:
            txa
            ora #$30
            sta SCREEN + (14 * 40) + 26

            ldx #0
hs_div_10:
            lda work_lo
            sec
            sbc #10
            bcc hs_done_10
            sta work_lo
            inx
            jmp hs_div_10
hs_done_10:
            txa
            ora #$30
            sta SCREEN + (14 * 40) + 27

            lda work_lo
            ora #$30
            sta SCREEN + (14 * 40) + 28

            ; Colour high score digits
            lda #11
            sta COLRAM + (14 * 40) + 24
            sta COLRAM + (14 * 40) + 25
            sta COLRAM + (14 * 40) + 26
            sta COLRAM + (14 * 40) + 27
            sta COLRAM + (14 * 40) + 28

go_draw_retry:
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

new_hs_text:
            !scr "new high score!"
            !byte 0

high_score_text:
            !scr "high score:"
            !byte 0

retry_text:
            !scr "press fire to continue"
            !byte 0

; ============================================================================
; SONG 1 DATA - "First Steps" (120 BPM) - Three Difficulty Variants
; ============================================================================
; Easy: Notes only on strong beats (0, 8, 16, 24...) - 8 notes
; Normal: Base pattern - 29 notes
; Hard: Dense pattern with off-beat additions - 45 notes

; --- EASY: Sparse pattern (strong beats only) ---
song1_easy:
            !byte 0, 1, $47          ; Beat 0
            !byte 8, 2, $27          ; Beat 8
            !byte 16, 1, $35         ; Beat 16
            !byte 24, 3, $11         ; Beat 24
            !byte 32, 2, $2F         ; Beat 32
            !byte 40, 1, $58         ; Beat 40
            !byte 48, 3, $1A         ; Beat 48
            !byte 56, 1, $47         ; Beat 56
            !byte $FF

; --- NORMAL: Base pattern ---
song1_normal:
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

; --- HARD: Dense pattern (added off-beats) ---
song1_hard:
            !byte 0, 1, $47
            !byte 1, 3, $16          ; Added
            !byte 2, 2, $2C
            !byte 3, 1, $35          ; Added
            !byte 4, 3, $11
            !byte 5, 2, $27          ; Added
            !byte 6, 1, $3B          ; Added
            !byte 8, 1, $3B
            !byte 9, 3, $13          ; Added
            !byte 10, 2, $27
            !byte 11, 1, $35         ; Added
            !byte 12, 3, $13
            !byte 14, 2, $2C         ; Added
            !byte 16, 1, $35
            !byte 17, 2, $2C
            !byte 18, 1, $3B
            !byte 19, 3, $11         ; Added
            !byte 20, 3, $16
            !byte 21, 1, $47         ; Added
            !byte 22, 2, $35         ; Added
            !byte 24, 1, $47
            !byte 25, 3, $16         ; Added
            !byte 26, 2, $35
            !byte 27, 1, $4F         ; Added
            !byte 28, 3, $11
            !byte 30, 2, $27         ; Added
            !byte 32, 2, $2F
            !byte 33, 1, $47         ; Added
            !byte 34, 1, $4F
            !byte 35, 3, $11         ; Added
            !byte 36, 3, $17
            !byte 38, 2, $2C         ; Added
            !byte 40, 1, $58
            !byte 41, 3, $1A         ; Added
            !byte 42, 2, $2C
            !byte 43, 1, $47         ; Added
            !byte 44, 3, $11
            !byte 45, 2, $35         ; Added
            !byte 46, 2, $27
            !byte 47, 1, $4F         ; Added
            !byte 48, 1, $6A
            !byte 49, 2, $35
            !byte 50, 1, $58
            !byte 51, 3, $16         ; Added
            !byte 52, 3, $1A
            !byte 53, 1, $47         ; Added
            !byte 54, 2, $2F
            !byte 55, 3, $11         ; Added
            !byte 56, 1, $47
            !byte 57, 2, $27         ; Added
            !byte 58, 2, $2C
            !byte 59, 1, $3B         ; Added
            !byte 60, 3, $11
            !byte 61, 2, $35         ; Added
            !byte 62, 1, $35
            !byte 63, 3, $16         ; Added
            !byte $FF

; ============================================================================
; SONG 2 DATA - "Upbeat Groove" (130 BPM) - Three Difficulty Variants
; ============================================================================
; Easy: Notes only on strong beats - 8 notes
; Normal: Base syncopated pattern - 52 notes
; Hard: Extremely dense pattern - 72 notes

; --- EASY: Sparse pattern (strong beats only) ---
song2_easy:
            !byte 0, 1, $47          ; Beat 0
            !byte 8, 3, $11          ; Beat 8
            !byte 16, 1, $4F         ; Beat 16
            !byte 24, 2, $47         ; Beat 24
            !byte 32, 1, $4F         ; Beat 32
            !byte 40, 3, $1A         ; Beat 40
            !byte 48, 3, $11         ; Beat 48
            !byte 56, 1, $47         ; Beat 56
            !byte $FF

; --- NORMAL: Base syncopated pattern ---
song2_normal:
            !byte 0, 1, $47
            !byte 1, 2, $35
            !byte 3, 3, $16
            !byte 4, 1, $4F
            !byte 5, 2, $2C
            !byte 7, 1, $47
            !byte 8, 3, $11
            !byte 10, 2, $35
            !byte 11, 1, $58
            !byte 13, 2, $2C
            !byte 14, 3, $1A
            !byte 15, 1, $47
            !byte 16, 1, $4F
            !byte 17, 2, $35
            !byte 18, 3, $16
            !byte 19, 1, $58
            !byte 20, 2, $2C
            !byte 22, 1, $6A
            !byte 23, 2, $35
            !byte 24, 3, $11
            !byte 25, 1, $58
            !byte 26, 2, $47
            !byte 28, 3, $1A
            !byte 30, 1, $47
            !byte 31, 2, $2C
            !byte 32, 1, $4F
            !byte 33, 3, $16
            !byte 34, 2, $35
            !byte 35, 1, $58
            !byte 36, 3, $11
            !byte 37, 1, $6A
            !byte 38, 2, $47
            !byte 39, 1, $58
            !byte 40, 3, $1A
            !byte 41, 2, $35
            !byte 42, 1, $4F
            !byte 43, 2, $2C
            !byte 44, 1, $47
            !byte 45, 3, $16
            !byte 46, 2, $35
            !byte 47, 1, $58
            !byte 48, 3, $11
            !byte 49, 2, $47
            !byte 51, 1, $4F
            !byte 52, 3, $1A
            !byte 54, 2, $35
            !byte 55, 1, $47
            !byte 56, 3, $11
            !byte 58, 2, $2C
            !byte 59, 1, $58
            !byte 60, 3, $16
            !byte 61, 2, $35
            !byte 62, 1, $47
            !byte $FF

; --- HARD: Extremely dense pattern ---
song2_hard:
            !byte 0, 1, $47
            !byte 0, 3, $11          ; Chord
            !byte 1, 2, $35
            !byte 2, 1, $4F          ; Added
            !byte 3, 3, $16
            !byte 4, 1, $4F
            !byte 4, 2, $2C          ; Chord
            !byte 5, 2, $2C
            !byte 6, 3, $1A          ; Added
            !byte 7, 1, $47
            !byte 8, 3, $11
            !byte 8, 1, $58          ; Chord
            !byte 9, 2, $35          ; Added
            !byte 10, 2, $35
            !byte 11, 1, $58
            !byte 12, 3, $16         ; Added
            !byte 13, 2, $2C
            !byte 14, 3, $1A
            !byte 15, 1, $47
            !byte 16, 1, $4F
            !byte 16, 3, $11         ; Chord
            !byte 17, 2, $35
            !byte 18, 3, $16
            !byte 19, 1, $58
            !byte 20, 2, $2C
            !byte 20, 1, $47         ; Chord
            !byte 21, 3, $1A         ; Added
            !byte 22, 1, $6A
            !byte 23, 2, $35
            !byte 24, 3, $11
            !byte 24, 1, $4F         ; Chord
            !byte 25, 1, $58
            !byte 26, 2, $47
            !byte 27, 3, $16         ; Added
            !byte 28, 3, $1A
            !byte 28, 1, $58         ; Chord
            !byte 29, 2, $35         ; Added
            !byte 30, 1, $47
            !byte 31, 2, $2C
            !byte 32, 1, $4F
            !byte 32, 3, $11         ; Chord
            !byte 33, 3, $16
            !byte 34, 2, $35
            !byte 35, 1, $58
            !byte 36, 3, $11
            !byte 36, 2, $47         ; Chord
            !byte 37, 1, $6A
            !byte 38, 2, $47
            !byte 39, 1, $58
            !byte 40, 3, $1A
            !byte 40, 1, $4F         ; Chord
            !byte 41, 2, $35
            !byte 42, 1, $4F
            !byte 43, 2, $2C
            !byte 44, 1, $47
            !byte 44, 3, $11         ; Chord
            !byte 45, 3, $16
            !byte 46, 2, $35
            !byte 47, 1, $58
            !byte 48, 3, $11
            !byte 48, 1, $6A         ; Chord
            !byte 49, 2, $47
            !byte 50, 1, $58         ; Added
            !byte 51, 1, $4F
            !byte 52, 3, $1A
            !byte 52, 2, $35         ; Chord
            !byte 53, 1, $47         ; Added
            !byte 54, 2, $35
            !byte 55, 1, $47
            !byte 56, 3, $11
            !byte 56, 1, $4F         ; Chord
            !byte 57, 2, $47         ; Added
            !byte 58, 2, $2C
            !byte 59, 1, $58
            !byte 60, 3, $16
            !byte 60, 1, $47         ; Chord
            !byte 61, 2, $35
            !byte 62, 1, $47
            !byte 63, 3, $11         ; Added
            !byte $FF

; ============================================================================
; SONG 3 DATA: "Speed Rush" (150 BPM)
; ============================================================================
; An energetic, fast-paced track designed to test reaction time.
; Higher frequencies and rapid note sequences.

; --- EASY: Strong beats only (8 notes) ---
song3_easy:
            !byte 0, 1, $58          ; Beat 0
            !byte 8, 2, $35          ; Beat 8
            !byte 16, 3, $1A         ; Beat 16
            !byte 24, 1, $6A         ; Beat 24
            !byte 32, 2, $47         ; Beat 32
            !byte 40, 3, $16         ; Beat 40
            !byte 48, 1, $58         ; Beat 48
            !byte 56, 2, $35         ; Beat 56
            !byte $FF

; --- NORMAL: Base pattern (32 notes) ---
song3_normal:
            !byte 0, 1, $58
            !byte 2, 2, $35
            !byte 4, 3, $1A
            !byte 6, 1, $6A
            !byte 8, 2, $35
            !byte 10, 1, $58
            !byte 12, 3, $16
            !byte 14, 2, $47
            !byte 16, 3, $1A
            !byte 18, 1, $6A
            !byte 20, 2, $35
            !byte 22, 3, $16
            !byte 24, 1, $6A
            !byte 26, 2, $47
            !byte 28, 3, $1A
            !byte 30, 1, $58
            !byte 32, 2, $47
            !byte 34, 1, $58
            !byte 36, 3, $16
            !byte 38, 2, $35
            !byte 40, 3, $16
            !byte 42, 1, $6A
            !byte 44, 2, $47
            !byte 46, 3, $1A
            !byte 48, 1, $58
            !byte 50, 2, $35
            !byte 52, 3, $16
            !byte 54, 1, $6A
            !byte 56, 2, $35
            !byte 58, 3, $1A
            !byte 60, 1, $58
            !byte 62, 2, $47
            !byte $FF

; --- HARD: Dense pattern with rapid-fire sections (56 notes) ---
song3_hard:
            !byte 0, 1, $58
            !byte 1, 3, $1A          ; Added
            !byte 2, 2, $35
            !byte 3, 1, $6A          ; Added
            !byte 4, 3, $1A
            !byte 5, 2, $47          ; Added
            !byte 6, 1, $6A
            !byte 7, 3, $16          ; Added
            !byte 8, 2, $35
            !byte 9, 1, $58          ; Added
            !byte 10, 1, $58
            !byte 11, 2, $35         ; Added
            !byte 12, 3, $16
            !byte 13, 1, $6A         ; Added
            !byte 14, 2, $47
            !byte 15, 3, $1A         ; Added
            !byte 16, 3, $1A
            !byte 17, 1, $58         ; Added
            !byte 18, 1, $6A
            !byte 19, 2, $35         ; Added
            !byte 20, 2, $35
            !byte 21, 3, $16         ; Added
            !byte 22, 3, $16
            !byte 23, 1, $58         ; Added
            !byte 24, 1, $6A
            !byte 25, 2, $47         ; Added
            !byte 26, 2, $47
            !byte 27, 3, $1A         ; Added
            !byte 28, 3, $1A
            !byte 29, 1, $6A         ; Added
            !byte 30, 1, $58
            !byte 31, 2, $35         ; Added
            !byte 32, 2, $47
            !byte 33, 3, $16         ; Added
            !byte 34, 1, $58
            !byte 35, 2, $47         ; Added
            !byte 36, 3, $16
            !byte 37, 1, $6A         ; Added
            !byte 38, 2, $35
            !byte 39, 3, $1A         ; Added
            !byte 40, 3, $16
            !byte 41, 1, $58         ; Added
            !byte 42, 1, $6A
            !byte 43, 2, $35         ; Added
            !byte 44, 2, $47
            !byte 45, 3, $16         ; Added
            !byte 46, 3, $1A
            !byte 47, 1, $6A         ; Added
            !byte 48, 1, $58
            !byte 49, 2, $47         ; Added
            !byte 50, 2, $35
            !byte 51, 3, $1A         ; Added
            !byte 52, 3, $16
            !byte 53, 1, $58         ; Added
            !byte 54, 1, $6A
            !byte 55, 2, $35         ; Added
            !byte 56, 2, $35
            !byte 57, 3, $16         ; Added
            !byte 58, 3, $1A
            !byte 59, 1, $6A         ; Added
            !byte 60, 1, $58
            !byte 61, 2, $47         ; Added
            !byte 62, 2, $47
            !byte 63, 3, $1A         ; Added
            !byte $FF

; ============================================================================
; SONG 4: "Off-Beat" (125 BPM) - Syncopated rhythms
; ============================================================================
; Syncopation emphasises off-beats. Notes land between expected beats,
; challenging players' sense of rhythm. The pattern feels "pushed" forward.

; --- EASY: Sparse syncopated notes (10 notes) ---
; Only the most prominent off-beat accents
song4_easy:
            !byte 1, 1, $47          ; Off-beat accent
            !byte 9, 2, $3B          ; Pushed note
            !byte 17, 3, $27         ; Syncopated hit
            !byte 25, 1, $47         ; Off-beat
            !byte 33, 2, $3B         ; Pushed
            !byte 41, 3, $27         ; Syncopated
            !byte 49, 1, $47         ; Off-beat
            !byte 55, 2, $3B         ; Pushed
            !byte 59, 3, $27         ; Syncopated
            !byte 63, 1, $47         ; Final accent
            !byte $FF

; --- NORMAL: Syncopated pattern with anchors (32 notes) ---
; Mix of on-beat anchors and off-beat accents
song4_normal:
            !byte 0, 1, $47          ; Anchor
            !byte 1, 2, $3B          ; Off-beat
            !byte 3, 3, $27          ; Syncopated
            !byte 4, 1, $47          ; Anchor
            !byte 5, 2, $3B          ; Off-beat
            !byte 7, 3, $27          ; Syncopated
            !byte 8, 1, $47          ; Anchor
            !byte 9, 2, $3B          ; Off-beat
            !byte 11, 3, $27         ; Syncopated
            !byte 12, 1, $47         ; Anchor
            !byte 13, 2, $3B         ; Off-beat
            !byte 15, 3, $27         ; Syncopated
            !byte 16, 1, $47         ; Anchor
            !byte 17, 2, $3B         ; Off-beat
            !byte 19, 3, $27         ; Syncopated
            !byte 20, 1, $47         ; Anchor
            !byte 21, 2, $3B         ; Off-beat
            !byte 23, 3, $27         ; Syncopated
            !byte 24, 1, $47         ; Anchor
            !byte 25, 2, $3B         ; Off-beat
            !byte 27, 3, $27         ; Syncopated
            !byte 28, 1, $47         ; Anchor
            !byte 29, 2, $3B         ; Off-beat
            !byte 31, 3, $27         ; Syncopated
            !byte 32, 1, $47         ; Anchor
            !byte 33, 2, $3B         ; Off-beat
            !byte 35, 3, $27         ; Syncopated
            !byte 40, 1, $47         ; Anchor
            !byte 41, 2, $3B         ; Off-beat
            !byte 48, 1, $47         ; Anchor
            !byte 49, 3, $27         ; Off-beat
            !byte 56, 1, $47         ; Final anchor
            !byte $FF

; --- HARD: Dense syncopated chaos (56 notes) ---
; Nearly every off-beat filled, minimal anchors
song4_hard:
            !byte 0, 1, $47          ; Anchor
            !byte 1, 2, $3B          ; Off-beat
            !byte 1, 3, $27          ; Chord
            !byte 3, 1, $47          ; Syncopated
            !byte 3, 2, $3B          ; Chord
            !byte 5, 3, $27          ; Off-beat
            !byte 5, 1, $47          ; Chord
            !byte 7, 2, $3B          ; Syncopated
            !byte 7, 3, $27          ; Chord
            !byte 8, 1, $47          ; Anchor
            !byte 9, 2, $3B          ; Off-beat
            !byte 9, 3, $27          ; Chord
            !byte 11, 1, $47         ; Syncopated
            !byte 11, 2, $3B         ; Chord
            !byte 13, 3, $27         ; Off-beat
            !byte 13, 1, $47         ; Chord
            !byte 15, 2, $3B         ; Syncopated
            !byte 15, 3, $27         ; Chord
            !byte 16, 1, $47         ; Anchor
            !byte 17, 2, $3B         ; Off-beat
            !byte 17, 3, $27         ; Chord
            !byte 19, 1, $47         ; Syncopated
            !byte 19, 2, $3B         ; Chord
            !byte 21, 3, $27         ; Off-beat
            !byte 21, 1, $47         ; Chord
            !byte 23, 2, $3B         ; Syncopated
            !byte 23, 3, $27         ; Chord
            !byte 24, 1, $47         ; Anchor
            !byte 25, 2, $3B         ; Off-beat
            !byte 25, 3, $27         ; Chord
            !byte 27, 1, $47         ; Syncopated
            !byte 27, 2, $3B         ; Chord
            !byte 29, 3, $27         ; Off-beat
            !byte 29, 1, $47         ; Chord
            !byte 31, 2, $3B         ; Syncopated
            !byte 31, 3, $27         ; Chord
            !byte 32, 1, $47         ; Anchor
            !byte 33, 2, $3B         ; Off-beat
            !byte 35, 3, $27         ; Syncopated
            !byte 37, 1, $47         ; Off-beat
            !byte 39, 2, $3B         ; Syncopated
            !byte 40, 1, $47         ; Anchor
            !byte 41, 3, $27         ; Off-beat
            !byte 43, 2, $3B         ; Syncopated
            !byte 45, 1, $47         ; Off-beat
            !byte 47, 3, $27         ; Syncopated
            !byte 48, 1, $47         ; Anchor
            !byte 49, 2, $3B         ; Off-beat
            !byte 51, 3, $27         ; Syncopated
            !byte 53, 1, $47         ; Off-beat
            !byte 55, 2, $3B         ; Syncopated
            !byte 56, 1, $47         ; Anchor
            !byte 57, 3, $27         ; Off-beat
            !byte 59, 2, $3B         ; Syncopated
            !byte 61, 1, $47         ; Off-beat
            !byte 63, 3, $27         ; Final syncopated
            !byte $FF

; ============================================================================
; SONG 5: "Chordstorm" (136 BPM) - Polyrhythms
; ============================================================================
; Polyrhythms feature multiple notes on the same beat across different tracks,
; creating chord-like moments that require simultaneous key presses.

; --- EASY: Sparse chords (12 notes) ---
; Simple two-note chords on strong beats
song5_easy:
            !byte 0, 1, $47          ; Track 1
            !byte 0, 2, $3B          ; Track 2 (chord)
            !byte 8, 2, $3B          ; Single
            !byte 16, 1, $47         ; Track 1
            !byte 16, 3, $27         ; Track 3 (chord)
            !byte 24, 3, $27         ; Single
            !byte 32, 1, $47         ; Track 1
            !byte 32, 2, $3B         ; Track 2 (chord)
            !byte 40, 2, $3B         ; Single
            !byte 48, 2, $3B         ; Track 2
            !byte 48, 3, $27         ; Track 3 (chord)
            !byte 56, 1, $47         ; Single
            !byte $FF

; --- NORMAL: Mixed chords and singles (36 notes) ---
; Regular chord patterns with some singles
song5_normal:
            !byte 0, 1, $47          ; 3-note chord
            !byte 0, 2, $3B
            !byte 0, 3, $27
            !byte 4, 1, $47          ; Single
            !byte 8, 2, $3B          ; 2-note chord
            !byte 8, 3, $27
            !byte 12, 2, $3B         ; Single
            !byte 16, 1, $47         ; 3-note chord
            !byte 16, 2, $3B
            !byte 16, 3, $27
            !byte 20, 3, $27         ; Single
            !byte 24, 1, $47         ; 2-note chord
            !byte 24, 2, $3B
            !byte 28, 1, $47         ; Single
            !byte 32, 2, $3B         ; 3-note chord
            !byte 32, 1, $47
            !byte 32, 3, $27
            !byte 36, 2, $3B         ; Single
            !byte 40, 1, $47         ; 2-note chord
            !byte 40, 3, $27
            !byte 44, 3, $27         ; Single
            !byte 48, 1, $47         ; 3-note chord
            !byte 48, 2, $3B
            !byte 48, 3, $27
            !byte 52, 1, $47         ; Single
            !byte 56, 2, $3B         ; 2-note chord
            !byte 56, 3, $27
            !byte 60, 1, $47         ; Single
            !byte $FF

; --- HARD: Dense chord patterns (64 notes) ---
; Frequent chords with minimal breaks
song5_hard:
            !byte 0, 1, $47          ; 3-note chord
            !byte 0, 2, $3B
            !byte 0, 3, $27
            !byte 2, 1, $47          ; 2-note chord
            !byte 2, 2, $3B
            !byte 4, 2, $3B          ; 3-note chord
            !byte 4, 1, $47
            !byte 4, 3, $27
            !byte 6, 3, $27          ; 2-note chord
            !byte 6, 1, $47
            !byte 8, 1, $47          ; 3-note chord
            !byte 8, 2, $3B
            !byte 8, 3, $27
            !byte 10, 2, $3B         ; Single
            !byte 12, 1, $47         ; 2-note chord
            !byte 12, 3, $27
            !byte 14, 2, $3B         ; 3-note chord
            !byte 14, 1, $47
            !byte 14, 3, $27
            !byte 16, 1, $47         ; 3-note chord
            !byte 16, 2, $3B
            !byte 16, 3, $27
            !byte 18, 3, $27         ; 2-note chord
            !byte 18, 2, $3B
            !byte 20, 1, $47         ; 2-note chord
            !byte 20, 2, $3B
            !byte 22, 2, $3B         ; 3-note chord
            !byte 22, 1, $47
            !byte 22, 3, $27
            !byte 24, 1, $47         ; 3-note chord
            !byte 24, 2, $3B
            !byte 24, 3, $27
            !byte 26, 1, $47         ; Single
            !byte 28, 2, $3B         ; 2-note chord
            !byte 28, 3, $27
            !byte 30, 1, $47         ; 3-note chord
            !byte 30, 2, $3B
            !byte 30, 3, $27
            !byte 32, 1, $47         ; 3-note chord
            !byte 32, 2, $3B
            !byte 32, 3, $27
            !byte 34, 2, $3B         ; 2-note chord
            !byte 34, 3, $27
            !byte 36, 1, $47         ; 2-note chord
            !byte 36, 2, $3B
            !byte 38, 3, $27         ; 3-note chord
            !byte 38, 1, $47
            !byte 38, 2, $3B
            !byte 40, 2, $3B         ; 3-note chord
            !byte 40, 1, $47
            !byte 40, 3, $27
            !byte 42, 1, $47         ; Single
            !byte 44, 2, $3B         ; 2-note chord
            !byte 44, 3, $27
            !byte 46, 1, $47         ; 3-note chord
            !byte 46, 2, $3B
            !byte 46, 3, $27
            !byte 48, 1, $47         ; 3-note chord
            !byte 48, 2, $3B
            !byte 48, 3, $27
            !byte 52, 2, $3B         ; 2-note chord
            !byte 52, 1, $47
            !byte 56, 1, $47         ; 3-note chord
            !byte 56, 2, $3B
            !byte 56, 3, $27
            !byte 60, 3, $27         ; 2-note chord
            !byte 60, 2, $3B
            !byte 62, 1, $47         ; Final 3-note chord
            !byte 62, 2, $3B
            !byte 62, 3, $27
            !byte $FF

; ============================================================================
; Song 6 - Fusion (130 BPM)
; ============================================================================
; Combines basic rhythm, syncopation, and polyrhythms
; Tests all skills developed throughout the game

; --- EASY: Learning mixed techniques (16 notes) ---
song6_easy:
            !byte 0, 1, $47          ; Strong beat
            !byte 4, 2, $3B          ; Basic rhythm
            !byte 8, 1, $47
            !byte 8, 2, $3B          ; Simple 2-note chord
            !byte 14, 3, $27         ; Off-beat (syncopation)
            !byte 16, 1, $47         ; Strong beat
            !byte 22, 2, $3B         ; Off-beat
            !byte 24, 3, $27
            !byte 28, 1, $47
            !byte 32, 1, $47
            !byte 32, 3, $27         ; 2-note chord
            !byte 38, 2, $3B         ; Off-beat
            !byte 40, 1, $47
            !byte 46, 3, $27         ; Off-beat
            !byte 48, 2, $3B
            !byte 56, 1, $47         ; Final note
            !byte $FF

; --- NORMAL: Balanced mix (32 notes) ---
song6_normal:
            ; Section 1: Basic + syncopation
            !byte 0, 1, $47          ; Strong downbeat
            !byte 2, 2, $3B          ; Quick follow
            !byte 6, 3, $27          ; Off-beat
            !byte 8, 1, $47          ; Beat
            !byte 10, 2, $3B
            !byte 14, 1, $47         ; Syncopation
            ; Section 2: Add chords
            !byte 16, 1, $47         ; 2-note chord
            !byte 16, 2, $3B
            !byte 20, 3, $27
            !byte 22, 2, $3B         ; Off-beat
            !byte 24, 1, $47
            !byte 26, 3, $27
            !byte 30, 2, $3B         ; Off-beat
            ; Section 3: Full mix
            !byte 32, 1, $47         ; 3-note chord
            !byte 32, 2, $3B
            !byte 32, 3, $27
            !byte 36, 1, $47
            !byte 38, 2, $3B         ; Off-beat
            !byte 40, 3, $27
            !byte 44, 1, $47
            !byte 46, 2, $3B         ; Off-beat
            ; Section 4: Climax
            !byte 48, 1, $47         ; 2-note chord
            !byte 48, 3, $27
            !byte 50, 2, $3B
            !byte 52, 1, $47
            !byte 54, 3, $27         ; Off-beat
            !byte 56, 1, $47         ; 2-note chord
            !byte 56, 2, $3B
            !byte 58, 3, $27
            !byte 60, 1, $47
            !byte 62, 2, $3B         ; Final off-beat
            !byte $FF

; --- HARD: All techniques combined (56 notes) ---
song6_hard:
            ; Section 1: Fast basic + syncopation
            !byte 0, 1, $47
            !byte 1, 2, $3B
            !byte 2, 3, $27
            !byte 3, 1, $58          ; Off-beat
            !byte 4, 2, $3B
            !byte 6, 1, $47          ; Off-beat
            !byte 7, 3, $27
            !byte 8, 1, $47          ; 2-note chord
            !byte 8, 2, $3B
            !byte 10, 3, $27
            !byte 11, 1, $47         ; Syncopation
            !byte 12, 2, $3B
            !byte 14, 1, $58         ; Off-beat
            !byte 15, 3, $27
            ; Section 2: Chord-heavy
            !byte 16, 1, $47         ; 3-note chord
            !byte 16, 2, $3B
            !byte 16, 3, $27
            !byte 18, 1, $58
            !byte 19, 2, $3B         ; Off-beat
            !byte 20, 1, $47         ; 2-note chord
            !byte 20, 3, $27
            !byte 22, 2, $3B         ; Off-beat
            !byte 23, 1, $47
            !byte 24, 2, $3B         ; 2-note chord
            !byte 24, 3, $27
            !byte 26, 1, $58
            !byte 27, 2, $3B         ; Off-beat
            !byte 28, 1, $47
            !byte 30, 3, $27         ; Off-beat
            ; Section 3: Maximum challenge
            !byte 32, 1, $47         ; 3-note chord
            !byte 32, 2, $3B
            !byte 32, 3, $27
            !byte 34, 1, $58         ; 2-note chord
            !byte 34, 2, $3B
            !byte 35, 3, $27         ; Off-beat
            !byte 36, 1, $47
            !byte 38, 2, $3B         ; Off-beat
            !byte 39, 3, $27
            !byte 40, 1, $47         ; 3-note chord
            !byte 40, 2, $3B
            !byte 40, 3, $27
            !byte 42, 1, $58
            !byte 43, 2, $3B         ; Off-beat
            !byte 44, 3, $27         ; 2-note chord
            !byte 44, 1, $47
            !byte 46, 2, $3B         ; Off-beat
            ; Section 4: Grand finale
            !byte 48, 1, $47         ; 3-note chord
            !byte 48, 2, $3B
            !byte 48, 3, $27
            !byte 50, 1, $58
            !byte 51, 2, $3B         ; Off-beat
            !byte 52, 1, $47         ; 2-note chord
            !byte 52, 3, $27
            !byte 54, 2, $3B
            !byte 55, 1, $47         ; Off-beat
            !byte 56, 1, $47         ; Final 3-note chord
            !byte 56, 2, $3B
            !byte 56, 3, $27
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
; new_high_score moved to zero page ($3E) for Unit 44 animation

; ----------------------------------------------------------------------------
; High Score Table (6 songs x 3 difficulties = 18 entries, 2 bytes each)
; Index = (song * 3) + difficulty
; Used for per-song high score tracking
; ----------------------------------------------------------------------------

high_scores:
            ; Song 1 (First Steps)
            !word 0               ; Easy high score
            !word 0               ; Normal high score
            !word 0               ; Hard high score
            ; Song 2 (Upbeat Groove)
            !word 0               ; Easy
            !word 0               ; Normal
            !word 0               ; Hard
            ; Song 3 (Speed Rush)
            !word 0               ; Easy
            !word 0               ; Normal
            !word 0               ; Hard
            ; Song 4 (Off-Beat)
            !word 0               ; Easy
            !word 0               ; Normal
            !word 0               ; Hard
            ; Song 5 (Chordstorm)
            !word 0               ; Easy
            !word 0               ; Normal
            !word 0               ; Hard
            ; Song 6 (Fusion)
            !word 0               ; Easy
            !word 0               ; Normal
            !word 0               ; Hard

; ----------------------------------------------------------------------------
; Global High Score Leaderboard (Unit 45)
; Top 5 scores across all songs/difficulties
; Each entry: 3 bytes name + 2 bytes score = 5 bytes
; Total: 5 entries x 5 bytes = 25 bytes
; ----------------------------------------------------------------------------

HS_ENTRY_SIZE = 5               ; 3 name + 2 score
HS_TABLE_SIZE = 5               ; Top 5 entries

hs_table:
            ; Entry 1: Default high score
            !byte 'S', 'I', 'D'   ; Name
            !word 5000            ; Score
            ; Entry 2
            !byte 'C', '6', '4'
            !word 4000
            ; Entry 3
            !byte 'A', 'S', 'M'
            !word 3000
            ; Entry 4
            !byte 'R', 'H', 'Y'
            !word 2000
            ; Entry 5
            !byte 'T', 'H', 'M'
            !word 1000

; ============================================================================
; END OF SID SYMPHONY - UNIT 46 (OPTIONS SCREEN)
; ============================================================================

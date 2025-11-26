;──────────────────────────────────────────────────────────────
; SID SYMPHONY
; A rhythm game for the Commodore 64
; Unit 6: Three Voices
;──────────────────────────────────────────────────────────────

            * = $0801

; BASIC stub: 10 SYS 2064
            !byte $0c, $08, $0a, $00, $9e
            !byte $32, $30, $36, $34
            !byte $00, $00, $00

;───────────────────────────────────────
; Constants
;───────────────────────────────────────
SCREEN      = $0400
COLOUR      = $d800

ROW_SCORE   = 1
ROW_TRACK1  = 8
ROW_TRACK2  = 12
ROW_TRACK3  = 16
ROW_CROWD   = 23

COL_WHITE   = $01
COL_RED     = $02
COL_CYAN    = $03
COL_GREEN   = $05
COL_YELLOW  = $07
COL_GREY    = $0b
COL_LBLUE   = $0e

HIT_ZONE_X  = 8

; Note constants
NOTE_SPEED      = 4
SPAWN_INTERVAL  = 70        ; Comfortable spawning interval
MAX_NOTES       = 6         ; 6 slots for 3 tracks (was 4)
NOTE_CHAR       = $a0
NOTE_COLOUR     = COL_WHITE
NOTE_INACTIVE   = $ff
NOTE_START_X    = 39
TRACK_CHAR      = $2d

; Track constants
NUM_TRACKS      = 3
TRACK_1         = 0
TRACK_2         = 1
TRACK_3         = 2

; Flash constants
FLASH_DURATION  = 4

; Scoring constants
POINTS_PER_HIT  = 10

; Crowd constants
CROWD_MAX       = 20
CROWD_START     = 10
CROWD_COL_START = 7

; Screen positions
SCORE_SCREEN_POS = SCREEN + (ROW_SCORE * 40) + 7
STREAK_SCREEN_POS = SCREEN + (ROW_SCORE * 40) + 32
CROWD_SCREEN_POS = SCREEN + (ROW_CROWD * 40) + CROWD_COL_START
CROWD_COLOUR_POS = COLOUR + (ROW_CROWD * 40) + CROWD_COL_START

; Game over text position
GAMEOVER_ROW    = 11
GAMEOVER_COL    = 14

; SID registers - Voice 1
SID         = $d400
SID_V1_FREQ_LO = SID + 0
SID_V1_FREQ_HI = SID + 1
SID_V1_PW_LO   = SID + 2
SID_V1_PW_HI   = SID + 3
SID_V1_CTRL    = SID + 4
SID_V1_AD      = SID + 5
SID_V1_SR      = SID + 6

; SID registers - Voice 2
SID_V2_FREQ_LO = SID + 7
SID_V2_FREQ_HI = SID + 8
SID_V2_PW_LO   = SID + 9
SID_V2_PW_HI   = SID + 10
SID_V2_CTRL    = SID + 11
SID_V2_AD      = SID + 12
SID_V2_SR      = SID + 13

; SID registers - Voice 3
SID_V3_FREQ_LO = SID + 14
SID_V3_FREQ_HI = SID + 15
SID_V3_PW_LO   = SID + 16
SID_V3_PW_HI   = SID + 17
SID_V3_CTRL    = SID + 18
SID_V3_AD      = SID + 19
SID_V3_SR      = SID + 20

SID_VOLUME  = SID + 24

; Pitches for C major chord (C, E, G)
PITCH_V1_LO = $17           ; C4 (~262 Hz)
PITCH_V1_HI = $11
PITCH_V2_LO = $8f           ; E4 (~330 Hz)
PITCH_V2_HI = $15
PITCH_V3_LO = $a1           ; G4 (~392 Hz)
PITCH_V3_HI = $19

CIA1_PRA    = $dc00
CIA1_PRB    = $dc01

RASTER      = $d012

;───────────────────────────────────────
; Entry point
;───────────────────────────────────────
            * = $0810

main:
            jsr setup_screen
            jsr init_sid
            jsr init_notes
            jsr init_score
            jsr init_crowd
            jmp main_loop

;───────────────────────────────────────
; Setup screen
;───────────────────────────────────────
setup_screen:
            lda #$00
            sta $d020
            sta $d021

            ldx #$00
clear_loop:
            lda #$20
            sta $0400,x
            sta $0500,x
            sta $0600,x
            sta $06e8,x
            lda #$00
            sta $d800,x
            sta $d900,x
            sta $da00,x
            sta $dae8,x
            inx
            bne clear_loop

            jsr draw_top_panel
            jsr draw_tracks
            jsr draw_bottom_panel
            rts

;───────────────────────────────────────
; Draw top panel
;───────────────────────────────────────
draw_top_panel:
            ldx #$00
top_loop:
            lda score_text,x
            beq top_done
            sta SCREEN + (ROW_SCORE * 40),x
            lda #COL_WHITE
            sta COLOUR + (ROW_SCORE * 40),x
            inx
            bne top_loop
top_done:
            rts

;───────────────────────────────────────
; Draw tracks - all three active now
;───────────────────────────────────────
draw_tracks:
            ; Track 1 (top) - now active
            ldx #$00
t1_loop:
            cpx #HIT_ZONE_X
            bcs t1_dim
            lda #$a0
            sta SCREEN + (ROW_TRACK1 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK1 * 40),x
            jmp t1_next
t1_dim:
            lda #TRACK_CHAR
            sta SCREEN + (ROW_TRACK1 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK1 * 40),x
t1_next:
            inx
            cpx #40
            bne t1_loop

            ; Track 2 (middle) - active
            ldx #$00
t2_loop:
            cpx #HIT_ZONE_X
            bcs t2_dim
            lda #$a0
            sta SCREEN + (ROW_TRACK2 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK2 * 40),x
            jmp t2_next
t2_dim:
            lda #TRACK_CHAR
            sta SCREEN + (ROW_TRACK2 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK2 * 40),x
t2_next:
            inx
            cpx #40
            bne t2_loop

            ; Track 3 (bottom) - now active
            ldx #$00
t3_loop:
            cpx #HIT_ZONE_X
            bcs t3_dim
            lda #$a0
            sta SCREEN + (ROW_TRACK3 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK3 * 40),x
            jmp t3_next
t3_dim:
            lda #TRACK_CHAR
            sta SCREEN + (ROW_TRACK3 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK3 * 40),x
t3_next:
            inx
            cpx #40
            bne t3_loop

            rts

;───────────────────────────────────────
; Draw bottom panel
;───────────────────────────────────────
draw_bottom_panel:
            ldx #$00
bottom_loop:
            lda crowd_text,x
            beq bottom_done
            sta SCREEN + (ROW_CROWD * 40),x
            lda #COL_GREEN
            sta COLOUR + (ROW_CROWD * 40),x
            inx
            bne bottom_loop
bottom_done:
            rts

;───────────────────────────────────────
; Init SID - all three voices
;───────────────────────────────────────
init_sid:
            lda #$0f
            sta SID_VOLUME

            ; Voice 1 - C note
            lda #$00
            sta SID_V1_AD
            lda #$f4
            sta SID_V1_SR
            lda #$00
            sta SID_V1_PW_LO
            lda #$08
            sta SID_V1_PW_HI
            lda #PITCH_V1_LO
            sta SID_V1_FREQ_LO
            lda #PITCH_V1_HI
            sta SID_V1_FREQ_HI

            ; Voice 2 - E note
            lda #$00
            sta SID_V2_AD
            lda #$f4
            sta SID_V2_SR
            lda #$00
            sta SID_V2_PW_LO
            lda #$08
            sta SID_V2_PW_HI
            lda #PITCH_V2_LO
            sta SID_V2_FREQ_LO
            lda #PITCH_V2_HI
            sta SID_V2_FREQ_HI

            ; Voice 3 - G note
            lda #$00
            sta SID_V3_AD
            lda #$f4
            sta SID_V3_SR
            lda #$00
            sta SID_V3_PW_LO
            lda #$08
            sta SID_V3_PW_HI
            lda #PITCH_V3_LO
            sta SID_V3_FREQ_LO
            lda #PITCH_V3_HI
            sta SID_V3_FREQ_HI

            rts

;───────────────────────────────────────
; Init notes - 6 slots now
;───────────────────────────────────────
init_notes:
            ldx #MAX_NOTES - 1
init_notes_loop:
            lda #NOTE_INACTIVE
            sta note_x,x
            lda #$00
            sta note_track,x
            dex
            bpl init_notes_loop

            lda #NOTE_SPEED
            sta move_timer
            lda #$01
            sta spawn_timer

            lda #$00
            sta hit_flash_t1
            sta hit_flash_t2
            sta hit_flash_t3
            sta miss_flash_t1
            sta miss_flash_t2
            sta miss_flash_t3

            sta key_x_was
            sta key_c_was
            sta key_v_was

            sta spawn_track

            rts

;───────────────────────────────────────
; Init score
;───────────────────────────────────────
init_score:
            lda #$00
            sta score_lo
            sta score_hi
            sta streak
            sta best_streak
            jsr update_display
            rts

;───────────────────────────────────────
; Init crowd
;───────────────────────────────────────
init_crowd:
            lda #CROWD_START
            sta crowd_meter
            lda #$01
            sta game_running
            jsr draw_crowd
            rts

;───────────────────────────────────────
; Main loop
;───────────────────────────────────────
main_loop:
            lda game_running
            bne ml_running
            jmp main_loop_frozen
ml_running:

wait_not_zero:
            lda RASTER
            beq wait_not_zero
wait_zero:
            lda RASTER
            bne wait_zero

            ; --- Check all three keys ---

            ; Key X (Track 1)
            jsr check_x_key
            ldx key_x_was
            sta key_x_was
            cpx #$00
            bne ml_x_not_down
            cmp #$01
            bne ml_x_not_down
            ; X just pressed
            lda #TRACK_1
            jsr check_hit_on_track
            lda #TRACK_1
            jsr play_voice
            lda #$01
            sta key_x_state
            jmp ml_x_done
ml_x_not_down:
            cmp #$00
            bne ml_x_done
            lda key_x_state
            beq ml_x_done
            lda #TRACK_1
            jsr stop_voice
            lda #$00
            sta key_x_state
ml_x_done:

            ; Key C (Track 2)
            jsr check_c_key
            ldx key_c_was
            sta key_c_was
            cpx #$00
            bne ml_c_not_down
            cmp #$01
            bne ml_c_not_down
            ; C just pressed
            lda #TRACK_2
            jsr check_hit_on_track
            lda #TRACK_2
            jsr play_voice
            lda #$01
            sta key_c_state
            jmp ml_c_done
ml_c_not_down:
            cmp #$00
            bne ml_c_done
            lda key_c_state
            beq ml_c_done
            lda #TRACK_2
            jsr stop_voice
            lda #$00
            sta key_c_state
ml_c_done:

            ; Key V (Track 3)
            jsr check_v_key
            ldx key_v_was
            sta key_v_was
            cpx #$00
            bne ml_v_not_down
            cmp #$01
            bne ml_v_not_down
            ; V just pressed
            lda #TRACK_3
            jsr check_hit_on_track
            lda #TRACK_3
            jsr play_voice
            lda #$01
            sta key_v_state
            jmp ml_v_done
ml_v_not_down:
            cmp #$00
            bne ml_v_done
            lda key_v_state
            beq ml_v_done
            lda #TRACK_3
            jsr stop_voice
            lda #$00
            sta key_v_state
ml_v_done:

            ; Check if game ended
            lda game_running
            bne ml_continue1
            jmp main_loop
ml_continue1:

            ; Handle note spawning
            dec spawn_timer
            bne no_spawn
            lda #SPAWN_INTERVAL
            sta spawn_timer
            jsr spawn_note

no_spawn:
            ; Handle note movement
            dec move_timer
            bne no_move
            lda #NOTE_SPEED
            sta move_timer
            jsr move_notes

no_move:
            lda game_running
            bne ml_continue2
            jmp main_loop
ml_continue2:

            ; Update flash effects for all tracks
            jsr update_flash

            ; Update displays
            jsr update_display
            jsr draw_crowd

            jmp main_loop

main_loop_frozen:
wait_frozen:
            lda RASTER
            bne wait_frozen
            jmp main_loop

;───────────────────────────────────────
; Check hit on specific track
; A = track (0, 1, or 2)
;───────────────────────────────────────
check_hit_on_track:
            sta check_track
            ldx #$00
chot_loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq chot_next

            lda note_track,x
            cmp check_track
            bne chot_next           ; Wrong track

            lda note_x,x
            cmp #HIT_ZONE_X
            bcs chot_next           ; Not in hit zone

            ; HIT!
            jsr erase_note
            lda #NOTE_INACTIVE
            sta note_x,x

            jsr add_score
            inc streak
            lda streak
            cmp best_streak
            bcc chot_skip_best
            sta best_streak
chot_skip_best:
            jsr update_crowd_hit

            ; Trigger hit flash for this track
            lda check_track
            cmp #TRACK_1
            bne chot_not_t1
            lda #FLASH_DURATION
            sta hit_flash_t1
            rts
chot_not_t1:
            cmp #TRACK_2
            bne chot_not_t2
            lda #FLASH_DURATION
            sta hit_flash_t2
            rts
chot_not_t2:
            lda #FLASH_DURATION
            sta hit_flash_t3
            rts

chot_next:
            inx
            cpx #MAX_NOTES
            bne chot_loop
            rts                     ; No hit (empty press)

check_track: !byte $00

;───────────────────────────────────────
; Play voice for track
; A = track (0, 1, or 2)
;───────────────────────────────────────
play_voice:
            cmp #TRACK_1
            bne pv_not_1
            lda #$41                ; Pulse + gate on
            sta SID_V1_CTRL
            rts
pv_not_1:
            cmp #TRACK_2
            bne pv_not_2
            lda #$41
            sta SID_V2_CTRL
            rts
pv_not_2:
            lda #$41
            sta SID_V3_CTRL
            rts

;───────────────────────────────────────
; Stop voice for track
; A = track (0, 1, or 2)
;───────────────────────────────────────
stop_voice:
            cmp #TRACK_1
            bne sv_not_1
            lda #$40                ; Gate off
            sta SID_V1_CTRL
            rts
sv_not_1:
            cmp #TRACK_2
            bne sv_not_2
            lda #$40
            sta SID_V2_CTRL
            rts
sv_not_2:
            lda #$40
            sta SID_V3_CTRL
            rts

;───────────────────────────────────────
; Add score
;───────────────────────────────────────
add_score:
            clc
            lda score_lo
            adc #POINTS_PER_HIT
            sta score_lo
            bcc as_done
            inc score_hi
as_done:
            rts

;───────────────────────────────────────
; Update crowd on hit
;───────────────────────────────────────
update_crowd_hit:
            lda crowd_meter
            cmp #CROWD_MAX
            bcs uch_done
            inc crowd_meter
uch_done:
            rts

;───────────────────────────────────────
; Update crowd on miss
;───────────────────────────────────────
update_crowd_miss:
            lda crowd_meter
            sec
            sbc #$02
            bcs ucm_store
            lda #$00
ucm_store:
            sta crowd_meter
            bne ucm_done
            jsr trigger_game_over
ucm_done:
            rts

;───────────────────────────────────────
; Trigger game over
;───────────────────────────────────────
trigger_game_over:
            lda #$00
            sta game_running

            ldx #$00
tgo_loop:
            lda gameover_text,x
            beq tgo_done
            sta SCREEN + (GAMEOVER_ROW * 40) + GAMEOVER_COL,x
            lda #COL_RED
            sta COLOUR + (GAMEOVER_ROW * 40) + GAMEOVER_COL,x
            inx
            bne tgo_loop
tgo_done:
            rts

;───────────────────────────────────────
; Update flash colours for all tracks
;───────────────────────────────────────
update_flash:
            ; Track 1
            lda hit_flash_t1
            beq uf_t1_no_hit
            dec hit_flash_t1
            lda #COL_GREEN
            jsr set_track1_zone_colour
            jmp uf_t1_done
uf_t1_no_hit:
            lda miss_flash_t1
            beq uf_t1_no_miss
            dec miss_flash_t1
            lda #COL_RED
            jsr set_track1_zone_colour
            jmp uf_t1_done
uf_t1_no_miss:
            lda #COL_CYAN
            jsr set_track1_zone_colour
uf_t1_done:

            ; Track 2
            lda hit_flash_t2
            beq uf_t2_no_hit
            dec hit_flash_t2
            lda #COL_GREEN
            jsr set_track2_zone_colour
            jmp uf_t2_done
uf_t2_no_hit:
            lda miss_flash_t2
            beq uf_t2_no_miss
            dec miss_flash_t2
            lda #COL_RED
            jsr set_track2_zone_colour
            jmp uf_t2_done
uf_t2_no_miss:
            lda #COL_CYAN
            jsr set_track2_zone_colour
uf_t2_done:

            ; Track 3
            lda hit_flash_t3
            beq uf_t3_no_hit
            dec hit_flash_t3
            lda #COL_GREEN
            jsr set_track3_zone_colour
            jmp uf_t3_done
uf_t3_no_hit:
            lda miss_flash_t3
            beq uf_t3_no_miss
            dec miss_flash_t3
            lda #COL_RED
            jsr set_track3_zone_colour
            jmp uf_t3_done
uf_t3_no_miss:
            lda #COL_CYAN
            jsr set_track3_zone_colour
uf_t3_done:
            rts

;───────────────────────────────────────
; Set track zone colours (A = colour)
;───────────────────────────────────────
set_track1_zone_colour:
            ldx #$00
st1_loop:
            sta COLOUR + (ROW_TRACK1 * 40),x
            inx
            cpx #HIT_ZONE_X
            bne st1_loop
            rts

set_track2_zone_colour:
            ldx #$00
st2_loop:
            sta COLOUR + (ROW_TRACK2 * 40),x
            inx
            cpx #HIT_ZONE_X
            bne st2_loop
            rts

set_track3_zone_colour:
            ldx #$00
st3_loop:
            sta COLOUR + (ROW_TRACK3 * 40),x
            inx
            cpx #HIT_ZONE_X
            bne st3_loop
            rts

;───────────────────────────────────────
; Draw crowd meter
;───────────────────────────────────────
draw_crowd:
            lda crowd_meter
            cmp #$05
            bcc dc_danger
            cmp #$0f
            bcc dc_normal
            lda #COL_GREEN
            jmp dc_set_colour
dc_normal:
            lda #COL_YELLOW
            jmp dc_set_colour
dc_danger:
            lda #COL_RED
dc_set_colour:
            sta crowd_colour

            ldx #$00
            ldy crowd_meter
dc_loop:
            cpx #CROWD_MAX
            bcs dc_done
            cpy #$00
            beq dc_empty
            lda #$a0
            dey
            jmp dc_draw
dc_empty:
            lda #$20
dc_draw:
            sta CROWD_SCREEN_POS,x
            lda crowd_colour
            sta CROWD_COLOUR_POS,x
            inx
            jmp dc_loop
dc_done:
            rts

;───────────────────────────────────────
; Spawn a new note on rotating track
;───────────────────────────────────────
spawn_note:
            ldx #$00
find_slot:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq found_slot
            inx
            cpx #MAX_NOTES
            bne find_slot
            rts                     ; No free slot

found_slot:
            lda #NOTE_START_X
            sta note_x,x

            ; Assign to current spawn track
            lda spawn_track
            sta note_track,x

            ; Rotate to next track
            inc spawn_track
            lda spawn_track
            cmp #NUM_TRACKS
            bcc sn_done
            lda #$00
            sta spawn_track

sn_done:
            jsr draw_note
            rts

;───────────────────────────────────────
; Move all active notes left
;───────────────────────────────────────
move_notes:
            ldx #$00
move_loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq move_next

            jsr erase_note
            dec note_x,x

            lda note_x,x
            cmp #NOTE_INACTIVE
            beq despawn_note

            jsr draw_note

move_next:
            inx
            cpx #MAX_NOTES
            bne move_loop
            rts

despawn_note:
            ; Save X (note index) before any subroutine calls
            stx despawn_idx

            ; Reset streak
            lda #$00
            sta streak

            ; Update crowd (may trigger game over, clobbers X)
            jsr update_crowd_miss

            ; Trigger miss flash for this track
            ldx despawn_idx
            lda note_track,x
            cmp #TRACK_1
            bne dn_not_t1
            lda #FLASH_DURATION
            sta miss_flash_t1
            jmp move_next
dn_not_t1:
            cmp #TRACK_2
            bne dn_not_t2
            lda #FLASH_DURATION
            sta miss_flash_t2
            jmp move_next
dn_not_t2:
            lda #FLASH_DURATION
            sta miss_flash_t3
            jmp move_next

;───────────────────────────────────────
; Draw note using track info
; X = note index
;───────────────────────────────────────
draw_note:
            stx temp_x

            lda note_x,x
            cmp #HIT_ZONE_X
            bcc draw_note_done

            ; Calculate screen position based on track
            lda note_track,x
            tay
            lda track_row_lo,y
            sta screen_ptr
            lda track_row_hi,y
            sta screen_ptr + 1

            ; Add X position
            lda temp_x
            tax
            lda note_x,x
            clc
            adc screen_ptr
            sta screen_ptr
            bcc dn_no_carry
            inc screen_ptr + 1
dn_no_carry:

            ldy #$00
            lda #NOTE_CHAR
            sta (screen_ptr),y

            ; Set colour
            lda note_track,x
            tay
            lda track_col_lo,y
            sta screen_ptr
            lda track_col_hi,y
            sta screen_ptr + 1

            lda temp_x
            tax
            lda note_x,x
            clc
            adc screen_ptr
            sta screen_ptr
            bcc dn_no_carry2
            inc screen_ptr + 1
dn_no_carry2:

            lda #NOTE_COLOUR
            sta (screen_ptr),y

draw_note_done:
            ldx temp_x
            rts

;───────────────────────────────────────
; Erase note using track info
; X = note index
;───────────────────────────────────────
erase_note:
            stx temp_x

            lda note_x,x
            cmp #HIT_ZONE_X
            bcc erase_note_done

            ; Calculate screen position based on track
            lda note_track,x
            tay
            lda track_row_lo,y
            sta screen_ptr
            lda track_row_hi,y
            sta screen_ptr + 1

            lda temp_x
            tax
            lda note_x,x
            clc
            adc screen_ptr
            sta screen_ptr
            bcc en_no_carry
            inc screen_ptr + 1
en_no_carry:

            ldy #$00
            lda #TRACK_CHAR
            sta (screen_ptr),y

            ; Set colour
            lda note_track,x
            tay
            lda track_col_lo,y
            sta screen_ptr
            lda track_col_hi,y
            sta screen_ptr + 1

            lda temp_x
            tax
            lda note_x,x
            clc
            adc screen_ptr
            sta screen_ptr
            bcc en_no_carry2
            inc screen_ptr + 1
en_no_carry2:

            lda #COL_CYAN
            sta (screen_ptr),y

erase_note_done:
            ldx temp_x
            rts

;───────────────────────────────────────
; Check keys
;───────────────────────────────────────
check_x_key:
            lda #%11111011          ; Row 2
            sta CIA1_PRA
            lda CIA1_PRB
            and #%10000000          ; Column 7 (X)
            bne cx_not
            lda #$01
            rts
cx_not:
            lda #$00
            rts

check_c_key:
            lda #%11111011          ; Row 2 (bit 2)
            sta CIA1_PRA
            lda CIA1_PRB
            and #%00010000          ; Column 4 (C)
            bne cc_not
            lda #$01
            rts
cc_not:
            lda #$00
            rts

check_v_key:
            lda #%11110111          ; Row 3 (bit 3)
            sta CIA1_PRA
            lda CIA1_PRB
            and #%10000000          ; Column 7 (V)
            bne cv_not
            lda #$01
            rts
cv_not:
            lda #$00
            rts

;───────────────────────────────────────
; Update display
;───────────────────────────────────────
update_display:
            jsr convert_score
            jsr draw_score
            jsr convert_streak
            jsr draw_streak
            rts

;───────────────────────────────────────
; Convert score to decimal
;───────────────────────────────────────
convert_score:
            ; Initialize all digits to 0
            lda #$00
            sta score_digits
            sta score_digits + 1
            sta score_digits + 2
            sta score_digits + 3
            sta score_digits + 4
            sta score_digits + 5

            lda score_lo
            sta work_lo
            lda score_hi
            sta work_hi

            ; 10000s digit (position 1)
cs_d0:
            ; Compare work >= 10000 ($2710)
            lda work_hi
            cmp #$27
            bcc cs_d0_done
            bne cs_d0_sub
            lda work_lo
            cmp #$10
            bcc cs_d0_done
cs_d0_sub:
            ; Subtract 10000
            lda work_lo
            sec
            sbc #$10
            sta work_lo
            lda work_hi
            sbc #$27
            sta work_hi
            inc score_digits + 1
            jmp cs_d0
cs_d0_done:

            ; 1000s digit (position 2)
cs_d1:
            ; Compare work >= 1000 ($03E8)
            lda work_hi
            cmp #$03
            bcc cs_d1_done
            bne cs_d1_sub
            lda work_lo
            cmp #$E8
            bcc cs_d1_done
cs_d1_sub:
            ; Subtract 1000
            lda work_lo
            sec
            sbc #$E8
            sta work_lo
            lda work_hi
            sbc #$03
            sta work_hi
            inc score_digits + 2
            jmp cs_d1
cs_d1_done:

            ; Now work_hi should be 0, work_lo < 1000
            ; 100s digit (position 3)
cs_d2:
            lda work_lo
            cmp #100
            bcc cs_d2_done
            sec
            sbc #100
            sta work_lo
            inc score_digits + 3
            jmp cs_d2
cs_d2_done:

            ; 10s digit (position 4)
cs_d3:
            lda work_lo
            cmp #10
            bcc cs_d3_done
            sec
            sbc #10
            sta work_lo
            inc score_digits + 4
            jmp cs_d3
cs_d3_done:

            ; 1s digit (position 5)
            lda work_lo
            sta score_digits + 5

            rts

;───────────────────────────────────────
; Convert streak to decimal
;───────────────────────────────────────
convert_streak:
            lda streak
            ldx #$00
cst_10:
            cmp #10
            bcc cst_10_done
            sec
            sbc #10
            inx
            jmp cst_10
cst_10_done:
            stx streak_digits
            sta streak_digits + 1
            rts

;───────────────────────────────────────
; Draw score/streak
;───────────────────────────────────────
draw_score:
            ldx #$00
ds_loop:
            lda score_digits,x
            clc
            adc #$30
            sta SCORE_SCREEN_POS,x
            inx
            cpx #$06
            bne ds_loop
            rts

draw_streak:
            lda streak_digits
            clc
            adc #$30
            sta STREAK_SCREEN_POS
            lda streak_digits + 1
            clc
            adc #$30
            sta STREAK_SCREEN_POS + 1
            rts

;───────────────────────────────────────
; Variables
;───────────────────────────────────────
key_x_was:      !byte $00
key_c_was:      !byte $00
key_v_was:      !byte $00

key_x_state:    !byte $00
key_c_state:    !byte $00
key_v_state:    !byte $00

move_timer:     !byte NOTE_SPEED
spawn_timer:    !byte SPAWN_INTERVAL
spawn_track:    !byte $00

hit_flash_t1:   !byte $00
hit_flash_t2:   !byte $00
hit_flash_t3:   !byte $00
miss_flash_t1:  !byte $00
miss_flash_t2:  !byte $00
miss_flash_t3:  !byte $00

temp_x:         !byte $00
despawn_idx:    !byte $00

score_lo:       !byte $00
score_hi:       !byte $00
streak:         !byte $00
best_streak:    !byte $00

crowd_meter:    !byte CROWD_START
crowd_colour:   !byte COL_GREEN
game_running:   !byte $01

work_lo:        !byte $00
work_hi:        !byte $00

score_digits:   !byte 0, 0, 0, 0, 0, 0
streak_digits:  !byte 0, 0

screen_ptr      = $fb

; Note data - 6 slots
note_x:
            !byte NOTE_INACTIVE, NOTE_INACTIVE, NOTE_INACTIVE
            !byte NOTE_INACTIVE, NOTE_INACTIVE, NOTE_INACTIVE
note_track:
            !byte 0, 0, 0, 0, 0, 0

; Track row addresses (screen)
track_row_lo:
            !byte <(SCREEN + ROW_TRACK1 * 40)
            !byte <(SCREEN + ROW_TRACK2 * 40)
            !byte <(SCREEN + ROW_TRACK3 * 40)
track_row_hi:
            !byte >(SCREEN + ROW_TRACK1 * 40)
            !byte >(SCREEN + ROW_TRACK2 * 40)
            !byte >(SCREEN + ROW_TRACK3 * 40)

; Track colour addresses
track_col_lo:
            !byte <(COLOUR + ROW_TRACK1 * 40)
            !byte <(COLOUR + ROW_TRACK2 * 40)
            !byte <(COLOUR + ROW_TRACK3 * 40)
track_col_hi:
            !byte >(COLOUR + ROW_TRACK1 * 40)
            !byte >(COLOUR + ROW_TRACK2 * 40)
            !byte >(COLOUR + ROW_TRACK3 * 40)

;───────────────────────────────────────
; Data
;───────────────────────────────────────
score_text:
            !scr "score: 000000          streak: 00"
            !byte 0

crowd_text:
            !scr "crowd [                    ]    "
            !byte 0

gameover_text:
            !scr "game over"
            !byte 0

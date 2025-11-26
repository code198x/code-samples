;──────────────────────────────────────────────────────────────
; SID SYMPHONY
; A rhythm game for the Commodore 64
; Unit 5: The Crowd
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

HIT_ZONE_X  = 8

; Note constants
NOTE_SPEED      = 4
SPAWN_INTERVAL  = 90
MAX_NOTES       = 4
NOTE_CHAR       = $a0
NOTE_COLOUR     = COL_WHITE
NOTE_INACTIVE   = $ff
NOTE_START_X    = 39
TRACK_CHAR      = $2d

; Flash constants
FLASH_DURATION  = 4

; Scoring constants
POINTS_PER_HIT  = 10

; Crowd constants
CROWD_MAX       = 20
CROWD_START     = 10
CROWD_COL_START = 7         ; Column where crowd meter starts (after "CROWD [")

; Screen positions
SCORE_SCREEN_POS = SCREEN + (ROW_SCORE * 40) + 7
STREAK_SCREEN_POS = SCREEN + (ROW_SCORE * 40) + 32
CROWD_SCREEN_POS = SCREEN + (ROW_CROWD * 40) + CROWD_COL_START
CROWD_COLOUR_POS = COLOUR + (ROW_CROWD * 40) + CROWD_COL_START

; Game over text position (centre of screen)
GAMEOVER_ROW    = 11
GAMEOVER_COL    = 14

SID         = $d400
SID_FREQ_LO = SID + 0
SID_FREQ_HI = SID + 1
SID_PW_LO   = SID + 2
SID_PW_HI   = SID + 3
SID_CTRL    = SID + 4
SID_AD      = SID + 5
SID_SR      = SID + 6
SID_VOLUME  = SID + 24

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
; Draw tracks
;───────────────────────────────────────
draw_tracks:
            ; Track 1 (dimmed)
            ldx #$00
t1_loop:
            cpx #HIT_ZONE_X
            bcs t1_dim
            lda #$a0
            sta SCREEN + (ROW_TRACK1 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK1 * 40),x
            jmp t1_next
t1_dim:
            lda #TRACK_CHAR
            sta SCREEN + (ROW_TRACK1 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK1 * 40),x
t1_next:
            inx
            cpx #40
            bne t1_loop

            ; Track 2 (active)
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

            ; Track 3 (dimmed)
            ldx #$00
t3_loop:
            cpx #HIT_ZONE_X
            bcs t3_dim
            lda #$a0
            sta SCREEN + (ROW_TRACK3 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK3 * 40),x
            jmp t3_next
t3_dim:
            lda #TRACK_CHAR
            sta SCREEN + (ROW_TRACK3 * 40),x
            lda #COL_GREY
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
; Init SID
;───────────────────────────────────────
init_sid:
            lda #$0f
            sta SID_VOLUME
            lda #$00
            sta SID_AD
            lda #$f4
            sta SID_SR
            lda #$00
            sta SID_PW_LO
            lda #$08
            sta SID_PW_HI
            lda #$12
            sta SID_FREQ_LO
            lda #$22
            sta SID_FREQ_HI
            rts

;───────────────────────────────────────
; Init notes
;───────────────────────────────────────
init_notes:
            ldx #MAX_NOTES - 1
init_notes_loop:
            lda #NOTE_INACTIVE
            sta note_x,x
            dex
            bpl init_notes_loop

            lda #NOTE_SPEED
            sta move_timer
            lda #$01
            sta spawn_timer

            lda #$00
            sta hit_flash
            sta miss_flash
            sta key_was_pressed

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
; Play/stop note
;───────────────────────────────────────
play_note:
            lda #$41
            sta SID_CTRL
            rts

stop_note:
            lda #$40
            sta SID_CTRL
            rts

;───────────────────────────────────────
; Main loop
;───────────────────────────────────────
main_loop:
            ; Check if game is still running
            lda game_running
            beq main_loop_frozen    ; Game over - just wait

            ; Wait for new frame
wait_not_zero:
            lda RASTER
            beq wait_not_zero
wait_zero:
            lda RASTER
            bne wait_zero

            ; --- Frame update ---

            ; Check for key-down transition
            jsr check_x_key
            ldx key_was_pressed
            sta key_was_pressed

            cpx #$00
            bne ml_not_key_down
            cmp #$01
            bne ml_not_key_down

            ; Key just went down
            jsr check_hit
            jsr play_note
            lda #$01
            sta key_state
            jmp ml_after_input

ml_not_key_down:
            cmp #$00
            bne ml_after_input
            lda key_state
            cmp #$01
            bne ml_after_input
            jsr stop_note
            lda #$00
            sta key_state

ml_after_input:
            ; Check if game ended from a hit (shouldn't happen but safe)
            lda game_running
            beq main_loop

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
            ; Check if game ended from a miss
            lda game_running
            beq main_loop

            ; Update flash effects
            jsr update_flash

            ; Update displays
            jsr update_display
            jsr draw_crowd

            jmp main_loop

; Frozen loop - game over state
main_loop_frozen:
            ; Just wait for raster to prevent CPU spin
wait_frozen:
            lda RASTER
            bne wait_frozen
            jmp main_loop

;───────────────────────────────────────
; Check for hit
;───────────────────────────────────────
check_hit:
            ldx #$00
check_hit_loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq check_hit_next

            cmp #HIT_ZONE_X
            bcs check_hit_next

            ; HIT!
            jsr erase_note
            lda #NOTE_INACTIVE
            sta note_x,x

            ; Award points
            jsr add_score

            ; Increment streak
            inc streak
            lda streak
            cmp best_streak
            bcc ch_skip_best
            sta best_streak
ch_skip_best:

            ; Update crowd (hit)
            jsr update_crowd_hit

            ; Trigger green flash
            lda #FLASH_DURATION
            sta hit_flash
            rts

check_hit_next:
            inx
            cpx #MAX_NOTES
            bne check_hit_loop
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
; Update crowd on hit (+1, capped at max)
;───────────────────────────────────────
update_crowd_hit:
            lda crowd_meter
            cmp #CROWD_MAX
            bcs uch_done            ; Already at max
            inc crowd_meter
uch_done:
            rts

;───────────────────────────────────────
; Update crowd on miss (-2, game over at 0)
;───────────────────────────────────────
update_crowd_miss:
            lda crowd_meter
            sec
            sbc #$02                ; Subtract 2
            bcs ucm_store           ; No underflow
            lda #$00                ; Floor at 0
ucm_store:
            sta crowd_meter
            bne ucm_done            ; Not zero, continue

            ; Game over!
            jsr trigger_game_over
ucm_done:
            rts

;───────────────────────────────────────
; Trigger game over
;───────────────────────────────────────
trigger_game_over:
            lda #$00
            sta game_running

            ; Draw "GAME OVER" text
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
; Update flash colours
;───────────────────────────────────────
update_flash:
            lda hit_flash
            beq uf_no_hit_flash
            dec hit_flash
            jsr flash_zone_green
            rts

uf_no_hit_flash:
            lda miss_flash
            beq uf_no_miss_flash
            dec miss_flash
            jsr flash_zone_red
            rts

uf_no_miss_flash:
            jsr restore_zone_colour
            rts

;───────────────────────────────────────
; Flash hit zone green
;───────────────────────────────────────
flash_zone_green:
            ldx #$00
fzg_loop:
            lda #COL_GREEN
            sta COLOUR + (ROW_TRACK2 * 40),x
            inx
            cpx #HIT_ZONE_X
            bne fzg_loop
            rts

;───────────────────────────────────────
; Flash hit zone red
;───────────────────────────────────────
flash_zone_red:
            ldx #$00
fzr_loop:
            lda #COL_RED
            sta COLOUR + (ROW_TRACK2 * 40),x
            inx
            cpx #HIT_ZONE_X
            bne fzr_loop
            rts

;───────────────────────────────────────
; Restore hit zone colour
;───────────────────────────────────────
restore_zone_colour:
            ldx #$00
rzc_loop:
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK2 * 40),x
            inx
            cpx #HIT_ZONE_X
            bne rzc_loop
            rts

;───────────────────────────────────────
; Draw crowd meter with colour feedback
;───────────────────────────────────────
draw_crowd:
            ; Determine colour based on crowd level
            lda crowd_meter
            cmp #$05                ; Below 5?
            bcc dc_danger
            cmp #$0f                ; Below 15?
            bcc dc_normal
            ; 15 or above - happy (green)
            lda #COL_GREEN
            jmp dc_set_colour
dc_normal:
            ; 5-14 - normal (yellow)
            lda #COL_YELLOW
            jmp dc_set_colour
dc_danger:
            ; Below 5 - danger (red)
            lda #COL_RED
dc_set_colour:
            sta crowd_colour

            ; Draw the meter
            ldx #$00
            ldy crowd_meter
dc_loop:
            cpx #CROWD_MAX
            bcs dc_done

            ; Draw filled or empty
            cpy #$00
            beq dc_empty
            lda #$a0                ; Solid block
            dey
            jmp dc_draw
dc_empty:
            lda #$20                ; Space
dc_draw:
            sta CROWD_SCREEN_POS,x
            lda crowd_colour
            sta CROWD_COLOUR_POS,x
            inx
            jmp dc_loop
dc_done:
            rts

;───────────────────────────────────────
; Spawn a new note
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
            rts

found_slot:
            lda #NOTE_START_X
            sta note_x,x
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
            ; Note missed! Reset streak
            lda #$00
            sta streak

            ; Update crowd (miss) - may trigger game over
            jsr update_crowd_miss

            ; Trigger red flash
            lda #FLASH_DURATION
            sta miss_flash
            jmp move_next

;───────────────────────────────────────
; Draw note
;───────────────────────────────────────
draw_note:
            stx temp_x

            lda note_x,x
            cmp #HIT_ZONE_X
            bcc draw_note_done

            clc
            adc #<(SCREEN + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(SCREEN + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ldy #$00
            lda #NOTE_CHAR
            sta (screen_ptr),y

            lda temp_x
            tax
            lda note_x,x
            clc
            adc #<(COLOUR + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(COLOUR + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            lda #NOTE_COLOUR
            sta (screen_ptr),y

draw_note_done:
            ldx temp_x
            rts

;───────────────────────────────────────
; Erase note
;───────────────────────────────────────
erase_note:
            stx temp_x

            lda note_x,x
            cmp #HIT_ZONE_X
            bcc erase_note_done

            clc
            adc #<(SCREEN + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(SCREEN + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ldy #$00
            lda #TRACK_CHAR
            sta (screen_ptr),y

            lda temp_x
            tax
            lda note_x,x
            clc
            adc #<(COLOUR + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(COLOUR + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            lda #COL_CYAN
            sta (screen_ptr),y

erase_note_done:
            ldx temp_x
            rts

;───────────────────────────────────────
; Check X key
;───────────────────────────────────────
check_x_key:
            lda #%11111011
            sta CIA1_PRA
            lda CIA1_PRB
            and #%10000000
            bne x_not_pressed
            lda #$01
            rts
x_not_pressed:
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
; Convert 16-bit score to decimal digits
; Fixed 16-bit comparison: check high byte first
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
            ; 10000 = $2710
cs_d0:
            lda work_hi
            cmp #$27
            bcc cs_d0_done          ; high < $27, definitely < 10000
            bne cs_d0_sub           ; high > $27, definitely >= 10000
            ; high == $27, check low byte
            lda work_lo
            cmp #$10
            bcc cs_d0_done
cs_d0_sub:
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
            ; 1000 = $03E8
cs_d1:
            lda work_hi
            cmp #$03
            bcc cs_d1_done          ; high < $03, definitely < 1000
            bne cs_d1_sub           ; high > $03, definitely >= 1000
            ; high == $03, check low byte
            lda work_lo
            cmp #$e8
            bcc cs_d1_done
cs_d1_sub:
            lda work_lo
            sec
            sbc #$e8
            sta work_lo
            lda work_hi
            sbc #$03
            sta work_hi
            inc score_digits + 2
            jmp cs_d1
cs_d1_done:

            ; 100s digit (position 3)
            ; 100 = $64, single byte
cs_d2:
            lda work_lo
            cmp #$64
            bcc cs_d2_done
            sec
            sbc #$64
            sta work_lo
            inc score_digits + 3
            jmp cs_d2
cs_d2_done:

            ; 10s digit (position 4)
cs_d3:
            lda work_lo
            cmp #$0a
            bcc cs_d3_done
            sec
            sbc #$0a
            sta work_lo
            inc score_digits + 4
            jmp cs_d3
cs_d3_done:

            ; 1s digit (position 5)
            lda work_lo
            sta score_digits + 5

            rts

;───────────────────────────────────────
; Convert streak to decimal digits
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
; Draw score digits
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

;───────────────────────────────────────
; Draw streak digits
;───────────────────────────────────────
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
key_state:
            !byte $00

key_was_pressed:
            !byte $00

move_timer:
            !byte NOTE_SPEED

spawn_timer:
            !byte SPAWN_INTERVAL

hit_flash:
            !byte $00

miss_flash:
            !byte $00

temp_x:
            !byte $00

; Score variables
score_lo:
            !byte $00
score_hi:
            !byte $00
streak:
            !byte $00
best_streak:
            !byte $00

; Crowd variables
crowd_meter:
            !byte CROWD_START
crowd_colour:
            !byte COL_GREEN
game_running:
            !byte $01

; Working variables
work_lo:
            !byte $00
work_hi:
            !byte $00

; Digit buffers
score_digits:
            !byte 0, 0, 0, 0, 0, 0
streak_digits:
            !byte 0, 0

; Zero page pointer
screen_ptr  = $fb

; Note positions
note_x:
            !byte NOTE_INACTIVE, NOTE_INACTIVE, NOTE_INACTIVE, NOTE_INACTIVE

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

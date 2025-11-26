;──────────────────────────────────────────────────────────────
; SID SYMPHONY
; A rhythm game for the Commodore 64
; Unit 4: Keeping Score
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
NOTE_SPEED      = 4         ; Frames between movements
SPAWN_INTERVAL  = 90        ; Frames between spawns
MAX_NOTES       = 4         ; Maximum simultaneous notes
NOTE_CHAR       = $a0       ; Solid block
NOTE_COLOUR     = COL_WHITE ; White notes
NOTE_INACTIVE   = $ff       ; Marker for empty slot
NOTE_START_X    = 39        ; Spawn column (right edge)
TRACK_CHAR      = $2d       ; Dash character for track

; Flash constants
FLASH_DURATION  = 4         ; Frames to show flash colour

; Scoring constants
POINTS_PER_HIT  = 10        ; Points awarded per hit

; Screen positions for score display
SCORE_SCREEN_POS = SCREEN + (ROW_SCORE * 40) + 7   ; After "SCORE: "
STREAK_SCREEN_POS = SCREEN + (ROW_SCORE * 40) + 32 ; After "STREAK: "

SID         = $d400
SID_FREQ_LO = SID + 0
SID_FREQ_HI = SID + 1
SID_PW_LO   = SID + 2
SID_PW_HI   = SID + 3
SID_CTRL    = SID + 4
SID_AD      = SID + 5
SID_SR      = SID + 6
SID_VOLUME  = SID + 24

; CIA for keyboard reading
CIA1_PRA    = $dc00
CIA1_PRB    = $dc01

; VIC-II for raster sync
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
; Init notes - mark all slots inactive
;───────────────────────────────────────
init_notes:
            ldx #MAX_NOTES - 1
init_notes_loop:
            lda #NOTE_INACTIVE
            sta note_x,x
            dex
            bpl init_notes_loop

            ; Reset timers
            lda #NOTE_SPEED
            sta move_timer
            lda #$01            ; Spawn first note quickly
            sta spawn_timer

            ; Reset flash timers
            lda #$00
            sta hit_flash
            sta miss_flash

            ; Reset key transition tracker
            lda #$00
            sta key_was_pressed

            rts

;───────────────────────────────────────
; Init score - reset all scoring variables
;───────────────────────────────────────
init_score:
            lda #$00
            sta score_lo
            sta score_hi
            sta streak
            sta best_streak
            ; Draw initial display
            jsr update_display
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
            ; Wait for raster line 255->0 transition (new frame)
wait_not_zero:
            lda RASTER
            beq wait_not_zero
wait_zero:
            lda RASTER
            bne wait_zero

            ; --- Frame update starts here ---

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
            ; Handle key release for SID gate
            cmp #$00
            bne ml_after_input
            lda key_state
            cmp #$01
            bne ml_after_input
            jsr stop_note
            lda #$00
            sta key_state

ml_after_input:
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
            ; Update flash effects
            jsr update_flash

            ; Update score display
            jsr update_display

            jmp main_loop

;───────────────────────────────────────
; Check for hit - is any note in hit zone?
;───────────────────────────────────────
check_hit:
            ldx #$00
check_hit_loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq check_hit_next

            cmp #HIT_ZONE_X
            bcs check_hit_next

            ; Found a note in hit zone - HIT!
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
; Add score - add POINTS_PER_HIT to score
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
            ; Trigger red flash
            lda #FLASH_DURATION
            sta miss_flash
            jmp move_next

;───────────────────────────────────────
; Draw note at position note_x,x on Track 2
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
; Erase note - restore track character
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
; Check if X key is currently held
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
; Update display - convert and draw score/streak
;───────────────────────────────────────
update_display:
            jsr convert_score
            jsr draw_score
            jsr convert_streak
            jsr draw_streak
            rts

;───────────────────────────────────────
; Convert 16-bit score to 6 decimal digits
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

            ; Copy score to working area
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
; Convert 8-bit streak to 2 decimal digits
;───────────────────────────────────────
convert_streak:
            lda streak

            ; 10s digit
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

            ; 1s digit (remainder in A)
            sta streak_digits + 1

            rts

;───────────────────────────────────────
; Draw score digits to screen
;───────────────────────────────────────
draw_score:
            ; Score display is 6 digits, but we show 5 significant + leading 0
            ; Position: SCORE_SCREEN_POS
            ldx #$00
ds_loop:
            lda score_digits,x
            clc
            adc #$30            ; Convert to screen code for '0'-'9'
            sta SCORE_SCREEN_POS,x
            inx
            cpx #$06
            bne ds_loop
            rts

;───────────────────────────────────────
; Draw streak digits to screen
;───────────────────────────────────────
draw_streak:
            ; Streak display is 2 digits
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

; Working variables for conversion
work_lo:
            !byte $00
work_hi:
            !byte $00

; Digit buffers
score_digits:
            !byte 0, 0, 0, 0, 0, 0      ; 6 digits for score
streak_digits:
            !byte 0, 0                   ; 2 digits for streak

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
            !scr "crowd [          ]              "
            !byte 0

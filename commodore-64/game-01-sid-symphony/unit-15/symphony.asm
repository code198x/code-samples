; ============================================================================
; SID Symphony - Unit 15: Song Completion
; ============================================================================
; Adding song completion detection and results screen:
; - Track when all notes have been processed
; - Show "SONG COMPLETE" message when finished
; - Display final score and performance rating
; - Allow replay or quit from results screen
; ============================================================================

* = $0801
                !byte $0c, $08, $0a, $00, $9e
                !text "2064"
                !byte $00, $00, $00

* = $0810

; ----------------------------------------------------------------------------
; Hardware registers
; ----------------------------------------------------------------------------
SCREEN          = $0400
COLOUR          = $d800
BORDER_COLOUR   = $d020
BACKGROUND      = $d021
RASTER          = $d012
CHAR_ROM        = $d000
CHAR_RAM        = $3000
VIC_MEMSETUP    = $d018
KEYBOARD_COLUMN = $dc00
KEYBOARD_ROW    = $dc01

; SID registers
SID             = $d400
SID_V1_FREQ_LO  = $d400
SID_V1_FREQ_HI  = $d401
SID_V1_PW_LO    = $d402
SID_V1_PW_HI    = $d403
SID_V1_CTRL     = $d404
SID_V1_AD       = $d405
SID_V1_SR       = $d406
SID_V2_FREQ_LO  = $d407
SID_V2_FREQ_HI  = $d408
SID_V2_PW_LO    = $d409
SID_V2_PW_HI    = $d40a
SID_V2_CTRL     = $d40b
SID_V2_AD       = $d40c
SID_V2_SR       = $d40d
SID_V3_FREQ_LO  = $d40e
SID_V3_FREQ_HI  = $d40f
SID_V3_PW_LO    = $d410
SID_V3_PW_HI    = $d411
SID_V3_CTRL     = $d412
SID_V3_AD       = $d413
SID_V3_SR       = $d414
SID_FILTER_LO   = $d415
SID_FILTER_HI   = $d416
SID_FILT_CTRL   = $d417
SID_VOLUME      = $d418

SCREEN_WIDTH    = 40

; Track positions (rows)
TRACK1_ROW      = 9
TRACK2_ROW      = 13
TRACK3_ROW      = 17

; Layout
KEY_COL         = 1
HIT_START       = 3
HIT_END         = 7
TRACK_START     = 7
SPAWN_COLUMN    = 39

; Characters
NOTE_CHAR       = 128
TRACK_CHAR      = 129
HITZONE_CHAR    = 130
KEY_BRACKET_L   = $1b
KEY_BRACKET_R   = $1d

; Colours
COL_BLACK       = 0
COL_WHITE       = 1
COL_RED         = 2
COL_CYAN        = 3
COL_GREEN       = 5
COL_YELLOW      = 7
COL_GREY        = 11
COL_DARK_GREY   = 12

; Timing
FRAMES_PER_BEAT = 12
MOVE_DELAY      = 3

; Health
HEALTH_MAX      = 64
HEALTH_START    = 64            ; Start at full health for easier testing
HEALTH_HIT      = 2             ; Gain per hit
HEALTH_MISS     = 2             ; Reduced loss per miss

; Health bar characters
HEALTH_FULL     = 131           ; Full bar segment
HEALTH_EMPTY    = 132           ; Empty bar segment

; Notes
MAX_NOTES       = 8
NOTE_INACTIVE   = 0
NOTE_ACTIVE     = 1

; Song data
END_MARKER      = $ff

; Key bits (active low - 0 = pressed)
KEY_X_COL       = %11111011     ; Column 2
KEY_X_ROW       = %10000000     ; Row 7 (bit 7)
KEY_C_COL       = %11111011     ; Column 2
KEY_C_ROW       = %00010000     ; Row 4 (bit 4)
KEY_V_COL       = %11110111     ; Column 3
KEY_V_ROW       = %10000000     ; Row 7 (bit 7)

; Zero page
screen_ptr      = $fb
colour_ptr      = $fd

; ============================================================================
; Program entry
; ============================================================================
start:
                jsr init

main_loop:
                jsr wait_raster
                jsr update_counters
                jsr check_spawn_notes
                jsr update_notes
                jsr draw_notes
                jsr scan_keyboard       ; Read keyboard
                jsr handle_input        ; Process key presses
                jsr update_display
                jsr check_song_complete ; Check if song finished
                jsr check_game_over     ; Check for game over
                jsr check_quit
                jmp main_loop

; ============================================================================
; Initialisation
; ============================================================================
init:
                jsr setup_charset
                jsr clear_screen
                jsr draw_header
                jsr draw_tracks
                jsr draw_footer

                lda #0
                sta frame_counter
                sta beat_counter
                sta song_position
                sta move_counter
                sta key_x_state
                sta key_c_state
                sta key_v_state
                sta key_x_pressed
                sta key_c_pressed
                sta key_v_pressed

                ldx #0
-               sta note_active,x
                inx
                cpx #MAX_NOTES
                bne -

                ; Initialize SID
                jsr init_sid

                ; Initialize score
                lda #0
                sta score
                sta score+1
                sta score+2

                ; Initialize health
                lda #HEALTH_START
                sta health
                lda #0
                sta game_over
                sta song_complete

                rts

; ----------------------------------------------------------------------------
; Initialize SID chip
; ----------------------------------------------------------------------------
init_sid:
                ; Clear all SID registers
                lda #0
                ldx #24
-               sta SID,x
                dex
                bpl -

                ; Set volume to max
                lda #$0f
                sta SID_VOLUME

                ; Configure voice 1 (track 1 - cyan)
                lda #$08                ; Pulse width
                sta SID_V1_PW_HI
                lda #$09                ; Attack=0, Decay=9
                sta SID_V1_AD
                lda #$00                ; Sustain=0, Release=0
                sta SID_V1_SR

                ; Configure voice 2 (track 2 - green)
                lda #$08
                sta SID_V2_PW_HI
                lda #$09
                sta SID_V2_AD
                lda #$00
                sta SID_V2_SR

                ; Configure voice 3 (track 3 - yellow)
                lda #$08
                sta SID_V3_PW_HI
                lda #$09
                sta SID_V3_AD
                lda #$00
                sta SID_V3_SR

                rts

; ----------------------------------------------------------------------------
; Scan keyboard - read X, C, V keys
; Sets key_X_pressed to 1 if newly pressed this frame
; ----------------------------------------------------------------------------
scan_keyboard:
                ; Clear pressed flags
                lda #0
                sta key_x_pressed
                sta key_c_pressed
                sta key_v_pressed

                ; --- Check X key (Column 2, Row 7) ---
                lda #KEY_X_COL
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #KEY_X_ROW
                bne .x_not_pressed

                ; X is pressed - check if NEW
                lda key_x_state
                bne .x_done             ; Already held
                lda #1
                sta key_x_pressed       ; New press!
                sta key_x_state
                inc key_x_count
                jmp .x_done

.x_not_pressed:
                lda #0
                sta key_x_state

.x_done:
                ; --- Check C key (Column 2, Row 4) ---
                lda #KEY_C_COL
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #KEY_C_ROW
                bne .c_not_pressed

                lda key_c_state
                bne .c_done
                lda #1
                sta key_c_pressed
                sta key_c_state
                inc key_c_count
                jmp .c_done

.c_not_pressed:
                lda #0
                sta key_c_state

.c_done:
                ; --- Check V key (Column 3, Row 7) ---
                lda #KEY_V_COL
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #KEY_V_ROW
                bne .v_not_pressed

                lda key_v_state
                bne .v_done
                lda #1
                sta key_v_pressed
                sta key_v_state
                inc key_v_count
                rts

.v_not_pressed:
                lda #0
                sta key_v_state

.v_done:
                rts

; ----------------------------------------------------------------------------
; Handle input - check for hits when key pressed
; ----------------------------------------------------------------------------
handle_input:
                ; Check X key (track 1)
                lda key_x_pressed
                beq .no_x
                lda #1
                sta miss_track          ; Store track for potential miss
                jsr check_hit
                bcc .miss_x             ; No hit - explicit miss
                lda #10                 ; Flash for 10 frames on hit
                sta flash_t1_timer
                jmp .no_x
.miss_x:
                jsr handle_explicit_miss

.no_x:
                ; Check C key (track 2)
                lda key_c_pressed
                beq .no_c
                lda #2
                sta miss_track
                jsr check_hit
                bcc .miss_c
                lda #10
                sta flash_t2_timer
                jmp .no_c
.miss_c:
                jsr handle_explicit_miss

.no_c:
                ; Check V key (track 3)
                lda key_v_pressed
                beq .no_v
                lda #3
                sta miss_track
                jsr check_hit
                bcc .miss_v
                lda #10
                sta flash_t3_timer
                jmp .no_v
.miss_v:
                jsr handle_explicit_miss

.no_v:
                rts

; ----------------------------------------------------------------------------
; Check for hit - find note in hit zone on given track
; Input: A = track number (1, 2, or 3)
; Output: Carry set if hit, clear if miss
; ----------------------------------------------------------------------------
check_hit:
                sta hit_track

                ; Search all active notes for one on this track in hit zone
                ldx #0
.search:
                lda note_active,x
                beq .next               ; Skip inactive notes

                ; Check if on correct track
                lda note_track,x
                cmp hit_track
                bne .next               ; Wrong track

                ; Check if in hit zone (columns HIT_START to HIT_END-1)
                lda note_x,x
                cmp #HIT_START
                bcc .next               ; Too far left
                cmp #HIT_END
                bcs .next               ; Too far right

                ; HIT! Play the note and remove it
                stx hit_note_idx
                jsr play_hit_note
                jsr add_score

                ; Deactivate the note
                ldx hit_note_idx
                lda #0
                sta note_active,x

                sec                     ; Set carry = hit
                rts

.next:
                inx
                cpx #MAX_NOTES
                bne .search

                clc                     ; Clear carry = miss
                rts

; ----------------------------------------------------------------------------
; Play hit note on SID
; X = note index
; ----------------------------------------------------------------------------
play_hit_note:
                ldx hit_note_idx
                lda note_value,x        ; Get note frequency index
                asl                     ; *2 for table lookup
                tax

                lda hit_track
                cmp #1
                bne .not_v1

                ; Voice 1
                lda freq_table,x
                sta SID_V1_FREQ_LO
                lda freq_table+1,x
                sta SID_V1_FREQ_HI
                lda #$41                ; Pulse wave, gate on
                sta SID_V1_CTRL
                rts

.not_v1:
                cmp #2
                bne .not_v2

                ; Voice 2
                lda freq_table,x
                sta SID_V2_FREQ_LO
                lda freq_table+1,x
                sta SID_V2_FREQ_HI
                lda #$41
                sta SID_V2_CTRL
                rts

.not_v2:
                ; Voice 3
                lda freq_table,x
                sta SID_V3_FREQ_LO
                lda freq_table+1,x
                sta SID_V3_FREQ_HI
                lda #$41
                sta SID_V3_CTRL
                rts

; ----------------------------------------------------------------------------
; Add score for a hit
; ----------------------------------------------------------------------------
add_score:
                ; Add 100 points (BCD)
                sed                     ; Decimal mode
                clc
                lda score
                adc #0
                sta score
                lda score+1
                adc #1                  ; +100
                sta score+1
                lda score+2
                adc #0
                sta score+2
                cld                     ; Binary mode

                ; Increase health (clamped to max)
                lda health
                clc
                adc #HEALTH_HIT
                cmp #HEALTH_MAX
                bcc +
                lda #HEALTH_MAX
+               sta health
                rts

; ----------------------------------------------------------------------------
; Handle miss - note left hit zone or wrong key pressed
; X = note index (for implicit miss from update_notes)
; ----------------------------------------------------------------------------
handle_miss:
                ; Increment miss counter
                inc miss_count

                ; Decrease health (clamped to 0)
                lda health
                sec
                sbc #HEALTH_MISS
                bcs +
                lda #0                  ; Clamp to 0
+               sta health
                beq .set_game_over      ; Health depleted?
                jmp .do_miss_flash

.set_game_over:
                lda #1
                sta game_over

.do_miss_flash:
                ; Get the track from the note
                lda note_track,x
                sta miss_track

                ; Set flash timer for miss (red)
                cmp #1
                bne .not_t1
                lda #10
                sta miss_t1_timer
                jmp .play_miss
.not_t1:
                cmp #2
                bne .not_t2
                lda #10
                sta miss_t2_timer
                jmp .play_miss
.not_t2:
                lda #10
                sta miss_t3_timer

.play_miss:
                ; Play miss sound (noise burst)
                lda #$80                ; Noise waveform
                sta SID_V3_CTRL
                lda #$20
                sta SID_V3_FREQ_HI
                lda #$00
                sta SID_V3_FREQ_LO
                lda #$0a                ; Quick attack/decay
                sta SID_V3_AD
                lda #$00
                sta SID_V3_SR
                lda #$81                ; Gate on
                sta SID_V3_CTRL
                rts

; Handle explicit miss (key pressed with no note)
handle_explicit_miss:
                inc miss_count

                ; Decrease health (same as implicit miss)
                lda health
                sec
                sbc #HEALTH_MISS
                bcs +
                lda #0                  ; Clamp to 0
+               sta health
                beq .exp_set_game_over
                jmp .exp_flash

.exp_set_game_over:
                lda #1
                sta game_over

.exp_flash:
                ; Set flash timer based on track
                lda miss_track
                cmp #1
                bne .exp_not_t1
                lda #10
                sta miss_t1_timer
                jmp .exp_sound
.exp_not_t1:
                cmp #2
                bne .exp_not_t2
                lda #10
                sta miss_t2_timer
                jmp .exp_sound
.exp_not_t2:
                lda #10
                sta miss_t3_timer

.exp_sound:
                ; Play miss sound
                lda #$80
                sta SID_V3_CTRL
                lda #$10
                sta SID_V3_FREQ_HI
                lda #$81
                sta SID_V3_CTRL
                rts

; ----------------------------------------------------------------------------
; Update counters
; ----------------------------------------------------------------------------
update_counters:
                inc frame_counter

                lda frame_counter
                cmp #FRAMES_PER_BEAT
                bne +

                lda #0
                sta frame_counter
                inc beat_counter

                lda beat_counter
                cmp #100
                bcc +
                lda #0
                sta beat_counter

+               rts

; ----------------------------------------------------------------------------
; Check spawn notes
; ----------------------------------------------------------------------------
check_spawn_notes:
                lda frame_counter
                bne .no_spawn

                ldx song_position
                lda song_beats,x
                cmp #END_MARKER
                beq .no_spawn

                cmp beat_counter
                bne .no_spawn

                lda song_tracks,x
                sta spawn_track
                lda song_notes,x
                sta spawn_note_val

                inc song_position
                jsr spawn_note

.no_spawn:      rts

; ----------------------------------------------------------------------------
; Spawn note
; ----------------------------------------------------------------------------
spawn_note:
                ldx #0
.find_slot:
                lda note_active,x
                beq .found_slot
                inx
                cpx #MAX_NOTES
                bne .find_slot
                rts

.found_slot:
                lda #NOTE_ACTIVE
                sta note_active,x
                lda #SPAWN_COLUMN
                sta note_x,x
                lda spawn_track
                sta note_track,x
                lda spawn_note_val
                sta note_value,x
                rts

; ----------------------------------------------------------------------------
; Update notes
; ----------------------------------------------------------------------------
update_notes:
                inc move_counter
                lda move_counter
                cmp #MOVE_DELAY
                bcc .no_move
                lda #0
                sta move_counter

                ldx #0

.update_loop:
                lda note_active,x
                beq .next_note

                stx temp_note_idx
                jsr erase_note

                ldx temp_note_idx
                dec note_x,x

                lda note_x,x
                cmp #HIT_START
                bcs .next_note

                ; Note left hit zone - it's a MISS!
                jsr handle_miss

                lda #NOTE_INACTIVE
                sta note_active,x

.next_note:
                inx
                cpx #MAX_NOTES
                bne .update_loop

.no_move:
                rts

; ----------------------------------------------------------------------------
; Erase note
; ----------------------------------------------------------------------------
erase_note:
                lda note_track,x
                cmp #1
                bne .e_not_t1
                lda #TRACK1_ROW
                jmp .e_got_row
.e_not_t1:
                cmp #2
                bne .e_not_t2
                lda #TRACK2_ROW
                jmp .e_got_row
.e_not_t2:
                lda #TRACK3_ROW

.e_got_row:
                stx temp_note_idx
                jsr calc_row_addr

                ldx temp_note_idx
                ldy note_x,x

                cpy #HIT_END
                bcc .e_in_hitzone

                lda #TRACK_CHAR
                sta (screen_ptr),y
                lda #COL_DARK_GREY
                sta (colour_ptr),y
                rts

.e_in_hitzone:
                lda #HITZONE_CHAR
                sta (screen_ptr),y

                ldx temp_note_idx
                lda note_track,x
                cmp #1
                bne .e_not_cyan
                lda #COL_CYAN
                jmp .e_set_col
.e_not_cyan:
                cmp #2
                bne .e_not_green
                lda #COL_GREEN
                jmp .e_set_col
.e_not_green:
                lda #COL_YELLOW
.e_set_col:
                sta (colour_ptr),y
                rts

; ----------------------------------------------------------------------------
; Draw notes
; ----------------------------------------------------------------------------
draw_notes:
                ldx #0

.d_loop:
                lda note_active,x
                beq .d_next

                lda note_track,x
                cmp #1
                bne .d_not_t1
                lda #TRACK1_ROW
                jmp .d_got_row
.d_not_t1:
                cmp #2
                bne .d_not_t2
                lda #TRACK2_ROW
                jmp .d_got_row
.d_not_t2:
                lda #TRACK3_ROW

.d_got_row:
                stx temp_note_idx
                jsr calc_row_addr

                ldx temp_note_idx
                ldy note_x,x

                lda #NOTE_CHAR
                sta (screen_ptr),y

                lda note_track,x
                cmp #1
                bne .d_not_cy
                lda #COL_CYAN
                jmp .d_set_col
.d_not_cy:
                cmp #2
                bne .d_not_gr
                lda #COL_GREEN
                jmp .d_set_col
.d_not_gr:
                lda #COL_YELLOW

.d_set_col:
                sta (colour_ptr),y

.d_next:
                inx
                cpx #MAX_NOTES
                bne .d_loop

                rts

; ----------------------------------------------------------------------------
; Update display
; ----------------------------------------------------------------------------
update_display:
                ; Update score display (BCD to screen)
                lda score+2             ; High byte (digits 5-6)
                jsr display_bcd_byte
                sta SCREEN + 6*40 + 10
                stx SCREEN + 6*40 + 9
                lda score+1             ; Mid byte (digits 3-4)
                jsr display_bcd_byte
                sta SCREEN + 6*40 + 12
                stx SCREEN + 6*40 + 11
                lda score               ; Low byte (digits 1-2)
                jsr display_bcd_byte
                sta SCREEN + 6*40 + 14
                stx SCREEN + 6*40 + 13

                lda beat_counter
                jsr display_two_digits
                sta SCREEN + 6*40 + 20
                stx SCREEN + 6*40 + 19

                lda song_position
                jsr display_two_digits
                sta SCREEN + 6*40 + 35
                stx SCREEN + 6*40 + 34

                ; Restore hit zone colours (after flash)
                jsr restore_hitzones

                ; Update health bar display
                jsr draw_health_bar

                rts

; Convert BCD byte to two screen code digits
; Input: A = BCD byte
; Output: X = high digit, A = low digit
display_bcd_byte:
                pha
                lsr
                lsr
                lsr
                lsr
                ora #$30                ; High nibble to screen code
                tax
                pla
                and #$0f
                ora #$30                ; Low nibble to screen code
                rts

; Restore hit zone colours (or keep flashing if timer active)
; Priority: hit flash (white) > miss flash (red) > normal colour
restore_hitzones:
                ; Track 1
                lda flash_t1_timer      ; Hit flash?
                beq .t1_check_miss
                dec flash_t1_timer
                lda #TRACK1_ROW
                ldy #COL_WHITE
                jsr set_hitzone_colour
                jmp .check_t2
.t1_check_miss:
                lda miss_t1_timer       ; Miss flash?
                beq .t1_normal
                dec miss_t1_timer
                lda #TRACK1_ROW
                ldy #COL_RED
                jsr set_hitzone_colour
                jmp .check_t2
.t1_normal:
                lda #TRACK1_ROW
                ldy #COL_CYAN
                jsr set_hitzone_colour

.check_t2:
                ; Track 2
                lda flash_t2_timer
                beq .t2_check_miss
                dec flash_t2_timer
                lda #TRACK2_ROW
                ldy #COL_WHITE
                jsr set_hitzone_colour
                jmp .check_t3
.t2_check_miss:
                lda miss_t2_timer
                beq .t2_normal
                dec miss_t2_timer
                lda #TRACK2_ROW
                ldy #COL_RED
                jsr set_hitzone_colour
                jmp .check_t3
.t2_normal:
                lda #TRACK2_ROW
                ldy #COL_GREEN
                jsr set_hitzone_colour

.check_t3:
                ; Track 3
                lda flash_t3_timer
                beq .t3_check_miss
                dec flash_t3_timer
                lda #TRACK3_ROW
                ldy #COL_WHITE
                jsr set_hitzone_colour
                rts
.t3_check_miss:
                lda miss_t3_timer
                beq .t3_normal
                dec miss_t3_timer
                lda #TRACK3_ROW
                ldy #COL_RED
                jsr set_hitzone_colour
                rts
.t3_normal:
                lda #TRACK3_ROW
                ldy #COL_YELLOW
                jsr set_hitzone_colour
                rts

set_hitzone_colour:
                sty flash_colour
                jsr calc_row_addr
                ldy #HIT_START
.shc_loop:
                lda flash_colour
                sta (colour_ptr),y
                iny
                cpy #HIT_END
                bne .shc_loop
                rts

; ----------------------------------------------------------------------------
; Draw health bar (8 segments, each = 8 health points)
; Health 0-64 displayed as bar on row 21
; ----------------------------------------------------------------------------
draw_health_bar:
                ; Health bar position: row 21, columns 20-27
                lda health
                lsr                     ; /2
                lsr                     ; /4
                lsr                     ; /8 = segments filled (0-8)
                sta health_segments

                ldx #0                  ; Segment counter
.hbar_loop:
                cpx health_segments
                bcs .draw_empty         ; If X >= segments, draw empty

                ; Draw full segment (green)
                lda #HEALTH_FULL
                sta SCREEN + 21*40 + 20,x
                lda #COL_GREEN
                sta COLOUR + 21*40 + 20,x
                jmp .hbar_next

.draw_empty:
                ; Draw empty segment (dark grey)
                lda #HEALTH_EMPTY
                sta SCREEN + 21*40 + 20,x
                lda #COL_DARK_GREY
                sta COLOUR + 21*40 + 20,x

.hbar_next:
                inx
                cpx #8
                bne .hbar_loop
                rts

health_segments: !byte 0

display_two_digits:
                ldx #0
-               cmp #10
                bcc .convert
                sbc #10
                inx
                jmp -
.convert:
                ora #$30
                pha
                txa
                ora #$30
                tax
                pla
                rts

; ----------------------------------------------------------------------------
; Wait for raster
; ----------------------------------------------------------------------------
wait_raster:
-               lda RASTER
                cmp #250
                beq -
-               lda RASTER
                cmp #250
                bne -
                rts

; ----------------------------------------------------------------------------
; Check for Q key
; ----------------------------------------------------------------------------
check_quit:
                lda #%01111111
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #%01000000
                bne +

                lda #$14
                sta VIC_MEMSETUP
                lda #14
                sta BORDER_COLOUR
                lda #6
                sta BACKGROUND
                lda #147
                jsr $ffd2
                jmp $a474
+               rts

; ----------------------------------------------------------------------------
; Check for game over condition
; ----------------------------------------------------------------------------
check_game_over:
                lda game_over
                beq .not_over

                ; Display GAME OVER message
                ldx #0
-               lda gameover_text,x
                beq +
                sta SCREEN + 12*40 + 15,x
                lda #COL_RED
                sta COLOUR + 12*40 + 15,x
                inx
                bne -

+               ; Flash border red
                lda #COL_RED
                sta BORDER_COLOUR

                ; Wait for space to restart or Q to quit
.wait_key:
                jsr wait_raster

                ; Check Space (row 7, col 7)
                lda #%01111111
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #%00010000          ; Space
                beq .restart

                ; Check Q
                lda KEYBOARD_ROW
                and #%01000000          ; Q
                beq .do_quit

                jmp .wait_key

.restart:
                ; Reset game
                lda #COL_BLACK
                sta BORDER_COLOUR
                jmp start               ; Full restart

.do_quit:
                lda #$14
                sta VIC_MEMSETUP
                lda #14
                sta BORDER_COLOUR
                lda #6
                sta BACKGROUND
                lda #147
                jsr $ffd2
                jmp $a474

.not_over:
                rts

gameover_text:  !scr "game over!"
                !byte 0

; ----------------------------------------------------------------------------
; Check for song completion
; ----------------------------------------------------------------------------
check_song_complete:
                ; Already complete?
                lda song_complete
                bne .already_done

                ; Check if song has reached end
                ldx song_position
                lda song_beats,x
                cmp #END_MARKER
                bne .not_done           ; Song still has notes to spawn

                ; Check if any notes still active
                ldx #0
.check_notes:
                lda note_active,x
                bne .not_done           ; Still notes on screen
                inx
                cpx #MAX_NOTES
                bne .check_notes

                ; Song complete!
                lda #1
                sta song_complete
                jsr show_results

.already_done:
.not_done:
                rts

; ----------------------------------------------------------------------------
; Show results screen
; ----------------------------------------------------------------------------
show_results:
                ; Display SONG COMPLETE message
                ldx #0
-               lda complete_text,x
                beq +
                sta SCREEN + 10*40 + 13,x
                lda #COL_GREEN
                sta COLOUR + 10*40 + 13,x
                inx
                bne -

+               ; Display final score label
                ldx #0
-               lda final_text,x
                beq +
                sta SCREEN + 12*40 + 12,x
                lda #COL_WHITE
                sta COLOUR + 12*40 + 12,x
                inx
                bne -

+               ; Display final score value (copy from header)
                ldx #0
-               lda SCREEN + 6*40 + 9,x
                sta SCREEN + 12*40 + 25,x
                lda #COL_YELLOW
                sta COLOUR + 12*40 + 25,x
                inx
                cpx #6
                bne -

                ; Calculate rating based on score
                ; Score 0000-0500 = POOR
                ; Score 0501-1000 = GOOD
                ; Score 1001-1500 = GREAT
                ; Score 1501+     = PERFECT

                ; Check score+1 (hundreds digit)
                lda score+1
                cmp #$15                ; >= 1500?
                bcs .perfect
                cmp #$10                ; >= 1000?
                bcs .great
                cmp #$05                ; >= 500?
                bcs .good

                ; POOR rating
                ldx #0
-               lda rating_poor,x
                beq .show_prompt
                sta SCREEN + 14*40 + 16,x
                lda #COL_RED
                sta COLOUR + 14*40 + 16,x
                inx
                bne -
                jmp .show_prompt

.good:
                ldx #0
-               lda rating_good,x
                beq .show_prompt
                sta SCREEN + 14*40 + 16,x
                lda #COL_YELLOW
                sta COLOUR + 14*40 + 16,x
                inx
                bne -
                jmp .show_prompt

.great:
                ldx #0
-               lda rating_great,x
                beq .show_prompt
                sta SCREEN + 14*40 + 16,x
                lda #COL_GREEN
                sta COLOUR + 14*40 + 16,x
                inx
                bne -
                jmp .show_prompt

.perfect:
                ldx #0
-               lda rating_perfect,x
                beq .show_prompt
                sta SCREEN + 14*40 + 15,x
                lda #COL_CYAN
                sta COLOUR + 14*40 + 15,x
                inx
                bne -

.show_prompt:
                ; Display prompt
                ldx #0
-               lda prompt_text,x
                beq +
                sta SCREEN + 18*40 + 8,x
                lda #COL_GREY
                sta COLOUR + 18*40 + 8,x
                inx
                bne -

+               ; Flash border green
                lda #COL_GREEN
                sta BORDER_COLOUR

                ; Wait for space to restart or Q to quit
.wait_input:
                jsr wait_raster

                ; Check Space
                lda #%01111111
                sta KEYBOARD_COLUMN
                lda KEYBOARD_ROW
                and #%00010000
                beq .do_restart

                ; Check Q
                lda KEYBOARD_ROW
                and #%01000000
                beq .do_exit

                jmp .wait_input

.do_restart:
                lda #COL_BLACK
                sta BORDER_COLOUR
                jmp start

.do_exit:
                lda #$14
                sta VIC_MEMSETUP
                lda #14
                sta BORDER_COLOUR
                lda #6
                sta BACKGROUND
                lda #147
                jsr $ffd2
                jmp $a474

complete_text:  !scr "song complete!"
                !byte 0
final_text:     !scr "final score:"
                !byte 0
rating_poor:    !scr "poor"
                !byte 0
rating_good:    !scr "good"
                !byte 0
rating_great:   !scr "great"
                !byte 0
rating_perfect: !scr "perfect!"
                !byte 0
prompt_text:    !scr "space=replay  q=quit"
                !byte 0

; ============================================================================
; Song data
; ============================================================================
song_beats:
                !byte 0, 2, 4, 6, 8, 10, 12, 14
                !byte 16, 18, 20, 22, 24, 26, 28, 30
                !byte END_MARKER

song_tracks:
                !byte 1, 2, 3, 2, 1, 3, 2, 1
                !byte 3, 1, 2, 3, 1, 2, 3, 1

song_notes:
                !byte $11, $13, $15, $16, $18, $1b, $1d, $22
                !byte $22, $1d, $1b, $18, $16, $15, $13, $11

; ----------------------------------------------------------------------------
; Frequency table (low byte, high byte pairs)
; Index corresponds to note number
; ----------------------------------------------------------------------------
freq_table:
                ; Notes 0-15 (low octave)
                !word $0112, $0123, $0134, $0146  ; C1, C#1, D1, D#1
                !word $0159, $016d, $0182, $0198  ; E1, F1, F#1, G1
                !word $01af, $01c7, $01e1, $01fc  ; G#1, A1, A#1, B1
                !word $0218, $0236, $0256, $0278  ; C2, C#2, D2, D#2

                ; Notes 16-31 (mid octave) - used by our song
                !word $029c, $02c1, $02e9, $0313  ; E2, F2, F#2, G2
                !word $0340, $036f, $03a1, $03d6  ; G#2, A2, A#2, B2
                !word $040e, $0449, $0488, $04cb  ; C3, C#3, D3, D#3
                !word $0511, $055c, $05ab, $05fe  ; E3, F3, F#3, G3

                ; Notes 32-47 (high octave)
                !word $0657, $06b5, $0718, $0781  ; G#3, A3, A#3, B3
                !word $07f1, $0867, $08e4, $0969  ; C4, C#4, D4, D#4
                !word $09f5, $0a8a, $0b28, $0bd0  ; E4, F4, F#4, G4
                !word $0c82, $0d3e, $0e06, $0eda  ; G#4, A4, A#4, B4

; ============================================================================
; Character set setup
; ============================================================================
setup_charset:
                sei
                lda $01
                pha
                and #%11111011
                sta $01

                ldx #0
-               lda CHAR_ROM,x
                sta CHAR_RAM,x
                lda CHAR_ROM+$100,x
                sta CHAR_RAM+$100,x
                lda CHAR_ROM+$200,x
                sta CHAR_RAM+$200,x
                lda CHAR_ROM+$300,x
                sta CHAR_RAM+$300,x
                lda CHAR_ROM+$400,x
                sta CHAR_RAM+$400,x
                lda CHAR_ROM+$500,x
                sta CHAR_RAM+$500,x
                lda CHAR_ROM+$600,x
                sta CHAR_RAM+$600,x
                lda CHAR_ROM+$700,x
                sta CHAR_RAM+$700,x
                inx
                bne -

                pla
                sta $01
                cli

                ldx #0
-               lda note_char_data,x
                sta CHAR_RAM + (NOTE_CHAR * 8),x
                inx
                cpx #8
                bne -

                ldx #0
-               lda track_char_data,x
                sta CHAR_RAM + (TRACK_CHAR * 8),x
                inx
                cpx #8
                bne -

                ldx #0
-               lda hitzone_char_data,x
                sta CHAR_RAM + (HITZONE_CHAR * 8),x
                inx
                cpx #8
                bne -

                ldx #0
-               lda health_full_data,x
                sta CHAR_RAM + (HEALTH_FULL * 8),x
                inx
                cpx #8
                bne -

                ldx #0
-               lda health_empty_data,x
                sta CHAR_RAM + (HEALTH_EMPTY * 8),x
                inx
                cpx #8
                bne -

                lda #$1c
                sta VIC_MEMSETUP
                rts

note_char_data:
                !byte %00111100, %01111110, %11111111, %11111111
                !byte %11111111, %11111111, %01111110, %00111100

track_char_data:
                !byte %00000000, %00000000, %00000000, %11111111
                !byte %11111111, %00000000, %00000000, %00000000

hitzone_char_data:
                !byte %11111111, %11111111, %11111111, %11111111
                !byte %11111111, %11111111, %11111111, %11111111

health_full_data:
                !byte %11111111, %11111111, %11111111, %11111111
                !byte %11111111, %11111111, %11111111, %11111111

health_empty_data:
                !byte %11111111, %10000001, %10000001, %10000001
                !byte %10000001, %10000001, %10000001, %11111111

; ============================================================================
; Screen drawing
; ============================================================================
clear_screen:
                lda #COL_BLACK
                sta BORDER_COLOUR
                sta BACKGROUND

                ldx #0
-               lda #$20
                sta SCREEN,x
                sta SCREEN+$100,x
                sta SCREEN+$200,x
                sta SCREEN+$2e8,x
                lda #COL_BLACK
                sta COLOUR,x
                sta COLOUR+$100,x
                sta COLOUR+$200,x
                sta COLOUR+$2e8,x
                inx
                bne -
                rts

draw_header:
                ldx #0
-               lda #TRACK_CHAR
                sta SCREEN,x
                lda #COL_DARK_GREY
                sta COLOUR,x
                inx
                cpx #40
                bne -

                ldx #0
-               lda title_text,x
                beq +
                sta SCREEN + 2*40 + 13,x
                lda #COL_CYAN
                sta COLOUR + 2*40 + 13,x
                inx
                bne -

+               ldx #0
-               lda subtitle_text,x
                beq +
                sta SCREEN + 4*40 + 12,x
                lda #COL_GREY
                sta COLOUR + 4*40 + 12,x
                inx
                bne -

+               ldx #0
-               lda score_text,x
                beq +
                sta SCREEN + 6*40 + 2,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 2,x
                inx
                bne -

+               ldx #0
-               lda #$30
                sta SCREEN + 6*40 + 9,x
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 9,x
                inx
                cpx #6
                bne -

                ldx #0
-               lda beat_text,x
                beq +
                sta SCREEN + 6*40 + 17,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 17,x
                inx
                bne -

+               lda #$30
                sta SCREEN + 6*40 + 19
                sta SCREEN + 6*40 + 20
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 19
                sta COLOUR + 6*40 + 20

                ldx #0
-               lda pos_text,x
                beq +
                sta SCREEN + 6*40 + 29,x
                lda #COL_WHITE
                sta COLOUR + 6*40 + 29,x
                inx
                bne -

+               lda #$30
                sta SCREEN + 6*40 + 34
                sta SCREEN + 6*40 + 35
                lda #COL_YELLOW
                sta COLOUR + 6*40 + 34
                sta COLOUR + 6*40 + 35
                rts

title_text:     !scr "sid symphony"
                !byte 0
subtitle_text:  !scr "x=t1 c=t2 v=t3 q=quit"
                !byte 0
score_text:     !scr "score:"
                !byte 0
beat_text:      !scr "b:"
                !byte 0
pos_text:       !scr "pos:"
                !byte 0

draw_tracks:
                lda #TRACK1_ROW
                ldx #$18
                ldy #COL_CYAN
                jsr draw_single_track

                lda #TRACK2_ROW
                ldx #$03
                ldy #COL_GREEN
                jsr draw_single_track

                lda #TRACK3_ROW
                ldx #$16
                ldy #COL_YELLOW
                jsr draw_single_track
                rts

draw_single_track:
                sta temp_row
                stx temp_key
                sty temp_colour

                lda temp_row
                jsr calc_row_addr

                ldy #KEY_COL
                lda #KEY_BRACKET_L
                sta (screen_ptr),y
                lda #COL_WHITE
                sta (colour_ptr),y

                iny
                lda temp_key
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y

                iny
                lda #KEY_BRACKET_R
                sta (screen_ptr),y
                lda #COL_WHITE
                sta (colour_ptr),y

                ldy #HIT_START
-               lda #HITZONE_CHAR
                sta (screen_ptr),y
                lda temp_colour
                sta (colour_ptr),y
                iny
                cpy #HIT_END
                bne -

                ldy #TRACK_START
-               lda #TRACK_CHAR
                sta (screen_ptr),y
                lda #COL_DARK_GREY
                sta (colour_ptr),y
                iny
                cpy #SCREEN_WIDTH
                bne -
                rts

calc_row_addr:
                sta temp_row
                sta temp_lo
                lda #0
                sta temp_hi

                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi

                lda temp_lo
                sta save_lo
                lda temp_hi
                sta save_hi

                asl temp_lo
                rol temp_hi
                asl temp_lo
                rol temp_hi

                clc
                lda save_lo
                adc temp_lo
                sta temp_lo
                lda save_hi
                adc temp_hi
                sta temp_hi

                clc
                lda temp_lo
                adc #<SCREEN
                sta screen_ptr
                lda temp_hi
                adc #>SCREEN
                sta screen_ptr+1

                clc
                lda temp_lo
                adc #<COLOUR
                sta colour_ptr
                lda temp_hi
                adc #>COLOUR
                sta colour_ptr+1
                rts

draw_footer:
                ldx #0
-               lda #TRACK_CHAR
                sta SCREEN + 22*40,x
                lda #COL_DARK_GREY
                sta COLOUR + 22*40,x
                inx
                cpx #40
                bne -

                ; Draw health label
                ldx #0
-               lda health_text,x
                beq +
                sta SCREEN + 21*40 + 12,x
                lda #COL_WHITE
                sta COLOUR + 21*40 + 12,x
                inx
                bne -

+               ldx #0
-               lda footer_text,x
                beq +
                sta SCREEN + 24*40 + 6,x
                lda #COL_GREY
                sta COLOUR + 24*40 + 6,x
                inx
                bne -
+               rts

health_text:    !scr "health:"
                !byte 0

footer_text:    !scr "hit notes as they reach ["
                !byte HITZONE_CHAR
                !scr "]"
                !byte 0

; ============================================================================
; Variables
; ============================================================================
temp_row:       !byte 0
temp_key:       !byte 0
temp_colour:    !byte 0
temp_lo:        !byte 0
temp_hi:        !byte 0
save_lo:        !byte 0
save_hi:        !byte 0

frame_counter:  !byte 0
beat_counter:   !byte 0
song_position:  !byte 0
move_counter:   !byte 0

spawn_track:    !byte 0
spawn_note_val: !byte 0
temp_note_idx:  !byte 0
flash_colour:   !byte 0

; Flash timers (frames remaining) - hits (white)
flash_t1_timer: !byte 0
flash_t2_timer: !byte 0
flash_t3_timer: !byte 0

; Miss timers (frames remaining) - misses (red)
miss_t1_timer:  !byte 0
miss_t2_timer:  !byte 0
miss_t3_timer:  !byte 0

; Miss tracking
miss_count:     !byte 0
miss_track:     !byte 0

; Keyboard state
key_x_state:    !byte 0         ; 1 if X was held last frame
key_c_state:    !byte 0         ; 1 if C was held last frame
key_v_state:    !byte 0         ; 1 if V was held last frame
key_x_pressed:  !byte 0         ; 1 if X newly pressed THIS frame
key_c_pressed:  !byte 0         ; 1 if C newly pressed THIS frame
key_v_pressed:  !byte 0         ; 1 if V newly pressed THIS frame

; Key press counters
key_x_count:    !byte 0
key_c_count:    !byte 0
key_v_count:    !byte 0

note_active:    !byte 0, 0, 0, 0, 0, 0, 0, 0
note_x:         !byte 0, 0, 0, 0, 0, 0, 0, 0
note_track:     !byte 0, 0, 0, 0, 0, 0, 0, 0
note_value:     !byte 0, 0, 0, 0, 0, 0, 0, 0

; Hit detection
hit_track:      !byte 0
hit_note_idx:   !byte 0

; Score (BCD, 6 digits)
score:          !byte 0, 0, 0           ; Low, mid, high bytes

; Health system
health:         !byte 0                 ; Current health (0-64)
game_over:      !byte 0                 ; 1 = game over
song_complete:  !byte 0                 ; 1 = song finished successfully

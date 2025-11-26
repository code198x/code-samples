;──────────────────────────────────────────────────────────────
; SID SYMPHONY
; A rhythm game for the Commodore 64
; Unit 3: Hit or Miss
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
            ; First wait for NOT line 0 (in case we're already there)
wait_not_zero:
            lda RASTER
            beq wait_not_zero
            ; Now wait for line 0
wait_zero:
            lda RASTER
            bne wait_zero

            ; --- Frame update starts here ---

            ; Check for key-down transition
            jsr check_x_key         ; A = 1 if pressed now
            ldx key_was_pressed     ; X = was it pressed last frame?
            sta key_was_pressed     ; Update for next frame

            ; Check transition: was=0, now=1 means key just went down
            cpx #$00
            bne ml_not_key_down     ; Was already pressed
            cmp #$01
            bne ml_not_key_down     ; Not pressed now either

            ; Key just went down - check for hit then play note
            jsr check_hit
            jsr play_note
            lda #$01
            sta key_state           ; Track for gate off
            jmp ml_after_input

ml_not_key_down:
            ; Check if key was released (for SID gate off)
            cmp #$00
            bne ml_after_input      ; Still pressed, do nothing
            lda key_state
            cmp #$01
            bne ml_after_input      ; Wasn't playing
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

            jmp main_loop

;───────────────────────────────────────
; Check for hit - is any note in hit zone?
; Called on key-down transition
;───────────────────────────────────────
check_hit:
            ldx #$00
check_hit_loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq check_hit_next      ; Skip inactive

            cmp #HIT_ZONE_X         ; Is position < HIT_ZONE_X?
            bcs check_hit_next      ; No, not in hit zone

            ; Found a note in hit zone - HIT!
            jsr erase_note          ; Remove from screen
            lda #NOTE_INACTIVE
            sta note_x,x            ; Mark as inactive
            lda #FLASH_DURATION
            sta hit_flash           ; Trigger green flash
            rts                     ; Done (first match only)

check_hit_next:
            inx
            cpx #MAX_NOTES
            bne check_hit_loop
            rts                     ; No note in zone (empty keypress)

;───────────────────────────────────────
; Update flash colours
;───────────────────────────────────────
update_flash:
            ; Handle hit flash (green) - takes priority
            lda hit_flash
            beq uf_no_hit_flash
            dec hit_flash
            jsr flash_zone_green
            rts

uf_no_hit_flash:
            ; Handle miss flash (red)
            lda miss_flash
            beq uf_no_miss_flash
            dec miss_flash
            jsr flash_zone_red
            rts

uf_no_miss_flash:
            ; Restore normal hit zone colour
            jsr restore_zone_colour
            rts

;───────────────────────────────────────
; Flash hit zone green (hit feedback)
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
; Flash hit zone red (miss feedback)
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
; Restore hit zone to normal colour
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
; Spawn a new note - find empty slot
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
            ; No free slot, skip spawn
            rts

found_slot:
            ; Place note at right edge
            lda #NOTE_START_X
            sta note_x,x
            ; Draw the note
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
            beq move_next          ; Skip inactive notes

            ; Erase note at current position
            jsr erase_note

            ; Move left
            dec note_x,x

            ; Check if off screen (underflow to $FF)
            lda note_x,x
            cmp #NOTE_INACTIVE     ; Did it wrap to $FF?
            beq despawn_note

            ; Still on screen - draw at new position
            jsr draw_note

move_next:
            inx
            cpx #MAX_NOTES
            bne move_loop
            rts

despawn_note:
            ; Note reached left edge without being hit - MISS!
            lda #FLASH_DURATION
            sta miss_flash          ; Trigger red flash
            jmp move_next

;───────────────────────────────────────
; Draw note at position note_x,x on Track 2
; X = note index
;───────────────────────────────────────
draw_note:
            stx temp_x             ; Save note index

            lda note_x,x           ; Get X position
            cmp #HIT_ZONE_X        ; In hit zone?
            bcc draw_note_done     ; Yes - don't overdraw hit zone

            clc
            adc #<(SCREEN + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(SCREEN + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ldy #$00
            lda #NOTE_CHAR
            sta (screen_ptr),y

            ; Set colour
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
            ldx temp_x             ; Restore note index
            rts

;───────────────────────────────────────
; Erase note - restore track character
; X = note index
;───────────────────────────────────────
erase_note:
            stx temp_x

            lda note_x,x
            cmp #HIT_ZONE_X        ; In hit zone?
            bcc erase_note_done    ; Yes - don't erase hit zone graphics

            clc
            adc #<(SCREEN + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(SCREEN + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ldy #$00
            lda #TRACK_CHAR
            sta (screen_ptr),y

            ; Restore track colour
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
; Variables
;───────────────────────────────────────
key_state:
            !byte $00

key_was_pressed:
            !byte $00               ; For detecting key-down transition

move_timer:
            !byte NOTE_SPEED

spawn_timer:
            !byte SPAWN_INTERVAL

hit_flash:
            !byte $00               ; Frames remaining for hit flash

miss_flash:
            !byte $00               ; Frames remaining for miss flash

temp_x:
            !byte $00

; Zero page pointer for indirect addressing
screen_ptr  = $fb              ; Using $FB/$FC as pointer

; Note positions (X coordinate for each note, $FF = inactive)
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

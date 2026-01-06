;═══════════════════════════════════════════════════════════════════════════════
; SID SYMPHONY - Unit 2: Notes in Motion
; A rhythm game for the Commodore 64
;
; Build: acme -f cbm -o symphony.prg symphony.asm
; Run:   x64sc symphony.prg
;═══════════════════════════════════════════════════════════════════════════════

;───────────────────────────────────────────────────────────────────────────────
; BASIC stub
;───────────────────────────────────────────────────────────────────────────────
            * = $0801

            !byte $0c, $08
            !byte $0a, $00
            !byte $9e
            !byte $32, $30, $36, $34
            !byte $00
            !byte $00, $00

;───────────────────────────────────────────────────────────────────────────────
; Constants
;───────────────────────────────────────────────────────────────────────────────
SCREEN      = $0400
COLOUR      = $d800

; Zero page
screen_ptr  = $fb               ; 2 bytes for indirect addressing

; Screen layout
ROW_SCORE   = 1
ROW_TRACK1  = 8
ROW_TRACK2  = 12
ROW_TRACK3  = 16
ROW_CROWD   = 23

; Colours
COL_BLACK   = $00
COL_WHITE   = $01
COL_CYAN    = $03
COL_GREEN   = $05
COL_GREY    = $0b

; Track dimensions
HIT_ZONE_W  = 4

; Note system
MAX_NOTES       = 4
NOTE_INACTIVE   = $ff
NOTE_CHAR       = $51           ; Ball character
TRACK_CHAR      = $2d           ; Dash for track

; Timing
NOTE_SPEED      = 4             ; Frames between moves
SPAWN_INTERVAL  = 50            ; Frames between spawns

; SID registers
SID         = $d400
SID_FREQ_LO = SID + 0
SID_FREQ_HI = SID + 1
SID_PW_LO   = SID + 2
SID_PW_HI   = SID + 3
SID_CTRL    = SID + 4
SID_AD      = SID + 5
SID_SR      = SID + 6
SID_VOLUME  = SID + 24

; CIA
CIA1_PRA    = $dc00
CIA1_PRB    = $dc01

;───────────────────────────────────────────────────────────────────────────────
; Entry Point
;───────────────────────────────────────────────────────────────────────────────
            * = $0810

!zone main
main:
            jsr setup_screen
            jsr draw_top_panel
            jsr draw_tracks
            jsr draw_bottom_panel
            jsr init_sid
            jsr init_notes
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Setup Screen
;───────────────────────────────────────────────────────────────────────────────
!zone setup_screen
setup_screen:
            lda #COL_BLACK
            sta $d020
            sta $d021

            ldx #$00
.clear_loop:
            lda #$20
            sta SCREEN,x
            sta SCREEN + $100,x
            sta SCREEN + $200,x
            sta SCREEN + $2e8,x
            lda #COL_BLACK
            sta COLOUR,x
            sta COLOUR + $100,x
            sta COLOUR + $200,x
            sta COLOUR + $2e8,x
            inx
            bne .clear_loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Draw Top Panel
;───────────────────────────────────────────────────────────────────────────────
!zone draw_top_panel
draw_top_panel:
            ldx #$00
.loop:
            lda score_text,x
            beq .done
            sta SCREEN + (ROW_SCORE * 40),x
            lda #COL_WHITE
            sta COLOUR + (ROW_SCORE * 40),x
            inx
            bne .loop
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Draw Tracks
;───────────────────────────────────────────────────────────────────────────────
!zone draw_tracks
draw_tracks:
            ; Track 1
            ldx #$00
.t1_loop:
            cpx #HIT_ZONE_W
            bcs .t1_lane
            lda #$a0
            jmp .t1_store
.t1_lane:
            lda #TRACK_CHAR
.t1_store:
            sta SCREEN + (ROW_TRACK1 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK1 * 40),x
            inx
            cpx #40
            bne .t1_loop

            ; Track 2
            ldx #$00
.t2_loop:
            cpx #HIT_ZONE_W
            bcs .t2_lane
            lda #$a0
            jmp .t2_store
.t2_lane:
            lda #TRACK_CHAR
.t2_store:
            sta SCREEN + (ROW_TRACK2 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK2 * 40),x
            inx
            cpx #40
            bne .t2_loop

            ; Track 3
            ldx #$00
.t3_loop:
            cpx #HIT_ZONE_W
            bcs .t3_lane
            lda #$a0
            jmp .t3_store
.t3_lane:
            lda #TRACK_CHAR
.t3_store:
            sta SCREEN + (ROW_TRACK3 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK3 * 40),x
            inx
            cpx #40
            bne .t3_loop

            rts

;───────────────────────────────────────────────────────────────────────────────
; Draw Bottom Panel
;───────────────────────────────────────────────────────────────────────────────
!zone draw_bottom_panel
draw_bottom_panel:
            ldx #$00
.loop:
            lda crowd_text,x
            beq .done
            sta SCREEN + (ROW_CROWD * 40),x
            lda #COL_GREEN
            sta COLOUR + (ROW_CROWD * 40),x
            inx
            bne .loop
.done:
            rts

;───────────────────────────────────────────────────────────────────────────────
; Init SID
;───────────────────────────────────────────────────────────────────────────────
!zone init_sid
init_sid:
            lda #$0f
            sta SID_VOLUME

            lda #$00
            sta SID_AD
            lda #$f9
            sta SID_SR

            lda #$00
            sta SID_PW_LO
            lda #$08
            sta SID_PW_HI

            lda #$12
            sta SID_FREQ_LO
            lda #$11
            sta SID_FREQ_HI

            rts

;───────────────────────────────────────────────────────────────────────────────
; Init Notes
;───────────────────────────────────────────────────────────────────────────────
!zone init_notes
init_notes:
            ldx #MAX_NOTES - 1
.loop:
            lda #NOTE_INACTIVE
            sta note_x,x
            dex
            bpl .loop

            lda #NOTE_SPEED
            sta move_timer
            lda #$01            ; Spawn first note quickly
            sta spawn_timer

            rts

;───────────────────────────────────────────────────────────────────────────────
; Wait Frame - Sync to raster line 0
;───────────────────────────────────────────────────────────────────────────────
!zone wait_frame
wait_frame:
.wait_not_0:
            lda $d012
            beq .wait_not_0
.wait_0:
            lda $d012
            bne .wait_0
            rts

;───────────────────────────────────────────────────────────────────────────────
; Spawn Note - Create new note at right edge
;───────────────────────────────────────────────────────────────────────────────
!zone spawn_note
spawn_note:
            ldx #$00
.find_slot:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq .found
            inx
            cpx #MAX_NOTES
            bne .find_slot
            rts                 ; No free slot

.found:
            lda #39             ; Right edge of screen
            sta note_x,x
            jsr draw_note
            rts

;───────────────────────────────────────────────────────────────────────────────
; Move Notes - Shift all active notes left
;───────────────────────────────────────────────────────────────────────────────
!zone move_notes
move_notes:
            ldx #$00
.loop:
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq .next

            ; Erase at old position
            jsr erase_note

            ; Move left
            dec note_x,x

            ; Check if despawned (wrapped to $FF)
            lda note_x,x
            cmp #NOTE_INACTIVE
            beq .next

            ; Draw at new position
            jsr draw_note

.next:
            inx
            cpx #MAX_NOTES
            bne .loop
            rts

;───────────────────────────────────────────────────────────────────────────────
; Draw Note - Display note at current position
; X = note index (preserved)
;───────────────────────────────────────────────────────────────────────────────
!zone draw_note
draw_note:
            stx temp_x

            lda note_x,x
            cmp #HIT_ZONE_W     ; Don't draw in hit zone
            bcc .done

            ; Calculate screen address
            clc
            adc #<(SCREEN + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(SCREEN + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ; Draw note character
            ldy #$00
            lda #NOTE_CHAR
            sta (screen_ptr),y

            ; Calculate colour address
            lda note_x,x
            clc
            adc #<(COLOUR + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(COLOUR + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ; Set colour
            lda #COL_WHITE
            sta (screen_ptr),y

.done:
            ldx temp_x
            rts

;───────────────────────────────────────────────────────────────────────────────
; Erase Note - Remove note from screen
; X = note index (preserved)
;───────────────────────────────────────────────────────────────────────────────
!zone erase_note
erase_note:
            stx temp_x

            lda note_x,x
            cmp #HIT_ZONE_W
            bcc .done

            ; Calculate screen address
            clc
            adc #<(SCREEN + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(SCREEN + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ; Restore track character
            ldy #$00
            lda #TRACK_CHAR
            sta (screen_ptr),y

            ; Calculate colour address
            lda note_x,x
            clc
            adc #<(COLOUR + ROW_TRACK2 * 40)
            sta screen_ptr
            lda #>(COLOUR + ROW_TRACK2 * 40)
            adc #$00
            sta screen_ptr + 1

            ; Restore track colour
            lda #COL_CYAN
            sta (screen_ptr),y

.done:
            ldx temp_x
            rts

;───────────────────────────────────────────────────────────────────────────────
; Play/Stop Note
;───────────────────────────────────────────────────────────────────────────────
!zone play_note
play_note:
            lda #$41
            sta SID_CTRL
            rts

!zone stop_note
stop_note:
            lda #$40
            sta SID_CTRL
            rts

;───────────────────────────────────────────────────────────────────────────────
; Check X Key
;───────────────────────────────────────────────────────────────────────────────
!zone check_x_key
check_x_key:
            lda #%11111011
            sta CIA1_PRA
            lda CIA1_PRB
            and #%10000000
            bne .not_pressed
            lda #$01
            rts
.not_pressed:
            lda #$00
            rts

;───────────────────────────────────────────────────────────────────────────────
; Main Loop
;───────────────────────────────────────────────────────────────────────────────
!zone main_loop
main_loop:
            jsr wait_frame

            ; Handle input (same as Unit 1)
            jsr check_x_key
            cmp #$01
            beq .x_pressed

            lda key_state
            cmp #$01
            bne .after_input
            lda #$00
            sta key_state
            jsr stop_note
            jmp .after_input

.x_pressed:
            lda key_state
            cmp #$01
            beq .after_input
            lda #$01
            sta key_state
            jsr play_note

.after_input:
            ; Spawn timer
            dec spawn_timer
            bne .no_spawn
            lda #SPAWN_INTERVAL
            sta spawn_timer
            jsr spawn_note
.no_spawn:

            ; Move timer
            dec move_timer
            bne .no_move
            lda #NOTE_SPEED
            sta move_timer
            jsr move_notes
.no_move:

            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Data
;───────────────────────────────────────────────────────────────────────────────
!zone score_text
score_text:
            !scr "score: 000000          streak: 00"
            !byte 0

!zone crowd_text
crowd_text:
            !scr "crowd [          ]"
            !byte 0

;───────────────────────────────────────────────────────────────────────────────
; Variables
;───────────────────────────────────────────────────────────────────────────────
key_state:      !byte $00
move_timer:     !byte NOTE_SPEED
spawn_timer:    !byte SPAWN_INTERVAL
temp_x:         !byte $00

; Note arrays
!zone note_x
note_x:
            !byte $ff, $ff, $ff, $ff

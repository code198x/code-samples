;──────────────────────────────────────────────────────────────
; SID SYMPHONY
; A rhythm game for the Commodore 64
; Unit 1: The Stage
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
COL_GREY    = $0b
COL_CYAN    = $03
COL_GREEN   = $05

HIT_ZONE_X  = 8

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
CIA1_PRA    = $dc00             ; Keyboard column select
CIA1_PRB    = $dc01             ; Keyboard row read

;───────────────────────────────────────
; Entry point
;───────────────────────────────────────
            * = $0810

main:
            jsr setup_screen
            jsr init_sid
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
            lda #$a0            ; Solid block in hit zone
            sta SCREEN + (ROW_TRACK1 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK1 * 40),x
            jmp t1_next
t1_dim:
            lda #$2d            ; Dash in lane
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
            lda #$2d
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
            lda #$2d
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
            lda #$00            ; Attack=0, Decay=0 (instant)
            sta SID_AD
            lda #$f4            ; Sustain=15 (full), Release=4 (short fade)
            sta SID_SR
            lda #$00            ; Pulse width low
            sta SID_PW_LO
            lda #$08            ; Pulse width high (50% duty cycle)
            sta SID_PW_HI
            lda #$12            ; Frequency low
            sta SID_FREQ_LO
            lda #$22            ; Frequency high
            sta SID_FREQ_HI
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
; key_state: 0=idle, 1=playing, 2=releasing
;───────────────────────────────────────
main_loop:
            jsr check_x_key     ; Returns A=1 if X pressed, A=0 if not
            cmp #$01
            beq x_pressed

            ; X not pressed
            lda key_state
            cmp #$01            ; Were we playing?
            bne main_loop       ; No - already idle or releasing, loop
            ; Transition from playing to releasing
            lda #$02
            sta key_state
            jsr stop_note       ; Close gate - starts release phase
            jmp main_loop

x_pressed:
            ; X pressed - start note if idle or releasing
            lda key_state
            cmp #$01
            beq main_loop       ; Already playing, loop
            ; Start playing
            lda #$01
            sta key_state
            jsr play_note
            jmp main_loop

;───────────────────────────────────────
; Check if X key is currently held
; Returns A=1 if pressed, A=0 if not
;───────────────────────────────────────
check_x_key:
            lda #%11111011      ; Select column 2 (X is row 7, col 2)
            sta CIA1_PRA
            lda CIA1_PRB        ; Read rows
            and #%10000000      ; Check row 7 (bit 7)
            bne x_not_pressed   ; Bit set = not pressed
            lda #$01            ; Pressed
            rts
x_not_pressed:
            lda #$00            ; Not pressed
            rts

;───────────────────────────────────────
; Variables
;───────────────────────────────────────
key_state:
            !byte $00           ; 0 = not playing, 1 = playing

;───────────────────────────────────────
; Data
;───────────────────────────────────────
score_text:
            !scr "score: 000000          streak: 00"
            !byte 0

crowd_text:
            !scr "crowd [          ]              "
            !byte 0

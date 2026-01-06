;═══════════════════════════════════════════════════════════════════════════════
; SID SYMPHONY - Unit 1: The Stage
; A rhythm game for the Commodore 64
;
; Build: acme -f cbm -o symphony.prg symphony.asm
; Run:   x64sc symphony.prg
;═══════════════════════════════════════════════════════════════════════════════

;───────────────────────────────────────────────────────────────────────────────
; BASIC stub: 10 SYS 2064
;───────────────────────────────────────────────────────────────────────────────
            * = $0801

            !byte $0c, $08      ; Pointer to next line
            !byte $0a, $00      ; Line number 10
            !byte $9e           ; SYS token
            !byte $32, $30, $36, $34  ; "2064"
            !byte $00           ; End of line
            !byte $00, $00      ; End of program

;───────────────────────────────────────────────────────────────────────────────
; Constants
;───────────────────────────────────────────────────────────────────────────────
SCREEN      = $0400
COLOUR      = $d800

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

main:
            jsr setup_screen
            jsr draw_top_panel
            jsr draw_tracks
            jsr draw_bottom_panel
            jsr init_sid
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Setup Screen - Clear and set colours
;───────────────────────────────────────────────────────────────────────────────
setup_screen:
            ; Set border and background to black
            lda #COL_BLACK
            sta $d020
            sta $d021

            ; Clear screen and colour RAM
            ldx #$00
.clear_loop:
            lda #$20            ; Space character
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
; Draw Top Panel - Score and streak display
;───────────────────────────────────────────────────────────────────────────────
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
; Draw Tracks - Three horizontal lanes
;───────────────────────────────────────────────────────────────────────────────
draw_tracks:
            ; Track 1 (row 8) - dimmed
            ldx #$00
.t1_loop:
            cpx #HIT_ZONE_W
            bcs .t1_lane
            lda #$a0            ; Solid block in hit zone
            jmp .t1_store
.t1_lane:
            lda #$2d            ; Dash in lane
.t1_store:
            sta SCREEN + (ROW_TRACK1 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK1 * 40),x
            inx
            cpx #40
            bne .t1_loop

            ; Track 2 (row 12) - active
            ldx #$00
.t2_loop:
            cpx #HIT_ZONE_W
            bcs .t2_lane
            lda #$a0
            jmp .t2_store
.t2_lane:
            lda #$2d
.t2_store:
            sta SCREEN + (ROW_TRACK2 * 40),x
            lda #COL_CYAN
            sta COLOUR + (ROW_TRACK2 * 40),x
            inx
            cpx #40
            bne .t2_loop

            ; Track 3 (row 16) - dimmed
            ldx #$00
.t3_loop:
            cpx #HIT_ZONE_W
            bcs .t3_lane
            lda #$a0
            jmp .t3_store
.t3_lane:
            lda #$2d
.t3_store:
            sta SCREEN + (ROW_TRACK3 * 40),x
            lda #COL_GREY
            sta COLOUR + (ROW_TRACK3 * 40),x
            inx
            cpx #40
            bne .t3_loop

            rts

;───────────────────────────────────────────────────────────────────────────────
; Draw Bottom Panel - Crowd meter
;───────────────────────────────────────────────────────────────────────────────
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
; Init SID - Configure voice 1
;───────────────────────────────────────────────────────────────────────────────
init_sid:
            ; Master volume
            lda #$0f
            sta SID_VOLUME

            ; Voice 1 ADSR
            lda #$00            ; Attack=0, Decay=0
            sta SID_AD
            lda #$f9            ; Sustain=15, Release=9
            sta SID_SR

            ; Pulse width for voice 1
            lda #$00
            sta SID_PW_LO
            lda #$08            ; 50% duty cycle
            sta SID_PW_HI

            ; Frequency (approximately middle C)
            lda #$12
            sta SID_FREQ_LO
            lda #$11
            sta SID_FREQ_HI

            rts

;───────────────────────────────────────────────────────────────────────────────
; Play Note - Open gate on voice 1
;───────────────────────────────────────────────────────────────────────────────
play_note:
            lda #$41            ; Pulse wave + gate on
            sta SID_CTRL
            rts

;───────────────────────────────────────────────────────────────────────────────
; Stop Note - Close gate on voice 1
;───────────────────────────────────────────────────────────────────────────────
stop_note:
            lda #$40            ; Pulse wave + gate off
            sta SID_CTRL
            rts

;───────────────────────────────────────────────────────────────────────────────
; Check X Key - Returns A=1 if pressed, A=0 if not
;───────────────────────────────────────────────────────────────────────────────
check_x_key:
            lda #%11111011      ; Select column 2
            sta CIA1_PRA
            lda CIA1_PRB        ; Read rows
            and #%10000000      ; Check bit 7 (X key)
            bne .not_pressed
            lda #$01
            rts
.not_pressed:
            lda #$00
            rts

;───────────────────────────────────────────────────────────────────────────────
; Main Loop - Handle input and sound
;───────────────────────────────────────────────────────────────────────────────
main_loop:
            jsr check_x_key
            cmp #$01
            beq .x_pressed

            ; X not pressed
            lda key_state
            cmp #$01
            bne main_loop       ; Wasn't playing anyway
            ; Was playing, now released - stop
            lda #$00
            sta key_state
            jsr stop_note
            jmp main_loop

.x_pressed:
            ; X pressed
            lda key_state
            cmp #$01
            beq main_loop       ; Already playing
            ; Start playing
            lda #$01
            sta key_state
            jsr play_note
            jmp main_loop

;───────────────────────────────────────────────────────────────────────────────
; Data
;───────────────────────────────────────────────────────────────────────────────
score_text:
            !scr "score: 000000          streak: 00"
            !byte 0

crowd_text:
            !scr "crowd [          ]"
            !byte 0

;───────────────────────────────────────────────────────────────────────────────
; Variables
;───────────────────────────────────────────────────────────────────────────────
key_state:
            !byte $00           ; 0=not playing, 1=playing

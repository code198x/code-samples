; PAL C64, PRG/RUN, joystick port 2. Exclusive screen/CIA1/SID voice 1.
*=$0801
 !byte $0b,$08,$0a,$00,$9e
 !text "2064"
 !byte 0,0,0
*=$0810
start:
    sei
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$35
    sta $01                  ; RAM at BASIC/KERNAL, I/O visible
    lda #<nmi_return
    sta $fffa
    lda #>nmi_return
    sta $fffb
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00                ; VIC bank 0
    lda #$14
    sta $d018                ; screen $0400, character ROM $1000
    lda #$1b
    sta $d011                ; display on, normal text
    lda #$08
    sta $d016                ; 40 columns, single-colour text
    lda #0
    sta $d015
    sta $d020
    sta $d021
    ldx #0
    lda #32
clear_screen:
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $06e8, x
    inx
    bne clear_screen

    jsr joy_init
    lda #15
    sta $d418
    lda #0
    ldx #$a0
    jsr sid_voice_setup
    jsr reset_game
main_loop:
    jsr wait_frame
    jsr joy_poll
    lda joy2
    sta controls
    jsr detect_edges
    jsr service_sound
    jsr update_player
    jsr draw_screen
    inc updates
frame_done:
    jmp main_loop
nmi_return: rti
updates: !byte 0
!source "state.inc"
!source "rules.inc"
!source "draw.inc"
!source "sound.inc"
!source "../game-loop/frame.inc"
!source "../../input/joystick-reading/joystick.inc"
SID_VOICE=$d400
!source "../../audio/sid-note-trigger/sid-note.inc"

!source "collision.inc"

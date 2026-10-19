; PAL C64. Load and RUN; joystick in case-labelled port 2; release keyboard keys.
; Owns CIA1, SID voice 1, master volume/filter routing and border. Reset to exit.
* = $0801
    !byte $0b,$08,$0a,$00,$9e
    !text "2064"
    !byte 0,0,0
* = $0810
SID_VOICE = $d400
start:
    sei
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$35
    sta $01
    lda #<nmi_return
    sta $fffa
    lda #>nmi_return
    sta $fffb
    lda #0
    sta $dc0e
    sta $dc0f
    sta $d417                 ; no filter routing
    lda #$0f
    sta $d418                 ; caller owns master volume
    jsr joy_init
    lda #0
    ldx #$f9
    jsr sid_voice_setup
; --- update loop
wait_top:
    bit $d011
    bmi wait_top
wait_bottom:
    bit $d011
    bpl wait_bottom
update:
    jsr joy_poll              ; one sample; computes held and new bits together
    lda joy2_new
    and #$10
    beq keep_note
    lda #$11                 ; PAL middle C frequency $1167
    ldx #$67
    jsr sid_note_on
    lda #6                   ; hold gate for six updates, not while Fire is held
    sta note_frames
    inc trigger_count
    inc $d020                ; visible confirmation for every new Fire press
    jmp frame_done
keep_note:
    lda note_frames
    beq frame_done
    dec note_frames
    bne frame_done
    jsr sid_note_off          ; SID releases while the next updates continue
frame_done:
    jmp wait_top
; --- support routines
nmi_return:
    rti
note_frames: !byte 0
trigger_count: !byte 0
!source "../../input/joystick-reading/joystick.inc"
!source "../../audio/sid-note-trigger/sid-note.inc"

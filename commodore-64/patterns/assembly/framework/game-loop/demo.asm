; PAL C64. RUN. Port 2 Fire holds an intentionally excessive CPU workload.
; Exclusive CIA1/border ownership, interrupts disabled, ROM banked out.
; Reuses the maintained joystick reader. Reset to leave.
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
    sta $01
    lda #<nmi_return
    sta $fffa
    lda #>nmi_return
    sta $fffb
    lda #0
    sta $dc0e
    sta $dc0f
    sta updates
    sta updates+1
    sta slow
    jsr joy_init
main_loop:
    jsr wait_frame
    jsr joy_poll
    lda joy2
    and #$10
    sta slow
    jsr update_game
    jsr draw_screen
    jsr expensive_work
frame_done:
    jmp main_loop
update_game:
    inc updates
    bne update_done
    inc updates+1
update_done:
    rts
draw_screen:
    lda updates
    lsr
    lsr
    lsr
    and #7
    sta $d020
    rts
expensive_work:
    lda slow
    beq work_done
    ldy #48
work_outer:
    ldx #0
work_inner:
    dex
    bne work_inner
    dey
    bne work_outer
work_done:
    rts
nmi_return: rti
updates: !word 0
slow: !byte 0
!source "frame.inc"
!source "../../input/joystick-reading/joystick.inc"

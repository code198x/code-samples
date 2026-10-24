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
    sta $d015
    sta $d020
    sta $d021
    sta actions
    ldx #7
clear_trace:
    sta edge_trace,x
    dex
    bpl clear_trace
    lda $dd02
    ora #3
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00
    lda #$14
    sta $d018
    lda #$1b
    sta $d011
    lda #8
    sta $d016
    ldx #0
clear_screen:
    lda #32
    sta $0400,x
    sta $0500,x
    sta $0600,x
    sta $06e8,x
    lda #1
    sta $d800,x
    sta $d900,x
    sta $da00,x
    sta $dae8,x
    inx
    bne clear_screen
    jsr joy_edges_init
    lda #$a5
    sta ready
wait_top:
    bit $d011
    bmi wait_top
wait_bottom:
    bit $d011
    bpl wait_bottom
sample:
    jsr POLL_ROUTINE
    lda joy1_new
    beq no_press1
    sta last_new1
    inc press_events1
no_press1:
    lda joy1_released
    beq no_release1
    sta last_release1
    inc release_events1
no_release1:
    lda joy2_new
    beq no_press2
    sta last_new2
    inc press_events2
no_press2:
    lda joy2_released
    beq no_release2
    sta last_release2
    inc release_events2
no_release2:
    lda joy2_new
    and #ACTION_MASK
    beq no_action
    inc actions
no_action:
    ldy #0
    lda joy1
    jsr draw_byte
    lda joy1_new
    jsr draw_byte
    lda joy1_released
    jsr draw_byte
    lda joy2
    jsr draw_byte
    lda joy2_new
    jsr draw_byte
    lda joy2_released
    jsr draw_byte
    lda actions
    jsr draw_byte
frame_done:
    jmp wait_top
nmi_return:
    rti
draw_byte:
    pha
    lsr
    lsr
    lsr
    lsr
    tax
    lda digits,x
    sta $0400,y
    iny
    pla
    and #15
    tax
    lda digits,x
    sta $0400,y
    iny
    lda #32
    sta $0400,y
    iny
    rts
digits: !byte 48,49,50,51,52,53,54,55,56,57,1,2,3,4,5,6
actions: !byte 0
ready: !byte 0
; Diagnostic latches/counters make one-update pulses observable after a frame.
edge_trace:
last_new1: !byte 0
last_release1: !byte 0
last_new2: !byte 0
last_release2: !byte 0
press_events1: !byte 0
release_events1: !byte 0
press_events2: !byte 0
release_events2: !byte 0

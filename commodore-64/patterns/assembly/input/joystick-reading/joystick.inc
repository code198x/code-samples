; Exclusive CIA1 port ownership. Stop keyboard scanning and timer PB outputs
; before calling joy_init. Read once per update with joy_poll.
; Both routines change A/X and flags, preserve Y. I/O must remain visible.
joy_init:
    lda #0
    sta $dc02                ; both ports input: no driven keyboard columns
    sta $dc03
    lda #$ff
    sta $dc00                ; leave the output latches released too
    sta $dc01
    lda #0
    ldx #5
joy_clear:
    sta joy1, x
    dex
    bpl joy_clear
    rts

joy_poll:
    lda $dc01                ; case-labelled port 1 is CIA1 port B
    eor #$ff
    and #$1f                 ; only directions and fire
    tax
    lda joy1
    eor #$ff
    sta joy1_new
    txa
    and joy1_new             ; current AND NOT previous
    sta joy1_new
    stx joy1
    lda $dc00                ; case-labelled port 2 is CIA1 port A
    eor #$ff
    and #$1f
    tax
    lda joy2
    eor #$ff
    sta joy2_new
    txa
    and joy2_new
    sta joy2_new
    stx joy2
    lda joy1_new
    and #$10
    beq joy_check2
    inc joy1_fires           ; one increment per sampled fire press
joy_check2:
    lda joy2_new
    and #$10
    beq joy_done
    inc joy2_fires
joy_done:
    rts
joy_code_end:

; Pressed bits: up=1, down=2, left=4, right=8, fire=16.
; Counters wrap from $ff to $00. First poll compares against released state.
joy1:       !byte 0
joy2:       !byte 0
joy1_new:   !byte 0
joy2_new:   !byte 0
joy1_fires: !byte 0
joy2_fires: !byte 0

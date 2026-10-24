; Extends the maintained reader without changing its held/new/counter interface.
; Exclusive CIA ownership and five-bit masks as documented in joystick.inc.
; Call once per update instead of joy_poll. A/X/flags change; Y survives.
joy_edges_init:
    jsr joy_init
    lda #0
    sta joy1_released
    sta joy2_released
    rts
joy_poll_edges:
    lda joy1
    sta joy1_released
    lda joy2
    sta joy2_released
    jsr joy_poll
    lda joy1_released
    ldx joy1
    jsr joy_release_bits
    sta joy1_released
    lda joy2_released
    ldx joy2
    jsr joy_release_bits
    sta joy2_released
    rts
; Pure second-caller entry: A=previous five-bit mask, X=current five-bit mask.
; A=previous minus current as a bit set. X/Y survive; flags/scratch change.
joy_release_bits:
    sta joy_edge_scratch
    txa
    eor #$ff
    and joy_edge_scratch
    rts
joy_edges_code_end:
joy1_released: !byte 0
joy2_released: !byte 0
joy_edge_scratch: !byte 0

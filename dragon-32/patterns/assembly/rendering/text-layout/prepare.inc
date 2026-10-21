; BEGIN LAYOUT INPUTS
    ldd #PANEL_LEFT
    std TL+0
    ldd #PANEL_TOP
    std TL+2
    ldd #PANEL_WIDTH
    std TL+4
    ldd #PANEL_HEIGHT
    std TL+6
    ldd #label_data
    std TL+10
    lda #PANEL_ALIGN
    sta TL+8
    lda #LINE_PITCH
    sta TL+9
    lda #MESSAGE_LENGTH
    sta TL+12
    jsr layout_block
; END LAYOUT INPUTS

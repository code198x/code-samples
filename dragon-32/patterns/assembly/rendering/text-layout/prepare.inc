; BEGIN LAYOUT INPUTS
    ldd #PANEL_LEFT
    std L+0
    ldd #PANEL_TOP
    std L+2
    ldd #PANEL_WIDTH
    std L+4
    ldd #PANEL_HEIGHT
    std L+6
    ldd #label_data
    std L+10
    lda #PANEL_ALIGN
    sta L+8
    lda #LINE_PITCH
    sta L+9
    lda #MESSAGE_LENGTH
    sta L+12
    jsr layout_block
; END LAYOUT INPUTS

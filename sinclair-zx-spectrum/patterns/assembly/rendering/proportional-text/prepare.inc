; BEGIN LAYOUT INPUTS
    ld hl,PANEL_LEFT
    ld (TL+0),hl
    ld hl,PANEL_TOP
    ld (TL+2),hl
    ld hl,PANEL_WIDTH
    ld (TL+4),hl
    ld hl,PANEL_HEIGHT
    ld (TL+6),hl
    ld hl,label_data
    ld (TL+10),hl
    ld a,PANEL_ALIGN
    ld (TL+8),a
    ld a,LINE_PITCH
    ld (TL+9),a
    ld a,MESSAGE_LENGTH
    ld (TL+12),a
    ld hl,metric_data
    ld (TL+64),hl
    ld a,LETTER_SPACING
    ld (TL+66),a
    call layout_block
; END LAYOUT INPUTS

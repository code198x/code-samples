; BEGIN LAYOUT INPUTS
    ld hl,PANEL_LEFT
    ld (L+0),hl
    ld hl,PANEL_TOP
    ld (L+2),hl
    ld hl,PANEL_WIDTH
    ld (L+4),hl
    ld hl,PANEL_HEIGHT
    ld (L+6),hl
    ld hl,label_data
    ld (L+10),hl
    ld a,PANEL_ALIGN
    ld (L+8),a
    ld a,LINE_PITCH
    ld (L+9),a
    ld a,MESSAGE_LENGTH
    ld (L+12),a
    call layout_block
; END LAYOUT INPUTS

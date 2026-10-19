; ANTIC mode8: 40 logical pixels, four colours, eight scanlines per row.
; Main owns $2000-$20EF bitmap and ANTIC/GTIA registers; no BIOS display IRQ.
init_picture:
    lda #0
    sta $1005
    sta $c01a
    ldx #0
clear_picture:
    sta $2000,x
    inx
    cpx #240
    bne clear_picture
    lda #14
    sta $c018
    lda #<display_list
    sta $d402
    lda #>display_list
    sta $d403
    lda #$22
    sta $d400
    rts
draw_picture:
    lda #0
    sta $207c
    sta $207d
    lda turns
    and #1
    tax
    lda #$ff
    sta $207c,x
    rts
display_list:
    !byte $70,$70,$70,$48,<$2000,>$2000
    !for i,1,23 { !byte 8 }
    !byte $41,<display_list,>display_list

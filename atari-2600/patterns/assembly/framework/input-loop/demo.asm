; NTSC 4 KiB cartridge. Display servicing runs every field, but only a new
; fire press advances the turn. Owns all TIA state and RIOT RAM $80-$84.
* = $f000
start:
    sei
    cld
    ldx #$ff
    txs
    lda #0
    ldx #$7f
clear_ram:
    sta $80,x
    dex
    bpl clear_ram
    lda #2
    sta $01                   ; VBLANK: blank, button latching disabled
frame:
    lda #2
    sta $00                   ; VSYNC
    sta $02
    sta $02
    sta $02                   ; three sync lines
    lda #0
    sta $00
    ldx #37
blank_lines:
    sta $02                   ; WSYNC
    dex
    bne blank_lines
    lda #0
    sta $01
    ldx #192
visible_lines:
    sta $02
    dex
    bne visible_lines
    lda #2
    sta $01
    sta $02                   ; overscan line 1; next line contains short work
    lda $0c                   ; INPT4, active-low fire
    and #$80
    eor #$80
    sta $84                   ; current active-high sample
    lda $81
    eor #$ff
    and $84
    beq no_action
    inc $80                   ; byte turn counter, wraps naturally
no_action:
    lda $84
    sta $81
    inc $82                   ; field counter, low
    bne show
    inc $83
show:
    lda $80
    and #1
    beq even_turn
    lda #$44
    bne colour
 even_turn:
    lda #$84
colour:
    sta $09                   ; COLUBK, next visible field's feedback
    sta $02                   ; finish overscan line 2
    ldx #28
overscan:
    sta $02
    dex
    bne overscan              ; total 30 overscan lines
    jmp frame
    !fill $fffa-*,0
    !word start,start,start

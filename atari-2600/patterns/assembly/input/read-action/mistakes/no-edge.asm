; Capability caller: original input/frame service, explicit drawing and sound.
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
    jsr init_picture
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
    !source "../sample.inc"
    lda $84
    nop
    nop
    nop
    nop
    beq no_action
    inc $80                   ; byte turn counter, wraps naturally
    jsr trigger_sound
no_action:
    lda $84
    sta $81
    inc $82                   ; field counter, low
    bne show
    inc $83
show:
    jsr draw_picture
    jsr service_sound
    sta $02                   ; finish overscan line 3 (bounded drawing/audio work)
    ldx #27
overscan:
    sta $02
    dex
    bne overscan              ; 30 overscan lines including the two-line work window
    jmp frame
!source "../picture.inc"
!source "../sound.inc"
    !fill $fffa-*,0
    !word start,start,start

; SPDX-License-Identifier: MIT
; NTSC mapper-0 cartridge: cold reset draws stripes and computes a RAM result.
; No startup state, injected memory, interrupt service or external assets.
.segment "HEADER"
    .byte "NES", $1a
    .byte 2, 1                  ; 32 KiB PRG ROM, 8 KiB CHR ROM
    .byte 0, 0                  ; mapper 0, horizontal mirroring, no battery
    .byte 1, 0                  ; explicit legacy 8 KiB PRG RAM, NTSC
    .byte 0, 0, 0, 0, 0, 0

.segment "CODE"
reset:
    sei
    cld
    ldx #$ff
    txs
    inx
    stx $2000                   ; disable NMI and rendering during setup
    stx $2001
    stx $4010                   ; disable DMC IRQ
    stx $4015                   ; silence APU
    lda #$40
    sta $4017                   ; disable frame IRQ
    stx $0200
    stx $0201
    bit $2002
wait_first:
    bit $2002
    bpl wait_first
wait_second:
    bit $2002
    bpl wait_second

    ; Fill a full RAM page with computed 0..255; no copy from ROM.
    ldx #0
ram_pattern:
    txa
    sta $0300,x
    inx
    bne ram_pattern

    ; One nametable: 960 copies of striped tile 1, then zero attributes.
    lda #$20
    sta $2006
    lda #0
    sta $2006
    ldy #3
    ldx #0
    lda #1
tile_pages:
    sta $2007
    inx
    bne tile_pages
    dey
    bne tile_pages
    ldx #192
tile_tail:
    sta $2007
    dex
    bne tile_tail
    lda #0
    ldx #64
attributes:
    sta $2007
    dex
    bne attributes

    ; All palette slots initialised; colour 1 is white, background is black.
    lda #$3f
    sta $2006
    lda #0
    sta $2006
    ldx #32
    lda #$0f
palette:
    sta $2007
    dex
    bne palette
    lda #$3f
    sta $2006
    lda #1
    sta $2006
    lda #$30
    sta $2007
    lda #0
    sta $2000
    sta $2005
    sta $2005
    lda #$0a                    ; background on, including leftmost eight pixels
    sta $2001

    lda #$a5
    eor #$ff
    sta $0200
    clc
    adc #1
    sta $0201
complete:
    jmp complete
interrupt:
    rti

.segment "VECTORS"
    .word interrupt, reset, interrupt

.segment "CHARS"
    .res 16, 0                  ; tile 0 is blank
    .res 8, $aa                 ; tile 1: alternating vertical colour-1 stripes
    .res 8, 0
    .res 8160, 0

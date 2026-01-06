draw_title_screen:
    ; Clear sprites (hide player, enemies, item)
    ldx #0
    lda #$FF
@clear_sprites:
    sta oam, x
    inx
    bne @clear_sprites

    ; Set PPU address for "NEON NEXUS" (row 10, column 11)
    lda PPUSTATUS           ; reset latch
    lda #$21
    sta PPUADDR
    lda #$4B                ; $214B
    sta PPUADDR

    ; Write "NEON NEXUS" - tile indices
    ldx #0
@title_loop:
    lda title_text, x
    beq @press_start        ; null terminator
    sta PPUDATA
    inx
    bne @title_loop

@press_start:
    ; Set PPU address for "PRESS START" (row 14, column 10)
    lda #$21
    sta PPUADDR
    lda #$CA                ; $21CA
    sta PPUADDR

    ldx #0
@press_loop:
    lda press_text, x
    beq @done
    sta PPUDATA
    inx
    bne @press_loop

@done:
    ; Reset scroll
    lda #0
    sta PPUSCROLL
    sta PPUSCROLL

    rts

; Text data (tile indices, null-terminated)
title_text:
    .byte 27, 18, 28, 27    ; NEON
    .byte 0                 ; space
    .byte 27, 18, 33, 32, 30; NEXUS
    .byte 0                 ; terminator

press_text:
    .byte 29, 31, 18, 30, 30; PRESS
    .byte 0                 ; space
    .byte 30, 31, 14, 31, 31; START (note: reuses letters)
    .byte 0                 ; terminator

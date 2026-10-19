; Maintained masked renderer, Pasmo syntax. Includes pixel_down separately.
; SPRITE_W=1.masked_32 bytes; DE=left screen byte, HL=interleaved mask/image pairs.
; C=height (zero is a no-op); the whole rectangle must fit 256x192 display.
; Caller owns bitmap; routine neither clips nor restores the old background.
; AF/BC/DE/HL change; HL advances by 2*SPRITE_W*height. C returns zero.
; pixel_down must preserve BC/DE. No call below pixel row191 is permitted.
; =============================================================================
; MASKED SPRITES - ZX SPECTRUM
; Draw one sprite row over the background:  screen = (screen AND mask) OR image
; Sprite data is stored as interleaved (mask, image) byte pairs.
; DE -> screen address for this row,  HL -> sprite data,  B = width in bytes
; =============================================================================

draw_row:
    ld a,b
    or a
    ret z                   ; zero width is a no-op
masked_byte:
    ld   a,(de)            ; the background byte
    and  (hl)              ; AND mask: 1s keep background, 0s clear for the sprite
    inc  hl
    or   (hl)              ; OR image: the sprite's own pixels
    inc  hl
    ld   (de),a            ; write it back
    inc  de                ; next byte across
    djnz masked_byte
    ret

; A full sprite: for each of its rows, draw a row then step the screen down.
; (pixel_down is the one-line-down routine from Bitmap Addressing.)
draw_sprite:
    ld a,c
    or a
    ret z                   ; zero height is a no-op
    ; DE -> top-left screen byte, HL -> sprite data, C = height in rows
masked_row:
    push bc
    push de                 ; retain this row's LEFT edge
    ld b,SPRITE_W
    call draw_row
    pop de
    pop bc
    dec c
    ret z                   ; do not step below the final display row
    ex de,hl
    call pixel_down          ; preserves DE: the sprite-data pointer survives
    ex de,hl
    jr masked_row

; =============================================================================
; SMOOTH SCROLLING - C64 (horizontal, leftward)
; Fine-scroll 7->0 with $D016; on wrap, coarse-shift the map one column
; CPU: Light per frame; heavy on the 1-in-8 coarse step
; =============================================================================

VIC_CTRL2   = $D016     ; bits 0-2 = X fine scroll (0-7); bit 3 = 40/38 columns
SCREEN      = $0400

scroll_x    = $FB       ; a free zero-page byte: our shadow of the fine offset

init_scroll:
    lda VIC_CTRL2
    and #%11110111      ; bit 3 = 0 -> 38-column mode (hides the edge characters)
    sta VIC_CTRL2
    lda #7
    sta scroll_x
    jmp set_fine

; Call once a frame (after raster sync) to scroll the world left by one pixel
scroll_left:
    dec scroll_x
    bpl set_fine        ; still 0..7? just update the fine offset
    lda #7              ; passed 0: a whole character has gone by
    sta scroll_x
    jsr coarse_left     ; shift the map one column left, fill the new right edge
set_fine:
    lda VIC_CTRL2
    and #%11111000      ; clear the low 3 bits
    ora scroll_x        ; set the new fine-scroll offset
    sta VIC_CTRL2
    rts

; Caller owns screen $0400-$07e7, colour $d800-$dbe7, ZP $fb,
; and next_column/next_colour (25 bytes each). Colour values use low four bits.
; Prepare the next right-hand column before the wrap step. No map streamer here.
; A, X, flags change; Y survives. Decimal mode must be clear. IRQ/NMI code
; must not change the owned state. This copies 1950 bytes on the coarse step:
; raster synchronisation alone does NOT make it tear-free or fit a frame budget.
; Use a smaller playfield or a separately budgeted buffer scheme when needed.
coarse_left:
    ldx #0
copy_columns:
    !for row,0,24 {
        lda SCREEN+row*40+1,x
        sta SCREEN+row*40,x
        lda $d800+row*40+1,x
        sta $d800+row*40,x
    }
    inx
    cpx #39
    beq fill_column
    jmp copy_columns
fill_column:
    !for row,0,24 {
        lda next_column+row
        sta SCREEN+row*40+39
        lda next_colour+row
        sta $d800+row*40+39
    }
    rts
next_column: !fill 25,32
next_colour: !fill 25,1

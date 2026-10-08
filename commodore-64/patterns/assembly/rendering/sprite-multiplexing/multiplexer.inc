; Two bands of 0..8 unexpanded, single-colour sprites, at Y=64 and Y=176.
; Owns the raster IRQ and VIC-II sprite registers. Call mux_init with IRQs off,
; RAM vectors visible ($01=$35), bank 0 and screen $0400 selected.
; The caller enables IRQs. Counts are atomic bytes; do not edit tables live.
mux_init:
    lda #0
    sta $d01a
    sta $d015
    sta $d017
    sta $d01b
    sta $d01c
    sta $d01d
    sta mux_phase
    sta mux_frames
    sta mux_errors
    sta mux_errors + 1
    lda #<mux_irq
    sta $fffe
    lda #>mux_irq
    sta $ffff
    lda #$1b             ; display on, 25 rows; raster compare high bit clear
    sta $d011
    lda #32
    sta $d012
    lda #$0f
    sta $d019            ; clear pending VIC-II sources before enabling raster
    lda #1
    sta $d01a
    rts

mux_irq:
    pha
    txa
    pha
    tya
    pha
    lda #1
    sta $d019
    lda #0
    sta $d015            ; the preceding band has finished
    sta mux_msb
    sta mux_slot
    sta mux_offset
    ldx mux_phase
    sta mux_errors, x
    lda mux_counts, x
    cmp #9
    bcc mux_valid
    lda #1               ; invalid count: reject this band, never index its data
    sta mux_errors, x
    lda #0
mux_valid:
    sta mux_count
    sta mux_remaining
    lda mux_starts, x
    sta mux_index
    lda mux_y, x
    sta mux_current_y
    lda mux_remaining
    beq mux_commit       ; zero entries means no table reads
mux_sprite:
    ldy mux_index
    ldx mux_offset       ; position registers have a two-byte stride
    lda mux_xlo, y
    sta $d000, x
    lda mux_current_y
    sta $d001, x
    ldx mux_slot         ; pointers and colours have a one-byte stride
    lda mux_pointers, y
    sta $07f8, x
    lda mux_colours, y
    sta $d027, x
    lda mux_xhi, y
    beq mux_low_x
    lda mux_msb
    ora mux_bits, x
    sta mux_msb
mux_low_x:
    inc mux_index
    inc mux_slot
    inc mux_offset
    inc mux_offset
    dec mux_remaining
    bne mux_sprite
mux_commit:
    lda mux_msb          ; rebuild all eight bits, including bits to clear
    sta $d010
    ldx mux_count
    lda mux_enables, x
    sta $d015
    ldx mux_phase
    lda $d012            ; completion raster, retained for the timing check
    sta mux_last_write, x
    txa
    eor #1
    sta mux_phase
    tax
    lda mux_irq_lines, x
    sta $d012
    cpx #0
    bne mux_return
    inc mux_frames
mux_return:
    pla
    tay
    pla
    tax
    pla
    rti

mux_counts:     !byte 8, 8
mux_xlo:        !byte 24, 64, 104, 144, 184, 224, 8, 48
                !byte 48, 8, 224, 184, 144, 104, 64, 24
mux_xhi:        !byte 0, 0, 0, 0, 0, 0, 1, 1
                !byte 1, 1, 0, 0, 0, 0, 0, 0
mux_pointers:   !fill 8, $80
                !fill 8, $81
mux_colours:    !byte 1, 2, 3, 4, 5, 6, 7, 8
                !byte 8, 7, 6, 5, 4, 3, 2, 1
mux_starts:     !byte 0, 8
mux_y:          !byte 64, 176
mux_irq_lines:  !byte 32, 144
mux_bits:       !byte 1, 2, 4, 8, 16, 32, 64, 128
mux_enables:    !byte 0, 1, 3, 7, 15, 31, 63, 127, 255
mux_phase:      !byte 0
mux_frames:     !byte 0
mux_errors:     !byte 0, 0
mux_last_write: !byte 0, 0
mux_msb:        !byte 0
mux_slot:       !byte 0
mux_offset:     !byte 0
mux_count:      !byte 0
mux_remaining:  !byte 0
mux_index:      !byte 0
mux_current_y:  !byte 0

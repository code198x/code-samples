; SPDX-License-Identifier: MIT
; Caller: arrays obj_{x,y,tile,attr,active}[64], object_count 0..64,
; first_object, oam_used, oam_status, objects_left, object_index.
; Page-aligned oam_buffer[256], exclusive to builder until it publishes ready.
; obj_y is the RAW OAM Y (visible top=Y+1), 0..238; >=239 is hidden.
; Only one 8x8 hardware sprite per object. No clipping, metasprites or DMA here.
; A/X/Y/flags clobbered. Decimal mode clear. Called outside NMI.
; Count >64: hide all entries, status=1 and carry set; no array reads.
build_oam:
    ldx #0
    lda #$ff
hide_oam:
    sta oam_buffer,x
    inx
    inx
    inx
    inx
    bne hide_oam
    lda #0
    sta oam_used
    sta oam_status
    lda object_count
    cmp #65
    bcs oam_invalid
    lda object_count
    beq oam_empty
    sta objects_left
    lda first_object
    cmp object_count
    bcc oam_start
    lda #0
    sta first_object
oam_start:
    sta object_index
oam_next:
    ldx object_index
    lda obj_active,x
    beq oam_skip
    lda obj_y,x
    cmp #239
    bcs oam_skip
    lda oam_used
    asl
    asl
    tay
    lda obj_y,x
    sta oam_buffer,y
    iny
    lda obj_tile,x
    sta oam_buffer,y
    iny
    lda obj_attr,x
    sta oam_buffer,y
    iny
    lda obj_x,x
    sta oam_buffer,y
    inc oam_used
oam_skip:
    inc object_index
    lda object_index
    cmp object_count
    bcc oam_no_wrap
    lda #0
    sta object_index
oam_no_wrap:
    dec objects_left
    bne oam_next
oam_empty:
    clc
    rts
oam_invalid:
    lda #1
    sta oam_status
    sec
    rts
; Rotate ONLY when the caller chooses. This shares dropout; it does not raise
; the hardware's eight-sprites-per-scanline capacity or preserve sprite-0 use.
advance_priority:
    lda object_count
    beq priority_reset
    cmp #65
    bcs priority_reset
    inc first_object
    lda first_object
    cmp object_count
    bcc priority_done
priority_reset:
    lda #0
    sta first_object
priority_done:
    rts

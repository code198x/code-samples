; SPDX-License-Identifier: MIT
; Advance a Timed Animation. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
animation_timeline_init:
    lda #0
    sta FRAME
    sta TICKS
    sta FRAME_COUNT
    sta DURATION
    sta LOOP
    sta FINISHED
    sta VALID
    sta T0
    rts
animation_timeline_step:
; VALID = 0
    lda #0
    sta VALID
; if FRAME_COUNT == 0:
    lda FRAME_COUNT
    cmp #0
    beq animation_timeline_L4
animation_timeline_L5:
    jmp animation_timeline_L2
animation_timeline_L4:
    jmp animation_timeline_L1
animation_timeline_L1:
; return
    rts
    jmp animation_timeline_L3
animation_timeline_L2:
animation_timeline_L3:
; if DURATION == 0:
    lda DURATION
    cmp #0
    beq animation_timeline_L9
animation_timeline_L10:
    jmp animation_timeline_L7
animation_timeline_L9:
    jmp animation_timeline_L6
animation_timeline_L6:
; return
    rts
    jmp animation_timeline_L8
animation_timeline_L7:
animation_timeline_L8:
; if FRAME >= FRAME_COUNT:
    lda FRAME
    cmp FRAME_COUNT
    bcs animation_timeline_L14
animation_timeline_L15:
    jmp animation_timeline_L12
animation_timeline_L14:
    jmp animation_timeline_L11
animation_timeline_L11:
; return
    rts
    jmp animation_timeline_L13
animation_timeline_L12:
animation_timeline_L13:
; if TICKS >= DURATION:
    lda TICKS
    cmp DURATION
    bcs animation_timeline_L19
animation_timeline_L20:
    jmp animation_timeline_L17
animation_timeline_L19:
    jmp animation_timeline_L16
animation_timeline_L16:
; return
    rts
    jmp animation_timeline_L18
animation_timeline_L17:
animation_timeline_L18:
; VALID = 1
    lda #1
    sta VALID
; if FINISHED != 0:
    lda FINISHED
    cmp #0
    bne animation_timeline_L24
animation_timeline_L25:
    jmp animation_timeline_L22
animation_timeline_L24:
    jmp animation_timeline_L21
animation_timeline_L21:
; return
    rts
    jmp animation_timeline_L23
animation_timeline_L22:
animation_timeline_L23:
; TICKS = TICKS + 1
    lda TICKS
    clc
    adc #1
    sta TICKS
; if TICKS < DURATION:
    lda TICKS
    cmp DURATION
    bcc animation_timeline_L29
animation_timeline_L30:
    jmp animation_timeline_L27
animation_timeline_L29:
    jmp animation_timeline_L26
animation_timeline_L26:
; return
    rts
    jmp animation_timeline_L28
animation_timeline_L27:
animation_timeline_L28:
; TICKS = 0
    lda #0
    sta TICKS
; T0 = FRAME_COUNT - 1
    lda FRAME_COUNT
    sec
    sbc #1
    sta T0
; if FRAME < T0:
    lda FRAME
    cmp T0
    bcc animation_timeline_L34
animation_timeline_L35:
    jmp animation_timeline_L32
animation_timeline_L34:
    jmp animation_timeline_L31
animation_timeline_L31:
; FRAME = FRAME + 1
    lda FRAME
    clc
    adc #1
    sta FRAME
; return
    rts
    jmp animation_timeline_L33
animation_timeline_L32:
animation_timeline_L33:
; if LOOP != 0:
    lda LOOP
    cmp #0
    bne animation_timeline_L39
animation_timeline_L40:
    jmp animation_timeline_L37
animation_timeline_L39:
    jmp animation_timeline_L36
animation_timeline_L36:
; FRAME = 0
    lda #0
    sta FRAME
    jmp animation_timeline_L38
animation_timeline_L37:
; FINISHED = 1
    lda #1
    sta FINISHED
animation_timeline_L38:
    rts
component_end:

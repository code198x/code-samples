; SPDX-License-Identifier: MIT
; Remember Contact Pairs for a Step. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
contact_pair_cache_init:
    lda #0
    sta FIRST
    sta VALID
    sta MODE
    sta OBJECT_A
    sta OBJECT_B
    sta B0
    sta B1
    sta B2
    sta B3
    sta B4
    sta B5
    sta B6
    sta B7
    sta T0
    sta T1
    sta T2
    sta T3
    sta T4
    sta EXPR_SAVE
    rts
contact_pair_cache_step:
; FIRST = 0
    lda #0
    sta FIRST
; VALID = 0
    lda #0
    sta VALID
; if MODE > 2:
    lda MODE
    cmp #2
    beq contact_pair_cache_L5
    bcs contact_pair_cache_L4
contact_pair_cache_L5:
    jmp contact_pair_cache_L2
contact_pair_cache_L4:
    jmp contact_pair_cache_L1
contact_pair_cache_L1:
; return
    rts
    jmp contact_pair_cache_L3
contact_pair_cache_L2:
contact_pair_cache_L3:
; if MODE == 0:
    lda MODE
    cmp #0
    beq contact_pair_cache_L9
contact_pair_cache_L10:
    jmp contact_pair_cache_L7
contact_pair_cache_L9:
    jmp contact_pair_cache_L6
contact_pair_cache_L6:
; T0 = 0
    lda #0
    sta T0
; while T0 < 8:
contact_pair_cache_L11:
    lda T0
    cmp #8
    bcc contact_pair_cache_L14
contact_pair_cache_L15:
    jmp contact_pair_cache_L13
contact_pair_cache_L14:
    jmp contact_pair_cache_L12
contact_pair_cache_L12:
; B[T0] = 0
    lda #0
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta B0,x
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp contact_pair_cache_L11
contact_pair_cache_L13:
; VALID = 1
    lda #1
    sta VALID
; return
    rts
    jmp contact_pair_cache_L8
contact_pair_cache_L7:
contact_pair_cache_L8:
; if OBJECT_A >= 8:
    lda OBJECT_A
    cmp #8
    bcs contact_pair_cache_L19
contact_pair_cache_L20:
    jmp contact_pair_cache_L17
contact_pair_cache_L19:
    jmp contact_pair_cache_L16
contact_pair_cache_L16:
; return
    rts
    jmp contact_pair_cache_L18
contact_pair_cache_L17:
contact_pair_cache_L18:
; if OBJECT_B >= 8:
    lda OBJECT_B
    cmp #8
    bcs contact_pair_cache_L24
contact_pair_cache_L25:
    jmp contact_pair_cache_L22
contact_pair_cache_L24:
    jmp contact_pair_cache_L21
contact_pair_cache_L21:
; return
    rts
    jmp contact_pair_cache_L23
contact_pair_cache_L22:
contact_pair_cache_L23:
; if OBJECT_A == OBJECT_B:
    lda OBJECT_A
    cmp OBJECT_B
    beq contact_pair_cache_L29
contact_pair_cache_L30:
    jmp contact_pair_cache_L27
contact_pair_cache_L29:
    jmp contact_pair_cache_L26
contact_pair_cache_L26:
; return
    rts
    jmp contact_pair_cache_L28
contact_pair_cache_L27:
contact_pair_cache_L28:
; T0 = OBJECT_A
    lda OBJECT_A
    sta T0
; T1 = OBJECT_B
    lda OBJECT_B
    sta T1
; if T0 > T1:
    lda T0
    cmp T1
    beq contact_pair_cache_L35
    bcs contact_pair_cache_L34
contact_pair_cache_L35:
    jmp contact_pair_cache_L32
contact_pair_cache_L34:
    jmp contact_pair_cache_L31
contact_pair_cache_L31:
; T0 = OBJECT_B
    lda OBJECT_B
    sta T0
; T1 = OBJECT_A
    lda OBJECT_A
    sta T1
    jmp contact_pair_cache_L33
contact_pair_cache_L32:
contact_pair_cache_L33:
; T2 = 1
    lda #1
    sta T2
; while T1 != 0:
contact_pair_cache_L36:
    lda T1
    cmp #0
    bne contact_pair_cache_L39
contact_pair_cache_L40:
    jmp contact_pair_cache_L38
contact_pair_cache_L39:
    jmp contact_pair_cache_L37
contact_pair_cache_L37:
; T2 = T2 << 1
    lda T2
    asl
    sta T2
; T1 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T1
    jmp contact_pair_cache_L36
contact_pair_cache_L38:
; T3 = B[T0]
    ldx T0
    lda B0,x
    sta T3
; T4 = T3 & T2
    lda T3
    and T2
    sta T4
; VALID = 1
    lda #1
    sta VALID
; if T4 == 0:
    lda T4
    cmp #0
    beq contact_pair_cache_L44
contact_pair_cache_L45:
    jmp contact_pair_cache_L42
contact_pair_cache_L44:
    jmp contact_pair_cache_L41
contact_pair_cache_L41:
; FIRST = 1
    lda #1
    sta FIRST
; if MODE == 1:
    lda MODE
    cmp #1
    beq contact_pair_cache_L49
contact_pair_cache_L50:
    jmp contact_pair_cache_L47
contact_pair_cache_L49:
    jmp contact_pair_cache_L46
contact_pair_cache_L46:
; T3 = T3 | T2
    lda T3
    ora T2
    sta T3
; B[T0] = T3
    lda T3
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta B0,x
    jmp contact_pair_cache_L48
contact_pair_cache_L47:
contact_pair_cache_L48:
    jmp contact_pair_cache_L43
contact_pair_cache_L42:
contact_pair_cache_L43:
    rts
component_end:

; SPDX-License-Identifier: MIT
; Build Bounded Spatial Buckets. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
spatial_bucket_init:
    lda #0
    sta BUCKET
    sta COUNT
    sta INSERTED
    sta FULL
    sta VALID
    sta MODE
    sta INPUT_X
    sta INPUT_Y
    sta ITEM
    sta C0
    sta C1
    sta C2
    sta C3
    sta S0
    sta S1
    sta S2
    sta S3
    sta S4
    sta S5
    sta S6
    sta S7
    sta S8
    sta S9
    sta S10
    sta S11
    sta S12
    sta S13
    sta S14
    sta S15
    sta T0
    sta T1
    sta T2
    sta EXPR_SAVE
    rts
spatial_bucket_step:
; BUCKET = 255
    lda #255
    sta BUCKET
; COUNT = 0
    lda #0
    sta COUNT
; INSERTED = 0
    lda #0
    sta INSERTED
; FULL = 0
    lda #0
    sta FULL
; VALID = 0
    lda #0
    sta VALID
; if MODE > 2:
    lda MODE
    cmp #2
    beq spatial_bucket_L5
    bcs spatial_bucket_L4
spatial_bucket_L5:
    jmp spatial_bucket_L2
spatial_bucket_L4:
    jmp spatial_bucket_L1
spatial_bucket_L1:
; return
    rts
    jmp spatial_bucket_L3
spatial_bucket_L2:
spatial_bucket_L3:
; if MODE == 0:
    lda MODE
    cmp #0
    beq spatial_bucket_L9
spatial_bucket_L10:
    jmp spatial_bucket_L7
spatial_bucket_L9:
    jmp spatial_bucket_L6
spatial_bucket_L6:
; T0 = 0
    lda #0
    sta T0
; while T0 < 4:
spatial_bucket_L11:
    lda T0
    cmp #4
    bcc spatial_bucket_L14
spatial_bucket_L15:
    jmp spatial_bucket_L13
spatial_bucket_L14:
    jmp spatial_bucket_L12
spatial_bucket_L12:
; C[T0] = 0
    lda #0
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta C0,x
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp spatial_bucket_L11
spatial_bucket_L13:
; T0 = 0
    lda #0
    sta T0
; while T0 < 16:
spatial_bucket_L16:
    lda T0
    cmp #16
    bcc spatial_bucket_L19
spatial_bucket_L20:
    jmp spatial_bucket_L18
spatial_bucket_L19:
    jmp spatial_bucket_L17
spatial_bucket_L17:
; S[T0] = 0
    lda #0
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta S0,x
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp spatial_bucket_L16
spatial_bucket_L18:
; VALID = 1
    lda #1
    sta VALID
; return
    rts
    jmp spatial_bucket_L8
spatial_bucket_L7:
spatial_bucket_L8:
; if INPUT_X >= 16:
    lda INPUT_X
    cmp #16
    bcs spatial_bucket_L24
spatial_bucket_L25:
    jmp spatial_bucket_L22
spatial_bucket_L24:
    jmp spatial_bucket_L21
spatial_bucket_L21:
; return
    rts
    jmp spatial_bucket_L23
spatial_bucket_L22:
spatial_bucket_L23:
; if INPUT_Y >= 16:
    lda INPUT_Y
    cmp #16
    bcs spatial_bucket_L29
spatial_bucket_L30:
    jmp spatial_bucket_L27
spatial_bucket_L29:
    jmp spatial_bucket_L26
spatial_bucket_L26:
; return
    rts
    jmp spatial_bucket_L28
spatial_bucket_L27:
spatial_bucket_L28:
; T0 = INPUT_X >> 3
    lda INPUT_X
    lsr
    lsr
    lsr
    sta T0
; T1 = INPUT_Y >> 3
    lda INPUT_Y
    lsr
    lsr
    lsr
    sta T1
; T1 = T1 << 1
    lda T1
    asl
    sta T1
; T0 = T0 + T1
    lda T0
    clc
    adc T1
    sta T0
; T1 = C[T0]
    ldx T0
    lda C0,x
    sta T1
; if T1 > 4:
    lda T1
    cmp #4
    beq spatial_bucket_L35
    bcs spatial_bucket_L34
spatial_bucket_L35:
    jmp spatial_bucket_L32
spatial_bucket_L34:
    jmp spatial_bucket_L31
spatial_bucket_L31:
; return
    rts
    jmp spatial_bucket_L33
spatial_bucket_L32:
spatial_bucket_L33:
; BUCKET = T0
    lda T0
    sta BUCKET
; COUNT = T1
    lda T1
    sta COUNT
; VALID = 1
    lda #1
    sta VALID
; if MODE == 1:
    lda MODE
    cmp #1
    beq spatial_bucket_L39
spatial_bucket_L40:
    jmp spatial_bucket_L37
spatial_bucket_L39:
    jmp spatial_bucket_L36
spatial_bucket_L36:
; if T1 < 4:
    lda T1
    cmp #4
    bcc spatial_bucket_L44
spatial_bucket_L45:
    jmp spatial_bucket_L42
spatial_bucket_L44:
    jmp spatial_bucket_L41
spatial_bucket_L41:
; T2 = T0 << 2
    lda T0
    asl
    asl
    sta T2
; T2 = T2 + T1
    lda T2
    clc
    adc T1
    sta T2
; S[T2] = ITEM
    lda ITEM
    sta EXPR_SAVE
    ldx T2
    lda EXPR_SAVE
    sta S0,x
; T1 = T1 + 1
    lda T1
    clc
    adc #1
    sta T1
; C[T0] = T1
    lda T1
    sta EXPR_SAVE
    ldx T0
    lda EXPR_SAVE
    sta C0,x
; COUNT = T1
    lda T1
    sta COUNT
; INSERTED = 1
    lda #1
    sta INSERTED
    jmp spatial_bucket_L43
spatial_bucket_L42:
spatial_bucket_L43:
    jmp spatial_bucket_L38
spatial_bucket_L37:
spatial_bucket_L38:
; if COUNT == 4:
    lda COUNT
    cmp #4
    beq spatial_bucket_L49
spatial_bucket_L50:
    jmp spatial_bucket_L47
spatial_bucket_L49:
    jmp spatial_bucket_L46
spatial_bucket_L46:
; FULL = 1
    lda #1
    sta FULL
    jmp spatial_bucket_L48
spatial_bucket_L47:
spatial_bucket_L48:
    rts
component_end:

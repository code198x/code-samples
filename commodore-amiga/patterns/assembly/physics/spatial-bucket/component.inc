; SPDX-License-Identifier: MIT
; Build Bounded Spatial Buckets. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
spatial_bucket_init:
    move.b #0,d0
    move.b d0,BUCKET
    move.b d0,COUNT
    move.b d0,INSERTED
    move.b d0,FULL
    move.b d0,VALID
    move.b d0,MODE
    move.b d0,INPUT_X
    move.b d0,INPUT_Y
    move.b d0,ITEM
    move.b d0,C0
    move.b d0,C1
    move.b d0,C2
    move.b d0,C3
    move.b d0,S0
    move.b d0,S1
    move.b d0,S2
    move.b d0,S3
    move.b d0,S4
    move.b d0,S5
    move.b d0,S6
    move.b d0,S7
    move.b d0,S8
    move.b d0,S9
    move.b d0,S10
    move.b d0,S11
    move.b d0,S12
    move.b d0,S13
    move.b d0,S14
    move.b d0,S15
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,EXPR_SAVE
    rts
spatial_bucket_step:
; BUCKET = 255
    move.b #255,d0
    move.b d0,BUCKET
; COUNT = 0
    move.b #0,d0
    move.b d0,COUNT
; INSERTED = 0
    move.b #0,d0
    move.b d0,INSERTED
; FULL = 0
    move.b #0,d0
    move.b d0,FULL
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MODE > 2:
    move.b MODE,d0
    cmp.b #2,d0
    bhi spatial_bucket_L1
    jmp spatial_bucket_L2
spatial_bucket_L1:
; return
    rts
    jmp spatial_bucket_L3
spatial_bucket_L2:
spatial_bucket_L3:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq spatial_bucket_L4
    jmp spatial_bucket_L5
spatial_bucket_L4:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < 4:
spatial_bucket_L7:
    move.b T0,d0
    cmp.b #4,d0
    bcs spatial_bucket_L8
    jmp spatial_bucket_L9
spatial_bucket_L8:
; C[T0] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp spatial_bucket_L7
spatial_bucket_L9:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < 16:
spatial_bucket_L10:
    move.b T0,d0
    cmp.b #16,d0
    bcs spatial_bucket_L11
    jmp spatial_bucket_L12
spatial_bucket_L11:
; S[T0] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea S0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp spatial_bucket_L10
spatial_bucket_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; return
    rts
    jmp spatial_bucket_L6
spatial_bucket_L5:
spatial_bucket_L6:
; if INPUT_X >= 16:
    move.b INPUT_X,d0
    cmp.b #16,d0
    bcc spatial_bucket_L13
    jmp spatial_bucket_L14
spatial_bucket_L13:
; return
    rts
    jmp spatial_bucket_L15
spatial_bucket_L14:
spatial_bucket_L15:
; if INPUT_Y >= 16:
    move.b INPUT_Y,d0
    cmp.b #16,d0
    bcc spatial_bucket_L16
    jmp spatial_bucket_L17
spatial_bucket_L16:
; return
    rts
    jmp spatial_bucket_L18
spatial_bucket_L17:
spatial_bucket_L18:
; T0 = INPUT_X >> 3
    move.b INPUT_X,d0
    lsr.b #3,d0
    move.b d0,T0
; T1 = INPUT_Y >> 3
    move.b INPUT_Y,d0
    lsr.b #3,d0
    move.b d0,T1
; T1 = T1 << 1
    move.b T1,d0
    lsl.b #1,d0
    move.b d0,T1
; T0 = T0 + T1
    move.b T0,d0
    move.b T1,d1
    add.b d1,d0
    move.b d0,T0
; T1 = C[T0]
    moveq #0,d1
    move.b T0,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if T1 > 4:
    move.b T1,d0
    cmp.b #4,d0
    bhi spatial_bucket_L19
    jmp spatial_bucket_L20
spatial_bucket_L19:
; return
    rts
    jmp spatial_bucket_L21
spatial_bucket_L20:
spatial_bucket_L21:
; BUCKET = T0
    move.b T0,d0
    move.b d0,BUCKET
; COUNT = T1
    move.b T1,d0
    move.b d0,COUNT
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if MODE == 1:
    move.b MODE,d0
    cmp.b #1,d0
    beq spatial_bucket_L22
    jmp spatial_bucket_L23
spatial_bucket_L22:
; if T1 < 4:
    move.b T1,d0
    cmp.b #4,d0
    bcs spatial_bucket_L25
    jmp spatial_bucket_L26
spatial_bucket_L25:
; T2 = T0 << 2
    move.b T0,d0
    lsl.b #2,d0
    move.b d0,T2
; T2 = T2 + T1
    move.b T2,d0
    move.b T1,d1
    add.b d1,d0
    move.b d0,T2
; S[T2] = ITEM
    move.b ITEM,d0
    move.b d0,d2
    moveq #0,d1
    move.b T2,d1
    lea S0,a0
    move.b d2,0(a0,d1.w)
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
; C[T0] = T1
    move.b T1,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea C0,a0
    move.b d2,0(a0,d1.w)
; COUNT = T1
    move.b T1,d0
    move.b d0,COUNT
; INSERTED = 1
    move.b #1,d0
    move.b d0,INSERTED
    jmp spatial_bucket_L27
spatial_bucket_L26:
spatial_bucket_L27:
    jmp spatial_bucket_L24
spatial_bucket_L23:
spatial_bucket_L24:
; if COUNT == 4:
    move.b COUNT,d0
    cmp.b #4,d0
    beq spatial_bucket_L28
    jmp spatial_bucket_L29
spatial_bucket_L28:
; FULL = 1
    move.b #1,d0
    move.b d0,FULL
    jmp spatial_bucket_L30
spatial_bucket_L29:
spatial_bucket_L30:
    rts
component_end:

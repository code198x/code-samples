; SPDX-License-Identifier: MIT
; Build Bounded Spatial Buckets. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
spatial_bucket_init:
    ld a,0
    ld (BUCKET),a
    ld (COUNT),a
    ld (INSERTED),a
    ld (FULL),a
    ld (VALID),a
    ld (MODE),a
    ld (INPUT_X),a
    ld (INPUT_Y),a
    ld (ITEM),a
    ld (C0),a
    ld (C1),a
    ld (C2),a
    ld (C3),a
    ld (S0),a
    ld (S1),a
    ld (S2),a
    ld (S3),a
    ld (S4),a
    ld (S5),a
    ld (S6),a
    ld (S7),a
    ld (S8),a
    ld (S9),a
    ld (S10),a
    ld (S11),a
    ld (S12),a
    ld (S13),a
    ld (S14),a
    ld (S15),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (EXPR_SAVE),a
    ret
spatial_bucket_step:
; BUCKET = 255
    ld a,255
    ld (BUCKET),a
; COUNT = 0
    ld a,0
    ld (COUNT),a
; INSERTED = 0
    ld a,0
    ld (INSERTED),a
; FULL = 0
    ld a,0
    ld (FULL),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MODE > 2:
    ld a,(MODE)
    cp 2
    jp z,spatial_bucket_L2
    jp nc,spatial_bucket_L1
    jp spatial_bucket_L2
spatial_bucket_L1:
; return
    ret
    jp spatial_bucket_L3
spatial_bucket_L2:
spatial_bucket_L3:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,spatial_bucket_L4
    jp spatial_bucket_L5
spatial_bucket_L4:
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < 4:
spatial_bucket_L7:
    ld a,(T0)
    cp 4
    jp c,spatial_bucket_L8
    jp spatial_bucket_L9
spatial_bucket_L8:
; C[T0] = 0
    ld a,0
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp spatial_bucket_L7
spatial_bucket_L9:
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < 16:
spatial_bucket_L10:
    ld a,(T0)
    cp 16
    jp c,spatial_bucket_L11
    jp spatial_bucket_L12
spatial_bucket_L11:
; S[T0] = 0
    ld a,0
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld (hl),c
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp spatial_bucket_L10
spatial_bucket_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; return
    ret
    jp spatial_bucket_L6
spatial_bucket_L5:
spatial_bucket_L6:
; if INPUT_X >= 16:
    ld a,(INPUT_X)
    cp 16
    jp nc,spatial_bucket_L13
    jp spatial_bucket_L14
spatial_bucket_L13:
; return
    ret
    jp spatial_bucket_L15
spatial_bucket_L14:
spatial_bucket_L15:
; if INPUT_Y >= 16:
    ld a,(INPUT_Y)
    cp 16
    jp nc,spatial_bucket_L16
    jp spatial_bucket_L17
spatial_bucket_L16:
; return
    ret
    jp spatial_bucket_L18
spatial_bucket_L17:
spatial_bucket_L18:
; T0 = INPUT_X >> 3
    ld a,(INPUT_X)
    srl a
    srl a
    srl a
    ld (T0),a
; T1 = INPUT_Y >> 3
    ld a,(INPUT_Y)
    srl a
    srl a
    srl a
    ld (T1),a
; T1 = T1 << 1
    ld a,(T1)
    sla a
    ld (T1),a
; T0 = T0 + T1
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
; T1 = C[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if T1 > 4:
    ld a,(T1)
    cp 4
    jp z,spatial_bucket_L20
    jp nc,spatial_bucket_L19
    jp spatial_bucket_L20
spatial_bucket_L19:
; return
    ret
    jp spatial_bucket_L21
spatial_bucket_L20:
spatial_bucket_L21:
; BUCKET = T0
    ld a,(T0)
    ld (BUCKET),a
; COUNT = T1
    ld a,(T1)
    ld (COUNT),a
; VALID = 1
    ld a,1
    ld (VALID),a
; if MODE == 1:
    ld a,(MODE)
    cp 1
    jp z,spatial_bucket_L22
    jp spatial_bucket_L23
spatial_bucket_L22:
; if T1 < 4:
    ld a,(T1)
    cp 4
    jp c,spatial_bucket_L25
    jp spatial_bucket_L26
spatial_bucket_L25:
; T2 = T0 << 2
    ld a,(T0)
    sla a
    sla a
    ld (T2),a
; T2 = T2 + T1
    ld a,(T2)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    add a,c
    ld (T2),a
; S[T2] = ITEM
    ld a,(ITEM)
    ld c,a
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld (hl),c
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
; C[T0] = T1
    ld a,(T1)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld (hl),c
; COUNT = T1
    ld a,(T1)
    ld (COUNT),a
; INSERTED = 1
    ld a,1
    ld (INSERTED),a
    jp spatial_bucket_L27
spatial_bucket_L26:
spatial_bucket_L27:
    jp spatial_bucket_L24
spatial_bucket_L23:
spatial_bucket_L24:
; if COUNT == 4:
    ld a,(COUNT)
    cp 4
    jp z,spatial_bucket_L28
    jp spatial_bucket_L29
spatial_bucket_L28:
; FULL = 1
    ld a,1
    ld (FULL),a
    jp spatial_bucket_L30
spatial_bucket_L29:
spatial_bucket_L30:
    ret
component_end:

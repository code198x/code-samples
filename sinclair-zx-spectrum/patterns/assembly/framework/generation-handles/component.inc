; SPDX-License-Identifier: MIT
; Reject Stale Object Handles. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
generation_handles_init:
    ld a,0
    ld (RESULT),a
    ld (OUT_SLOT),a
    ld (OUT_GENERATION),a
    ld (VALID),a
    ld (MODE),a
    ld (SLOT),a
    ld (GENERATION),a
    ld (ACTIVE),a
    ld (G0),a
    ld (G1),a
    ld (G2),a
    ld (G3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (EXPR_SAVE),a
    ret
generation_handles_step:
; RESULT = 0
    ld a,0
    ld (RESULT),a
; OUT_SLOT = 255
    ld a,255
    ld (OUT_SLOT),a
; OUT_GENERATION = 0
    ld a,0
    ld (OUT_GENERATION),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if ACTIVE > 15:
    ld a,(ACTIVE)
    cp 15
    jp z,generation_handles_L2
    jp nc,generation_handles_L1
    jp generation_handles_L2
generation_handles_L1:
; return
    ret
    jp generation_handles_L3
generation_handles_L2:
generation_handles_L3:
; if MODE >= 3:
    ld a,(MODE)
    cp 3
    jp nc,generation_handles_L4
    jp generation_handles_L5
generation_handles_L4:
; return
    ret
    jp generation_handles_L6
generation_handles_L5:
generation_handles_L6:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,generation_handles_L7
    jp generation_handles_L8
generation_handles_L7:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; T1 = 1
    ld a,1
    ld (T1),a
; while T0 < 4:
generation_handles_L10:
    ld a,(T0)
    cp 4
    jp c,generation_handles_L11
    jp generation_handles_L12
generation_handles_L11:
; T2 = ACTIVE & T1
    ld a,(ACTIVE)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    and c
    ld (T2),a
; if T2 == 0:
    ld a,(T2)
    cp 0
    jp z,generation_handles_L13
    jp generation_handles_L14
generation_handles_L13:
; T2 = G[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,G0
    add hl,de
    ld a,(hl)
    ld (T2),a
; T2 = T2 + 1
    ld a,(T2)
    add a,1
    ld (T2),a
; G[T0] = T2
    ld a,(T2)
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,G0
    add hl,de
    ld (hl),c
; ACTIVE = ACTIVE | T1
    ld a,(ACTIVE)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    or c
    ld (ACTIVE),a
; OUT_SLOT = T0
    ld a,(T0)
    ld (OUT_SLOT),a
; OUT_GENERATION = T2
    ld a,(T2)
    ld (OUT_GENERATION),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
; return
    ret
    jp generation_handles_L15
generation_handles_L14:
generation_handles_L15:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
; T1 = T1 << 1
    ld a,(T1)
    sla a
    ld (T1),a
    jp generation_handles_L10
generation_handles_L12:
; return
    ret
    jp generation_handles_L9
generation_handles_L8:
generation_handles_L9:
; if SLOT >= 4:
    ld a,(SLOT)
    cp 4
    jp nc,generation_handles_L16
    jp generation_handles_L17
generation_handles_L16:
; return
    ret
    jp generation_handles_L18
generation_handles_L17:
generation_handles_L18:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 1
    ld a,1
    ld (T0),a
; T1 = SLOT
    ld a,(SLOT)
    ld (T1),a
; while T1 != 0:
generation_handles_L19:
    ld a,(T1)
    cp 0
    jp nz,generation_handles_L20
    jp generation_handles_L21
generation_handles_L20:
; T0 = T0 << 1
    ld a,(T0)
    sla a
    ld (T0),a
; T1 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T1),a
    jp generation_handles_L19
generation_handles_L21:
; T1 = ACTIVE & T0
    ld a,(ACTIVE)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    and c
    ld (T1),a
; if T1 == 0:
    ld a,(T1)
    cp 0
    jp z,generation_handles_L22
    jp generation_handles_L23
generation_handles_L22:
; return
    ret
    jp generation_handles_L24
generation_handles_L23:
generation_handles_L24:
; T1 = G[SLOT]
    ld a,(SLOT)
    ld e,a
    ld d,0
    ld hl,G0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if T1 != GENERATION:
    ld a,(T1)
    ld b,a
    ld a,(GENERATION)
    ld c,a
    ld a,b
    cp c
    jp nz,generation_handles_L25
    jp generation_handles_L26
generation_handles_L25:
; return
    ret
    jp generation_handles_L27
generation_handles_L26:
generation_handles_L27:
; OUT_SLOT = SLOT
    ld a,(SLOT)
    ld (OUT_SLOT),a
; OUT_GENERATION = T1
    ld a,(T1)
    ld (OUT_GENERATION),a
; RESULT = 1
    ld a,1
    ld (RESULT),a
; if MODE == 1:
    ld a,(MODE)
    cp 1
    jp z,generation_handles_L28
    jp generation_handles_L29
generation_handles_L28:
; T0 = T0 ^ 255
    ld a,(T0)
    xor 255
    ld (T0),a
; ACTIVE = ACTIVE & T0
    ld a,(ACTIVE)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    and c
    ld (ACTIVE),a
    jp generation_handles_L30
generation_handles_L29:
generation_handles_L30:
    ret
component_end:

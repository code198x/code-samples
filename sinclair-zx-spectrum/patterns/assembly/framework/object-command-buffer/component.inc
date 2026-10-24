; SPDX-License-Identifier: MIT
; Defer Object Changes Until After Traversal. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
object_command_buffer_init:
    ld a,0
    ld (APPLIED),a
    ld (REJECTED),a
    ld (FULL),a
    ld (VALID),a
    ld (MODE),a
    ld (SLOT),a
    ld (GENERATION),a
    ld (ACTIVE),a
    ld (COUNT),a
    ld (G0),a
    ld (G1),a
    ld (G2),a
    ld (G3),a
    ld (O0),a
    ld (O1),a
    ld (O2),a
    ld (O3),a
    ld (S0),a
    ld (S1),a
    ld (S2),a
    ld (S3),a
    ld (H0),a
    ld (H1),a
    ld (H2),a
    ld (H3),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (EXPR_SAVE),a
    ret
object_command_buffer_step:
; APPLIED = 0
    ld a,0
    ld (APPLIED),a
; REJECTED = 0
    ld a,0
    ld (REJECTED),a
; FULL = 0
    ld a,0
    ld (FULL),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if ACTIVE >= 16:
    ld a,(ACTIVE)
    cp 16
    jp nc,object_command_buffer_L1
    jp object_command_buffer_L2
object_command_buffer_L1:
; return
    ret
    jp object_command_buffer_L3
object_command_buffer_L2:
object_command_buffer_L3:
; if COUNT > 4:
    ld a,(COUNT)
    cp 4
    jp z,object_command_buffer_L5
    jp nc,object_command_buffer_L4
    jp object_command_buffer_L5
object_command_buffer_L4:
; return
    ret
    jp object_command_buffer_L6
object_command_buffer_L5:
object_command_buffer_L6:
; if MODE > 3:
    ld a,(MODE)
    cp 3
    jp z,object_command_buffer_L8
    jp nc,object_command_buffer_L7
    jp object_command_buffer_L8
object_command_buffer_L7:
; return
    ret
    jp object_command_buffer_L9
object_command_buffer_L8:
object_command_buffer_L9:
; if MODE == 0:
    ld a,(MODE)
    cp 0
    jp z,object_command_buffer_L10
    jp object_command_buffer_L11
object_command_buffer_L10:
; COUNT = 0
    ld a,0
    ld (COUNT),a
; VALID = 1
    ld a,1
    ld (VALID),a
; return
    ret
    jp object_command_buffer_L12
object_command_buffer_L11:
object_command_buffer_L12:
; if MODE < 3:
    ld a,(MODE)
    cp 3
    jp c,object_command_buffer_L13
    jp object_command_buffer_L14
object_command_buffer_L13:
; if SLOT >= 4:
    ld a,(SLOT)
    cp 4
    jp nc,object_command_buffer_L16
    jp object_command_buffer_L17
object_command_buffer_L16:
; return
    ret
    jp object_command_buffer_L18
object_command_buffer_L17:
object_command_buffer_L18:
; VALID = 1
    ld a,1
    ld (VALID),a
; if COUNT == 4:
    ld a,(COUNT)
    cp 4
    jp z,object_command_buffer_L19
    jp object_command_buffer_L20
object_command_buffer_L19:
; FULL = 1
    ld a,1
    ld (FULL),a
; return
    ret
    jp object_command_buffer_L21
object_command_buffer_L20:
object_command_buffer_L21:
; O[COUNT] = MODE
    ld a,(MODE)
    ld c,a
    ld a,(COUNT)
    ld e,a
    ld d,0
    ld hl,O0
    add hl,de
    ld (hl),c
; S[COUNT] = SLOT
    ld a,(SLOT)
    ld c,a
    ld a,(COUNT)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld (hl),c
; H[COUNT] = GENERATION
    ld a,(GENERATION)
    ld c,a
    ld a,(COUNT)
    ld e,a
    ld d,0
    ld hl,H0
    add hl,de
    ld (hl),c
; COUNT = COUNT + 1
    ld a,(COUNT)
    add a,1
    ld (COUNT),a
; return
    ret
    jp object_command_buffer_L15
object_command_buffer_L14:
object_command_buffer_L15:
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < COUNT:
object_command_buffer_L22:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,object_command_buffer_L23
    jp object_command_buffer_L24
object_command_buffer_L23:
; T1 = O[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,O0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if T1 == 0:
    ld a,(T1)
    cp 0
    jp z,object_command_buffer_L25
    jp object_command_buffer_L26
object_command_buffer_L25:
; return
    ret
    jp object_command_buffer_L27
object_command_buffer_L26:
object_command_buffer_L27:
; if T1 > 2:
    ld a,(T1)
    cp 2
    jp z,object_command_buffer_L29
    jp nc,object_command_buffer_L28
    jp object_command_buffer_L29
object_command_buffer_L28:
; return
    ret
    jp object_command_buffer_L30
object_command_buffer_L29:
object_command_buffer_L30:
; T1 = S[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if T1 >= 4:
    ld a,(T1)
    cp 4
    jp nc,object_command_buffer_L31
    jp object_command_buffer_L32
object_command_buffer_L31:
; return
    ret
    jp object_command_buffer_L33
object_command_buffer_L32:
object_command_buffer_L33:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp object_command_buffer_L22
object_command_buffer_L24:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < COUNT:
object_command_buffer_L34:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,object_command_buffer_L35
    jp object_command_buffer_L36
object_command_buffer_L35:
; T1 = S[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,S0
    add hl,de
    ld a,(hl)
    ld (T1),a
; T2 = 1
    ld a,1
    ld (T2),a
; T3 = T1
    ld a,(T1)
    ld (T3),a
; while T3 != 0:
object_command_buffer_L37:
    ld a,(T3)
    cp 0
    jp nz,object_command_buffer_L38
    jp object_command_buffer_L39
object_command_buffer_L38:
; T2 = T2 << 1
    ld a,(T2)
    sla a
    ld (T2),a
; T3 = T3 - 1
    ld a,(T3)
    sub 1
    ld (T3),a
    jp object_command_buffer_L37
object_command_buffer_L39:
; T3 = ACTIVE & T2
    ld a,(ACTIVE)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    and c
    ld (T3),a
; T4 = O[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,O0
    add hl,de
    ld a,(hl)
    ld (T4),a
; T5 = 0
    ld a,0
    ld (T5),a
; if T4 == 1:
    ld a,(T4)
    cp 1
    jp z,object_command_buffer_L40
    jp object_command_buffer_L41
object_command_buffer_L40:
; if T3 == 0:
    ld a,(T3)
    cp 0
    jp z,object_command_buffer_L43
    jp object_command_buffer_L44
object_command_buffer_L43:
; ACTIVE = ACTIVE | T2
    ld a,(ACTIVE)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    or c
    ld (ACTIVE),a
; T4 = G[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,G0
    add hl,de
    ld a,(hl)
    ld (T4),a
; T4 = T4 + 1
    ld a,(T4)
    add a,1
    ld (T4),a
; G[T1] = T4
    ld a,(T4)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,G0
    add hl,de
    ld (hl),c
; T5 = 1
    ld a,1
    ld (T5),a
    jp object_command_buffer_L45
object_command_buffer_L44:
object_command_buffer_L45:
    jp object_command_buffer_L42
object_command_buffer_L41:
; if T3 != 0:
    ld a,(T3)
    cp 0
    jp nz,object_command_buffer_L46
    jp object_command_buffer_L47
object_command_buffer_L46:
; T4 = G[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,G0
    add hl,de
    ld a,(hl)
    ld (T4),a
; T6 = H[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,H0
    add hl,de
    ld a,(hl)
    ld (T6),a
; if T4 == T6:
    ld a,(T4)
    ld b,a
    ld a,(T6)
    ld c,a
    ld a,b
    cp c
    jp z,object_command_buffer_L49
    jp object_command_buffer_L50
object_command_buffer_L49:
; ACTIVE = ACTIVE ^ T2
    ld a,(ACTIVE)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    xor c
    ld (ACTIVE),a
; T5 = 1
    ld a,1
    ld (T5),a
    jp object_command_buffer_L51
object_command_buffer_L50:
object_command_buffer_L51:
    jp object_command_buffer_L48
object_command_buffer_L47:
object_command_buffer_L48:
object_command_buffer_L42:
; if T5 != 0:
    ld a,(T5)
    cp 0
    jp nz,object_command_buffer_L52
    jp object_command_buffer_L53
object_command_buffer_L52:
; APPLIED = APPLIED + 1
    ld a,(APPLIED)
    add a,1
    ld (APPLIED),a
    jp object_command_buffer_L54
object_command_buffer_L53:
; REJECTED = REJECTED + 1
    ld a,(REJECTED)
    add a,1
    ld (REJECTED),a
object_command_buffer_L54:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp object_command_buffer_L34
object_command_buffer_L36:
; COUNT = 0
    ld a,0
    ld (COUNT),a
    ret
component_end:

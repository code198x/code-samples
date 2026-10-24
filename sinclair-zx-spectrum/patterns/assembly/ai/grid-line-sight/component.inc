; SPDX-License-Identifier: MIT
; Trace a Thin Grid Line of Sight. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
grid_line_sight_init:
    ld a,0
    ld (VISIBLE),a
    ld (VALID),a
    ld (FROM),a
    ld (TO),a
    ld (C0),a
    ld (C1),a
    ld (C2),a
    ld (C3),a
    ld (C4),a
    ld (C5),a
    ld (C6),a
    ld (C7),a
    ld (C8),a
    ld (C9),a
    ld (C10),a
    ld (C11),a
    ld (C12),a
    ld (C13),a
    ld (C14),a
    ld (C15),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ld (T4),a
    ld (T5),a
    ld (T6),a
    ld (T7),a
    ld (T8),a
    ld (T9),a
    ld (T10),a
    ld (T11),a
    ret
grid_line_sight_step:
; VISIBLE = 0
    ld a,0
    ld (VISIBLE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if FROM >= 16:
    ld a,(FROM)
    cp 16
    jp nc,grid_line_sight_L1
    jp grid_line_sight_L2
grid_line_sight_L1:
; return
    ret
    jp grid_line_sight_L3
grid_line_sight_L2:
grid_line_sight_L3:
; if TO >= 16:
    ld a,(TO)
    cp 16
    jp nc,grid_line_sight_L4
    jp grid_line_sight_L5
grid_line_sight_L4:
; return
    ret
    jp grid_line_sight_L6
grid_line_sight_L5:
grid_line_sight_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = FROM & 3
    ld a,(FROM)
    and 3
    ld (T0),a
; T1 = FROM >> 2
    ld a,(FROM)
    srl a
    srl a
    ld (T1),a
; T2 = TO & 3
    ld a,(TO)
    and 3
    ld (T2),a
; T3 = TO >> 2
    ld a,(TO)
    srl a
    srl a
    ld (T3),a
; T6 = 1
    ld a,1
    ld (T6),a
; if T2 >= T0:
    ld a,(T2)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp nc,grid_line_sight_L7
    jp grid_line_sight_L8
grid_line_sight_L7:
; T4 = T2 - T0
    ld a,(T2)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T4),a
    jp grid_line_sight_L9
grid_line_sight_L8:
; T4 = T0 - T2
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    sub c
    ld (T4),a
; T6 = 255
    ld a,255
    ld (T6),a
grid_line_sight_L9:
; T7 = 1
    ld a,1
    ld (T7),a
; if T3 >= T1:
    ld a,(T3)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp nc,grid_line_sight_L10
    jp grid_line_sight_L11
grid_line_sight_L10:
; T5 = T3 - T1
    ld a,(T3)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    sub c
    ld (T5),a
    jp grid_line_sight_L12
grid_line_sight_L11:
; T5 = T1 - T3
    ld a,(T1)
    ld b,a
    ld a,(T3)
    ld c,a
    ld a,b
    sub c
    ld (T5),a
; T7 = 255
    ld a,255
    ld (T7),a
grid_line_sight_L12:
; T8 = 128 + T4
    ld a,128
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T8),a
; T8 = T8 - T5
    ld a,(T8)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    sub c
    ld (T8),a
; T9 = FROM
    ld a,(FROM)
    ld (T9),a
; while T9 != TO:
grid_line_sight_L13:
    ld a,(T9)
    ld b,a
    ld a,(TO)
    ld c,a
    ld a,b
    cp c
    jp nz,grid_line_sight_L14
    jp grid_line_sight_L15
grid_line_sight_L14:
; T10 = T8 - 128
    ld a,(T8)
    sub 128
    ld (T10),a
; T10 = T10 << 1
    ld a,(T10)
    sla a
    ld (T10),a
; T10 = T10 + 128
    ld a,(T10)
    add a,128
    ld (T10),a
; T11 = 128 - T5
    ld a,128
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    sub c
    ld (T11),a
; if T10 > T11:
    ld a,(T10)
    ld b,a
    ld a,(T11)
    ld c,a
    ld a,b
    cp c
    jp z,grid_line_sight_L17
    jp nc,grid_line_sight_L16
    jp grid_line_sight_L17
grid_line_sight_L16:
; T8 = T8 - T5
    ld a,(T8)
    ld b,a
    ld a,(T5)
    ld c,a
    ld a,b
    sub c
    ld (T8),a
; T0 = T0 + T6
    ld a,(T0)
    ld b,a
    ld a,(T6)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
    jp grid_line_sight_L18
grid_line_sight_L17:
grid_line_sight_L18:
; T11 = 128 + T4
    ld a,128
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T11),a
; if T10 < T11:
    ld a,(T10)
    ld b,a
    ld a,(T11)
    ld c,a
    ld a,b
    cp c
    jp c,grid_line_sight_L19
    jp grid_line_sight_L20
grid_line_sight_L19:
; T8 = T8 + T4
    ld a,(T8)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    add a,c
    ld (T8),a
; T1 = T1 + T7
    ld a,(T1)
    ld b,a
    ld a,(T7)
    ld c,a
    ld a,b
    add a,c
    ld (T1),a
    jp grid_line_sight_L21
grid_line_sight_L20:
grid_line_sight_L21:
; T9 = T1 << 2
    ld a,(T1)
    sla a
    sla a
    ld (T9),a
; T9 = T9 + T0
    ld a,(T9)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    add a,c
    ld (T9),a
; T11 = C[T9]
    ld a,(T9)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T11),a
; if T11 != 0:
    ld a,(T11)
    cp 0
    jp nz,grid_line_sight_L22
    jp grid_line_sight_L23
grid_line_sight_L22:
; return
    ret
    jp grid_line_sight_L24
grid_line_sight_L23:
grid_line_sight_L24:
    jp grid_line_sight_L13
grid_line_sight_L15:
; VISIBLE = 1
    ld a,1
    ld (VISIBLE),a
    ret
component_end:

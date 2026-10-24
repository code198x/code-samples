; SPDX-License-Identifier: MIT
; Test Sight Along a Grid Row or Column. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
cardinal_sight_init:
    ld a,0
    ld (FROM),a
    ld (TO),a
    ld (VISIBLE),a
    ld (VALID),a
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
    ret
cardinal_sight_step:
; VISIBLE = 0
    ld a,0
    ld (VISIBLE),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if FROM >= 16:
    ld a,(FROM)
    cp 16
    jp nc,cardinal_sight_L1
    jp cardinal_sight_L2
cardinal_sight_L1:
; return
    ret
    jp cardinal_sight_L3
cardinal_sight_L2:
cardinal_sight_L3:
; if TO >= 16:
    ld a,(TO)
    cp 16
    jp nc,cardinal_sight_L4
    jp cardinal_sight_L5
cardinal_sight_L4:
; return
    ret
    jp cardinal_sight_L6
cardinal_sight_L5:
cardinal_sight_L6:
; if FROM == TO:
    ld a,(FROM)
    ld b,a
    ld a,(TO)
    ld c,a
    ld a,b
    cp c
    jp z,cardinal_sight_L7
    jp cardinal_sight_L8
cardinal_sight_L7:
; VALID = 1
    ld a,1
    ld (VALID),a
; VISIBLE = 1
    ld a,1
    ld (VISIBLE),a
; return
    ret
    jp cardinal_sight_L9
cardinal_sight_L8:
cardinal_sight_L9:
; T0 = FROM >> 2
    ld a,(FROM)
    srl a
    srl a
    ld (T0),a
; T1 = TO >> 2
    ld a,(TO)
    srl a
    srl a
    ld (T1),a
; T2 = 1
    ld a,1
    ld (T2),a
; if T0 != T1:
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp nz,cardinal_sight_L10
    jp cardinal_sight_L11
cardinal_sight_L10:
; T0 = FROM & 3
    ld a,(FROM)
    and 3
    ld (T0),a
; T1 = TO & 3
    ld a,(TO)
    and 3
    ld (T1),a
; if T0 != T1:
    ld a,(T0)
    ld b,a
    ld a,(T1)
    ld c,a
    ld a,b
    cp c
    jp nz,cardinal_sight_L13
    jp cardinal_sight_L14
cardinal_sight_L13:
; return
    ret
    jp cardinal_sight_L15
cardinal_sight_L14:
cardinal_sight_L15:
; T2 = 4
    ld a,4
    ld (T2),a
    jp cardinal_sight_L12
cardinal_sight_L11:
cardinal_sight_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = FROM
    ld a,(FROM)
    ld (T0),a
; while T0 != TO:
cardinal_sight_L16:
    ld a,(T0)
    ld b,a
    ld a,(TO)
    ld c,a
    ld a,b
    cp c
    jp nz,cardinal_sight_L17
    jp cardinal_sight_L18
cardinal_sight_L17:
; if T0 < TO:
    ld a,(T0)
    ld b,a
    ld a,(TO)
    ld c,a
    ld a,b
    cp c
    jp c,cardinal_sight_L19
    jp cardinal_sight_L20
cardinal_sight_L19:
; T0 = T0 + T2
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
    jp cardinal_sight_L21
cardinal_sight_L20:
; T0 = T0 - T2
    ld a,(T0)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
cardinal_sight_L21:
; T1 = C[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T1),a
; if T1 != 0:
    ld a,(T1)
    cp 0
    jp nz,cardinal_sight_L22
    jp cardinal_sight_L23
cardinal_sight_L22:
; return
    ret
    jp cardinal_sight_L24
cardinal_sight_L23:
cardinal_sight_L24:
    jp cardinal_sight_L16
cardinal_sight_L18:
; VISIBLE = 1
    ld a,1
    ld (VISIBLE),a
    ret
component_end:

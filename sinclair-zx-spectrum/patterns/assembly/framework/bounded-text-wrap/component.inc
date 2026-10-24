; SPDX-License-Identifier: MIT
; Choose a Bounded Text Line. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_text_wrap_init:
    ld a,0
    ld (LENGTH),a
    ld (NEXT),a
    ld (VALID),a
    ld (START),a
    ld (WIDTH),a
    ld (COUNT),a
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
    ret
bounded_text_wrap_step:
; LENGTH = 0
    ld a,0
    ld (LENGTH),a
; NEXT = START
    ld a,(START)
    ld (NEXT),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if COUNT > 16:
    ld a,(COUNT)
    cp 16
    jp z,bounded_text_wrap_L2
    jp nc,bounded_text_wrap_L1
    jp bounded_text_wrap_L2
bounded_text_wrap_L1:
; return
    ret
    jp bounded_text_wrap_L3
bounded_text_wrap_L2:
bounded_text_wrap_L3:
; if START > COUNT:
    ld a,(START)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_text_wrap_L5
    jp nc,bounded_text_wrap_L4
    jp bounded_text_wrap_L5
bounded_text_wrap_L4:
; return
    ret
    jp bounded_text_wrap_L6
bounded_text_wrap_L5:
bounded_text_wrap_L6:
; if WIDTH == 0:
    ld a,(WIDTH)
    cp 0
    jp z,bounded_text_wrap_L7
    jp bounded_text_wrap_L8
bounded_text_wrap_L7:
; return
    ret
    jp bounded_text_wrap_L9
bounded_text_wrap_L8:
bounded_text_wrap_L9:
; if WIDTH > 16:
    ld a,(WIDTH)
    cp 16
    jp z,bounded_text_wrap_L11
    jp nc,bounded_text_wrap_L10
    jp bounded_text_wrap_L11
bounded_text_wrap_L10:
; return
    ret
    jp bounded_text_wrap_L12
bounded_text_wrap_L11:
bounded_text_wrap_L12:
; VALID = 1
    ld a,1
    ld (VALID),a
; while START < COUNT:
bounded_text_wrap_L13:
    ld a,(START)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_text_wrap_L14
    jp bounded_text_wrap_L15
bounded_text_wrap_L14:
; T0 = C[START]
    ld a,(START)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if T0 != 32:
    ld a,(T0)
    cp 32
    jp nz,bounded_text_wrap_L16
    jp bounded_text_wrap_L17
bounded_text_wrap_L16:
; break
    jp bounded_text_wrap_L15
    jp bounded_text_wrap_L18
bounded_text_wrap_L17:
bounded_text_wrap_L18:
; START = START + 1
    ld a,(START)
    add a,1
    ld (START),a
    jp bounded_text_wrap_L13
bounded_text_wrap_L15:
; NEXT = START
    ld a,(START)
    ld (NEXT),a
; T0 = START
    ld a,(START)
    ld (T0),a
; T1 = 255
    ld a,255
    ld (T1),a
; while T0 < COUNT:
bounded_text_wrap_L19:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_text_wrap_L20
    jp bounded_text_wrap_L21
bounded_text_wrap_L20:
; T2 = T0 - START
    ld a,(T0)
    ld b,a
    ld a,(START)
    ld c,a
    ld a,b
    sub c
    ld (T2),a
; if T2 == WIDTH:
    ld a,(T2)
    ld b,a
    ld a,(WIDTH)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_text_wrap_L22
    jp bounded_text_wrap_L23
bounded_text_wrap_L22:
; break
    jp bounded_text_wrap_L21
    jp bounded_text_wrap_L24
bounded_text_wrap_L23:
bounded_text_wrap_L24:
; T2 = C[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T2),a
; if T2 == 32:
    ld a,(T2)
    cp 32
    jp z,bounded_text_wrap_L25
    jp bounded_text_wrap_L26
bounded_text_wrap_L25:
; T1 = T0
    ld a,(T0)
    ld (T1),a
    jp bounded_text_wrap_L27
bounded_text_wrap_L26:
bounded_text_wrap_L27:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp bounded_text_wrap_L19
bounded_text_wrap_L21:
; T2 = T0
    ld a,(T0)
    ld (T2),a
; if T0 < COUNT:
    ld a,(T0)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_text_wrap_L28
    jp bounded_text_wrap_L29
bounded_text_wrap_L28:
; T3 = C[T0]
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 != 32:
    ld a,(T3)
    cp 32
    jp nz,bounded_text_wrap_L31
    jp bounded_text_wrap_L32
bounded_text_wrap_L31:
; if T1 != 255:
    ld a,(T1)
    cp 255
    jp nz,bounded_text_wrap_L34
    jp bounded_text_wrap_L35
bounded_text_wrap_L34:
; T2 = T1
    ld a,(T1)
    ld (T2),a
    jp bounded_text_wrap_L36
bounded_text_wrap_L35:
bounded_text_wrap_L36:
    jp bounded_text_wrap_L33
bounded_text_wrap_L32:
bounded_text_wrap_L33:
    jp bounded_text_wrap_L30
bounded_text_wrap_L29:
bounded_text_wrap_L30:
; LENGTH = T2 - START
    ld a,(T2)
    ld b,a
    ld a,(START)
    ld c,a
    ld a,b
    sub c
    ld (LENGTH),a
; NEXT = T2
    ld a,(T2)
    ld (NEXT),a
; while NEXT < COUNT:
bounded_text_wrap_L37:
    ld a,(NEXT)
    ld b,a
    ld a,(COUNT)
    ld c,a
    ld a,b
    cp c
    jp c,bounded_text_wrap_L38
    jp bounded_text_wrap_L39
bounded_text_wrap_L38:
; T3 = C[NEXT]
    ld a,(NEXT)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 != 32:
    ld a,(T3)
    cp 32
    jp nz,bounded_text_wrap_L40
    jp bounded_text_wrap_L41
bounded_text_wrap_L40:
; break
    jp bounded_text_wrap_L39
    jp bounded_text_wrap_L42
bounded_text_wrap_L41:
bounded_text_wrap_L42:
; NEXT = NEXT + 1
    ld a,(NEXT)
    add a,1
    ld (NEXT),a
    jp bounded_text_wrap_L37
bounded_text_wrap_L39:
    ret
component_end:

; SPDX-License-Identifier: MIT
; Push an Actor with a Moving Solid. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
moving_solid_push_init:
    ld a,0
    ld (POSITION),a
    ld (PUSHED),a
    ld (BLOCKED),a
    ld (VALID),a
    ld (ACTOR_POSITION),a
    ld (ACTOR_SIZE),a
    ld (SOLID_OLD),a
    ld (SOLID_NEW),a
    ld (SOLID_SIZE),a
    ld (MINIMUM),a
    ld (MAXIMUM),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ld (T3),a
    ret
moving_solid_push_step:
; POSITION = ACTOR_POSITION
    ld a,(ACTOR_POSITION)
    ld (POSITION),a
; PUSHED = 0
    ld a,0
    ld (PUSHED),a
; BLOCKED = 0
    ld a,0
    ld (BLOCKED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if ACTOR_SIZE == 0:
    ld a,(ACTOR_SIZE)
    cp 0
    jp z,moving_solid_push_L1
    jp moving_solid_push_L2
moving_solid_push_L1:
; return
    ret
    jp moving_solid_push_L3
moving_solid_push_L2:
moving_solid_push_L3:
; if SOLID_SIZE == 0:
    ld a,(SOLID_SIZE)
    cp 0
    jp z,moving_solid_push_L4
    jp moving_solid_push_L5
moving_solid_push_L4:
; return
    ret
    jp moving_solid_push_L6
moving_solid_push_L5:
moving_solid_push_L6:
; if MINIMUM > MAXIMUM:
    ld a,(MINIMUM)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,moving_solid_push_L8
    jp nc,moving_solid_push_L7
    jp moving_solid_push_L8
moving_solid_push_L7:
; return
    ret
    jp moving_solid_push_L9
moving_solid_push_L8:
moving_solid_push_L9:
; if ACTOR_POSITION < MINIMUM:
    ld a,(ACTOR_POSITION)
    ld b,a
    ld a,(MINIMUM)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L10
    jp moving_solid_push_L11
moving_solid_push_L10:
; return
    ret
    jp moving_solid_push_L12
moving_solid_push_L11:
moving_solid_push_L12:
; if ACTOR_POSITION > MAXIMUM:
    ld a,(ACTOR_POSITION)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,moving_solid_push_L14
    jp nc,moving_solid_push_L13
    jp moving_solid_push_L14
moving_solid_push_L13:
; return
    ret
    jp moving_solid_push_L15
moving_solid_push_L14:
moving_solid_push_L15:
; T0 = ACTOR_POSITION + ACTOR_SIZE
    ld a,(ACTOR_POSITION)
    ld b,a
    ld a,(ACTOR_SIZE)
    ld c,a
    ld a,b
    add a,c
    ld (T0),a
; if T0 < ACTOR_POSITION:
    ld a,(T0)
    ld b,a
    ld a,(ACTOR_POSITION)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L16
    jp moving_solid_push_L17
moving_solid_push_L16:
; return
    ret
    jp moving_solid_push_L18
moving_solid_push_L17:
moving_solid_push_L18:
; T1 = SOLID_OLD + SOLID_SIZE
    ld a,(SOLID_OLD)
    ld b,a
    ld a,(SOLID_SIZE)
    ld c,a
    ld a,b
    add a,c
    ld (T1),a
; if T1 < SOLID_OLD:
    ld a,(T1)
    ld b,a
    ld a,(SOLID_OLD)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L19
    jp moving_solid_push_L20
moving_solid_push_L19:
; return
    ret
    jp moving_solid_push_L21
moving_solid_push_L20:
moving_solid_push_L21:
; T2 = SOLID_NEW + SOLID_SIZE
    ld a,(SOLID_NEW)
    ld b,a
    ld a,(SOLID_SIZE)
    ld c,a
    ld a,b
    add a,c
    ld (T2),a
; if T2 < SOLID_NEW:
    ld a,(T2)
    ld b,a
    ld a,(SOLID_NEW)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L22
    jp moving_solid_push_L23
moving_solid_push_L22:
; return
    ret
    jp moving_solid_push_L24
moving_solid_push_L23:
moving_solid_push_L24:
; if SOLID_OLD < T0:
    ld a,(SOLID_OLD)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L25
    jp moving_solid_push_L26
moving_solid_push_L25:
; if T1 > ACTOR_POSITION:
    ld a,(T1)
    ld b,a
    ld a,(ACTOR_POSITION)
    ld c,a
    ld a,b
    cp c
    jp z,moving_solid_push_L29
    jp nc,moving_solid_push_L28
    jp moving_solid_push_L29
moving_solid_push_L28:
; return
    ret
    jp moving_solid_push_L30
moving_solid_push_L29:
moving_solid_push_L30:
    jp moving_solid_push_L27
moving_solid_push_L26:
moving_solid_push_L27:
; VALID = 1
    ld a,1
    ld (VALID),a
; if SOLID_NEW > SOLID_OLD:
    ld a,(SOLID_NEW)
    ld b,a
    ld a,(SOLID_OLD)
    ld c,a
    ld a,b
    cp c
    jp z,moving_solid_push_L32
    jp nc,moving_solid_push_L31
    jp moving_solid_push_L32
moving_solid_push_L31:
; if T1 <= ACTOR_POSITION:
    ld a,(T1)
    ld b,a
    ld a,(ACTOR_POSITION)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L34
    jp z,moving_solid_push_L34
    jp moving_solid_push_L35
moving_solid_push_L34:
; if T2 > ACTOR_POSITION:
    ld a,(T2)
    ld b,a
    ld a,(ACTOR_POSITION)
    ld c,a
    ld a,b
    cp c
    jp z,moving_solid_push_L38
    jp nc,moving_solid_push_L37
    jp moving_solid_push_L38
moving_solid_push_L37:
; if T2 > MAXIMUM:
    ld a,(T2)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,moving_solid_push_L41
    jp nc,moving_solid_push_L40
    jp moving_solid_push_L41
moving_solid_push_L40:
; BLOCKED = 1
    ld a,1
    ld (BLOCKED),a
; return
    ret
    jp moving_solid_push_L42
moving_solid_push_L41:
moving_solid_push_L42:
; T3 = T2 + ACTOR_SIZE
    ld a,(T2)
    ld b,a
    ld a,(ACTOR_SIZE)
    ld c,a
    ld a,b
    add a,c
    ld (T3),a
; if T3 < T2:
    ld a,(T3)
    ld b,a
    ld a,(T2)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L43
    jp moving_solid_push_L44
moving_solid_push_L43:
; BLOCKED = 1
    ld a,1
    ld (BLOCKED),a
; return
    ret
    jp moving_solid_push_L45
moving_solid_push_L44:
moving_solid_push_L45:
; POSITION = T2
    ld a,(T2)
    ld (POSITION),a
; PUSHED = 1
    ld a,1
    ld (PUSHED),a
    jp moving_solid_push_L39
moving_solid_push_L38:
moving_solid_push_L39:
    jp moving_solid_push_L36
moving_solid_push_L35:
moving_solid_push_L36:
    jp moving_solid_push_L33
moving_solid_push_L32:
moving_solid_push_L33:
; if SOLID_NEW < SOLID_OLD:
    ld a,(SOLID_NEW)
    ld b,a
    ld a,(SOLID_OLD)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L46
    jp moving_solid_push_L47
moving_solid_push_L46:
; if SOLID_OLD >= T0:
    ld a,(SOLID_OLD)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp nc,moving_solid_push_L49
    jp moving_solid_push_L50
moving_solid_push_L49:
; if SOLID_NEW < T0:
    ld a,(SOLID_NEW)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L52
    jp moving_solid_push_L53
moving_solid_push_L52:
; if SOLID_NEW < ACTOR_SIZE:
    ld a,(SOLID_NEW)
    ld b,a
    ld a,(ACTOR_SIZE)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L55
    jp moving_solid_push_L56
moving_solid_push_L55:
; BLOCKED = 1
    ld a,1
    ld (BLOCKED),a
; return
    ret
    jp moving_solid_push_L57
moving_solid_push_L56:
moving_solid_push_L57:
; T3 = SOLID_NEW - ACTOR_SIZE
    ld a,(SOLID_NEW)
    ld b,a
    ld a,(ACTOR_SIZE)
    ld c,a
    ld a,b
    sub c
    ld (T3),a
; if T3 < MINIMUM:
    ld a,(T3)
    ld b,a
    ld a,(MINIMUM)
    ld c,a
    ld a,b
    cp c
    jp c,moving_solid_push_L58
    jp moving_solid_push_L59
moving_solid_push_L58:
; BLOCKED = 1
    ld a,1
    ld (BLOCKED),a
; return
    ret
    jp moving_solid_push_L60
moving_solid_push_L59:
moving_solid_push_L60:
; POSITION = T3
    ld a,(T3)
    ld (POSITION),a
; PUSHED = 1
    ld a,1
    ld (PUSHED),a
    jp moving_solid_push_L54
moving_solid_push_L53:
moving_solid_push_L54:
    jp moving_solid_push_L51
moving_solid_push_L50:
moving_solid_push_L51:
    jp moving_solid_push_L48
moving_solid_push_L47:
moving_solid_push_L48:
    ret
component_end:

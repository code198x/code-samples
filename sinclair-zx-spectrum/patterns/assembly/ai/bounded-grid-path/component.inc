; SPDX-License-Identifier: MIT
; Find the First Step Along a Shortest Grid Path. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_grid_path_init:
    ld a,0
    ld (MOVE),a
    ld (DISTANCE),a
    ld (FOUND),a
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
    ld (EXPR_SAVE),a
    ld (V0),a
    ld (V1),a
    ld (V2),a
    ld (V3),a
    ld (V4),a
    ld (V5),a
    ld (V6),a
    ld (V7),a
    ld (V8),a
    ld (V9),a
    ld (V10),a
    ld (V11),a
    ld (V12),a
    ld (V13),a
    ld (V14),a
    ld (V15),a
    ret
bounded_grid_path_step:
; MOVE = 0
    ld a,0
    ld (MOVE),a
; DISTANCE = 255
    ld a,255
    ld (DISTANCE),a
; FOUND = 0
    ld a,0
    ld (FOUND),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if FROM >= 16:
    ld a,(FROM)
    cp 16
    jp nc,bounded_grid_path_L1
    jp bounded_grid_path_L2
bounded_grid_path_L1:
; return
    ret
    jp bounded_grid_path_L3
bounded_grid_path_L2:
bounded_grid_path_L3:
; if TO >= 16:
    ld a,(TO)
    cp 16
    jp nc,bounded_grid_path_L4
    jp bounded_grid_path_L5
bounded_grid_path_L4:
; return
    ret
    jp bounded_grid_path_L6
bounded_grid_path_L5:
bounded_grid_path_L6:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = C[FROM]
    ld a,(FROM)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,bounded_grid_path_L7
    jp bounded_grid_path_L8
bounded_grid_path_L7:
; return
    ret
    jp bounded_grid_path_L9
bounded_grid_path_L8:
bounded_grid_path_L9:
; T0 = C[TO]
    ld a,(TO)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,bounded_grid_path_L10
    jp bounded_grid_path_L11
bounded_grid_path_L10:
; return
    ret
    jp bounded_grid_path_L12
bounded_grid_path_L11:
bounded_grid_path_L12:
; T0 = 0
    ld a,0
    ld (T0),a
; while T0 < 16:
bounded_grid_path_L13:
    ld a,(T0)
    cp 16
    jp c,bounded_grid_path_L14
    jp bounded_grid_path_L15
bounded_grid_path_L14:
; V[T0] = 255
    ld a,255
    ld c,a
    ld a,(T0)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp bounded_grid_path_L13
bounded_grid_path_L15:
; V[TO] = 0
    ld a,0
    ld c,a
    ld a,(TO)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
; T0 = 1
    ld a,1
    ld (T0),a
; while T0 < 16:
bounded_grid_path_L16:
    ld a,(T0)
    cp 16
    jp c,bounded_grid_path_L17
    jp bounded_grid_path_L18
bounded_grid_path_L17:
; T1 = 0
    ld a,0
    ld (T1),a
; while T1 < 16:
bounded_grid_path_L19:
    ld a,(T1)
    cp 16
    jp c,bounded_grid_path_L20
    jp bounded_grid_path_L21
bounded_grid_path_L20:
; T2 = C[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T2),a
; T3 = V[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T2 == 0:
    ld a,(T2)
    cp 0
    jp z,bounded_grid_path_L22
    jp bounded_grid_path_L23
bounded_grid_path_L22:
; if T3 == 255:
    ld a,(T3)
    cp 255
    jp z,bounded_grid_path_L25
    jp bounded_grid_path_L26
bounded_grid_path_L25:
; T4 = T0 - 1
    ld a,(T0)
    sub 1
    ld (T4),a
; T5 = T1 & 3
    ld a,(T1)
    and 3
    ld (T5),a
; if T5 != 0:
    ld a,(T5)
    cp 0
    jp nz,bounded_grid_path_L28
    jp bounded_grid_path_L29
bounded_grid_path_L28:
; T6 = T1 - 1
    ld a,(T1)
    sub 1
    ld (T6),a
; T7 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T7),a
; if T7 == T4:
    ld a,(T7)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L31
    jp bounded_grid_path_L32
bounded_grid_path_L31:
; V[T1] = T0
    ld a,(T0)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
    jp bounded_grid_path_L33
bounded_grid_path_L32:
bounded_grid_path_L33:
    jp bounded_grid_path_L30
bounded_grid_path_L29:
bounded_grid_path_L30:
; if T5 != 3:
    ld a,(T5)
    cp 3
    jp nz,bounded_grid_path_L34
    jp bounded_grid_path_L35
bounded_grid_path_L34:
; T6 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T6),a
; T7 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T7),a
; if T7 == T4:
    ld a,(T7)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L37
    jp bounded_grid_path_L38
bounded_grid_path_L37:
; V[T1] = T0
    ld a,(T0)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
    jp bounded_grid_path_L39
bounded_grid_path_L38:
bounded_grid_path_L39:
    jp bounded_grid_path_L36
bounded_grid_path_L35:
bounded_grid_path_L36:
; if T1 >= 4:
    ld a,(T1)
    cp 4
    jp nc,bounded_grid_path_L40
    jp bounded_grid_path_L41
bounded_grid_path_L40:
; T6 = T1 - 4
    ld a,(T1)
    sub 4
    ld (T6),a
; T7 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T7),a
; if T7 == T4:
    ld a,(T7)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L43
    jp bounded_grid_path_L44
bounded_grid_path_L43:
; V[T1] = T0
    ld a,(T0)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
    jp bounded_grid_path_L45
bounded_grid_path_L44:
bounded_grid_path_L45:
    jp bounded_grid_path_L42
bounded_grid_path_L41:
bounded_grid_path_L42:
; if T1 < 12:
    ld a,(T1)
    cp 12
    jp c,bounded_grid_path_L46
    jp bounded_grid_path_L47
bounded_grid_path_L46:
; T6 = T1 + 4
    ld a,(T1)
    add a,4
    ld (T6),a
; T7 = V[T6]
    ld a,(T6)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T7),a
; if T7 == T4:
    ld a,(T7)
    ld b,a
    ld a,(T4)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L49
    jp bounded_grid_path_L50
bounded_grid_path_L49:
; V[T1] = T0
    ld a,(T0)
    ld c,a
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld (hl),c
    jp bounded_grid_path_L51
bounded_grid_path_L50:
bounded_grid_path_L51:
    jp bounded_grid_path_L48
bounded_grid_path_L47:
bounded_grid_path_L48:
    jp bounded_grid_path_L27
bounded_grid_path_L26:
bounded_grid_path_L27:
    jp bounded_grid_path_L24
bounded_grid_path_L23:
bounded_grid_path_L24:
; T1 = T1 + 1
    ld a,(T1)
    add a,1
    ld (T1),a
    jp bounded_grid_path_L19
bounded_grid_path_L21:
; T0 = T0 + 1
    ld a,(T0)
    add a,1
    ld (T0),a
    jp bounded_grid_path_L16
bounded_grid_path_L18:
; DISTANCE = V[FROM]
    ld a,(FROM)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (DISTANCE),a
; if DISTANCE == 255:
    ld a,(DISTANCE)
    cp 255
    jp z,bounded_grid_path_L52
    jp bounded_grid_path_L53
bounded_grid_path_L52:
; return
    ret
    jp bounded_grid_path_L54
bounded_grid_path_L53:
bounded_grid_path_L54:
; FOUND = 1
    ld a,1
    ld (FOUND),a
; if DISTANCE == 0:
    ld a,(DISTANCE)
    cp 0
    jp z,bounded_grid_path_L55
    jp bounded_grid_path_L56
bounded_grid_path_L55:
; return
    ret
    jp bounded_grid_path_L57
bounded_grid_path_L56:
bounded_grid_path_L57:
; T0 = DISTANCE - 1
    ld a,(DISTANCE)
    sub 1
    ld (T0),a
; T1 = FROM & 3
    ld a,(FROM)
    and 3
    ld (T1),a
; if T1 != 0:
    ld a,(T1)
    cp 0
    jp nz,bounded_grid_path_L58
    jp bounded_grid_path_L59
bounded_grid_path_L58:
; T2 = FROM - 1
    ld a,(FROM)
    sub 1
    ld (T2),a
; T3 = V[T2]
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 == T0:
    ld a,(T3)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L61
    jp bounded_grid_path_L62
bounded_grid_path_L61:
; MOVE = 1
    ld a,1
    ld (MOVE),a
; return
    ret
    jp bounded_grid_path_L63
bounded_grid_path_L62:
bounded_grid_path_L63:
    jp bounded_grid_path_L60
bounded_grid_path_L59:
bounded_grid_path_L60:
; if T1 != 3:
    ld a,(T1)
    cp 3
    jp nz,bounded_grid_path_L64
    jp bounded_grid_path_L65
bounded_grid_path_L64:
; T2 = FROM + 1
    ld a,(FROM)
    add a,1
    ld (T2),a
; T3 = V[T2]
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 == T0:
    ld a,(T3)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L67
    jp bounded_grid_path_L68
bounded_grid_path_L67:
; MOVE = 2
    ld a,2
    ld (MOVE),a
; return
    ret
    jp bounded_grid_path_L69
bounded_grid_path_L68:
bounded_grid_path_L69:
    jp bounded_grid_path_L66
bounded_grid_path_L65:
bounded_grid_path_L66:
; if FROM >= 4:
    ld a,(FROM)
    cp 4
    jp nc,bounded_grid_path_L70
    jp bounded_grid_path_L71
bounded_grid_path_L70:
; T2 = FROM - 4
    ld a,(FROM)
    sub 4
    ld (T2),a
; T3 = V[T2]
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 == T0:
    ld a,(T3)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L73
    jp bounded_grid_path_L74
bounded_grid_path_L73:
; MOVE = 3
    ld a,3
    ld (MOVE),a
; return
    ret
    jp bounded_grid_path_L75
bounded_grid_path_L74:
bounded_grid_path_L75:
    jp bounded_grid_path_L72
bounded_grid_path_L71:
bounded_grid_path_L72:
; if FROM < 12:
    ld a,(FROM)
    cp 12
    jp c,bounded_grid_path_L76
    jp bounded_grid_path_L77
bounded_grid_path_L76:
; T2 = FROM + 4
    ld a,(FROM)
    add a,4
    ld (T2),a
; T3 = V[T2]
    ld a,(T2)
    ld e,a
    ld d,0
    ld hl,V0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 == T0:
    ld a,(T3)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp z,bounded_grid_path_L79
    jp bounded_grid_path_L80
bounded_grid_path_L79:
; MOVE = 4
    ld a,4
    ld (MOVE),a
    jp bounded_grid_path_L81
bounded_grid_path_L80:
bounded_grid_path_L81:
    jp bounded_grid_path_L78
bounded_grid_path_L77:
bounded_grid_path_L78:
    ret
component_end:

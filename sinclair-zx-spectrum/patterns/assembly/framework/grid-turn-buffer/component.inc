; SPDX-License-Identifier: MIT
; Buffer Turns Through a Grid. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
grid_turn_buffer_init:
    ld a,0
    ld (CELL),a
    ld (DIRECTION),a
    ld (PENDING),a
    ld (MOVED),a
    ld (VALID),a
    ld (REQUEST),a
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
    ret
grid_turn_buffer_step:
; MOVED = 0
    ld a,0
    ld (MOVED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if CELL >= 16:
    ld a,(CELL)
    cp 16
    jp nc,grid_turn_buffer_L1
    jp grid_turn_buffer_L2
grid_turn_buffer_L1:
; return
    ret
    jp grid_turn_buffer_L3
grid_turn_buffer_L2:
grid_turn_buffer_L3:
; if DIRECTION > 4:
    ld a,(DIRECTION)
    cp 4
    jp z,grid_turn_buffer_L5
    jp nc,grid_turn_buffer_L4
    jp grid_turn_buffer_L5
grid_turn_buffer_L4:
; return
    ret
    jp grid_turn_buffer_L6
grid_turn_buffer_L5:
grid_turn_buffer_L6:
; if PENDING > 4:
    ld a,(PENDING)
    cp 4
    jp z,grid_turn_buffer_L8
    jp nc,grid_turn_buffer_L7
    jp grid_turn_buffer_L8
grid_turn_buffer_L7:
; return
    ret
    jp grid_turn_buffer_L9
grid_turn_buffer_L8:
grid_turn_buffer_L9:
; if REQUEST > 4:
    ld a,(REQUEST)
    cp 4
    jp z,grid_turn_buffer_L11
    jp nc,grid_turn_buffer_L10
    jp grid_turn_buffer_L11
grid_turn_buffer_L10:
; return
    ret
    jp grid_turn_buffer_L12
grid_turn_buffer_L11:
grid_turn_buffer_L12:
; T0 = C[CELL]
    ld a,(CELL)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T0),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,grid_turn_buffer_L13
    jp grid_turn_buffer_L14
grid_turn_buffer_L13:
; return
    ret
    jp grid_turn_buffer_L15
grid_turn_buffer_L14:
grid_turn_buffer_L15:
; VALID = 1
    ld a,1
    ld (VALID),a
; if REQUEST != 0:
    ld a,(REQUEST)
    cp 0
    jp nz,grid_turn_buffer_L16
    jp grid_turn_buffer_L17
grid_turn_buffer_L16:
; PENDING = REQUEST
    ld a,(REQUEST)
    ld (PENDING),a
    jp grid_turn_buffer_L18
grid_turn_buffer_L17:
grid_turn_buffer_L18:
; T4 = 2
    ld a,2
    ld (T4),a
; T0 = PENDING
    ld a,(PENDING)
    ld (T0),a
; while T4 != 0:
grid_turn_buffer_L19:
    ld a,(T4)
    cp 0
    jp nz,grid_turn_buffer_L20
    jp grid_turn_buffer_L21
grid_turn_buffer_L20:
; T1 = 255
    ld a,255
    ld (T1),a
; T2 = CELL & 3
    ld a,(CELL)
    and 3
    ld (T2),a
; if T0 == 1:
    ld a,(T0)
    cp 1
    jp z,grid_turn_buffer_L22
    jp grid_turn_buffer_L23
grid_turn_buffer_L22:
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,grid_turn_buffer_L25
    jp grid_turn_buffer_L26
grid_turn_buffer_L25:
; T1 = CELL - 1
    ld a,(CELL)
    sub 1
    ld (T1),a
    jp grid_turn_buffer_L27
grid_turn_buffer_L26:
grid_turn_buffer_L27:
    jp grid_turn_buffer_L24
grid_turn_buffer_L23:
grid_turn_buffer_L24:
; if T0 == 2:
    ld a,(T0)
    cp 2
    jp z,grid_turn_buffer_L28
    jp grid_turn_buffer_L29
grid_turn_buffer_L28:
; if T2 != 3:
    ld a,(T2)
    cp 3
    jp nz,grid_turn_buffer_L31
    jp grid_turn_buffer_L32
grid_turn_buffer_L31:
; T1 = CELL + 1
    ld a,(CELL)
    add a,1
    ld (T1),a
    jp grid_turn_buffer_L33
grid_turn_buffer_L32:
grid_turn_buffer_L33:
    jp grid_turn_buffer_L30
grid_turn_buffer_L29:
grid_turn_buffer_L30:
; if T0 == 3:
    ld a,(T0)
    cp 3
    jp z,grid_turn_buffer_L34
    jp grid_turn_buffer_L35
grid_turn_buffer_L34:
; if CELL >= 4:
    ld a,(CELL)
    cp 4
    jp nc,grid_turn_buffer_L37
    jp grid_turn_buffer_L38
grid_turn_buffer_L37:
; T1 = CELL - 4
    ld a,(CELL)
    sub 4
    ld (T1),a
    jp grid_turn_buffer_L39
grid_turn_buffer_L38:
grid_turn_buffer_L39:
    jp grid_turn_buffer_L36
grid_turn_buffer_L35:
grid_turn_buffer_L36:
; if T0 == 4:
    ld a,(T0)
    cp 4
    jp z,grid_turn_buffer_L40
    jp grid_turn_buffer_L41
grid_turn_buffer_L40:
; if CELL < 12:
    ld a,(CELL)
    cp 12
    jp c,grid_turn_buffer_L43
    jp grid_turn_buffer_L44
grid_turn_buffer_L43:
; T1 = CELL + 4
    ld a,(CELL)
    add a,4
    ld (T1),a
    jp grid_turn_buffer_L45
grid_turn_buffer_L44:
grid_turn_buffer_L45:
    jp grid_turn_buffer_L42
grid_turn_buffer_L41:
grid_turn_buffer_L42:
; if T1 < 16:
    ld a,(T1)
    cp 16
    jp c,grid_turn_buffer_L46
    jp grid_turn_buffer_L47
grid_turn_buffer_L46:
; T3 = C[T1]
    ld a,(T1)
    ld e,a
    ld d,0
    ld hl,C0
    add hl,de
    ld a,(hl)
    ld (T3),a
; if T3 == 0:
    ld a,(T3)
    cp 0
    jp z,grid_turn_buffer_L49
    jp grid_turn_buffer_L50
grid_turn_buffer_L49:
; CELL = T1
    ld a,(T1)
    ld (CELL),a
; DIRECTION = T0
    ld a,(T0)
    ld (DIRECTION),a
; if T4 == 2:
    ld a,(T4)
    cp 2
    jp z,grid_turn_buffer_L52
    jp grid_turn_buffer_L53
grid_turn_buffer_L52:
; PENDING = 0
    ld a,0
    ld (PENDING),a
    jp grid_turn_buffer_L54
grid_turn_buffer_L53:
grid_turn_buffer_L54:
; MOVED = 1
    ld a,1
    ld (MOVED),a
; return
    ret
    jp grid_turn_buffer_L51
grid_turn_buffer_L50:
grid_turn_buffer_L51:
    jp grid_turn_buffer_L48
grid_turn_buffer_L47:
grid_turn_buffer_L48:
; T4 = T4 - 1
    ld a,(T4)
    sub 1
    ld (T4),a
; T0 = DIRECTION
    ld a,(DIRECTION)
    ld (T0),a
    jp grid_turn_buffer_L19
grid_turn_buffer_L21:
    ret
component_end:

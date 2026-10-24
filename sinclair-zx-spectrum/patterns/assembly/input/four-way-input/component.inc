; SPDX-License-Identifier: MIT
; Resolve Input to Four Directions. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
four_way_input_init:
    ld a,0
    ld (HELD),a
    ld (LAST_AXIS),a
    ld (DIRECTION),a
    ld (VALID),a
    ld (T0),a
    ld (T1),a
    ld (T2),a
    ret
four_way_input_step:
; DIRECTION = 0
    ld a,0
    ld (DIRECTION),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if LAST_AXIS >= 2:
    ld a,(LAST_AXIS)
    cp 2
    jp nc,four_way_input_L1
    jp four_way_input_L2
four_way_input_L1:
; return
    ret
    jp four_way_input_L3
four_way_input_L2:
four_way_input_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = HELD & 3
    ld a,(HELD)
    and 3
    ld (T0),a
; T1 = 0
    ld a,0
    ld (T1),a
; if T0 == 1:
    ld a,(T0)
    cp 1
    jp z,four_way_input_L4
    jp four_way_input_L5
four_way_input_L4:
; T1 = 1
    ld a,1
    ld (T1),a
    jp four_way_input_L6
four_way_input_L5:
four_way_input_L6:
; if T0 == 2:
    ld a,(T0)
    cp 2
    jp z,four_way_input_L7
    jp four_way_input_L8
four_way_input_L7:
; T1 = 2
    ld a,2
    ld (T1),a
    jp four_way_input_L9
four_way_input_L8:
four_way_input_L9:
; T0 = HELD & 12
    ld a,(HELD)
    and 12
    ld (T0),a
; T2 = 0
    ld a,0
    ld (T2),a
; if T0 == 4:
    ld a,(T0)
    cp 4
    jp z,four_way_input_L10
    jp four_way_input_L11
four_way_input_L10:
; T2 = 3
    ld a,3
    ld (T2),a
    jp four_way_input_L12
four_way_input_L11:
four_way_input_L12:
; if T0 == 8:
    ld a,(T0)
    cp 8
    jp z,four_way_input_L13
    jp four_way_input_L14
four_way_input_L13:
; T2 = 4
    ld a,4
    ld (T2),a
    jp four_way_input_L15
four_way_input_L14:
four_way_input_L15:
; if T1 != 0:
    ld a,(T1)
    cp 0
    jp nz,four_way_input_L16
    jp four_way_input_L17
four_way_input_L16:
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,four_way_input_L19
    jp four_way_input_L20
four_way_input_L19:
; if LAST_AXIS == 1:
    ld a,(LAST_AXIS)
    cp 1
    jp z,four_way_input_L22
    jp four_way_input_L23
four_way_input_L22:
; DIRECTION = T2
    ld a,(T2)
    ld (DIRECTION),a
; return
    ret
    jp four_way_input_L24
four_way_input_L23:
four_way_input_L24:
    jp four_way_input_L21
four_way_input_L20:
four_way_input_L21:
; DIRECTION = T1
    ld a,(T1)
    ld (DIRECTION),a
; LAST_AXIS = 0
    ld a,0
    ld (LAST_AXIS),a
; return
    ret
    jp four_way_input_L18
four_way_input_L17:
four_way_input_L18:
; if T2 != 0:
    ld a,(T2)
    cp 0
    jp nz,four_way_input_L25
    jp four_way_input_L26
four_way_input_L25:
; DIRECTION = T2
    ld a,(T2)
    ld (DIRECTION),a
; LAST_AXIS = 1
    ld a,1
    ld (LAST_AXIS),a
    jp four_way_input_L27
four_way_input_L26:
four_way_input_L27:
    ret
component_end:

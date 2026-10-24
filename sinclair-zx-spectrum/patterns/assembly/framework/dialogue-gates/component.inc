; SPDX-License-Identifier: MIT
; Gate a Dialogue Choice with Flags. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dialogue_gates_init:
    ld a,0
    ld (FLAGS),a
    ld (REQUIRED),a
    ld (FORBIDDEN),a
    ld (SET_MASK),a
    ld (CLEAR_MASK),a
    ld (ACCEPT),a
    ld (AVAILABLE),a
    ld (TAKEN),a
    ld (VALID),a
    ld (T0),a
    ret
dialogue_gates_step:
; AVAILABLE = 0
    ld a,0
    ld (AVAILABLE),a
; TAKEN = 0
    ld a,0
    ld (TAKEN),a
; VALID = 0
    ld a,0
    ld (VALID),a
; T0 = REQUIRED & FORBIDDEN
    ld a,(REQUIRED)
    ld b,a
    ld a,(FORBIDDEN)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,dialogue_gates_L1
    jp dialogue_gates_L2
dialogue_gates_L1:
; return
    ret
    jp dialogue_gates_L3
dialogue_gates_L2:
dialogue_gates_L3:
; VALID = 1
    ld a,1
    ld (VALID),a
; T0 = FLAGS & REQUIRED
    ld a,(FLAGS)
    ld b,a
    ld a,(REQUIRED)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 != REQUIRED:
    ld a,(T0)
    ld b,a
    ld a,(REQUIRED)
    ld c,a
    ld a,b
    cp c
    jp nz,dialogue_gates_L4
    jp dialogue_gates_L5
dialogue_gates_L4:
; return
    ret
    jp dialogue_gates_L6
dialogue_gates_L5:
dialogue_gates_L6:
; T0 = FLAGS & FORBIDDEN
    ld a,(FLAGS)
    ld b,a
    ld a,(FORBIDDEN)
    ld c,a
    ld a,b
    and c
    ld (T0),a
; if T0 != 0:
    ld a,(T0)
    cp 0
    jp nz,dialogue_gates_L7
    jp dialogue_gates_L8
dialogue_gates_L7:
; return
    ret
    jp dialogue_gates_L9
dialogue_gates_L8:
dialogue_gates_L9:
; AVAILABLE = 1
    ld a,1
    ld (AVAILABLE),a
; if ACCEPT == 0:
    ld a,(ACCEPT)
    cp 0
    jp z,dialogue_gates_L10
    jp dialogue_gates_L11
dialogue_gates_L10:
; return
    ret
    jp dialogue_gates_L12
dialogue_gates_L11:
dialogue_gates_L12:
; T0 = CLEAR_MASK ^ 255
    ld a,(CLEAR_MASK)
    xor 255
    ld (T0),a
; FLAGS = FLAGS & T0
    ld a,(FLAGS)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    and c
    ld (FLAGS),a
; FLAGS = FLAGS | SET_MASK
    ld a,(FLAGS)
    ld b,a
    ld a,(SET_MASK)
    ld c,a
    ld a,b
    or c
    ld (FLAGS),a
; TAKEN = 1
    ld a,1
    ld (TAKEN),a
    ret
component_end:

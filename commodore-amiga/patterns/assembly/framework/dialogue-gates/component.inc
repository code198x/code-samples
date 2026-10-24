; SPDX-License-Identifier: MIT
; Gate a Dialogue Choice with Flags. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
dialogue_gates_init:
    move.b #0,d0
    move.b d0,FLAGS
    move.b d0,REQUIRED
    move.b d0,FORBIDDEN
    move.b d0,SET_MASK
    move.b d0,CLEAR_MASK
    move.b d0,ACCEPT
    move.b d0,AVAILABLE
    move.b d0,TAKEN
    move.b d0,VALID
    move.b d0,T0
    rts
dialogue_gates_step:
; AVAILABLE = 0
    move.b #0,d0
    move.b d0,AVAILABLE
; TAKEN = 0
    move.b #0,d0
    move.b d0,TAKEN
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; T0 = REQUIRED & FORBIDDEN
    move.b REQUIRED,d0
    move.b FORBIDDEN,d1
    and.b d1,d0
    move.b d0,T0
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne dialogue_gates_L1
    jmp dialogue_gates_L2
dialogue_gates_L1:
; return
    rts
    jmp dialogue_gates_L3
dialogue_gates_L2:
dialogue_gates_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = FLAGS & REQUIRED
    move.b FLAGS,d0
    move.b REQUIRED,d1
    and.b d1,d0
    move.b d0,T0
; if T0 != REQUIRED:
    move.b T0,d0
    move.b REQUIRED,d1
    cmp.b d1,d0
    bne dialogue_gates_L4
    jmp dialogue_gates_L5
dialogue_gates_L4:
; return
    rts
    jmp dialogue_gates_L6
dialogue_gates_L5:
dialogue_gates_L6:
; T0 = FLAGS & FORBIDDEN
    move.b FLAGS,d0
    move.b FORBIDDEN,d1
    and.b d1,d0
    move.b d0,T0
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne dialogue_gates_L7
    jmp dialogue_gates_L8
dialogue_gates_L7:
; return
    rts
    jmp dialogue_gates_L9
dialogue_gates_L8:
dialogue_gates_L9:
; AVAILABLE = 1
    move.b #1,d0
    move.b d0,AVAILABLE
; if ACCEPT == 0:
    move.b ACCEPT,d0
    cmp.b #0,d0
    beq dialogue_gates_L10
    jmp dialogue_gates_L11
dialogue_gates_L10:
; return
    rts
    jmp dialogue_gates_L12
dialogue_gates_L11:
dialogue_gates_L12:
; T0 = CLEAR_MASK ^ 255
    move.b CLEAR_MASK,d0
    eor.b #255,d0
    move.b d0,T0
; FLAGS = FLAGS & T0
    move.b FLAGS,d0
    move.b T0,d1
    and.b d1,d0
    move.b d0,FLAGS
; FLAGS = FLAGS | SET_MASK
    move.b FLAGS,d0
    move.b SET_MASK,d1
    or.b d1,d0
    move.b d0,FLAGS
; TAKEN = 1
    move.b #1,d0
    move.b d0,TAKEN
    rts
component_end:

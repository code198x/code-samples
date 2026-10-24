; SPDX-License-Identifier: MIT
; Buffer Turns Through a Grid. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
grid_turn_buffer_init:
    move.b #0,d0
    move.b d0,CELL
    move.b d0,DIRECTION
    move.b d0,PENDING
    move.b d0,MOVED
    move.b d0,VALID
    move.b d0,REQUEST
    move.b d0,C0
    move.b d0,C1
    move.b d0,C2
    move.b d0,C3
    move.b d0,C4
    move.b d0,C5
    move.b d0,C6
    move.b d0,C7
    move.b d0,C8
    move.b d0,C9
    move.b d0,C10
    move.b d0,C11
    move.b d0,C12
    move.b d0,C13
    move.b d0,C14
    move.b d0,C15
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    rts
grid_turn_buffer_step:
; MOVED = 0
    move.b #0,d0
    move.b d0,MOVED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if CELL >= 16:
    move.b CELL,d0
    cmp.b #16,d0
    bcc grid_turn_buffer_L1
    jmp grid_turn_buffer_L2
grid_turn_buffer_L1:
; return
    rts
    jmp grid_turn_buffer_L3
grid_turn_buffer_L2:
grid_turn_buffer_L3:
; if DIRECTION > 4:
    move.b DIRECTION,d0
    cmp.b #4,d0
    bhi grid_turn_buffer_L4
    jmp grid_turn_buffer_L5
grid_turn_buffer_L4:
; return
    rts
    jmp grid_turn_buffer_L6
grid_turn_buffer_L5:
grid_turn_buffer_L6:
; if PENDING > 4:
    move.b PENDING,d0
    cmp.b #4,d0
    bhi grid_turn_buffer_L7
    jmp grid_turn_buffer_L8
grid_turn_buffer_L7:
; return
    rts
    jmp grid_turn_buffer_L9
grid_turn_buffer_L8:
grid_turn_buffer_L9:
; if REQUEST > 4:
    move.b REQUEST,d0
    cmp.b #4,d0
    bhi grid_turn_buffer_L10
    jmp grid_turn_buffer_L11
grid_turn_buffer_L10:
; return
    rts
    jmp grid_turn_buffer_L12
grid_turn_buffer_L11:
grid_turn_buffer_L12:
; T0 = C[CELL]
    moveq #0,d1
    move.b CELL,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne grid_turn_buffer_L13
    jmp grid_turn_buffer_L14
grid_turn_buffer_L13:
; return
    rts
    jmp grid_turn_buffer_L15
grid_turn_buffer_L14:
grid_turn_buffer_L15:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if REQUEST != 0:
    move.b REQUEST,d0
    cmp.b #0,d0
    bne grid_turn_buffer_L16
    jmp grid_turn_buffer_L17
grid_turn_buffer_L16:
; PENDING = REQUEST
    move.b REQUEST,d0
    move.b d0,PENDING
    jmp grid_turn_buffer_L18
grid_turn_buffer_L17:
grid_turn_buffer_L18:
; T4 = 2
    move.b #2,d0
    move.b d0,T4
; T0 = PENDING
    move.b PENDING,d0
    move.b d0,T0
; while T4 != 0:
grid_turn_buffer_L19:
    move.b T4,d0
    cmp.b #0,d0
    bne grid_turn_buffer_L20
    jmp grid_turn_buffer_L21
grid_turn_buffer_L20:
; T1 = 255
    move.b #255,d0
    move.b d0,T1
; T2 = CELL & 3
    move.b CELL,d0
    and.b #3,d0
    move.b d0,T2
; if T0 == 1:
    move.b T0,d0
    cmp.b #1,d0
    beq grid_turn_buffer_L22
    jmp grid_turn_buffer_L23
grid_turn_buffer_L22:
; if T2 != 0:
    move.b T2,d0
    cmp.b #0,d0
    bne grid_turn_buffer_L25
    jmp grid_turn_buffer_L26
grid_turn_buffer_L25:
; T1 = CELL - 1
    move.b CELL,d0
    sub.b #1,d0
    move.b d0,T1
    jmp grid_turn_buffer_L27
grid_turn_buffer_L26:
grid_turn_buffer_L27:
    jmp grid_turn_buffer_L24
grid_turn_buffer_L23:
grid_turn_buffer_L24:
; if T0 == 2:
    move.b T0,d0
    cmp.b #2,d0
    beq grid_turn_buffer_L28
    jmp grid_turn_buffer_L29
grid_turn_buffer_L28:
; if T2 != 3:
    move.b T2,d0
    cmp.b #3,d0
    bne grid_turn_buffer_L31
    jmp grid_turn_buffer_L32
grid_turn_buffer_L31:
; T1 = CELL + 1
    move.b CELL,d0
    add.b #1,d0
    move.b d0,T1
    jmp grid_turn_buffer_L33
grid_turn_buffer_L32:
grid_turn_buffer_L33:
    jmp grid_turn_buffer_L30
grid_turn_buffer_L29:
grid_turn_buffer_L30:
; if T0 == 3:
    move.b T0,d0
    cmp.b #3,d0
    beq grid_turn_buffer_L34
    jmp grid_turn_buffer_L35
grid_turn_buffer_L34:
; if CELL >= 4:
    move.b CELL,d0
    cmp.b #4,d0
    bcc grid_turn_buffer_L37
    jmp grid_turn_buffer_L38
grid_turn_buffer_L37:
; T1 = CELL - 4
    move.b CELL,d0
    sub.b #4,d0
    move.b d0,T1
    jmp grid_turn_buffer_L39
grid_turn_buffer_L38:
grid_turn_buffer_L39:
    jmp grid_turn_buffer_L36
grid_turn_buffer_L35:
grid_turn_buffer_L36:
; if T0 == 4:
    move.b T0,d0
    cmp.b #4,d0
    beq grid_turn_buffer_L40
    jmp grid_turn_buffer_L41
grid_turn_buffer_L40:
; if CELL < 12:
    move.b CELL,d0
    cmp.b #12,d0
    bcs grid_turn_buffer_L43
    jmp grid_turn_buffer_L44
grid_turn_buffer_L43:
; T1 = CELL + 4
    move.b CELL,d0
    add.b #4,d0
    move.b d0,T1
    jmp grid_turn_buffer_L45
grid_turn_buffer_L44:
grid_turn_buffer_L45:
    jmp grid_turn_buffer_L42
grid_turn_buffer_L41:
grid_turn_buffer_L42:
; if T1 < 16:
    move.b T1,d0
    cmp.b #16,d0
    bcs grid_turn_buffer_L46
    jmp grid_turn_buffer_L47
grid_turn_buffer_L46:
; T3 = C[T1]
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 == 0:
    move.b T3,d0
    cmp.b #0,d0
    beq grid_turn_buffer_L49
    jmp grid_turn_buffer_L50
grid_turn_buffer_L49:
; CELL = T1
    move.b T1,d0
    move.b d0,CELL
; DIRECTION = T0
    move.b T0,d0
    move.b d0,DIRECTION
; if T4 == 2:
    move.b T4,d0
    cmp.b #2,d0
    beq grid_turn_buffer_L52
    jmp grid_turn_buffer_L53
grid_turn_buffer_L52:
; PENDING = 0
    move.b #0,d0
    move.b d0,PENDING
    jmp grid_turn_buffer_L54
grid_turn_buffer_L53:
grid_turn_buffer_L54:
; MOVED = 1
    move.b #1,d0
    move.b d0,MOVED
; return
    rts
    jmp grid_turn_buffer_L51
grid_turn_buffer_L50:
grid_turn_buffer_L51:
    jmp grid_turn_buffer_L48
grid_turn_buffer_L47:
grid_turn_buffer_L48:
; T4 = T4 - 1
    move.b T4,d0
    sub.b #1,d0
    move.b d0,T4
; T0 = DIRECTION
    move.b DIRECTION,d0
    move.b d0,T0
    jmp grid_turn_buffer_L19
grid_turn_buffer_L21:
    rts
component_end:

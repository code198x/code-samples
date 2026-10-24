; SPDX-License-Identifier: MIT
; Trace a Thin Grid Line of Sight. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
grid_line_sight_init:
    move.b #0,d0
    move.b d0,VISIBLE
    move.b d0,VALID
    move.b d0,FROM
    move.b d0,TO
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
    move.b d0,T5
    move.b d0,T6
    move.b d0,T7
    move.b d0,T8
    move.b d0,T9
    move.b d0,T10
    move.b d0,T11
    rts
grid_line_sight_step:
; VISIBLE = 0
    move.b #0,d0
    move.b d0,VISIBLE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if FROM >= 16:
    move.b FROM,d0
    cmp.b #16,d0
    bcc grid_line_sight_L1
    jmp grid_line_sight_L2
grid_line_sight_L1:
; return
    rts
    jmp grid_line_sight_L3
grid_line_sight_L2:
grid_line_sight_L3:
; if TO >= 16:
    move.b TO,d0
    cmp.b #16,d0
    bcc grid_line_sight_L4
    jmp grid_line_sight_L5
grid_line_sight_L4:
; return
    rts
    jmp grid_line_sight_L6
grid_line_sight_L5:
grid_line_sight_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = FROM & 3
    move.b FROM,d0
    and.b #3,d0
    move.b d0,T0
; T1 = FROM >> 2
    move.b FROM,d0
    lsr.b #2,d0
    move.b d0,T1
; T2 = TO & 3
    move.b TO,d0
    and.b #3,d0
    move.b d0,T2
; T3 = TO >> 2
    move.b TO,d0
    lsr.b #2,d0
    move.b d0,T3
; T6 = 1
    move.b #1,d0
    move.b d0,T6
; if T2 >= T0:
    move.b T2,d0
    move.b T0,d1
    cmp.b d1,d0
    bcc grid_line_sight_L7
    jmp grid_line_sight_L8
grid_line_sight_L7:
; T4 = T2 - T0
    move.b T2,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T4
    jmp grid_line_sight_L9
grid_line_sight_L8:
; T4 = T0 - T2
    move.b T0,d0
    move.b T2,d1
    sub.b d1,d0
    move.b d0,T4
; T6 = 255
    move.b #255,d0
    move.b d0,T6
grid_line_sight_L9:
; T7 = 1
    move.b #1,d0
    move.b d0,T7
; if T3 >= T1:
    move.b T3,d0
    move.b T1,d1
    cmp.b d1,d0
    bcc grid_line_sight_L10
    jmp grid_line_sight_L11
grid_line_sight_L10:
; T5 = T3 - T1
    move.b T3,d0
    move.b T1,d1
    sub.b d1,d0
    move.b d0,T5
    jmp grid_line_sight_L12
grid_line_sight_L11:
; T5 = T1 - T3
    move.b T1,d0
    move.b T3,d1
    sub.b d1,d0
    move.b d0,T5
; T7 = 255
    move.b #255,d0
    move.b d0,T7
grid_line_sight_L12:
; T8 = 128 + T4
    move.b #128,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T8
; T8 = T8 - T5
    move.b T8,d0
    move.b T5,d1
    sub.b d1,d0
    move.b d0,T8
; T9 = FROM
    move.b FROM,d0
    move.b d0,T9
; while T9 != TO:
grid_line_sight_L13:
    move.b T9,d0
    move.b TO,d1
    cmp.b d1,d0
    bne grid_line_sight_L14
    jmp grid_line_sight_L15
grid_line_sight_L14:
; T10 = T8 - 128
    move.b T8,d0
    sub.b #128,d0
    move.b d0,T10
; T10 = T10 << 1
    move.b T10,d0
    lsl.b #1,d0
    move.b d0,T10
; T10 = T10 + 128
    move.b T10,d0
    add.b #128,d0
    move.b d0,T10
; T11 = 128 - T5
    move.b #128,d0
    move.b T5,d1
    sub.b d1,d0
    move.b d0,T11
; if T10 > T11:
    move.b T10,d0
    move.b T11,d1
    cmp.b d1,d0
    bhi grid_line_sight_L16
    jmp grid_line_sight_L17
grid_line_sight_L16:
; T8 = T8 - T5
    move.b T8,d0
    move.b T5,d1
    sub.b d1,d0
    move.b d0,T8
; T0 = T0 + T6
    move.b T0,d0
    move.b T6,d1
    add.b d1,d0
    move.b d0,T0
    jmp grid_line_sight_L18
grid_line_sight_L17:
grid_line_sight_L18:
; T11 = 128 + T4
    move.b #128,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T11
; if T10 < T11:
    move.b T10,d0
    move.b T11,d1
    cmp.b d1,d0
    bcs grid_line_sight_L19
    jmp grid_line_sight_L20
grid_line_sight_L19:
; T8 = T8 + T4
    move.b T8,d0
    move.b T4,d1
    add.b d1,d0
    move.b d0,T8
; T1 = T1 + T7
    move.b T1,d0
    move.b T7,d1
    add.b d1,d0
    move.b d0,T1
    jmp grid_line_sight_L21
grid_line_sight_L20:
grid_line_sight_L21:
; T9 = T1 << 2
    move.b T1,d0
    lsl.b #2,d0
    move.b d0,T9
; T9 = T9 + T0
    move.b T9,d0
    move.b T0,d1
    add.b d1,d0
    move.b d0,T9
; T11 = C[T9]
    moveq #0,d1
    move.b T9,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T11
; if T11 != 0:
    move.b T11,d0
    cmp.b #0,d0
    bne grid_line_sight_L22
    jmp grid_line_sight_L23
grid_line_sight_L22:
; return
    rts
    jmp grid_line_sight_L24
grid_line_sight_L23:
grid_line_sight_L24:
    jmp grid_line_sight_L13
grid_line_sight_L15:
; VISIBLE = 1
    move.b #1,d0
    move.b d0,VISIBLE
    rts
component_end:

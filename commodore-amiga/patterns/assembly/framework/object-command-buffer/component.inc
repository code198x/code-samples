; SPDX-License-Identifier: MIT
; Defer Object Changes Until After Traversal. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
object_command_buffer_init:
    move.b #0,d0
    move.b d0,APPLIED
    move.b d0,REJECTED
    move.b d0,FULL
    move.b d0,VALID
    move.b d0,MODE
    move.b d0,SLOT
    move.b d0,GENERATION
    move.b d0,ACTIVE
    move.b d0,COUNT
    move.b d0,G0
    move.b d0,G1
    move.b d0,G2
    move.b d0,G3
    move.b d0,O0
    move.b d0,O1
    move.b d0,O2
    move.b d0,O3
    move.b d0,S0
    move.b d0,S1
    move.b d0,S2
    move.b d0,S3
    move.b d0,H0
    move.b d0,H1
    move.b d0,H2
    move.b d0,H3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    move.b d0,T6
    move.b d0,EXPR_SAVE
    rts
object_command_buffer_step:
; APPLIED = 0
    move.b #0,d0
    move.b d0,APPLIED
; REJECTED = 0
    move.b #0,d0
    move.b d0,REJECTED
; FULL = 0
    move.b #0,d0
    move.b d0,FULL
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if ACTIVE >= 16:
    move.b ACTIVE,d0
    cmp.b #16,d0
    bcc object_command_buffer_L1
    jmp object_command_buffer_L2
object_command_buffer_L1:
; return
    rts
    jmp object_command_buffer_L3
object_command_buffer_L2:
object_command_buffer_L3:
; if COUNT > 4:
    move.b COUNT,d0
    cmp.b #4,d0
    bhi object_command_buffer_L4
    jmp object_command_buffer_L5
object_command_buffer_L4:
; return
    rts
    jmp object_command_buffer_L6
object_command_buffer_L5:
object_command_buffer_L6:
; if MODE > 3:
    move.b MODE,d0
    cmp.b #3,d0
    bhi object_command_buffer_L7
    jmp object_command_buffer_L8
object_command_buffer_L7:
; return
    rts
    jmp object_command_buffer_L9
object_command_buffer_L8:
object_command_buffer_L9:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq object_command_buffer_L10
    jmp object_command_buffer_L11
object_command_buffer_L10:
; COUNT = 0
    move.b #0,d0
    move.b d0,COUNT
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; return
    rts
    jmp object_command_buffer_L12
object_command_buffer_L11:
object_command_buffer_L12:
; if MODE < 3:
    move.b MODE,d0
    cmp.b #3,d0
    bcs object_command_buffer_L13
    jmp object_command_buffer_L14
object_command_buffer_L13:
; if SLOT >= 4:
    move.b SLOT,d0
    cmp.b #4,d0
    bcc object_command_buffer_L16
    jmp object_command_buffer_L17
object_command_buffer_L16:
; return
    rts
    jmp object_command_buffer_L18
object_command_buffer_L17:
object_command_buffer_L18:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if COUNT == 4:
    move.b COUNT,d0
    cmp.b #4,d0
    beq object_command_buffer_L19
    jmp object_command_buffer_L20
object_command_buffer_L19:
; FULL = 1
    move.b #1,d0
    move.b d0,FULL
; return
    rts
    jmp object_command_buffer_L21
object_command_buffer_L20:
object_command_buffer_L21:
; O[COUNT] = MODE
    move.b MODE,d0
    move.b d0,d2
    moveq #0,d1
    move.b COUNT,d1
    lea O0,a0
    move.b d2,0(a0,d1.w)
; S[COUNT] = SLOT
    move.b SLOT,d0
    move.b d0,d2
    moveq #0,d1
    move.b COUNT,d1
    lea S0,a0
    move.b d2,0(a0,d1.w)
; H[COUNT] = GENERATION
    move.b GENERATION,d0
    move.b d0,d2
    moveq #0,d1
    move.b COUNT,d1
    lea H0,a0
    move.b d2,0(a0,d1.w)
; COUNT = COUNT + 1
    move.b COUNT,d0
    add.b #1,d0
    move.b d0,COUNT
; return
    rts
    jmp object_command_buffer_L15
object_command_buffer_L14:
object_command_buffer_L15:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < COUNT:
object_command_buffer_L22:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs object_command_buffer_L23
    jmp object_command_buffer_L24
object_command_buffer_L23:
; T1 = O[T0]
    moveq #0,d1
    move.b T0,d1
    lea O0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if T1 == 0:
    move.b T1,d0
    cmp.b #0,d0
    beq object_command_buffer_L25
    jmp object_command_buffer_L26
object_command_buffer_L25:
; return
    rts
    jmp object_command_buffer_L27
object_command_buffer_L26:
object_command_buffer_L27:
; if T1 > 2:
    move.b T1,d0
    cmp.b #2,d0
    bhi object_command_buffer_L28
    jmp object_command_buffer_L29
object_command_buffer_L28:
; return
    rts
    jmp object_command_buffer_L30
object_command_buffer_L29:
object_command_buffer_L30:
; T1 = S[T0]
    moveq #0,d1
    move.b T0,d1
    lea S0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if T1 >= 4:
    move.b T1,d0
    cmp.b #4,d0
    bcc object_command_buffer_L31
    jmp object_command_buffer_L32
object_command_buffer_L31:
; return
    rts
    jmp object_command_buffer_L33
object_command_buffer_L32:
object_command_buffer_L33:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp object_command_buffer_L22
object_command_buffer_L24:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < COUNT:
object_command_buffer_L34:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs object_command_buffer_L35
    jmp object_command_buffer_L36
object_command_buffer_L35:
; T1 = S[T0]
    moveq #0,d1
    move.b T0,d1
    lea S0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; T3 = T1
    move.b T1,d0
    move.b d0,T3
; while T3 != 0:
object_command_buffer_L37:
    move.b T3,d0
    cmp.b #0,d0
    bne object_command_buffer_L38
    jmp object_command_buffer_L39
object_command_buffer_L38:
; T2 = T2 << 1
    move.b T2,d0
    lsl.b #1,d0
    move.b d0,T2
; T3 = T3 - 1
    move.b T3,d0
    sub.b #1,d0
    move.b d0,T3
    jmp object_command_buffer_L37
object_command_buffer_L39:
; T3 = ACTIVE & T2
    move.b ACTIVE,d0
    move.b T2,d1
    and.b d1,d0
    move.b d0,T3
; T4 = O[T0]
    moveq #0,d1
    move.b T0,d1
    lea O0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T4
; T5 = 0
    move.b #0,d0
    move.b d0,T5
; if T4 == 1:
    move.b T4,d0
    cmp.b #1,d0
    beq object_command_buffer_L40
    jmp object_command_buffer_L41
object_command_buffer_L40:
; if T3 == 0:
    move.b T3,d0
    cmp.b #0,d0
    beq object_command_buffer_L43
    jmp object_command_buffer_L44
object_command_buffer_L43:
; ACTIVE = ACTIVE | T2
    move.b ACTIVE,d0
    move.b T2,d1
    or.b d1,d0
    move.b d0,ACTIVE
; T4 = G[T1]
    moveq #0,d1
    move.b T1,d1
    lea G0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T4
; T4 = T4 + 1
    move.b T4,d0
    add.b #1,d0
    move.b d0,T4
; G[T1] = T4
    move.b T4,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea G0,a0
    move.b d2,0(a0,d1.w)
; T5 = 1
    move.b #1,d0
    move.b d0,T5
    jmp object_command_buffer_L45
object_command_buffer_L44:
object_command_buffer_L45:
    jmp object_command_buffer_L42
object_command_buffer_L41:
; if T3 != 0:
    move.b T3,d0
    cmp.b #0,d0
    bne object_command_buffer_L46
    jmp object_command_buffer_L47
object_command_buffer_L46:
; T4 = G[T1]
    moveq #0,d1
    move.b T1,d1
    lea G0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T4
; T6 = H[T0]
    moveq #0,d1
    move.b T0,d1
    lea H0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T6
; if T4 == T6:
    move.b T4,d0
    move.b T6,d1
    cmp.b d1,d0
    beq object_command_buffer_L49
    jmp object_command_buffer_L50
object_command_buffer_L49:
; ACTIVE = ACTIVE ^ T2
    move.b ACTIVE,d0
    move.b T2,d1
    eor.b d1,d0
    move.b d0,ACTIVE
; T5 = 1
    move.b #1,d0
    move.b d0,T5
    jmp object_command_buffer_L51
object_command_buffer_L50:
object_command_buffer_L51:
    jmp object_command_buffer_L48
object_command_buffer_L47:
object_command_buffer_L48:
object_command_buffer_L42:
; if T5 != 0:
    move.b T5,d0
    cmp.b #0,d0
    bne object_command_buffer_L52
    jmp object_command_buffer_L53
object_command_buffer_L52:
; APPLIED = APPLIED + 1
    move.b APPLIED,d0
    add.b #1,d0
    move.b d0,APPLIED
    jmp object_command_buffer_L54
object_command_buffer_L53:
; REJECTED = REJECTED + 1
    move.b REJECTED,d0
    add.b #1,d0
    move.b d0,REJECTED
object_command_buffer_L54:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp object_command_buffer_L34
object_command_buffer_L36:
; COUNT = 0
    move.b #0,d0
    move.b d0,COUNT
    rts
component_end:

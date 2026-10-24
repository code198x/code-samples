; SPDX-License-Identifier: MIT
; Find the First Step Along a Shortest Grid Path. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_grid_path_init:
    move.b #0,d0
    move.b d0,MOVE
    move.b d0,DISTANCE
    move.b d0,FOUND
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
    move.b d0,EXPR_SAVE
    move.b d0,V0
    move.b d0,V1
    move.b d0,V2
    move.b d0,V3
    move.b d0,V4
    move.b d0,V5
    move.b d0,V6
    move.b d0,V7
    move.b d0,V8
    move.b d0,V9
    move.b d0,V10
    move.b d0,V11
    move.b d0,V12
    move.b d0,V13
    move.b d0,V14
    move.b d0,V15
    rts
bounded_grid_path_step:
; MOVE = 0
    move.b #0,d0
    move.b d0,MOVE
; DISTANCE = 255
    move.b #255,d0
    move.b d0,DISTANCE
; FOUND = 0
    move.b #0,d0
    move.b d0,FOUND
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if FROM >= 16:
    move.b FROM,d0
    cmp.b #16,d0
    bcc bounded_grid_path_L1
    jmp bounded_grid_path_L2
bounded_grid_path_L1:
; return
    rts
    jmp bounded_grid_path_L3
bounded_grid_path_L2:
bounded_grid_path_L3:
; if TO >= 16:
    move.b TO,d0
    cmp.b #16,d0
    bcc bounded_grid_path_L4
    jmp bounded_grid_path_L5
bounded_grid_path_L4:
; return
    rts
    jmp bounded_grid_path_L6
bounded_grid_path_L5:
bounded_grid_path_L6:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = C[FROM]
    moveq #0,d1
    move.b FROM,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne bounded_grid_path_L7
    jmp bounded_grid_path_L8
bounded_grid_path_L7:
; return
    rts
    jmp bounded_grid_path_L9
bounded_grid_path_L8:
bounded_grid_path_L9:
; T0 = C[TO]
    moveq #0,d1
    move.b TO,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if T0 != 0:
    move.b T0,d0
    cmp.b #0,d0
    bne bounded_grid_path_L10
    jmp bounded_grid_path_L11
bounded_grid_path_L10:
; return
    rts
    jmp bounded_grid_path_L12
bounded_grid_path_L11:
bounded_grid_path_L12:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; while T0 < 16:
bounded_grid_path_L13:
    move.b T0,d0
    cmp.b #16,d0
    bcs bounded_grid_path_L14
    jmp bounded_grid_path_L15
bounded_grid_path_L14:
; V[T0] = 255
    move.b #255,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp bounded_grid_path_L13
bounded_grid_path_L15:
; V[TO] = 0
    move.b #0,d0
    move.b d0,d2
    moveq #0,d1
    move.b TO,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
; T0 = 1
    move.b #1,d0
    move.b d0,T0
; while T0 < 16:
bounded_grid_path_L16:
    move.b T0,d0
    cmp.b #16,d0
    bcs bounded_grid_path_L17
    jmp bounded_grid_path_L18
bounded_grid_path_L17:
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T1 < 16:
bounded_grid_path_L19:
    move.b T1,d0
    cmp.b #16,d0
    bcs bounded_grid_path_L20
    jmp bounded_grid_path_L21
bounded_grid_path_L20:
; T2 = C[T1]
    moveq #0,d1
    move.b T1,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; T3 = V[T1]
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T2 == 0:
    move.b T2,d0
    cmp.b #0,d0
    beq bounded_grid_path_L22
    jmp bounded_grid_path_L23
bounded_grid_path_L22:
; if T3 == 255:
    move.b T3,d0
    cmp.b #255,d0
    beq bounded_grid_path_L25
    jmp bounded_grid_path_L26
bounded_grid_path_L25:
; T4 = T0 - 1
    move.b T0,d0
    sub.b #1,d0
    move.b d0,T4
; T5 = T1 & 3
    move.b T1,d0
    and.b #3,d0
    move.b d0,T5
; if T5 != 0:
    move.b T5,d0
    cmp.b #0,d0
    bne bounded_grid_path_L28
    jmp bounded_grid_path_L29
bounded_grid_path_L28:
; T6 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T6
; T7 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T7
; if T7 == T4:
    move.b T7,d0
    move.b T4,d1
    cmp.b d1,d0
    beq bounded_grid_path_L31
    jmp bounded_grid_path_L32
bounded_grid_path_L31:
; V[T1] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
    jmp bounded_grid_path_L33
bounded_grid_path_L32:
bounded_grid_path_L33:
    jmp bounded_grid_path_L30
bounded_grid_path_L29:
bounded_grid_path_L30:
; if T5 != 3:
    move.b T5,d0
    cmp.b #3,d0
    bne bounded_grid_path_L34
    jmp bounded_grid_path_L35
bounded_grid_path_L34:
; T6 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T6
; T7 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T7
; if T7 == T4:
    move.b T7,d0
    move.b T4,d1
    cmp.b d1,d0
    beq bounded_grid_path_L37
    jmp bounded_grid_path_L38
bounded_grid_path_L37:
; V[T1] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
    jmp bounded_grid_path_L39
bounded_grid_path_L38:
bounded_grid_path_L39:
    jmp bounded_grid_path_L36
bounded_grid_path_L35:
bounded_grid_path_L36:
; if T1 >= 4:
    move.b T1,d0
    cmp.b #4,d0
    bcc bounded_grid_path_L40
    jmp bounded_grid_path_L41
bounded_grid_path_L40:
; T6 = T1 - 4
    move.b T1,d0
    sub.b #4,d0
    move.b d0,T6
; T7 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T7
; if T7 == T4:
    move.b T7,d0
    move.b T4,d1
    cmp.b d1,d0
    beq bounded_grid_path_L43
    jmp bounded_grid_path_L44
bounded_grid_path_L43:
; V[T1] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
    jmp bounded_grid_path_L45
bounded_grid_path_L44:
bounded_grid_path_L45:
    jmp bounded_grid_path_L42
bounded_grid_path_L41:
bounded_grid_path_L42:
; if T1 < 12:
    move.b T1,d0
    cmp.b #12,d0
    bcs bounded_grid_path_L46
    jmp bounded_grid_path_L47
bounded_grid_path_L46:
; T6 = T1 + 4
    move.b T1,d0
    add.b #4,d0
    move.b d0,T6
; T7 = V[T6]
    moveq #0,d1
    move.b T6,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T7
; if T7 == T4:
    move.b T7,d0
    move.b T4,d1
    cmp.b d1,d0
    beq bounded_grid_path_L49
    jmp bounded_grid_path_L50
bounded_grid_path_L49:
; V[T1] = T0
    move.b T0,d0
    move.b d0,d2
    moveq #0,d1
    move.b T1,d1
    lea V0,a0
    move.b d2,0(a0,d1.w)
    jmp bounded_grid_path_L51
bounded_grid_path_L50:
bounded_grid_path_L51:
    jmp bounded_grid_path_L48
bounded_grid_path_L47:
bounded_grid_path_L48:
    jmp bounded_grid_path_L27
bounded_grid_path_L26:
bounded_grid_path_L27:
    jmp bounded_grid_path_L24
bounded_grid_path_L23:
bounded_grid_path_L24:
; T1 = T1 + 1
    move.b T1,d0
    add.b #1,d0
    move.b d0,T1
    jmp bounded_grid_path_L19
bounded_grid_path_L21:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp bounded_grid_path_L16
bounded_grid_path_L18:
; DISTANCE = V[FROM]
    moveq #0,d1
    move.b FROM,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,DISTANCE
; if DISTANCE == 255:
    move.b DISTANCE,d0
    cmp.b #255,d0
    beq bounded_grid_path_L52
    jmp bounded_grid_path_L53
bounded_grid_path_L52:
; return
    rts
    jmp bounded_grid_path_L54
bounded_grid_path_L53:
bounded_grid_path_L54:
; FOUND = 1
    move.b #1,d0
    move.b d0,FOUND
; if DISTANCE == 0:
    move.b DISTANCE,d0
    cmp.b #0,d0
    beq bounded_grid_path_L55
    jmp bounded_grid_path_L56
bounded_grid_path_L55:
; return
    rts
    jmp bounded_grid_path_L57
bounded_grid_path_L56:
bounded_grid_path_L57:
; T0 = DISTANCE - 1
    move.b DISTANCE,d0
    sub.b #1,d0
    move.b d0,T0
; T1 = FROM & 3
    move.b FROM,d0
    and.b #3,d0
    move.b d0,T1
; if T1 != 0:
    move.b T1,d0
    cmp.b #0,d0
    bne bounded_grid_path_L58
    jmp bounded_grid_path_L59
bounded_grid_path_L58:
; T2 = FROM - 1
    move.b FROM,d0
    sub.b #1,d0
    move.b d0,T2
; T3 = V[T2]
    moveq #0,d1
    move.b T2,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 == T0:
    move.b T3,d0
    move.b T0,d1
    cmp.b d1,d0
    beq bounded_grid_path_L61
    jmp bounded_grid_path_L62
bounded_grid_path_L61:
; MOVE = 1
    move.b #1,d0
    move.b d0,MOVE
; return
    rts
    jmp bounded_grid_path_L63
bounded_grid_path_L62:
bounded_grid_path_L63:
    jmp bounded_grid_path_L60
bounded_grid_path_L59:
bounded_grid_path_L60:
; if T1 != 3:
    move.b T1,d0
    cmp.b #3,d0
    bne bounded_grid_path_L64
    jmp bounded_grid_path_L65
bounded_grid_path_L64:
; T2 = FROM + 1
    move.b FROM,d0
    add.b #1,d0
    move.b d0,T2
; T3 = V[T2]
    moveq #0,d1
    move.b T2,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 == T0:
    move.b T3,d0
    move.b T0,d1
    cmp.b d1,d0
    beq bounded_grid_path_L67
    jmp bounded_grid_path_L68
bounded_grid_path_L67:
; MOVE = 2
    move.b #2,d0
    move.b d0,MOVE
; return
    rts
    jmp bounded_grid_path_L69
bounded_grid_path_L68:
bounded_grid_path_L69:
    jmp bounded_grid_path_L66
bounded_grid_path_L65:
bounded_grid_path_L66:
; if FROM >= 4:
    move.b FROM,d0
    cmp.b #4,d0
    bcc bounded_grid_path_L70
    jmp bounded_grid_path_L71
bounded_grid_path_L70:
; T2 = FROM - 4
    move.b FROM,d0
    sub.b #4,d0
    move.b d0,T2
; T3 = V[T2]
    moveq #0,d1
    move.b T2,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 == T0:
    move.b T3,d0
    move.b T0,d1
    cmp.b d1,d0
    beq bounded_grid_path_L73
    jmp bounded_grid_path_L74
bounded_grid_path_L73:
; MOVE = 3
    move.b #3,d0
    move.b d0,MOVE
; return
    rts
    jmp bounded_grid_path_L75
bounded_grid_path_L74:
bounded_grid_path_L75:
    jmp bounded_grid_path_L72
bounded_grid_path_L71:
bounded_grid_path_L72:
; if FROM < 12:
    move.b FROM,d0
    cmp.b #12,d0
    bcs bounded_grid_path_L76
    jmp bounded_grid_path_L77
bounded_grid_path_L76:
; T2 = FROM + 4
    move.b FROM,d0
    add.b #4,d0
    move.b d0,T2
; T3 = V[T2]
    moveq #0,d1
    move.b T2,d1
    lea V0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 == T0:
    move.b T3,d0
    move.b T0,d1
    cmp.b d1,d0
    beq bounded_grid_path_L79
    jmp bounded_grid_path_L80
bounded_grid_path_L79:
; MOVE = 4
    move.b #4,d0
    move.b d0,MOVE
    jmp bounded_grid_path_L81
bounded_grid_path_L80:
bounded_grid_path_L81:
    jmp bounded_grid_path_L78
bounded_grid_path_L77:
bounded_grid_path_L78:
    rts
component_end:

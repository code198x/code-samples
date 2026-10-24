; SPDX-License-Identifier: MIT
; Keep a Stable Interaction Focus. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
interaction_focus_init:
    move.b #0,d0
    move.b d0,SELECTED
    move.b d0,VALID
    move.b d0,CURRENT
    move.b d0,ACTIVE
    move.b d0,RANGE
    move.b d0,MARGIN
    move.b d0,DIST0
    move.b d0,DIST1
    move.b d0,DIST2
    move.b d0,DIST3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,T3
    move.b d0,T4
    move.b d0,T5
    rts
interaction_focus_step:
; SELECTED = 255
    move.b #255,d0
    move.b d0,SELECTED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if CURRENT != 255:
    move.b CURRENT,d0
    cmp.b #255,d0
    bne interaction_focus_L1
    jmp interaction_focus_L2
interaction_focus_L1:
; if CURRENT >= 4:
    move.b CURRENT,d0
    cmp.b #4,d0
    bcc interaction_focus_L4
    jmp interaction_focus_L5
interaction_focus_L4:
; return
    rts
    jmp interaction_focus_L6
interaction_focus_L5:
interaction_focus_L6:
    jmp interaction_focus_L3
interaction_focus_L2:
interaction_focus_L3:
; if ACTIVE >= 16:
    move.b ACTIVE,d0
    cmp.b #16,d0
    bcc interaction_focus_L7
    jmp interaction_focus_L8
interaction_focus_L7:
; return
    rts
    jmp interaction_focus_L9
interaction_focus_L8:
interaction_focus_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = ACTIVE
    move.b ACTIVE,d0
    move.b d0,T1
; T2 = 255
    move.b #255,d0
    move.b d0,T2
; T3 = 0
    move.b #0,d0
    move.b d0,T3
; T4 = 255
    move.b #255,d0
    move.b d0,T4
; while T0 < 4:
interaction_focus_L10:
    move.b T0,d0
    cmp.b #4,d0
    bcs interaction_focus_L11
    jmp interaction_focus_L12
interaction_focus_L11:
; T5 = T1 & 1
    move.b T1,d0
    and.b #1,d0
    move.b d0,T5
; if T5 != 0:
    move.b T5,d0
    cmp.b #0,d0
    bne interaction_focus_L13
    jmp interaction_focus_L14
interaction_focus_L13:
; T5 = D[T0]
    moveq #0,d1
    move.b T0,d1
    lea DIST0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T5
; if T5 <= RANGE:
    move.b T5,d0
    move.b RANGE,d1
    cmp.b d1,d0
    bls interaction_focus_L16
    jmp interaction_focus_L17
interaction_focus_L16:
; if SELECTED == 255:
    move.b SELECTED,d0
    cmp.b #255,d0
    beq interaction_focus_L19
    jmp interaction_focus_L20
interaction_focus_L19:
; SELECTED = T0
    move.b T0,d0
    move.b d0,SELECTED
; T2 = T5
    move.b T5,d0
    move.b d0,T2
    jmp interaction_focus_L21
interaction_focus_L20:
; if T5 < T2:
    move.b T5,d0
    move.b T2,d1
    cmp.b d1,d0
    bcs interaction_focus_L22
    jmp interaction_focus_L23
interaction_focus_L22:
; SELECTED = T0
    move.b T0,d0
    move.b d0,SELECTED
; T2 = T5
    move.b T5,d0
    move.b d0,T2
    jmp interaction_focus_L24
interaction_focus_L23:
interaction_focus_L24:
interaction_focus_L21:
; if T0 == CURRENT:
    move.b T0,d0
    move.b CURRENT,d1
    cmp.b d1,d0
    beq interaction_focus_L25
    jmp interaction_focus_L26
interaction_focus_L25:
; T3 = 1
    move.b #1,d0
    move.b d0,T3
; T4 = T5
    move.b T5,d0
    move.b d0,T4
    jmp interaction_focus_L27
interaction_focus_L26:
interaction_focus_L27:
    jmp interaction_focus_L18
interaction_focus_L17:
interaction_focus_L18:
    jmp interaction_focus_L15
interaction_focus_L14:
interaction_focus_L15:
; T1 = T1 >> 1
    move.b T1,d0
    lsr.b #1,d0
    move.b d0,T1
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp interaction_focus_L10
interaction_focus_L12:
; if T3 != 0:
    move.b T3,d0
    cmp.b #0,d0
    bne interaction_focus_L28
    jmp interaction_focus_L29
interaction_focus_L28:
; T5 = T4 - T2
    move.b T4,d0
    move.b T2,d1
    sub.b d1,d0
    move.b d0,T5
; if T5 <= MARGIN:
    move.b T5,d0
    move.b MARGIN,d1
    cmp.b d1,d0
    bls interaction_focus_L31
    jmp interaction_focus_L32
interaction_focus_L31:
; SELECTED = CURRENT
    move.b CURRENT,d0
    move.b d0,SELECTED
    jmp interaction_focus_L33
interaction_focus_L32:
interaction_focus_L33:
    jmp interaction_focus_L30
interaction_focus_L29:
interaction_focus_L30:
    rts
component_end:

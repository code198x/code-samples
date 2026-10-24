; SPDX-License-Identifier: MIT
; Choose a Bounded Text Line. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
bounded_text_wrap_init:
    move.b #0,d0
    move.b d0,LENGTH
    move.b d0,NEXT
    move.b d0,VALID
    move.b d0,START
    move.b d0,WIDTH
    move.b d0,COUNT
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
    rts
bounded_text_wrap_step:
; LENGTH = 0
    move.b #0,d0
    move.b d0,LENGTH
; NEXT = START
    move.b START,d0
    move.b d0,NEXT
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if COUNT > 16:
    move.b COUNT,d0
    cmp.b #16,d0
    bhi bounded_text_wrap_L1
    jmp bounded_text_wrap_L2
bounded_text_wrap_L1:
; return
    rts
    jmp bounded_text_wrap_L3
bounded_text_wrap_L2:
bounded_text_wrap_L3:
; if START > COUNT:
    move.b START,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bhi bounded_text_wrap_L4
    jmp bounded_text_wrap_L5
bounded_text_wrap_L4:
; return
    rts
    jmp bounded_text_wrap_L6
bounded_text_wrap_L5:
bounded_text_wrap_L6:
; if WIDTH == 0:
    move.b WIDTH,d0
    cmp.b #0,d0
    beq bounded_text_wrap_L7
    jmp bounded_text_wrap_L8
bounded_text_wrap_L7:
; return
    rts
    jmp bounded_text_wrap_L9
bounded_text_wrap_L8:
bounded_text_wrap_L9:
; if WIDTH > 16:
    move.b WIDTH,d0
    cmp.b #16,d0
    bhi bounded_text_wrap_L10
    jmp bounded_text_wrap_L11
bounded_text_wrap_L10:
; return
    rts
    jmp bounded_text_wrap_L12
bounded_text_wrap_L11:
bounded_text_wrap_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; while START < COUNT:
bounded_text_wrap_L13:
    move.b START,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs bounded_text_wrap_L14
    jmp bounded_text_wrap_L15
bounded_text_wrap_L14:
; T0 = C[START]
    moveq #0,d1
    move.b START,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T0
; if T0 != 32:
    move.b T0,d0
    cmp.b #32,d0
    bne bounded_text_wrap_L16
    jmp bounded_text_wrap_L17
bounded_text_wrap_L16:
; break
    jmp bounded_text_wrap_L15
    jmp bounded_text_wrap_L18
bounded_text_wrap_L17:
bounded_text_wrap_L18:
; START = START + 1
    move.b START,d0
    add.b #1,d0
    move.b d0,START
    jmp bounded_text_wrap_L13
bounded_text_wrap_L15:
; NEXT = START
    move.b START,d0
    move.b d0,NEXT
; T0 = START
    move.b START,d0
    move.b d0,T0
; T1 = 255
    move.b #255,d0
    move.b d0,T1
; while T0 < COUNT:
bounded_text_wrap_L19:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs bounded_text_wrap_L20
    jmp bounded_text_wrap_L21
bounded_text_wrap_L20:
; T2 = T0 - START
    move.b T0,d0
    move.b START,d1
    sub.b d1,d0
    move.b d0,T2
; if T2 == WIDTH:
    move.b T2,d0
    move.b WIDTH,d1
    cmp.b d1,d0
    beq bounded_text_wrap_L22
    jmp bounded_text_wrap_L23
bounded_text_wrap_L22:
; break
    jmp bounded_text_wrap_L21
    jmp bounded_text_wrap_L24
bounded_text_wrap_L23:
bounded_text_wrap_L24:
; T2 = C[T0]
    moveq #0,d1
    move.b T0,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; if T2 == 32:
    move.b T2,d0
    cmp.b #32,d0
    beq bounded_text_wrap_L25
    jmp bounded_text_wrap_L26
bounded_text_wrap_L25:
; T1 = T0
    move.b T0,d0
    move.b d0,T1
    jmp bounded_text_wrap_L27
bounded_text_wrap_L26:
bounded_text_wrap_L27:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp bounded_text_wrap_L19
bounded_text_wrap_L21:
; T2 = T0
    move.b T0,d0
    move.b d0,T2
; if T0 < COUNT:
    move.b T0,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs bounded_text_wrap_L28
    jmp bounded_text_wrap_L29
bounded_text_wrap_L28:
; T3 = C[T0]
    moveq #0,d1
    move.b T0,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 != 32:
    move.b T3,d0
    cmp.b #32,d0
    bne bounded_text_wrap_L31
    jmp bounded_text_wrap_L32
bounded_text_wrap_L31:
; if T1 != 255:
    move.b T1,d0
    cmp.b #255,d0
    bne bounded_text_wrap_L34
    jmp bounded_text_wrap_L35
bounded_text_wrap_L34:
; T2 = T1
    move.b T1,d0
    move.b d0,T2
    jmp bounded_text_wrap_L36
bounded_text_wrap_L35:
bounded_text_wrap_L36:
    jmp bounded_text_wrap_L33
bounded_text_wrap_L32:
bounded_text_wrap_L33:
    jmp bounded_text_wrap_L30
bounded_text_wrap_L29:
bounded_text_wrap_L30:
; LENGTH = T2 - START
    move.b T2,d0
    move.b START,d1
    sub.b d1,d0
    move.b d0,LENGTH
; NEXT = T2
    move.b T2,d0
    move.b d0,NEXT
; while NEXT < COUNT:
bounded_text_wrap_L37:
    move.b NEXT,d0
    move.b COUNT,d1
    cmp.b d1,d0
    bcs bounded_text_wrap_L38
    jmp bounded_text_wrap_L39
bounded_text_wrap_L38:
; T3 = C[NEXT]
    moveq #0,d1
    move.b NEXT,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T3
; if T3 != 32:
    move.b T3,d0
    cmp.b #32,d0
    bne bounded_text_wrap_L40
    jmp bounded_text_wrap_L41
bounded_text_wrap_L40:
; break
    jmp bounded_text_wrap_L39
    jmp bounded_text_wrap_L42
bounded_text_wrap_L41:
bounded_text_wrap_L42:
; NEXT = NEXT + 1
    move.b NEXT,d0
    add.b #1,d0
    move.b d0,NEXT
    jmp bounded_text_wrap_L37
bounded_text_wrap_L39:
    rts
component_end:

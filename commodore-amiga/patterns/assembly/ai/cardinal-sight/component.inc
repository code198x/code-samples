; SPDX-License-Identifier: MIT
; Test Sight Along a Grid Row or Column. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
cardinal_sight_init:
    move.b #0,d0
    move.b d0,FROM
    move.b d0,TO
    move.b d0,VISIBLE
    move.b d0,VALID
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
    rts
cardinal_sight_step:
; VISIBLE = 0
    move.b #0,d0
    move.b d0,VISIBLE
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if FROM >= 16:
    move.b FROM,d0
    cmp.b #16,d0
    bcc cardinal_sight_L1
    jmp cardinal_sight_L2
cardinal_sight_L1:
; return
    rts
    jmp cardinal_sight_L3
cardinal_sight_L2:
cardinal_sight_L3:
; if TO >= 16:
    move.b TO,d0
    cmp.b #16,d0
    bcc cardinal_sight_L4
    jmp cardinal_sight_L5
cardinal_sight_L4:
; return
    rts
    jmp cardinal_sight_L6
cardinal_sight_L5:
cardinal_sight_L6:
; if FROM == TO:
    move.b FROM,d0
    move.b TO,d1
    cmp.b d1,d0
    beq cardinal_sight_L7
    jmp cardinal_sight_L8
cardinal_sight_L7:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; VISIBLE = 1
    move.b #1,d0
    move.b d0,VISIBLE
; return
    rts
    jmp cardinal_sight_L9
cardinal_sight_L8:
cardinal_sight_L9:
; T0 = FROM >> 2
    move.b FROM,d0
    lsr.b #2,d0
    move.b d0,T0
; T1 = TO >> 2
    move.b TO,d0
    lsr.b #2,d0
    move.b d0,T1
; T2 = 1
    move.b #1,d0
    move.b d0,T2
; if T0 != T1:
    move.b T0,d0
    move.b T1,d1
    cmp.b d1,d0
    bne cardinal_sight_L10
    jmp cardinal_sight_L11
cardinal_sight_L10:
; T0 = FROM & 3
    move.b FROM,d0
    and.b #3,d0
    move.b d0,T0
; T1 = TO & 3
    move.b TO,d0
    and.b #3,d0
    move.b d0,T1
; if T0 != T1:
    move.b T0,d0
    move.b T1,d1
    cmp.b d1,d0
    bne cardinal_sight_L13
    jmp cardinal_sight_L14
cardinal_sight_L13:
; return
    rts
    jmp cardinal_sight_L15
cardinal_sight_L14:
cardinal_sight_L15:
; T2 = 4
    move.b #4,d0
    move.b d0,T2
    jmp cardinal_sight_L12
cardinal_sight_L11:
cardinal_sight_L12:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = FROM
    move.b FROM,d0
    move.b d0,T0
; while T0 != TO:
cardinal_sight_L16:
    move.b T0,d0
    move.b TO,d1
    cmp.b d1,d0
    bne cardinal_sight_L17
    jmp cardinal_sight_L18
cardinal_sight_L17:
; if T0 < TO:
    move.b T0,d0
    move.b TO,d1
    cmp.b d1,d0
    bcs cardinal_sight_L19
    jmp cardinal_sight_L20
cardinal_sight_L19:
; T0 = T0 + T2
    move.b T0,d0
    move.b T2,d1
    add.b d1,d0
    move.b d0,T0
    jmp cardinal_sight_L21
cardinal_sight_L20:
; T0 = T0 - T2
    move.b T0,d0
    move.b T2,d1
    sub.b d1,d0
    move.b d0,T0
cardinal_sight_L21:
; T1 = C[T0]
    moveq #0,d1
    move.b T0,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if T1 != 0:
    move.b T1,d0
    cmp.b #0,d0
    bne cardinal_sight_L22
    jmp cardinal_sight_L23
cardinal_sight_L22:
; return
    rts
    jmp cardinal_sight_L24
cardinal_sight_L23:
cardinal_sight_L24:
    jmp cardinal_sight_L16
cardinal_sight_L18:
; VISIBLE = 1
    move.b #1,d0
    move.b d0,VISIBLE
    rts
component_end:

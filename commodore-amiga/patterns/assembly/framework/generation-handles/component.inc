; SPDX-License-Identifier: MIT
; Reject Stale Object Handles. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
generation_handles_init:
    move.b #0,d0
    move.b d0,RESULT
    move.b d0,OUT_SLOT
    move.b d0,OUT_GENERATION
    move.b d0,VALID
    move.b d0,MODE
    move.b d0,SLOT
    move.b d0,GENERATION
    move.b d0,ACTIVE
    move.b d0,G0
    move.b d0,G1
    move.b d0,G2
    move.b d0,G3
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    move.b d0,EXPR_SAVE
    rts
generation_handles_step:
; RESULT = 0
    move.b #0,d0
    move.b d0,RESULT
; OUT_SLOT = 255
    move.b #255,d0
    move.b d0,OUT_SLOT
; OUT_GENERATION = 0
    move.b #0,d0
    move.b d0,OUT_GENERATION
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if ACTIVE > 15:
    move.b ACTIVE,d0
    cmp.b #15,d0
    bhi generation_handles_L1
    jmp generation_handles_L2
generation_handles_L1:
; return
    rts
    jmp generation_handles_L3
generation_handles_L2:
generation_handles_L3:
; if MODE >= 3:
    move.b MODE,d0
    cmp.b #3,d0
    bcc generation_handles_L4
    jmp generation_handles_L5
generation_handles_L4:
; return
    rts
    jmp generation_handles_L6
generation_handles_L5:
generation_handles_L6:
; if MODE == 0:
    move.b MODE,d0
    cmp.b #0,d0
    beq generation_handles_L7
    jmp generation_handles_L8
generation_handles_L7:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = 1
    move.b #1,d0
    move.b d0,T1
; while T0 < 4:
generation_handles_L10:
    move.b T0,d0
    cmp.b #4,d0
    bcs generation_handles_L11
    jmp generation_handles_L12
generation_handles_L11:
; T2 = ACTIVE & T1
    move.b ACTIVE,d0
    move.b T1,d1
    and.b d1,d0
    move.b d0,T2
; if T2 == 0:
    move.b T2,d0
    cmp.b #0,d0
    beq generation_handles_L13
    jmp generation_handles_L14
generation_handles_L13:
; T2 = G[T0]
    moveq #0,d1
    move.b T0,d1
    lea G0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; T2 = T2 + 1
    move.b T2,d0
    add.b #1,d0
    move.b d0,T2
; G[T0] = T2
    move.b T2,d0
    move.b d0,d2
    moveq #0,d1
    move.b T0,d1
    lea G0,a0
    move.b d2,0(a0,d1.w)
; ACTIVE = ACTIVE | T1
    move.b ACTIVE,d0
    move.b T1,d1
    or.b d1,d0
    move.b d0,ACTIVE
; OUT_SLOT = T0
    move.b T0,d0
    move.b d0,OUT_SLOT
; OUT_GENERATION = T2
    move.b T2,d0
    move.b d0,OUT_GENERATION
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
; return
    rts
    jmp generation_handles_L15
generation_handles_L14:
generation_handles_L15:
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
; T1 = T1 << 1
    move.b T1,d0
    lsl.b #1,d0
    move.b d0,T1
    jmp generation_handles_L10
generation_handles_L12:
; return
    rts
    jmp generation_handles_L9
generation_handles_L8:
generation_handles_L9:
; if SLOT >= 4:
    move.b SLOT,d0
    cmp.b #4,d0
    bcc generation_handles_L16
    jmp generation_handles_L17
generation_handles_L16:
; return
    rts
    jmp generation_handles_L18
generation_handles_L17:
generation_handles_L18:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; T0 = 1
    move.b #1,d0
    move.b d0,T0
; T1 = SLOT
    move.b SLOT,d0
    move.b d0,T1
; while T1 != 0:
generation_handles_L19:
    move.b T1,d0
    cmp.b #0,d0
    bne generation_handles_L20
    jmp generation_handles_L21
generation_handles_L20:
; T0 = T0 << 1
    move.b T0,d0
    lsl.b #1,d0
    move.b d0,T0
; T1 = T1 - 1
    move.b T1,d0
    sub.b #1,d0
    move.b d0,T1
    jmp generation_handles_L19
generation_handles_L21:
; T1 = ACTIVE & T0
    move.b ACTIVE,d0
    move.b T0,d1
    and.b d1,d0
    move.b d0,T1
; if T1 == 0:
    move.b T1,d0
    cmp.b #0,d0
    beq generation_handles_L22
    jmp generation_handles_L23
generation_handles_L22:
; return
    rts
    jmp generation_handles_L24
generation_handles_L23:
generation_handles_L24:
; T1 = G[SLOT]
    moveq #0,d1
    move.b SLOT,d1
    lea G0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T1
; if T1 != GENERATION:
    move.b T1,d0
    move.b GENERATION,d1
    cmp.b d1,d0
    bne generation_handles_L25
    jmp generation_handles_L26
generation_handles_L25:
; return
    rts
    jmp generation_handles_L27
generation_handles_L26:
generation_handles_L27:
; OUT_SLOT = SLOT
    move.b SLOT,d0
    move.b d0,OUT_SLOT
; OUT_GENERATION = T1
    move.b T1,d0
    move.b d0,OUT_GENERATION
; RESULT = 1
    move.b #1,d0
    move.b d0,RESULT
; if MODE == 1:
    move.b MODE,d0
    cmp.b #1,d0
    beq generation_handles_L28
    jmp generation_handles_L29
generation_handles_L28:
; T0 = T0 ^ 255
    move.b T0,d0
    eor.b #255,d0
    move.b d0,T0
; ACTIVE = ACTIVE & T0
    move.b ACTIVE,d0
    move.b T0,d1
    and.b d1,d0
    move.b d0,ACTIVE
    jmp generation_handles_L30
generation_handles_L29:
generation_handles_L30:
    rts
component_end:

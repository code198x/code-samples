; SPDX-License-Identifier: MIT
; Validate a Save Before Replacing Live State. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
save_record_validation_init:
    move.b #0,d0
    move.b d0,ACCEPTED
    move.b d0,VALID
    move.b d0,MODE
    move.b d0,L0
    move.b d0,L1
    move.b d0,L2
    move.b d0,L3
    move.b d0,C0
    move.b d0,C1
    move.b d0,C2
    move.b d0,C3
    move.b d0,C4
    move.b d0,C5
    move.b d0,C6
    move.b d0,C7
    move.b d0,T0
    move.b d0,T1
    move.b d0,T2
    rts
save_record_validation_step:
; ACCEPTED = 0
    move.b #0,d0
    move.b d0,ACCEPTED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MODE > 1:
    move.b MODE,d0
    cmp.b #1,d0
    bhi save_record_validation_L1
    jmp save_record_validation_L2
save_record_validation_L1:
; return
    rts
    jmp save_record_validation_L3
save_record_validation_L2:
save_record_validation_L3:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if C0 != 198:
    move.b C0,d0
    cmp.b #198,d0
    bne save_record_validation_L4
    jmp save_record_validation_L5
save_record_validation_L4:
; return
    rts
    jmp save_record_validation_L6
save_record_validation_L5:
save_record_validation_L6:
; if C1 != 1:
    move.b C1,d0
    cmp.b #1,d0
    bne save_record_validation_L7
    jmp save_record_validation_L8
save_record_validation_L7:
; return
    rts
    jmp save_record_validation_L9
save_record_validation_L8:
save_record_validation_L9:
; if C2 != 4:
    move.b C2,d0
    cmp.b #4,d0
    bne save_record_validation_L10
    jmp save_record_validation_L11
save_record_validation_L10:
; return
    rts
    jmp save_record_validation_L12
save_record_validation_L11:
save_record_validation_L12:
; if C3 > 15:
    move.b C3,d0
    cmp.b #15,d0
    bhi save_record_validation_L13
    jmp save_record_validation_L14
save_record_validation_L13:
; return
    rts
    jmp save_record_validation_L15
save_record_validation_L14:
save_record_validation_L15:
; if C4 > 31:
    move.b C4,d0
    cmp.b #31,d0
    bhi save_record_validation_L16
    jmp save_record_validation_L17
save_record_validation_L16:
; return
    rts
    jmp save_record_validation_L18
save_record_validation_L17:
save_record_validation_L18:
; if C5 > 9:
    move.b C5,d0
    cmp.b #9,d0
    bhi save_record_validation_L19
    jmp save_record_validation_L20
save_record_validation_L19:
; return
    rts
    jmp save_record_validation_L21
save_record_validation_L20:
save_record_validation_L21:
; if C6 > 15:
    move.b C6,d0
    cmp.b #15,d0
    bhi save_record_validation_L22
    jmp save_record_validation_L23
save_record_validation_L22:
; return
    rts
    jmp save_record_validation_L24
save_record_validation_L23:
save_record_validation_L24:
; T0 = 0
    move.b #0,d0
    move.b d0,T0
; T1 = 0
    move.b #0,d0
    move.b d0,T1
; while T0 < 7:
save_record_validation_L25:
    move.b T0,d0
    cmp.b #7,d0
    bcs save_record_validation_L26
    jmp save_record_validation_L27
save_record_validation_L26:
; T2 = C[T0]
    moveq #0,d1
    move.b T0,d1
    lea C0,a0
    move.b 0(a0,d1.w),d0
    move.b d0,T2
; T1 = T1 ^ T2
    move.b T1,d0
    move.b T2,d1
    eor.b d1,d0
    move.b d0,T1
; T0 = T0 + 1
    move.b T0,d0
    add.b #1,d0
    move.b d0,T0
    jmp save_record_validation_L25
save_record_validation_L27:
; if T1 != C7:
    move.b T1,d0
    move.b C7,d1
    cmp.b d1,d0
    bne save_record_validation_L28
    jmp save_record_validation_L29
save_record_validation_L28:
; return
    rts
    jmp save_record_validation_L30
save_record_validation_L29:
save_record_validation_L30:
; ACCEPTED = 1
    move.b #1,d0
    move.b d0,ACCEPTED
; if MODE == 1:
    move.b MODE,d0
    cmp.b #1,d0
    beq save_record_validation_L31
    jmp save_record_validation_L32
save_record_validation_L31:
; L0 = C3
    move.b C3,d0
    move.b d0,L0
; L1 = C4
    move.b C4,d0
    move.b d0,L1
; L2 = C5
    move.b C5,d0
    move.b d0,L2
; L3 = C6
    move.b C6,d0
    move.b d0,L3
    jmp save_record_validation_L33
save_record_validation_L32:
save_record_validation_L33:
    rts
component_end:

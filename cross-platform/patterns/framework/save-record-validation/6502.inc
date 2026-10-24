; SPDX-License-Identifier: MIT
; Validate a Save Before Replacing Live State. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
save_record_validation_init:
    lda #0
    sta ACCEPTED
    sta VALID
    sta MODE
    sta L0
    sta L1
    sta L2
    sta L3
    sta C0
    sta C1
    sta C2
    sta C3
    sta C4
    sta C5
    sta C6
    sta C7
    sta T0
    sta T1
    sta T2
    rts
save_record_validation_step:
; ACCEPTED = 0
    lda #0
    sta ACCEPTED
; VALID = 0
    lda #0
    sta VALID
; if MODE > 1:
    lda MODE
    cmp #1
    beq save_record_validation_L5
    bcs save_record_validation_L4
save_record_validation_L5:
    jmp save_record_validation_L2
save_record_validation_L4:
    jmp save_record_validation_L1
save_record_validation_L1:
; return
    rts
    jmp save_record_validation_L3
save_record_validation_L2:
save_record_validation_L3:
; VALID = 1
    lda #1
    sta VALID
; if C0 != 198:
    lda C0
    cmp #198
    bne save_record_validation_L9
save_record_validation_L10:
    jmp save_record_validation_L7
save_record_validation_L9:
    jmp save_record_validation_L6
save_record_validation_L6:
; return
    rts
    jmp save_record_validation_L8
save_record_validation_L7:
save_record_validation_L8:
; if C1 != 1:
    lda C1
    cmp #1
    bne save_record_validation_L14
save_record_validation_L15:
    jmp save_record_validation_L12
save_record_validation_L14:
    jmp save_record_validation_L11
save_record_validation_L11:
; return
    rts
    jmp save_record_validation_L13
save_record_validation_L12:
save_record_validation_L13:
; if C2 != 4:
    lda C2
    cmp #4
    bne save_record_validation_L19
save_record_validation_L20:
    jmp save_record_validation_L17
save_record_validation_L19:
    jmp save_record_validation_L16
save_record_validation_L16:
; return
    rts
    jmp save_record_validation_L18
save_record_validation_L17:
save_record_validation_L18:
; if C3 > 15:
    lda C3
    cmp #15
    beq save_record_validation_L25
    bcs save_record_validation_L24
save_record_validation_L25:
    jmp save_record_validation_L22
save_record_validation_L24:
    jmp save_record_validation_L21
save_record_validation_L21:
; return
    rts
    jmp save_record_validation_L23
save_record_validation_L22:
save_record_validation_L23:
; if C4 > 31:
    lda C4
    cmp #31
    beq save_record_validation_L30
    bcs save_record_validation_L29
save_record_validation_L30:
    jmp save_record_validation_L27
save_record_validation_L29:
    jmp save_record_validation_L26
save_record_validation_L26:
; return
    rts
    jmp save_record_validation_L28
save_record_validation_L27:
save_record_validation_L28:
; if C5 > 9:
    lda C5
    cmp #9
    beq save_record_validation_L35
    bcs save_record_validation_L34
save_record_validation_L35:
    jmp save_record_validation_L32
save_record_validation_L34:
    jmp save_record_validation_L31
save_record_validation_L31:
; return
    rts
    jmp save_record_validation_L33
save_record_validation_L32:
save_record_validation_L33:
; if C6 > 15:
    lda C6
    cmp #15
    beq save_record_validation_L40
    bcs save_record_validation_L39
save_record_validation_L40:
    jmp save_record_validation_L37
save_record_validation_L39:
    jmp save_record_validation_L36
save_record_validation_L36:
; return
    rts
    jmp save_record_validation_L38
save_record_validation_L37:
save_record_validation_L38:
; T0 = 0
    lda #0
    sta T0
; T1 = 0
    lda #0
    sta T1
; while T0 < 7:
save_record_validation_L41:
    lda T0
    cmp #7
    bcc save_record_validation_L44
save_record_validation_L45:
    jmp save_record_validation_L43
save_record_validation_L44:
    jmp save_record_validation_L42
save_record_validation_L42:
; T2 = C[T0]
    ldx T0
    lda C0,x
    sta T2
; T1 = T1 ^ T2
    lda T1
    eor T2
    sta T1
; T0 = T0 + 1
    lda T0
    clc
    adc #1
    sta T0
    jmp save_record_validation_L41
save_record_validation_L43:
; if T1 != C7:
    lda T1
    cmp C7
    bne save_record_validation_L49
save_record_validation_L50:
    jmp save_record_validation_L47
save_record_validation_L49:
    jmp save_record_validation_L46
save_record_validation_L46:
; return
    rts
    jmp save_record_validation_L48
save_record_validation_L47:
save_record_validation_L48:
; ACCEPTED = 1
    lda #1
    sta ACCEPTED
; if MODE == 1:
    lda MODE
    cmp #1
    beq save_record_validation_L54
save_record_validation_L55:
    jmp save_record_validation_L52
save_record_validation_L54:
    jmp save_record_validation_L51
save_record_validation_L51:
; L0 = C3
    lda C3
    sta L0
; L1 = C4
    lda C4
    sta L1
; L2 = C5
    lda C5
    sta L2
; L3 = C6
    lda C6
    sta L3
    jmp save_record_validation_L53
save_record_validation_L52:
save_record_validation_L53:
    rts
component_end:

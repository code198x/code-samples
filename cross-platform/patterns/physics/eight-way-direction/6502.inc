; SPDX-License-Identifier: MIT
; Choose an Eight-way Direction. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
eight_way_direction_init:
    lda #0
    sta DIRECTION
    sta DX
    sta DY
    sta FROM_X
    sta FROM_Y
    sta TO_X
    sta TO_Y
    sta T0
    sta T1
    sta T2
    rts
eight_way_direction_step:
; T0 = 0
    lda #0
    sta T0
; T1 = 0
    lda #0
    sta T1
; if TO_X >= FROM_X:
    lda TO_X
    cmp FROM_X
    bcs eight_way_direction_L4
eight_way_direction_L5:
    jmp eight_way_direction_L2
eight_way_direction_L4:
    jmp eight_way_direction_L1
eight_way_direction_L1:
; DX = TO_X - FROM_X
    lda TO_X
    sec
    sbc FROM_X
    sta DX
    jmp eight_way_direction_L3
eight_way_direction_L2:
; DX = FROM_X - TO_X
    lda FROM_X
    sec
    sbc TO_X
    sta DX
; T0 = 1
    lda #1
    sta T0
eight_way_direction_L3:
; if TO_Y >= FROM_Y:
    lda TO_Y
    cmp FROM_Y
    bcs eight_way_direction_L9
eight_way_direction_L10:
    jmp eight_way_direction_L7
eight_way_direction_L9:
    jmp eight_way_direction_L6
eight_way_direction_L6:
; DY = TO_Y - FROM_Y
    lda TO_Y
    sec
    sbc FROM_Y
    sta DY
    jmp eight_way_direction_L8
eight_way_direction_L7:
; DY = FROM_Y - TO_Y
    lda FROM_Y
    sec
    sbc TO_Y
    sta DY
; T1 = 1
    lda #1
    sta T1
eight_way_direction_L8:
; DIRECTION = 0
    lda #0
    sta DIRECTION
; if DX == 0:
    lda DX
    cmp #0
    beq eight_way_direction_L14
eight_way_direction_L15:
    jmp eight_way_direction_L12
eight_way_direction_L14:
    jmp eight_way_direction_L11
eight_way_direction_L11:
; if DY == 0:
    lda DY
    cmp #0
    beq eight_way_direction_L19
eight_way_direction_L20:
    jmp eight_way_direction_L17
eight_way_direction_L19:
    jmp eight_way_direction_L16
eight_way_direction_L16:
; return
    rts
    jmp eight_way_direction_L18
eight_way_direction_L17:
eight_way_direction_L18:
    jmp eight_way_direction_L13
eight_way_direction_L12:
eight_way_direction_L13:
; T2 = DY >> 1
    lda DY
    lsr
    sta T2
; if DX <= T2:
    lda DX
    cmp T2
    bcc eight_way_direction_L24
    beq eight_way_direction_L24
eight_way_direction_L25:
    jmp eight_way_direction_L22
eight_way_direction_L24:
    jmp eight_way_direction_L21
eight_way_direction_L21:
; DIRECTION = 5
    lda #5
    sta DIRECTION
; if T1 != 0:
    lda T1
    cmp #0
    bne eight_way_direction_L29
eight_way_direction_L30:
    jmp eight_way_direction_L27
eight_way_direction_L29:
    jmp eight_way_direction_L26
eight_way_direction_L26:
; DIRECTION = 1
    lda #1
    sta DIRECTION
    jmp eight_way_direction_L28
eight_way_direction_L27:
eight_way_direction_L28:
; return
    rts
    jmp eight_way_direction_L23
eight_way_direction_L22:
eight_way_direction_L23:
; T2 = DX >> 1
    lda DX
    lsr
    sta T2
; if DY <= T2:
    lda DY
    cmp T2
    bcc eight_way_direction_L34
    beq eight_way_direction_L34
eight_way_direction_L35:
    jmp eight_way_direction_L32
eight_way_direction_L34:
    jmp eight_way_direction_L31
eight_way_direction_L31:
; DIRECTION = 3
    lda #3
    sta DIRECTION
; if T0 != 0:
    lda T0
    cmp #0
    bne eight_way_direction_L39
eight_way_direction_L40:
    jmp eight_way_direction_L37
eight_way_direction_L39:
    jmp eight_way_direction_L36
eight_way_direction_L36:
; DIRECTION = 7
    lda #7
    sta DIRECTION
    jmp eight_way_direction_L38
eight_way_direction_L37:
eight_way_direction_L38:
; return
    rts
    jmp eight_way_direction_L33
eight_way_direction_L32:
eight_way_direction_L33:
; DIRECTION = 4
    lda #4
    sta DIRECTION
; if T0 != 0:
    lda T0
    cmp #0
    bne eight_way_direction_L44
eight_way_direction_L45:
    jmp eight_way_direction_L42
eight_way_direction_L44:
    jmp eight_way_direction_L41
eight_way_direction_L41:
; DIRECTION = 6
    lda #6
    sta DIRECTION
    jmp eight_way_direction_L43
eight_way_direction_L42:
eight_way_direction_L43:
; if T1 != 0:
    lda T1
    cmp #0
    bne eight_way_direction_L49
eight_way_direction_L50:
    jmp eight_way_direction_L47
eight_way_direction_L49:
    jmp eight_way_direction_L46
eight_way_direction_L46:
; DIRECTION = 2
    lda #2
    sta DIRECTION
; if T0 != 0:
    lda T0
    cmp #0
    bne eight_way_direction_L54
eight_way_direction_L55:
    jmp eight_way_direction_L52
eight_way_direction_L54:
    jmp eight_way_direction_L51
eight_way_direction_L51:
; DIRECTION = 8
    lda #8
    sta DIRECTION
    jmp eight_way_direction_L53
eight_way_direction_L52:
eight_way_direction_L53:
    jmp eight_way_direction_L48
eight_way_direction_L47:
eight_way_direction_L48:
    rts
component_end:

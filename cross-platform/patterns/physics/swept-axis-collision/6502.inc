; SPDX-License-Identifier: MIT
; Sweep an Interval Along One Axis. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
swept_axis_collision_init:
    lda #0
    sta POSITION
    sta HIT
    sta VALID
    sta OLD_POSITION
    sta TARGET
    sta SIZE
    sta WALL_START
    sta WALL_END
    sta T0
    sta T1
    rts
swept_axis_collision_step:
; POSITION = OLD_POSITION
    lda OLD_POSITION
    sta POSITION
; HIT = 0
    lda #0
    sta HIT
; VALID = 0
    lda #0
    sta VALID
; if SIZE == 0:
    lda SIZE
    cmp #0
    beq swept_axis_collision_L4
swept_axis_collision_L5:
    jmp swept_axis_collision_L2
swept_axis_collision_L4:
    jmp swept_axis_collision_L1
swept_axis_collision_L1:
; return
    rts
    jmp swept_axis_collision_L3
swept_axis_collision_L2:
swept_axis_collision_L3:
; if WALL_START >= WALL_END:
    lda WALL_START
    cmp WALL_END
    bcs swept_axis_collision_L9
swept_axis_collision_L10:
    jmp swept_axis_collision_L7
swept_axis_collision_L9:
    jmp swept_axis_collision_L6
swept_axis_collision_L6:
; return
    rts
    jmp swept_axis_collision_L8
swept_axis_collision_L7:
swept_axis_collision_L8:
; T0 = OLD_POSITION + SIZE
    lda OLD_POSITION
    clc
    adc SIZE
    sta T0
; if T0 < OLD_POSITION:
    lda T0
    cmp OLD_POSITION
    bcc swept_axis_collision_L14
swept_axis_collision_L15:
    jmp swept_axis_collision_L12
swept_axis_collision_L14:
    jmp swept_axis_collision_L11
swept_axis_collision_L11:
; return
    rts
    jmp swept_axis_collision_L13
swept_axis_collision_L12:
swept_axis_collision_L13:
; T1 = TARGET + SIZE
    lda TARGET
    clc
    adc SIZE
    sta T1
; if T1 < TARGET:
    lda T1
    cmp TARGET
    bcc swept_axis_collision_L19
swept_axis_collision_L20:
    jmp swept_axis_collision_L17
swept_axis_collision_L19:
    jmp swept_axis_collision_L16
swept_axis_collision_L16:
; return
    rts
    jmp swept_axis_collision_L18
swept_axis_collision_L17:
swept_axis_collision_L18:
; if OLD_POSITION < WALL_END:
    lda OLD_POSITION
    cmp WALL_END
    bcc swept_axis_collision_L24
swept_axis_collision_L25:
    jmp swept_axis_collision_L22
swept_axis_collision_L24:
    jmp swept_axis_collision_L21
swept_axis_collision_L21:
; if T0 > WALL_START:
    lda T0
    cmp WALL_START
    beq swept_axis_collision_L30
    bcs swept_axis_collision_L29
swept_axis_collision_L30:
    jmp swept_axis_collision_L27
swept_axis_collision_L29:
    jmp swept_axis_collision_L26
swept_axis_collision_L26:
; return
    rts
    jmp swept_axis_collision_L28
swept_axis_collision_L27:
swept_axis_collision_L28:
    jmp swept_axis_collision_L23
swept_axis_collision_L22:
swept_axis_collision_L23:
; VALID = 1
    lda #1
    sta VALID
; POSITION = TARGET
    lda TARGET
    sta POSITION
; if TARGET > OLD_POSITION:
    lda TARGET
    cmp OLD_POSITION
    beq swept_axis_collision_L35
    bcs swept_axis_collision_L34
swept_axis_collision_L35:
    jmp swept_axis_collision_L32
swept_axis_collision_L34:
    jmp swept_axis_collision_L31
swept_axis_collision_L31:
; if T0 <= WALL_START:
    lda T0
    cmp WALL_START
    bcc swept_axis_collision_L39
    beq swept_axis_collision_L39
swept_axis_collision_L40:
    jmp swept_axis_collision_L37
swept_axis_collision_L39:
    jmp swept_axis_collision_L36
swept_axis_collision_L36:
; if T1 >= WALL_START:
    lda T1
    cmp WALL_START
    bcs swept_axis_collision_L44
swept_axis_collision_L45:
    jmp swept_axis_collision_L42
swept_axis_collision_L44:
    jmp swept_axis_collision_L41
swept_axis_collision_L41:
; POSITION = WALL_START - SIZE
    lda WALL_START
    sec
    sbc SIZE
    sta POSITION
; HIT = 1
    lda #1
    sta HIT
    jmp swept_axis_collision_L43
swept_axis_collision_L42:
swept_axis_collision_L43:
    jmp swept_axis_collision_L38
swept_axis_collision_L37:
swept_axis_collision_L38:
    jmp swept_axis_collision_L33
swept_axis_collision_L32:
swept_axis_collision_L33:
; if TARGET < OLD_POSITION:
    lda TARGET
    cmp OLD_POSITION
    bcc swept_axis_collision_L49
swept_axis_collision_L50:
    jmp swept_axis_collision_L47
swept_axis_collision_L49:
    jmp swept_axis_collision_L46
swept_axis_collision_L46:
; if OLD_POSITION >= WALL_END:
    lda OLD_POSITION
    cmp WALL_END
    bcs swept_axis_collision_L54
swept_axis_collision_L55:
    jmp swept_axis_collision_L52
swept_axis_collision_L54:
    jmp swept_axis_collision_L51
swept_axis_collision_L51:
; if TARGET <= WALL_END:
    lda TARGET
    cmp WALL_END
    bcc swept_axis_collision_L59
    beq swept_axis_collision_L59
swept_axis_collision_L60:
    jmp swept_axis_collision_L57
swept_axis_collision_L59:
    jmp swept_axis_collision_L56
swept_axis_collision_L56:
; POSITION = WALL_END
    lda WALL_END
    sta POSITION
; HIT = 1
    lda #1
    sta HIT
    jmp swept_axis_collision_L58
swept_axis_collision_L57:
swept_axis_collision_L58:
    jmp swept_axis_collision_L53
swept_axis_collision_L52:
swept_axis_collision_L53:
    jmp swept_axis_collision_L48
swept_axis_collision_L47:
swept_axis_collision_L48:
    rts
component_end:

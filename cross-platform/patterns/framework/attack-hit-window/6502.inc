; SPDX-License-Identifier: MIT
; Limit Hits to an Attack Window. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
attack_hit_window_init:
    lda #0
    sta HIT
    sta VALID
    sta SEEN
    sta FRAME
    sta START_FRAME
    sta END_FRAME
    sta TARGET
    sta CONTACT
    sta NEW_ATTACK
    sta T0
    sta T1
    rts
attack_hit_window_step:
; HIT = 0
    lda #0
    sta HIT
; VALID = 0
    lda #0
    sta VALID
; if START_FRAME >= END_FRAME:
    lda START_FRAME
    cmp END_FRAME
    bcs attack_hit_window_L4
attack_hit_window_L5:
    jmp attack_hit_window_L2
attack_hit_window_L4:
    jmp attack_hit_window_L1
attack_hit_window_L1:
; return
    rts
    jmp attack_hit_window_L3
attack_hit_window_L2:
attack_hit_window_L3:
; if TARGET >= 8:
    lda TARGET
    cmp #8
    bcs attack_hit_window_L9
attack_hit_window_L10:
    jmp attack_hit_window_L7
attack_hit_window_L9:
    jmp attack_hit_window_L6
attack_hit_window_L6:
; return
    rts
    jmp attack_hit_window_L8
attack_hit_window_L7:
attack_hit_window_L8:
; VALID = 1
    lda #1
    sta VALID
; if NEW_ATTACK != 0:
    lda NEW_ATTACK
    cmp #0
    bne attack_hit_window_L14
attack_hit_window_L15:
    jmp attack_hit_window_L12
attack_hit_window_L14:
    jmp attack_hit_window_L11
attack_hit_window_L11:
; SEEN = 0
    lda #0
    sta SEEN
    jmp attack_hit_window_L13
attack_hit_window_L12:
attack_hit_window_L13:
; if FRAME < START_FRAME:
    lda FRAME
    cmp START_FRAME
    bcc attack_hit_window_L19
attack_hit_window_L20:
    jmp attack_hit_window_L17
attack_hit_window_L19:
    jmp attack_hit_window_L16
attack_hit_window_L16:
; return
    rts
    jmp attack_hit_window_L18
attack_hit_window_L17:
attack_hit_window_L18:
; if FRAME >= END_FRAME:
    lda FRAME
    cmp END_FRAME
    bcs attack_hit_window_L24
attack_hit_window_L25:
    jmp attack_hit_window_L22
attack_hit_window_L24:
    jmp attack_hit_window_L21
attack_hit_window_L21:
; return
    rts
    jmp attack_hit_window_L23
attack_hit_window_L22:
attack_hit_window_L23:
; if CONTACT == 0:
    lda CONTACT
    cmp #0
    beq attack_hit_window_L29
attack_hit_window_L30:
    jmp attack_hit_window_L27
attack_hit_window_L29:
    jmp attack_hit_window_L26
attack_hit_window_L26:
; return
    rts
    jmp attack_hit_window_L28
attack_hit_window_L27:
attack_hit_window_L28:
; T0 = 1
    lda #1
    sta T0
; T1 = TARGET
    lda TARGET
    sta T1
; while T1 != 0:
attack_hit_window_L31:
    lda T1
    cmp #0
    bne attack_hit_window_L34
attack_hit_window_L35:
    jmp attack_hit_window_L33
attack_hit_window_L34:
    jmp attack_hit_window_L32
attack_hit_window_L32:
; T0 = T0 << 1
    lda T0
    asl
    sta T0
; T1 = T1 - 1
    lda T1
    sec
    sbc #1
    sta T1
    jmp attack_hit_window_L31
attack_hit_window_L33:
; T1 = SEEN & T0
    lda SEEN
    and T0
    sta T1
; if T1 == 0:
    lda T1
    cmp #0
    beq attack_hit_window_L39
attack_hit_window_L40:
    jmp attack_hit_window_L37
attack_hit_window_L39:
    jmp attack_hit_window_L36
attack_hit_window_L36:
; SEEN = SEEN | T0
    lda SEEN
    ora T0
    sta SEEN
; HIT = 1
    lda #1
    sta HIT
    jmp attack_hit_window_L38
attack_hit_window_L37:
attack_hit_window_L38:
    rts
component_end:

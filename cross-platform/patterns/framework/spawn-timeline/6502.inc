; SPDX-License-Identifier: MIT
; Service a Small Spawn Timeline. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
spawn_timeline_init:
    lda #0
    sta EVENT
    sta FIRED
    sta INDEX
    sta WAIT
    sta COUNT
    sta DONE
    sta VALID
    sta E0
    sta E1
    sta E2
    sta E3
    sta L0
    sta L1
    sta L2
    sta L3
    sta T0
    rts
spawn_timeline_step:
; EVENT = 255
    lda #255
    sta EVENT
; FIRED = 0
    lda #0
    sta FIRED
; VALID = 0
    lda #0
    sta VALID
; if COUNT == 0:
    lda COUNT
    cmp #0
    beq spawn_timeline_L4
spawn_timeline_L5:
    jmp spawn_timeline_L2
spawn_timeline_L4:
    jmp spawn_timeline_L1
spawn_timeline_L1:
; return
    rts
    jmp spawn_timeline_L3
spawn_timeline_L2:
spawn_timeline_L3:
; if COUNT > 4:
    lda COUNT
    cmp #4
    beq spawn_timeline_L10
    bcs spawn_timeline_L9
spawn_timeline_L10:
    jmp spawn_timeline_L7
spawn_timeline_L9:
    jmp spawn_timeline_L6
spawn_timeline_L6:
; return
    rts
    jmp spawn_timeline_L8
spawn_timeline_L7:
spawn_timeline_L8:
; if INDEX >= COUNT:
    lda INDEX
    cmp COUNT
    bcs spawn_timeline_L14
spawn_timeline_L15:
    jmp spawn_timeline_L12
spawn_timeline_L14:
    jmp spawn_timeline_L11
spawn_timeline_L11:
; return
    rts
    jmp spawn_timeline_L13
spawn_timeline_L12:
spawn_timeline_L13:
; VALID = 1
    lda #1
    sta VALID
; if DONE != 0:
    lda DONE
    cmp #0
    bne spawn_timeline_L19
spawn_timeline_L20:
    jmp spawn_timeline_L17
spawn_timeline_L19:
    jmp spawn_timeline_L16
spawn_timeline_L16:
; return
    rts
    jmp spawn_timeline_L18
spawn_timeline_L17:
spawn_timeline_L18:
; T0 = L[INDEX]
    ldx INDEX
    lda L0,x
    sta T0
; if WAIT < T0:
    lda WAIT
    cmp T0
    bcc spawn_timeline_L24
spawn_timeline_L25:
    jmp spawn_timeline_L22
spawn_timeline_L24:
    jmp spawn_timeline_L21
spawn_timeline_L21:
; WAIT = WAIT + 1
    lda WAIT
    clc
    adc #1
    sta WAIT
; return
    rts
    jmp spawn_timeline_L23
spawn_timeline_L22:
spawn_timeline_L23:
; EVENT = E[INDEX]
    ldx INDEX
    lda E0,x
    sta EVENT
; FIRED = 1
    lda #1
    sta FIRED
; WAIT = 0
    lda #0
    sta WAIT
; T0 = COUNT - 1
    lda COUNT
    sec
    sbc #1
    sta T0
; if INDEX < T0:
    lda INDEX
    cmp T0
    bcc spawn_timeline_L29
spawn_timeline_L30:
    jmp spawn_timeline_L27
spawn_timeline_L29:
    jmp spawn_timeline_L26
spawn_timeline_L26:
; INDEX = INDEX + 1
    lda INDEX
    clc
    adc #1
    sta INDEX
    jmp spawn_timeline_L28
spawn_timeline_L27:
; DONE = 1
    lda #1
    sta DONE
spawn_timeline_L28:
    rts
component_end:

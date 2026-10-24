; SPDX-License-Identifier: MIT
; Carry a Supported Passenger. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
moving_platform_carry_init:
    lda #0
    sta POSITION
    sta CLAMPED
    sta VALID
    sta PASSENGER
    sta PLATFORM_OLD
    sta PLATFORM_NEW
    sta SUPPORTED
    sta MINIMUM
    sta MAXIMUM
    sta T0
    sta T1
    rts
moving_platform_carry_step:
; POSITION = PASSENGER
    lda PASSENGER
    sta POSITION
; CLAMPED = 0
    lda #0
    sta CLAMPED
; VALID = 0
    lda #0
    sta VALID
; if MINIMUM > MAXIMUM:
    lda MINIMUM
    cmp MAXIMUM
    beq moving_platform_carry_L5
    bcs moving_platform_carry_L4
moving_platform_carry_L5:
    jmp moving_platform_carry_L2
moving_platform_carry_L4:
    jmp moving_platform_carry_L1
moving_platform_carry_L1:
; return
    rts
    jmp moving_platform_carry_L3
moving_platform_carry_L2:
moving_platform_carry_L3:
; if PASSENGER < MINIMUM:
    lda PASSENGER
    cmp MINIMUM
    bcc moving_platform_carry_L9
moving_platform_carry_L10:
    jmp moving_platform_carry_L7
moving_platform_carry_L9:
    jmp moving_platform_carry_L6
moving_platform_carry_L6:
; return
    rts
    jmp moving_platform_carry_L8
moving_platform_carry_L7:
moving_platform_carry_L8:
; if PASSENGER > MAXIMUM:
    lda PASSENGER
    cmp MAXIMUM
    beq moving_platform_carry_L15
    bcs moving_platform_carry_L14
moving_platform_carry_L15:
    jmp moving_platform_carry_L12
moving_platform_carry_L14:
    jmp moving_platform_carry_L11
moving_platform_carry_L11:
; return
    rts
    jmp moving_platform_carry_L13
moving_platform_carry_L12:
moving_platform_carry_L13:
; VALID = 1
    lda #1
    sta VALID
; if SUPPORTED == 0:
    lda SUPPORTED
    cmp #0
    beq moving_platform_carry_L19
moving_platform_carry_L20:
    jmp moving_platform_carry_L17
moving_platform_carry_L19:
    jmp moving_platform_carry_L16
moving_platform_carry_L16:
; return
    rts
    jmp moving_platform_carry_L18
moving_platform_carry_L17:
moving_platform_carry_L18:
; if PLATFORM_NEW >= PLATFORM_OLD:
    lda PLATFORM_NEW
    cmp PLATFORM_OLD
    bcs moving_platform_carry_L24
moving_platform_carry_L25:
    jmp moving_platform_carry_L22
moving_platform_carry_L24:
    jmp moving_platform_carry_L21
moving_platform_carry_L21:
; T0 = PLATFORM_NEW - PLATFORM_OLD
    lda PLATFORM_NEW
    sec
    sbc PLATFORM_OLD
    sta T0
; T1 = PASSENGER + T0
    lda PASSENGER
    clc
    adc T0
    sta T1
; if T1 < PASSENGER:
    lda T1
    cmp PASSENGER
    bcc moving_platform_carry_L29
moving_platform_carry_L30:
    jmp moving_platform_carry_L27
moving_platform_carry_L29:
    jmp moving_platform_carry_L26
moving_platform_carry_L26:
; POSITION = MAXIMUM
    lda MAXIMUM
    sta POSITION
; CLAMPED = 1
    lda #1
    sta CLAMPED
; return
    rts
    jmp moving_platform_carry_L28
moving_platform_carry_L27:
moving_platform_carry_L28:
; if T1 > MAXIMUM:
    lda T1
    cmp MAXIMUM
    beq moving_platform_carry_L35
    bcs moving_platform_carry_L34
moving_platform_carry_L35:
    jmp moving_platform_carry_L32
moving_platform_carry_L34:
    jmp moving_platform_carry_L31
moving_platform_carry_L31:
; POSITION = MAXIMUM
    lda MAXIMUM
    sta POSITION
; CLAMPED = 1
    lda #1
    sta CLAMPED
; return
    rts
    jmp moving_platform_carry_L33
moving_platform_carry_L32:
moving_platform_carry_L33:
; POSITION = T1
    lda T1
    sta POSITION
    jmp moving_platform_carry_L23
moving_platform_carry_L22:
; T0 = PLATFORM_OLD - PLATFORM_NEW
    lda PLATFORM_OLD
    sec
    sbc PLATFORM_NEW
    sta T0
; if PASSENGER < T0:
    lda PASSENGER
    cmp T0
    bcc moving_platform_carry_L39
moving_platform_carry_L40:
    jmp moving_platform_carry_L37
moving_platform_carry_L39:
    jmp moving_platform_carry_L36
moving_platform_carry_L36:
; POSITION = MINIMUM
    lda MINIMUM
    sta POSITION
; CLAMPED = 1
    lda #1
    sta CLAMPED
; return
    rts
    jmp moving_platform_carry_L38
moving_platform_carry_L37:
moving_platform_carry_L38:
; T1 = PASSENGER - T0
    lda PASSENGER
    sec
    sbc T0
    sta T1
; if T1 < MINIMUM:
    lda T1
    cmp MINIMUM
    bcc moving_platform_carry_L44
moving_platform_carry_L45:
    jmp moving_platform_carry_L42
moving_platform_carry_L44:
    jmp moving_platform_carry_L41
moving_platform_carry_L41:
; POSITION = MINIMUM
    lda MINIMUM
    sta POSITION
; CLAMPED = 1
    lda #1
    sta CLAMPED
; return
    rts
    jmp moving_platform_carry_L43
moving_platform_carry_L42:
moving_platform_carry_L43:
; POSITION = T1
    lda T1
    sta POSITION
moving_platform_carry_L23:
    rts
component_end:

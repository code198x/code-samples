; SPDX-License-Identifier: MIT
; Carry a Supported Passenger. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
moving_platform_carry_init:
    move.b #0,d0
    move.b d0,POSITION
    move.b d0,CLAMPED
    move.b d0,VALID
    move.b d0,PASSENGER
    move.b d0,PLATFORM_OLD
    move.b d0,PLATFORM_NEW
    move.b d0,SUPPORTED
    move.b d0,MINIMUM
    move.b d0,MAXIMUM
    move.b d0,T0
    move.b d0,T1
    rts
moving_platform_carry_step:
; POSITION = PASSENGER
    move.b PASSENGER,d0
    move.b d0,POSITION
; CLAMPED = 0
    move.b #0,d0
    move.b d0,CLAMPED
; VALID = 0
    move.b #0,d0
    move.b d0,VALID
; if MINIMUM > MAXIMUM:
    move.b MINIMUM,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi moving_platform_carry_L1
    jmp moving_platform_carry_L2
moving_platform_carry_L1:
; return
    rts
    jmp moving_platform_carry_L3
moving_platform_carry_L2:
moving_platform_carry_L3:
; if PASSENGER < MINIMUM:
    move.b PASSENGER,d0
    move.b MINIMUM,d1
    cmp.b d1,d0
    bcs moving_platform_carry_L4
    jmp moving_platform_carry_L5
moving_platform_carry_L4:
; return
    rts
    jmp moving_platform_carry_L6
moving_platform_carry_L5:
moving_platform_carry_L6:
; if PASSENGER > MAXIMUM:
    move.b PASSENGER,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi moving_platform_carry_L7
    jmp moving_platform_carry_L8
moving_platform_carry_L7:
; return
    rts
    jmp moving_platform_carry_L9
moving_platform_carry_L8:
moving_platform_carry_L9:
; VALID = 1
    move.b #1,d0
    move.b d0,VALID
; if SUPPORTED == 0:
    move.b SUPPORTED,d0
    cmp.b #0,d0
    beq moving_platform_carry_L10
    jmp moving_platform_carry_L11
moving_platform_carry_L10:
; return
    rts
    jmp moving_platform_carry_L12
moving_platform_carry_L11:
moving_platform_carry_L12:
; if PLATFORM_NEW >= PLATFORM_OLD:
    move.b PLATFORM_NEW,d0
    move.b PLATFORM_OLD,d1
    cmp.b d1,d0
    bcc moving_platform_carry_L13
    jmp moving_platform_carry_L14
moving_platform_carry_L13:
; T0 = PLATFORM_NEW - PLATFORM_OLD
    move.b PLATFORM_NEW,d0
    move.b PLATFORM_OLD,d1
    sub.b d1,d0
    move.b d0,T0
; T1 = PASSENGER + T0
    move.b PASSENGER,d0
    move.b T0,d1
    add.b d1,d0
    move.b d0,T1
; if T1 < PASSENGER:
    move.b T1,d0
    move.b PASSENGER,d1
    cmp.b d1,d0
    bcs moving_platform_carry_L16
    jmp moving_platform_carry_L17
moving_platform_carry_L16:
; POSITION = MAXIMUM
    move.b MAXIMUM,d0
    move.b d0,POSITION
; CLAMPED = 1
    move.b #1,d0
    move.b d0,CLAMPED
; return
    rts
    jmp moving_platform_carry_L18
moving_platform_carry_L17:
moving_platform_carry_L18:
; if T1 > MAXIMUM:
    move.b T1,d0
    move.b MAXIMUM,d1
    cmp.b d1,d0
    bhi moving_platform_carry_L19
    jmp moving_platform_carry_L20
moving_platform_carry_L19:
; POSITION = MAXIMUM
    move.b MAXIMUM,d0
    move.b d0,POSITION
; CLAMPED = 1
    move.b #1,d0
    move.b d0,CLAMPED
; return
    rts
    jmp moving_platform_carry_L21
moving_platform_carry_L20:
moving_platform_carry_L21:
; POSITION = T1
    move.b T1,d0
    move.b d0,POSITION
    jmp moving_platform_carry_L15
moving_platform_carry_L14:
; T0 = PLATFORM_OLD - PLATFORM_NEW
    move.b PLATFORM_OLD,d0
    move.b PLATFORM_NEW,d1
    sub.b d1,d0
    move.b d0,T0
; if PASSENGER < T0:
    move.b PASSENGER,d0
    move.b T0,d1
    cmp.b d1,d0
    bcs moving_platform_carry_L22
    jmp moving_platform_carry_L23
moving_platform_carry_L22:
; POSITION = MINIMUM
    move.b MINIMUM,d0
    move.b d0,POSITION
; CLAMPED = 1
    move.b #1,d0
    move.b d0,CLAMPED
; return
    rts
    jmp moving_platform_carry_L24
moving_platform_carry_L23:
moving_platform_carry_L24:
; T1 = PASSENGER - T0
    move.b PASSENGER,d0
    move.b T0,d1
    sub.b d1,d0
    move.b d0,T1
; if T1 < MINIMUM:
    move.b T1,d0
    move.b MINIMUM,d1
    cmp.b d1,d0
    bcs moving_platform_carry_L25
    jmp moving_platform_carry_L26
moving_platform_carry_L25:
; POSITION = MINIMUM
    move.b MINIMUM,d0
    move.b d0,POSITION
; CLAMPED = 1
    move.b #1,d0
    move.b d0,CLAMPED
; return
    rts
    jmp moving_platform_carry_L27
moving_platform_carry_L26:
moving_platform_carry_L27:
; POSITION = T1
    move.b T1,d0
    move.b d0,POSITION
moving_platform_carry_L15:
    rts
component_end:

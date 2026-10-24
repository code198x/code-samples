; SPDX-License-Identifier: MIT
; Carry a Supported Passenger. See README.md for the byte interface and ownership.
; init clears the public fields and private workspace; set inputs afterwards.
moving_platform_carry_init:
    ld a,0
    ld (POSITION),a
    ld (CLAMPED),a
    ld (VALID),a
    ld (PASSENGER),a
    ld (PLATFORM_OLD),a
    ld (PLATFORM_NEW),a
    ld (SUPPORTED),a
    ld (MINIMUM),a
    ld (MAXIMUM),a
    ld (T0),a
    ld (T1),a
    ret
moving_platform_carry_step:
; POSITION = PASSENGER
    ld a,(PASSENGER)
    ld (POSITION),a
; CLAMPED = 0
    ld a,0
    ld (CLAMPED),a
; VALID = 0
    ld a,0
    ld (VALID),a
; if MINIMUM > MAXIMUM:
    ld a,(MINIMUM)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,moving_platform_carry_L2
    jp nc,moving_platform_carry_L1
    jp moving_platform_carry_L2
moving_platform_carry_L1:
; return
    ret
    jp moving_platform_carry_L3
moving_platform_carry_L2:
moving_platform_carry_L3:
; if PASSENGER < MINIMUM:
    ld a,(PASSENGER)
    ld b,a
    ld a,(MINIMUM)
    ld c,a
    ld a,b
    cp c
    jp c,moving_platform_carry_L4
    jp moving_platform_carry_L5
moving_platform_carry_L4:
; return
    ret
    jp moving_platform_carry_L6
moving_platform_carry_L5:
moving_platform_carry_L6:
; if PASSENGER > MAXIMUM:
    ld a,(PASSENGER)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,moving_platform_carry_L8
    jp nc,moving_platform_carry_L7
    jp moving_platform_carry_L8
moving_platform_carry_L7:
; return
    ret
    jp moving_platform_carry_L9
moving_platform_carry_L8:
moving_platform_carry_L9:
; VALID = 1
    ld a,1
    ld (VALID),a
; if SUPPORTED == 0:
    ld a,(SUPPORTED)
    cp 0
    jp z,moving_platform_carry_L10
    jp moving_platform_carry_L11
moving_platform_carry_L10:
; return
    ret
    jp moving_platform_carry_L12
moving_platform_carry_L11:
moving_platform_carry_L12:
; if PLATFORM_NEW >= PLATFORM_OLD:
    ld a,(PLATFORM_NEW)
    ld b,a
    ld a,(PLATFORM_OLD)
    ld c,a
    ld a,b
    cp c
    jp nc,moving_platform_carry_L13
    jp moving_platform_carry_L14
moving_platform_carry_L13:
; T0 = PLATFORM_NEW - PLATFORM_OLD
    ld a,(PLATFORM_NEW)
    ld b,a
    ld a,(PLATFORM_OLD)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; T1 = PASSENGER + T0
    ld a,(PASSENGER)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    add a,c
    ld (T1),a
; if T1 < PASSENGER:
    ld a,(T1)
    ld b,a
    ld a,(PASSENGER)
    ld c,a
    ld a,b
    cp c
    jp c,moving_platform_carry_L16
    jp moving_platform_carry_L17
moving_platform_carry_L16:
; POSITION = MAXIMUM
    ld a,(MAXIMUM)
    ld (POSITION),a
; CLAMPED = 1
    ld a,1
    ld (CLAMPED),a
; return
    ret
    jp moving_platform_carry_L18
moving_platform_carry_L17:
moving_platform_carry_L18:
; if T1 > MAXIMUM:
    ld a,(T1)
    ld b,a
    ld a,(MAXIMUM)
    ld c,a
    ld a,b
    cp c
    jp z,moving_platform_carry_L20
    jp nc,moving_platform_carry_L19
    jp moving_platform_carry_L20
moving_platform_carry_L19:
; POSITION = MAXIMUM
    ld a,(MAXIMUM)
    ld (POSITION),a
; CLAMPED = 1
    ld a,1
    ld (CLAMPED),a
; return
    ret
    jp moving_platform_carry_L21
moving_platform_carry_L20:
moving_platform_carry_L21:
; POSITION = T1
    ld a,(T1)
    ld (POSITION),a
    jp moving_platform_carry_L15
moving_platform_carry_L14:
; T0 = PLATFORM_OLD - PLATFORM_NEW
    ld a,(PLATFORM_OLD)
    ld b,a
    ld a,(PLATFORM_NEW)
    ld c,a
    ld a,b
    sub c
    ld (T0),a
; if PASSENGER < T0:
    ld a,(PASSENGER)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    cp c
    jp c,moving_platform_carry_L22
    jp moving_platform_carry_L23
moving_platform_carry_L22:
; POSITION = MINIMUM
    ld a,(MINIMUM)
    ld (POSITION),a
; CLAMPED = 1
    ld a,1
    ld (CLAMPED),a
; return
    ret
    jp moving_platform_carry_L24
moving_platform_carry_L23:
moving_platform_carry_L24:
; T1 = PASSENGER - T0
    ld a,(PASSENGER)
    ld b,a
    ld a,(T0)
    ld c,a
    ld a,b
    sub c
    ld (T1),a
; if T1 < MINIMUM:
    ld a,(T1)
    ld b,a
    ld a,(MINIMUM)
    ld c,a
    ld a,b
    cp c
    jp c,moving_platform_carry_L25
    jp moving_platform_carry_L26
moving_platform_carry_L25:
; POSITION = MINIMUM
    ld a,(MINIMUM)
    ld (POSITION),a
; CLAMPED = 1
    ld a,1
    ld (CLAMPED),a
; return
    ret
    jp moving_platform_carry_L27
moving_platform_carry_L26:
moving_platform_carry_L27:
; POSITION = T1
    ld a,(T1)
    ld (POSITION),a
moving_platform_carry_L15:
    ret
component_end:

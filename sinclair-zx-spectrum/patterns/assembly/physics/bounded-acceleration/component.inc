; SPDX-License-Identifier: MIT
; Bounded Signed Acceleration. Contiguous private bytes: VEL_LO, VEL_HI, ACC_LO, ACC_HI, LIMIT_LO, LIMIT_HI, CLIPPED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
bounded_acceleration_init:
    xor a
    ld (VEL_LO),a
    ld (VEL_HI),a
    ld (ACC_LO),a
    ld (ACC_HI),a
    ld (LIMIT_LO),a
    ld (LIMIT_HI),a
    ld (CLIPPED),a
    ld (VALID),a
    ret
bounded_acceleration_step:
    xor a
    ld (CLIPPED),a
    ld (VALID),a
    ld a,(LIMIT_HI)
    bit 7,a
    ret nz
    ld a,1
    ld (VALID),a
    ld hl,(VEL_LO)
    ld de,(ACC_LO)
    or a
    adc hl,de
    jp po,accel_normal
    ld a,(ACC_HI)
    bit 7,a
    jr nz,accel_negative_cap
    jr accel_positive_cap
accel_normal:
    ld de,(LIMIT_LO)
    bit 7,h
    jr nz,accel_negative
    push hl
    or a
    sbc hl,de
    pop hl
    jr c,accel_store
    jr z,accel_store
accel_positive_cap:
    ld hl,(LIMIT_LO)
    jr accel_clipped
accel_negative:
    push hl
    xor a
    sub l
    ld l,a
    sbc a,a
    sub h
    ld h,a
    or a
    sbc hl,de
    pop hl
    jr c,accel_store
    jr z,accel_store
accel_negative_cap:
    ld hl,(LIMIT_LO)
    xor a
    sub l
    ld l,a
    sbc a,a
    sub h
    ld h,a
accel_clipped:
    ld a,1
    ld (CLIPPED),a
accel_store:
    ld (VEL_LO),hl
    ret
component_end:

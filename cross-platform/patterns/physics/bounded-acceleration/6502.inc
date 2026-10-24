; SPDX-License-Identifier: MIT
; Bounded Signed Acceleration. Contiguous private bytes: VEL_LO, VEL_HI, ACC_LO, ACC_HI, LIMIT_LO, LIMIT_HI, CLIPPED, VALID.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; A/X/flags change; Y and decimal mode survive. D=0 for binary arithmetic.
bounded_acceleration_init:
    lda #0
    sta VEL_LO
    sta VEL_HI
    sta ACC_LO
    sta ACC_HI
    sta LIMIT_LO
    sta LIMIT_HI
    sta CLIPPED
    sta VALID
    rts
bounded_acceleration_step:
    lda #0
    sta CLIPPED
    sta VALID
    lda LIMIT_HI
    bpl accel_valid
    rts
accel_valid:
    inc VALID
    lda VEL_LO
    clc
    adc ACC_LO
    sta VEL_LO
    lda VEL_HI
    adc ACC_HI
    sta VEL_HI
    bvc accel_normal
    lda ACC_HI
    bmi accel_negative_cap
    jmp accel_positive_cap
accel_normal:
    lda VEL_HI
    bmi accel_negative
    cmp LIMIT_HI
    bcc accel_done
    bne accel_positive_cap
    lda VEL_LO
    cmp LIMIT_LO
    bcc accel_done
    beq accel_done
accel_positive_cap:
    lda LIMIT_LO
    sta VEL_LO
    lda LIMIT_HI
    sta VEL_HI
    lda #1
    sta CLIPPED
    rts
accel_negative:
    lda VEL_LO
    eor #255
    clc
    adc #1
    pha
    lda VEL_HI
    eor #255
    adc #0
    tax
    pla
    cpx LIMIT_HI
    bcc accel_done
    bne accel_negative_cap
    cmp LIMIT_LO
    bcc accel_done
    beq accel_done
accel_negative_cap:
    lda LIMIT_LO
    eor #255
    clc
    adc #1
    sta VEL_LO
    lda LIMIT_HI
    eor #255
    adc #0
    sta VEL_HI
    lda #1
    sta CLIPPED
accel_done:
    rts
component_end:

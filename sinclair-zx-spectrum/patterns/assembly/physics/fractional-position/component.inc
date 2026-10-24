; SPDX-License-Identifier: MIT
; Fractional Position Updates. Contiguous private bytes: POS_LO, POS_HI, VEL_LO, VEL_HI.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
fractional_position_init:
    xor a
    ld (POS_LO),a
    ld (POS_HI),a
    ld (VEL_LO),a
    ld (VEL_HI),a
    ret
fractional_position_step:
    ld hl,(POS_LO)
    ld de,(VEL_LO)
    add hl,de
    ld (POS_LO),hl
    ret
component_end:

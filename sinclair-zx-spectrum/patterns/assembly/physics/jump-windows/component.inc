; SPDX-License-Identifier: MIT
; Jump Buffering and Coyote Time. Contiguous private bytes: JUMPED, COYOTE, BUFFER, GROUNDED, PRESSED.
; init clears all fields; set inputs afterwards. No I/O, waits or IRQ ownership.
; AF/BC/DE/HL change; IX/IY survive.
jump_windows_init:
    xor a
    ld (JUMPED),a
    ld (COYOTE),a
    ld (BUFFER),a
    ld (GROUNDED),a
    ld (PRESSED),a
    ret
jump_windows_step:
    xor a
    ld (JUMPED),a
    ld a,(COYOTE)
    or a
    jr z,jump_buffer
    dec a
    ld (COYOTE),a
jump_buffer:
    ld a,(BUFFER)
    or a
    jr z,jump_ground
    dec a
    ld (BUFFER),a
jump_ground:
    ld a,(GROUNDED)
    or a
    jr z,jump_press
    ld a,COYOTE_STEPS
    ld (COYOTE),a
jump_press:
    ld a,(PRESSED)
    or a
    jr z,jump_test
    ld a,BUFFER_STEPS
    ld (BUFFER),a
jump_test:
    ld a,(COYOTE)
    or a
    ret z
    ld a,(BUFFER)
    or a
    ret z
    xor a
    ld (COYOTE),a
    ld (BUFFER),a
    inc a
    ld (JUMPED),a
    ret
component_end:

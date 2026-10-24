; SPDX-License-Identifier: MIT
; Choose the Highest-priority Request. Bind these contiguous private bytes: PRESENT, ID, PRIORITY, REQUEST_ID, REQUEST_PRIORITY, ACCEPTED.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
priority_arbiter_init:
    xor a
    ld (PRESENT),a
    ld (ID),a
    ld (PRIORITY),a
    ld (REQUEST_ID),a
    ld (REQUEST_PRIORITY),a
    ld (ACCEPTED),a
    ret
priority_arbiter_step:
    xor a
    ld (ACCEPTED),a
    ld a,(PRESENT)
    or a
    jr z,arbiter_accept
    ld a,(PRIORITY)
    ld b,a
    ld a,(REQUEST_PRIORITY)
    cp b
    ret c
    ret z
arbiter_accept:
    ld a,(REQUEST_ID)
    ld (ID),a
    ld a,(REQUEST_PRIORITY)
    ld (PRIORITY),a
    ld a,1
    ld (PRESENT),a
    ld (ACCEPTED),a
    ret
component_end:

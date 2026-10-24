; SPDX-License-Identifier: MIT
; A Bounded Event Queue. Bind these contiguous private bytes: HEAD, TAIL, COUNT, VALUE, MODE, OK, B0, B1, B2, B3.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
event_queue_init:
    xor a
    ld (HEAD),a
    ld (TAIL),a
    ld (COUNT),a
    ld (VALUE),a
    ld (MODE),a
    ld (OK),a
    ld (B0),a
    ld (B1),a
    ld (B2),a
    ld (B3),a
    ret
event_queue_step:
    xor a
    ld (OK),a
    ld a,(MODE)
    cp 1
    jr z,queue_push
    cp 2
    ret nz
    ld a,(COUNT)
    or a
    ret z
    dec a
    ld (COUNT),a
    ld a,(HEAD)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(hl)
    ld (VALUE),a
    ld a,e
    inc a
    cp QUEUE_CAP
    jr c,queue_pop_index
    xor a
queue_pop_index:
    ld (HEAD),a
    jr queue_success
queue_push:
    ld a,(COUNT)
    cp QUEUE_CAP
    ret nc
    inc a
    ld (COUNT),a
    ld a,(TAIL)
    ld e,a
    ld d,0
    ld hl,B0
    add hl,de
    ld a,(VALUE)
    ld (hl),a
    ld a,e
    inc a
    cp QUEUE_CAP
    jr c,queue_push_index
    xor a
queue_push_index:
    ld (TAIL),a
queue_success:
    ld a,1
    ld (OK),a
    ret
component_end:

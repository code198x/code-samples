; SPDX-License-Identifier: MIT
; Resource Counters. Bind these contiguous private bytes: BALANCE, AMOUNT, MODE, OK.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
resource_wallet_init:
    xor a
    ld (BALANCE),a
    ld (AMOUNT),a
    ld (MODE),a
    ld (OK),a
    ret
resource_wallet_step:
    xor a
    ld (OK),a
    ld a,(MODE)
    or a
    jr z,wallet_add
    cp 1
    ret nz
    ld a,(AMOUNT)
    ld b,a
    ld a,(BALANCE)
    sub b
    ret c
    jr wallet_store
wallet_add:
    ld a,(AMOUNT)
    ld b,a
    ld a,(BALANCE)
    add a,b
    jr nc,wallet_store
    ld a,255
wallet_store:
    ld (BALANCE),a
    ld a,1
    ld (OK),a
    ret
component_end:

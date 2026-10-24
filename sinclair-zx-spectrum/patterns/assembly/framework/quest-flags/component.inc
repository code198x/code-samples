; SPDX-License-Identifier: MIT
; Quest and Inventory Flags. Bind these contiguous private bytes: FLAGS, MASK, MODE, ALL_SET.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
quest_flags_init:
    xor a
    ld (FLAGS),a
    ld (MASK),a
    ld (MODE),a
    ld (ALL_SET),a
    ret
quest_flags_step:
    ld a,(MASK)
    ld b,a
    ld a,(MODE)
    cp 1
    jr z,flags_set
    cp 2
    jr nz,flags_test
    ld a,b
    cpl
    ld b,a
    ld a,(FLAGS)
    and b
    ld (FLAGS),a
    jr flags_test
flags_set:
    ld a,(FLAGS)
    or b
    ld (FLAGS),a
flags_test:
    xor a
    ld (ALL_SET),a
    ld a,(MASK)
    ld b,a
    ld a,(FLAGS)
    and b
    cp b
    ret nz
    ld a,1
    ld (ALL_SET),a
    ret
component_end:

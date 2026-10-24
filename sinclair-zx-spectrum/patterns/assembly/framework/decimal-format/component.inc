; SPDX-License-Identifier: MIT
; Format a 16-bit Decimal Number. Bind these contiguous private bytes: VALUE_LO, VALUE_HI, DIGIT0, DIGIT1, DIGIT2, DIGIT3, DIGIT4, WORK_LO, WORK_HI.
; init clears the whole block; step uses current inputs. No I/O, waits or IRQ owner.
; AF/BC/DE/HL may change; IX/IY survive.
decimal_format_init:
    xor a
    ld (VALUE_LO),a
    ld (VALUE_HI),a
    ld (DIGIT0),a
    ld (DIGIT1),a
    ld (DIGIT2),a
    ld (DIGIT3),a
    ld (DIGIT4),a
    ld (WORK_LO),a
    ld (WORK_HI),a
    ret
decimal_format_step:
    ld hl,(VALUE_LO)
    ld de,10000
    ld b,48
format_0:
    or a
    sbc hl,de
    jr c,format_done_0
    inc b
    jr format_0
format_done_0:
    add hl,de
    ld a,b
    ld (DIGIT0),a
    ld de,1000
    ld b,48
format_1:
    or a
    sbc hl,de
    jr c,format_done_1
    inc b
    jr format_1
format_done_1:
    add hl,de
    ld a,b
    ld (DIGIT1),a
    ld de,100
    ld b,48
format_2:
    or a
    sbc hl,de
    jr c,format_done_2
    inc b
    jr format_2
format_done_2:
    add hl,de
    ld a,b
    ld (DIGIT2),a
    ld de,10
    ld b,48
format_3:
    or a
    sbc hl,de
    jr c,format_done_3
    inc b
    jr format_3
format_done_3:
    add hl,de
    ld a,b
    ld (DIGIT3),a
    ld de,1
    ld b,48
format_4:
    or a
    sbc hl,de
    jr c,format_done_4
    inc b
    jr format_4
format_done_4:
    add hl,de
    ld a,b
    ld (DIGIT4),a
    ld (WORK_LO),hl
    ret
component_end:

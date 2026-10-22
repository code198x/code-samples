include "settings.inc"
org $9000
start:
    ei
    ld a,INITIAL
    call init_turn
    ld a,STEP
    ld (TURN+1),a
    call display
next_command:
    call $bb06
    call dispatch
    call display
    jr next_command
include "dispatch.inc"
include "../../../../../cross-platform/patterns/framework/command-turns/z80.inc"
display:
    ld a,12
    call $bb5a
    ld hl,label
print_label:
    ld a,(hl)
    inc hl
    or a
    jr z,print_value
    call $bb5a
    jr print_label
print_value:
    ld a,(TURN)
    rrca
    rrca
    rrca
    rrca
    and 15
    call hex_digit
    ld a,(TURN)
    and 15
hex_digit:
    ld hl,digits
    ld e,a
    ld d,0
    add hl,de
    ld a,(hl)
    jp $bb5a
label: db "TURN ",0
digits: db "0123456789ABCDEF"

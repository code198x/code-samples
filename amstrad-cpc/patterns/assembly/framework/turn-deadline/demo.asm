include "settings.inc"
org $9000
start:
    ei
    xor a
    ld hl,STATE
    ld b,10
clear_state:
    ld (hl),a
    inc hl
    djnz clear_state
    ld hl,DURATION
    ld (DEADLINE),hl
    call $bd0d
    call deadline_init
    call display
next_sample:
    call $bd0d
    call deadline_poll
    call $bb09
    jr c,have_key
    xor a
have_key:
    ld (STATE+8),a
    ld a,(DEADLINE+5)
    or a
    jr nz,no_toggle
    ld a,(STATE+8)
    cp 'T'
    jr z,toggle_timer
    cp 't'
    jr nz,no_toggle
toggle_timer:
    ld a,(DEADLINE+4)
    or a
    jr z,enable_timer
    xor a
    ld (DEADLINE+4),a
    jr no_toggle
enable_timer:
    call deadline_start
no_toggle:
    call dispatch
    ld a,(STATE+7)
    or a
    jr z,next_sample
    call display
    xor a
    ld (STATE+7),a
    jr next_sample
commit_turn:
    ld hl,(STATE+4)
    inc hl
    ld (STATE+4),hl
    ret
include "dispatch.inc"
include "../../../../../cross-platform/patterns/framework/elapsed-deadline/z80.inc"
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
    ld a,(STATE+4)
    rrca
    rrca
    rrca
    rrca
    and 15
    call hex_digit
    ld a,(STATE+4)
    and 15
hex_digit:
    ld hl,digits
    ld e,a
    ld d,0
    add hl,de
    ld a,(hl)
    jp $bb5a
label: db "SPACE:TURN T:TIMER TURN ",0
digits: db "0123456789ABCDEF"

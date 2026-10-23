; BASIC USR entry, normal BIOS slots and firmware IRQs retained.
start:
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    xor a
    ld (TURN),a
    ld (EXPIRIES),a
    ld hl,DURATION
    ld (DEADLINE),hl
    call clock_read
    call deadline_init
main:
    call clock_read
    call deadline_poll
    call read_command
    ld (KEY),a
    call dispatch
    call show_state
    ld a,(KEY)
    cp 3
    jr nz,main
quit_release:
    ld a,7
    call $0141
    bit 2,a
    jr z,quit_release
    call $0156
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret
show_state:
    ld a,(TURN)
    ld de,DISPLAY
    call show_byte
    ld a,(EXPIRIES)
    ld de,DISPLAY+3
    call show_byte
    ld a,(DEADLINE+4)
    ld de,DISPLAY+6
    call show_byte
    ld hl,DISPLAY
    ld de,0
    ld bc,8
    call $005C
    ret
show_byte:
    push af
    rrca
    rrca
    rrca
    rrca
    and 15
    call hex_digit
    ld (de),a
    inc de
    pop af
    and 15
    call hex_digit
    ld (de),a
    ret
hex_digit:
    cp 10
    jr c,hex_number
    add a,7
hex_number:
    add a,48
    ret

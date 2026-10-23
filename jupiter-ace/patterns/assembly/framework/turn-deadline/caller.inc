; FORTH wrapper reserves dictionary through code_end. IX/IY unchanged.
start:
    push af
    push bc
    push de
    push hl
    xor a
    ld (TURN),a
    ld (EXPIRIES),a
    ld (HELD),a
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
; Keep the quit key out of FORTH's next editor line. The normal IRQ service
; must observe its release before returning to the interpreter.
quit_release:
    call read_command
    ld a,(HELD)
    or a
    jr nz,quit_release
    halt
    pop hl
    pop de
    pop bc
    pop af
    jp (iy)
show_state:
    ld a,32
    ld ($2402),a
    ld ($2405),a
    ld a,(TURN)
    ld de,$2400
    call show_byte
    ld a,(EXPIRIES)
    ld de,$2403
    call show_byte
    ld a,(DEADLINE+4)
    ld de,$2406
    call show_byte
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

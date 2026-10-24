; 48K BASIC USR entry, existing stack/IM1/IY/ROM retained.
start:
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    call $0DAF
    xor a
    ld (TURN),a
    ld (EXPIRIES),a
    ld (HELD),a
    ld hl,DURATION
    ld (DEADLINE),hl
    call clock_read
    call deadline_init
    ld hl,$CAFE
    ld (READY),hl
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
    call read_command
    ld a,(HELD)
    or a
    jr nz,quit_release
    halt
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret
show_state:
    ld de,$4000
    ld a,(TURN)
    call show_byte
    ld a,32
    call show_char
    ld a,(EXPIRIES)
    call show_byte
    ld a,32
    call show_char
    ld a,(DEADLINE+4)
show_byte:
    push af
    rrca
    rrca
    rrca
    rrca
    and 15
    call digit
    call show_char
    pop af
    and 15
    call digit
    jp show_char
digit:
    cp 10
    jr c,digit_number
    add a,7
digit_number:
    add a,48
    ret
; A=ASCII, DE=top scanline cell. CHARS points 256 bytes before glyph 32.
; AF/BC/HL clobbered; DE advances one character column.
show_char:
    push de
    ld l,a
    ld h,0
    add hl,hl
    add hl,hl
    add hl,hl
    ld bc,($5C36)
    add hl,bc
    ld b,8
show_scan:
    ld a,(hl)
    ld (de),a
    inc hl
    inc d
    djnz show_scan
    pop de
    inc e
    ret

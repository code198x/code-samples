; Original memotech-mtx diagnostic ROM. Replaces stock firmware for this run.
; Not a BASIC/OS loader. Owns keyboard, VDP, RAM $c000-$c003, stack.
    org 0
    jp start
    defs $66-$,0
    retn
    defs $100-$,0
start:
    di
    ld sp,$fff0
    xor a
    ld ($c000),a
    ld ($c001),a
    ld ($c002),a
    ld ($c003),a
    in a,($02)
    xor a
    out ($02),a
    ld a,$80
    out ($02),a          ; R0 legacy graphics
    xor a
    out ($02),a
    ld a,$81
    out ($02),a          ; R1 display and VDP IRQ disabled
main:
    call wait_frame
    ld hl,($c002)
    inc hl
    ld ($c002),hl
    ld a,$7f
    out ($05),a               ; select column 7, active-low column drive
    in a,($06)                ; Space is bit 8 of the 10-bit return: high bit 0
    cpl
    and 1
    ld b,a
    ld a,($c001)
    cpl
    and b
    jr z,no_action
    ld a,($c000)
    inc a
    ld ($c000),a
no_action:
    ld a,b
    ld ($c001),a
    ld a,($c000)
    and 1
    add a,2
    out ($02),a
    ld a,$87
    out ($02),a          ; backdrop changes only with a new Space press
    jp main

; AF clobbered; caller exclusively owns status/control-port latch.
wait_frame:
    in a,($02)
wait_new:
    in a,($02)
    and $80
    jr z,wait_new
    ret
    defs $4000-$,0

; Original tatung-einstein diagnostic ROM. Replaces stock firmware for this run.
; Not a BASIC/OS loader. Owns keyboard, VDP, RAM $8000-$8003, stack.
    org 0
    jp start
    defs $66-$,0
    retn
    defs $100-$,0
start:
    di
    ld sp,$fff0
    xor a
    ld ($8000),a
    ld ($8001),a
    ld ($8002),a
    ld ($8003),a
    ld a,1
    out ($20),a               ; mask dedicated keyboard interrupt
    ld a,7
    out ($02),a
    ld a,$7f
    out ($03),a               ; mute tone/noise gates, port A output / B input
    in a,($09)
    xor a
    out ($09),a
    ld a,$80
    out ($09),a          ; R0 legacy graphics
    xor a
    out ($09),a
    ld a,$81
    out ($09),a          ; R1 display and VDP IRQ disabled
main:
    call wait_frame
    ld hl,($8002)
    inc hl
    ld ($8002),hl
    ld a,14
    out ($02),a               ; AY port A: row select
    ld a,$fe
    out ($03),a               ; select keyboard row 0
    ld a,15
    out ($02),a               ; AY port B: column return
    in a,($02)
    cpl
    and $40                   ; Space, row 0 bit 6
    ld b,a
    ld a,($8001)
    cpl
    and b
    jr z,no_action
    ld a,($8000)
    inc a
    ld ($8000),a
no_action:
    ld a,b
    ld ($8001),a
    ld a,($8000)
    and 1
    add a,2
    out ($09),a
    ld a,$87
    out ($09),a          ; backdrop changes only with a new Space press
    jp main

; AF clobbered; caller exclusively owns status/control-port latch.
wait_frame:
    in a,($09)
wait_new:
    in a,($09)
    and $80
    jr z,wait_new
    ret
    defs $2000-$,0

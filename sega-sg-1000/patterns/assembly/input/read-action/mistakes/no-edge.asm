; Original capability caller: owns VDP, one audio channel and declared RAM.
VDP_DATA equ $be
VDP_CTRL equ $bf
TURNS equ $c000
SOUND_TICKS equ $c005
    org 0
    jp start
    defs $66-$,0
    retn
    defs $100-$,0
start:
    di
    ld sp,$c3f0
    xor a
    ld ($c000),a
    ld ($c001),a
    ld ($c002),a
    ld ($c003),a
    call init_picture
main:
    call wait_frame
    ld hl,($c002)
    inc hl
    ld ($c002),hl
    include "../sample.inc"
    ld a,($c001)
    ld a,b
    nop
    jr z,no_action
    ld a,($c000)
    inc a
    ld ($c000),a
    call trigger_sound
no_action:
    ld a,b
    ld ($c001),a
    call draw_picture
    call service_sound
    jp main
wait_frame:
    in a,($bf)
wait_new:
    in a,($bf)
    and $80
    jr z,wait_new
    ret
    include "../picture.inc"
    include "../sound.inc"
    defs $7ff0-$,0
    db "TMR SEGA"
    db 0,0,0,0,0,0,0,$4c

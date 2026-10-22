include "settings.inc"
org $8000
    db $55,$aa
    dw 0,0,0,0,start
    jp unused_rst
    jp unused_rst
    jp unused_rst
    jp unused_rst
    jp unused_rst
    jp unused_rst
    jp unused_rst
    jp nmi_return
start:
    di
    ld sp,$63f0
    ld a,INITIAL
    call init_turn
    ld a,STEP
    ld (T+5),a
    ld a,165
    ld (T+7),a
    ld a,90
    ld (T+8),a
    call init_picture
    xor a
    out ($c0),a               ; controller joystick/left-fire mode
    call draw_counter
main:
    call wait_frame
    call service_tick
    in a,($fc)
    cpl
    and $40
    call sample_turn
    ld a,(T+6)
    or a
    call nz,draw_counter
    jp main
include "turn.inc"
include "frame.inc"
include "picture.inc"
unused_rst:
    ret
nmi_return:
    in a,($bf)
    retn
    defs 32768-($-$8000),0

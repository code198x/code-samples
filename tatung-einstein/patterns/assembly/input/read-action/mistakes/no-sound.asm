; Original capability caller: owns VDP, one audio channel and declared RAM.
VDP_DATA equ $08
VDP_CTRL equ $09
TURNS equ $8000
SOUND_TICKS equ $8005
; Stock MOS disk boot header: destination, end, entry, disk mode.
    org $9000
    dw $9000,$9200,start
    db 0
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
    call init_picture
main:
    call wait_frame
    ld hl,($8002)
    inc hl
    ld ($8002),hl
    include "../sample.inc"
    ld a,($8001)
    cpl
    and b
    jr z,no_action
    ld a,($8000)
    inc a
    ld ($8000),a
    nop
    nop
    nop
no_action:
    ld a,b
    ld ($8001),a
    call draw_picture
    call service_sound
    jp main

; AF clobbered; caller exclusively owns status/control-port latch.
wait_frame:
    in a,($09)
wait_new:
    in a,($09)
    and $80
    jr z,wait_new
    ret
    include "../picture.inc"
    include "../sound.inc"
    defs $9200-$,0

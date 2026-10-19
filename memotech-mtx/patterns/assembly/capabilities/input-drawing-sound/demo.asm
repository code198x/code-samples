; Original capability caller: owns VDP, one audio channel and declared RAM.
VDP_DATA equ $01
VDP_CTRL equ $02
TURNS equ $df00
SOUND_TICKS equ $df05
; Entered from stock MTX BASIC using POKE and USR. Takes over until reset.
    org $e000
start:
    di
    ld sp,$f7f0
    xor a
    ld ($df00),a
    ld ($df01),a
    ld ($df02),a
    ld ($df03),a
    in a,($02)
    xor a
    out ($02),a
    ld a,$80
    out ($02),a          ; R0 legacy graphics
    xor a
    out ($02),a
    ld a,$81
    out ($02),a          ; R1 display and VDP IRQ disabled
    call init_picture
main:
    call wait_frame
    ld hl,($df02)
    inc hl
    ld ($df02),hl
    ld a,$7f
    out ($05),a               ; select column 7, active-low column drive
    in a,($06)                ; Space is bit 8 of the 10-bit return: high bit 0
    cpl
    and 1
    ld b,a
    ld a,($df01)
    cpl
    and b
    jr z,no_action
    ld a,($df00)
    inc a
    ld ($df00),a
    call trigger_sound
no_action:
    ld a,b
    ld ($df01),a
    call draw_picture
    call service_sound
    jp main

; AF clobbered; caller exclusively owns status/control-port latch.
wait_frame:
    in a,($02)
wait_new:
    in a,($02)
    and $80
    jr z,wait_new
    ret
    include "picture.inc"
    include "sound.inc"

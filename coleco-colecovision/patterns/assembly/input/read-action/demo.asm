; Original capability caller: owns VDP, one audio channel and declared RAM.
VDP_DATA equ $be
VDP_CTRL equ $bf
TURNS equ $6000
SOUND_TICKS equ $6005
; ColecoVision BIOS-started cartridge. Left fire commits one untimed turn.
; Owns VDP/controller mode, RAM $6000-$6004 and stack below $63F0.
    org $8000
    db $55,$aa                ; skip BIOS title, enter start vector
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
    xor a
    ld ($6000),a
    ld ($6001),a
    ld ($6002),a
    ld ($6003),a
    in a,($bf)                ; reset control latch and clear pending flags
    xor a
    out ($bf),a
    ld a,$80
    out ($bf),a               ; R0: legacy graphics
    xor a
    out ($bf),a
    ld a,$81
    out ($bf),a               ; R1: display/VDP interrupt disabled
    out ($c0),a               ; controller reads now use joystick mode
    call init_picture
main:
    call wait_frame
    ld hl,($6002)
    inc hl
    ld ($6002),hl
    include "sample.inc"
    ld a,($6001)
    cpl
    and b
    jr z,no_action
    ld a,($6000)
    inc a
    ld ($6000),a
    call trigger_sound
no_action:
    ld a,b
    ld ($6001),a
    call draw_picture
    call service_sound
    jp main

; AF clobbered. This caller exclusively owns the VDP status/command latch.
wait_frame:
    in a,($bf)
wait_new:
    in a,($bf)
    and $80
    jr z,wait_new
    ret
unused_rst:
    ret
nmi_return:
    retn
    include "picture.inc"
    include "sound.inc"
    defs $ffff-$+1,0

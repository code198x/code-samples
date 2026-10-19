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
main:
    call wait_frame
    ld hl,($6002)
    inc hl
    ld ($6002),hl
    in a,($fc)                ; controller 1, left fire on bit 6
    cpl
    and $40
    ld b,a
    ld a,($6001)
    cpl
    and b
    jr z,no_action
    ld a,($6000)
    inc a
    ld ($6000),a
no_action:
    ld a,b
    ld ($6001),a
    ld a,($6000)
    and 1
    add a,2
    out ($bf),a
    ld a,$87
    out ($bf),a               ; fixed-palette backdrop gives turn feedback
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
    defs $10000-$,0

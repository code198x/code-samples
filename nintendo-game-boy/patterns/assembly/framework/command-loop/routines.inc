; A -> count. A and flags preserved. No display/input/clock access.
turn_init:
    ld [CTX],a
    ret
; Add STEP modulo 256. A/flags and count changed.
turn_advance:
    ld a,[CTX]
    add a,STEP
    ld [CTX],a
    ret
; A=1 for a new A-button press, otherwise zero. AF/BC changed.
; Six reads allow selected action-button lines to settle, then release JOYP.
sample_action:
    ld a,$10
    ld [$FF00],a
    ld a,[$FF00]
    ld a,[$FF00]
    ld a,[$FF00]
    ld a,[$FF00]
    ld a,[$FF00]
    ld a,[$FF00]
    cpl
    and 1
    ld b,a
    ld a,$30
    ld [$FF00],a
    ld a,NO_EDGE
    or a
    ld a,b
    jr nz,accept_sample
    ld a,[CTX+1]
    cpl
    and b
accept_sample:
    ld c,a
    ld a,b
    ld [CTX+1],a
    ld a,c
    ret
; AF changed. LCD must remain enabled; interrupts stay disabled.
; Leave any current VBlank before accepting the next one. No missed-frame count.
wait_frame:
    ld a,NO_WAIT
    or a
    ret nz
leave_vblank:
    ld a,[$FF44]
    cp 144
    jr nc,leave_vblank
wait_vblank:
    ld a,[$FF44]
    cp 144
    jr c,wait_vblank
    ret

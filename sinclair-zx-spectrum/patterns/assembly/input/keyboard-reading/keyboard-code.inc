; Include the maintained framework/input-to-sound/input.inc once.
; read_keyboard: A and key_pressed = 0 none,1 Q,2 A,3 O,4 P,5 Space.
; Priority is Q,A,O,P,Space; use controls for simultaneous held controls.
; Changes AF/BC; preserves DE/HL/IX/IY. No key is a held state, not an edge.
read_keyboard:
    call read_controls
    ld b,a
    xor a
    bit 0,b
    jr z,keyboard_not_q
    ld a,1
    jr keyboard_store
keyboard_not_q:
    bit 1,b
    jr z,keyboard_not_a
    ld a,2
    jr keyboard_store
keyboard_not_a:
    bit 2,b
    jr z,keyboard_not_o
    ld a,3
    jr keyboard_store
keyboard_not_o:
    bit 3,b
    jr z,keyboard_not_p
    ld a,4
    jr keyboard_store
keyboard_not_p:
    bit 4,b
    jr z,keyboard_store
    ld a,5
keyboard_store:
    ld (key_pressed),a
    ret
key_pressed: defb 0

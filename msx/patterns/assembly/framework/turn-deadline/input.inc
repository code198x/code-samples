; Mainline, normal BIOS mapping, sole consumer of buffered characters.
; CHSNS says Z=empty; CHGET is called only after availability was established.
; Return A: 0 none/ignored, 1 Space, 2 T, 3 Escape. BIOS registers clobbered.
read_command:
    call $009C
    jr z,input_none
    call $009F
    cp 32
    jr z,input_action
    cp 'T'
    jr z,input_toggle
    cp 't'
    jr z,input_toggle
    cp 27
    jr z,input_quit
input_none:
    xor a
    ret
input_action:
    ld a,1
    ret
input_toggle:
    ld a,2
    ret
input_quit:
    ld a,3
    ret

; QAOP + Space. One bit per held control: U D L R Fire = 1 2 4 8 16.
; read_controls: returns A and controls; clobbers AF/BC, preserves DE/HL/IX/IY.
; Read once per update. Interrupt code must not use this state or these ports.
read_controls:
    ld c,0
    ld a,$fb
    in a,($fe)
    bit 0,a
    jr nz,input_no_q
    set 0,c
input_no_q:
    ld a,$fd
    in a,($fe)
    bit 0,a
    jr nz,input_no_a
    set 1,c
input_no_a:
    ld a,$df
    in a,($fe)
    bit 1,a
    jr nz,input_no_o
    set 2,c
input_no_o:
    bit 0,a
    jr nz,input_no_p
    set 3,c
input_no_p:
    ld a,$7f
    in a,($fe)
    bit 0,a
    jr nz,input_no_space
    set 4,c
input_no_space:
    ld a,c
    ld (controls),a
    ret
controls: defb 0

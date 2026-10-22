; A in; A/flags out. One byte, addition modulo 256.
turn_init:
    ld (turn_count),a
    ret
turn_advance:
    ld a,(turn_count)
    add a,STEP
    ld (turn_count),a
    ret
; Release both command keys, then wait. A=1 for 1, A=0 for Q.
; Q wins if both are down. BC/flags clobbered; not a general keyboard scanner.
new_action:
release_keys:
    ld bc,$F7FE
    in a,(c)
    bit 0,a
    jr z,release_keys
    ld b,$FB
    in a,(c)
    bit 0,a
    jr z,release_keys
wait_key:
    ld bc,$FBFE
    in a,(c)
    bit 0,a
    jr z,quit_key
    ld b,$F7
    in a,(c)
    bit 0,a
    jr nz,wait_key
    ld a,1
    ret
quit_key:
    in a,(c)
    bit 0,a
    jr z,quit_key
    xor a
    ret
; Default ASCII character set from ROM; eight display cells, no cursor change.
show_turn:
    ld hl,label
    ld de,$2400
    ld bc,6
    ldir
    ld a,(turn_count)
    rrca
    rrca
    rrca
    rrca
    and 15
    call hex_digit
    ld ($2406),a
    ld a,(turn_count)
    and 15
    call hex_digit
    ld ($2407),a
    ret
hex_digit:
    cp 10
    jr c,digit
    add a,7
digit:
    add a,48
    ret
label:
    db "TURN $"
draw_box:
    ld a,DRAW
    or a
    ret z
    ld a,88
    ld ($2440),a
    ld ($2441),a
    ld ($2442),a
    ld ($2460),a
    ld ($2462),a
    ld ($2480),a
    ld ($2481),a
    ld ($2482),a
    ld a,32
    ld ($2461),a
    ret
; OUT pushes speaker out; IN pushes it in. Reads are not silent on the Ace.
; Blocking pulse train; BC/DE/A/flags clobbered, no pitch guarantee.
trigger_sound:
    ld a,SOUND
    or a
    ret z
    ld d,100
sound_pulse:
    ld bc,$FEFE
    xor a
    out (c),a
    ld e,100
sound_delay_out:
    dec e
    jr nz,sound_delay_out
    in a,(c)
    ld e,100
sound_delay_in:
    dec e
    jr nz,sound_delay_in
    dec d
    jr nz,sound_pulse
    ret
turn_count:
    db 0
code_end:

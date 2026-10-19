; 48K PAL, ROM IM1 interrupts intact. Space holds deliberately slow CPU work.
; SNA or TAP. Code/stack in uncontended RAM; reset to leave.
    org $8000
start:
    di
    im 1
    ld sp,$ff00
    xor a
    ld (updates),a
    ld (updates+1),a
    ld (slow),a
    call initialise_clock
    ei
main_loop:
    call wait_frame
    call read_controls
    ld a,(controls)
    and $10
    ld (slow),a
    call update_game
    call draw_screen
    call expensive_work
frame_done:
    jr main_loop
update_game:
    ld hl,(updates)
    inc hl
    ld (updates),hl
    ret
draw_screen:
    ld a,(updates)
    rrca
    rrca
    rrca
    and 7
    out ($fe),a
    ret
expensive_work:
    ld a,(slow)
    or a
    ret z
    ld c,64
work_outer:
    ld b,0
work_inner:
    djnz work_inner
    dec c
    jr nz,work_outer
    ret
updates: defw 0
slow: defb 0
    include "frame.inc"
    include "../input-to-sound/input.inc"
    end start

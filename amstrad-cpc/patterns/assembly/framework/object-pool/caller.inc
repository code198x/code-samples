    org $8000
mask_index equ $8e00
mask_shift equ $8e01
selected equ $8e02
status_bits equ $8e03
saved_y equ $8e04
saved_x equ $8e05
occupancy_bits equ $8e06
init_sig equ $8e07
preview equ $8e08
check_a equ $8e12
check_b equ $8e13
ready equ $8e14
end_ptr equ $8e16
case_i equ $8e18
saved_iy equ $8e1a
OUTPUT equ $9800
pool_flags equ $9000
pool_life equ $9200
guard_a equ pool_flags-1
guard_b equ pool_flags+POOL_CAPACITY
start:
    push af
    push bc
    push de
    push hl
    push ix
    push iy
    ld (saved_iy),iy
    if BOUNDARY=0
    call exercise_pool
    call preview_pool
    xor a
    ld (check_a),a
    ld (check_b),a
    ld a,(preview+4)
    cp 1
    jr nz,main_a_done
    ld a,1
    ld (check_a),a
main_a_done:
    ld a,(preview+8)
    or a
    jr nz,main_b_done
    ld a,1
    ld (check_b),a
main_b_done:
    ld hl,preview
    ld b,9
main_preview:
    ld a,(hl)
    call emit
    inc hl
    djnz main_preview
    else
    call boundary_pool
    ld a,1
    ld (check_a),a
    ld (check_b),a
    endif
    push iy
    pop hl
    ld de,(saved_iy)
    or a
    sbc hl,de
    jr z,main_registers
    xor a
    ld (check_b),a
main_registers:
    ld a,(check_a)
    call emit
    ld a,(check_b)
    call emit
    ld a,239
    call emit
    ld (end_ptr),ix
    ld a,239
    ld (ready),a
    pop iy
    pop ix
    pop hl
    pop de
    pop bc
    pop af
    ret
    if BOUNDARY=0
    include "../../../../../cross-platform/patterns/framework/additional-object-pools/exercisez80.inc"
    else
    include "../../../../../cross-platform/patterns/framework/additional-object-pools/boundaryz80.inc"
emit:
    ld (ix+0),a
    inc ix
    ret
    endif
    include "pool.inc"
    include "age.inc"
    if POOL_CAPACITY=1
CASE_COUNT equ 2
free_cases: defb 0,1
    else
CASE_COUNT equ 5
free_cases: defb 0,127,128,254,255
    endif
code_end:
    end start

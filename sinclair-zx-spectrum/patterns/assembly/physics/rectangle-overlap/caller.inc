; 48K PAL stock ROM; own stack/display, reset to leave.
start:
    di
    ld sp,$ff00
    call $0daf
    ld hl,case_table
    ld ix,results
    ld a,CASE_COUNT
    ld (remaining),a
case_loop:
    ld de,rect_a
    ld bc,8
    ldir
    call boxes_overlap
    ld a,0
    adc a,0
    ld (ix+0),a
    inc ix
    ld a,(remaining)
    dec a
    ld (remaining),a
    jr nz,case_loop
    ld a,165
    ld (completed),a
    ld hl,example
    ld de,rect_a
    ld bc,8
    ldir
    call boxes_overlap
    ld a,0
    adc a,0
    ld (result),a
    add a,48
    ld de,$4000
    call show_char
    ld a,239
    ld (ready),a
hold:
    jr hold
completed: defb 0
ready: defb 0
remaining: defb 0
result: defb 0
results: defs CASE_COUNT,0

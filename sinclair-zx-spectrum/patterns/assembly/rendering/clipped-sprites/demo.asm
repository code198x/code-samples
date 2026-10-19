org $8000
start:
    di
    ld sp,$ff00
    ld hl,$4000
    ld de,$4001
    ld bc,6143
    ld (hl),$55
    ldir
    ld hl,$5800
    ld de,$5801
    ld bc,767
    ld (hl),71
    ldir
    ld hl,-1
    ld (context),hl
    ld hl,-8
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,31
    ld (context),hl
    ld hl,-8
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,-1
    ld (context),hl
    ld hl,184
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,31
    ld (context),hl
    ld hl,184
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,15
    ld (context),hl
    ld hl,88
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,0
    ld (context),hl
    ld hl,80
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,30
    ld (context),hl
    ld hl,112
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,-2
    ld (context),hl
    ld hl,32
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,32
    ld (context),hl
    ld hl,32
    ld (context+14),hl
    ld hl,shape_a
    ld (context+28),hl
    ld ix,context
    call draw_clipped
    ld hl,$cafe
    ld (ready),hl
    im 1
    ei
main:
    halt
    ld hl,(updates)
    inc hl
    ld (updates),hl
    jr main
ready: defw 0
updates: defw 0
context: defs 32,0
include "clip.inc"
include "draw.inc"
include "shapes.inc"
include "../bitmap-addressing/bitmap-addressing.inc"
end start

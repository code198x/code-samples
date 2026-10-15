; SPDX-License-Identifier: MIT
; Maintained Code198x Bitmap Addressing pattern; no third-party derivation claimed.
; =============================================================================
; BITMAP ADDRESSING - ZX SPECTRUM
; Pixel (D = y 0..191, E = x 0..255) -> HL = screen byte address
; High byte:  0 1 0 y7 y6 y2 y1 y0     Low byte:  y5 y4 y3 x4 x3 x2 x1 x0
; =============================================================================

pixel_addr:
    ld   a,d
    and  %00000111         ; y2 y1 y0
    ld   h,a
    ld   a,d
    and  %11000000         ; y7 y6 (which third)
    rrca
    rrca
    rrca                   ; -> bits 4,3
    or   h
    or   %01000000         ; the $40 base
    ld   h,a               ; H = 010 y7 y6 y2 y1 y0

    ld   a,d
    and  %00111000         ; y5 y4 y3 (char row within third)
    rlca
    rlca                   ; -> bits 7,6,5
    ld   l,a
    ld   a,e
    rrca
    rrca
    rrca
    and  %00011111         ; x / 8 -> column 0..31
    or   l
    ld   l,a               ; L = y5 y4 y3 x4 x3 x2 x1 x0
    ; the pixel within the byte is bit (7 - (x AND 7)); mask = $80 >> (x AND 7)
    ret

; Step HL down exactly one pixel line — the interleave made cheap
end_pixel_addr:

pixel_down:
    inc  h                 ; within a cell, the next line is simply H+1
    ld   a,h
    and  %00000111
    ret  nz                ; still inside this character cell — done
    ld   a,l
    add  a,32              ; crossed a cell: move to the next character row
    ld   l,a
    ret  c                 ; carried into the next third — H is already right
    ld   a,h
    sub  8                 ; else undo the cell carry that inc h left in H
    ld   h,a
    ret
end_pixel_down:

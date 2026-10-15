; SPDX-License-Identifier: MIT
; Qualification caller: 16 rows x 256 pixels, 4 result bytes per input.
; Code $8000, result buffer $9000-$CFFF, stack $FF00; 48K PAL, DI.
; Each record: pixel_addr word, pixel_down word (zero for excluded row 191).
        org $8000
main:
        di
        ld sp,$ff00
        ld ix,$9000
        ld bc,$a55a
        ld a,(start_y)
        ld d,a
        ld e,0
next_pixel:
        ld (before_de),de
        call pixel_addr
        ld (ix+0),l
        ld (ix+1),h
        inc ix
        inc ix
        push hl
        call check_preserved
        pop hl
        ld a,d
        cp 191
        jr z,bottom_row
        call pixel_down
        jr store_down
bottom_row:
        ld hl,0
store_down:
        ld (ix+0),l
        ld (ix+1),h
        inc ix
        inc ix
        call check_preserved
        inc e
        jr nz,next_pixel
        inc d
        ld a,(end_y)
        cp d
        jr nz,next_pixel
        ld a,1
        ld (done),a
        halt
        jr $
check_preserved:
        ld a,b
        cp $a5
        jr nz,failed
        ld a,c
        cp $5a
        jr nz,failed
        ld hl,(before_de)
        ld a,d
        cp h
        jr nz,failed
        ld a,e
        cp l
        jr nz,failed
        ret
failed:
        ld a,255
        ld (done),a
        halt
        jr $
end_main:
start_y: defb 0
end_y: defb 16
before_de: defw 0
done: defb 0
        include "bitmap-addressing.inc"
        end main

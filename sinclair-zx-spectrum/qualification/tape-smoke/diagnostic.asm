; SPDX-License-Identifier: MIT
; A tape-loaded program must execute to produce this result.
; The screen and completion word live outside the CODE block.
        org $8000
start:  di
        ld sp,$ff00
        xor a
        ld ($7000),a
        ld ($7001),a
        ld hl,$4000
        ld de,$4001
        ld bc,6143
        ld (hl),$aa
        ldir
        ld hl,$5800
        ld de,$5801
        ld bc,767
        ld (hl),$47
        ldir
        ld a,4
        out ($fe),a
; Compute the completion bytes instead of embedding the expected word.
        ld a,$a5
        xor $ff
        ld ($7000),a
        inc a
        ld ($7001),a
complete:
        jr complete
        end start

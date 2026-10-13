; SPDX-License-Identifier: MIT
; A source-generated SNA must restore, then execute to produce this result.
; No DEVICE or ROM routines: this deliberately uses the no-DEVICE RAM model.
; Distinct origin and entry exercise the PC saved on the snapshot stack.
        org $8000
        db $de,$ad,$be,$ef
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

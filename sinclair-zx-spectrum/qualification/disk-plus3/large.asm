; SPDX-License-Identifier: MIT
; 20 KiB CODE: the ROM must load across tracks and two CP/M extents.
; Verify the filler, then execute completion code beyond the first extent.
        org $8000
start:  di
        ld sp,$ff00
        xor a
        ld ($7000),a
        ld ($7001),a
        ld hl,data_start
        ld bc,tail-data_start
verify: ld a,h
        cp (hl)
        jr nz,failed
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,verify
        jp tail
failed: ld a,2
        out ($fe),a
        jr failed
        defs $8040-$,0
data_start:
; Each page has a different value: its high address byte.
; Repeating a sector from another track cannot satisfy this check.
        defs $8100-$,$ >> 8
        rept 78
        defs 256,$ >> 8
        endm
        defs $cfc0-$,$ >> 8
; File offset $4FC0 is beyond the $3F80 CODE boundary of extent zero:
; the +3DOS header occupies the first 128 bytes of the first extent.
tail:   ld hl,$4000
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
        ld a,$a5
        xor $ff
        ld ($7000),a
        inc a
        ld ($7001),a
complete:
        jr complete
        defs $d000-$,$3c
        end start

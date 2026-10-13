; SPDX-License-Identifier: MIT
; Eight distinct bank markers, written before any readback.
; Code stays in bank 2, stack below C000, observations in bank 5.
; Offset 3B00 aliases BB00 (bank 2) and 7B00 (bank 5), away from
; code, stack, screen, signature and observations.
        org $8000
start:  di
        ld sp,$bf00
        xor a
        ld ($7000),a
        ld ($7001),a
        ld bc,$7ffd
        ld d,0
write_bank:
        ld a,d
        or $10                  ; ROM 1, primary screen, paging unlocked
        out (c),a
        ld a,d
        add a,$a0
        ld ($fb00),a
        inc d
        ld a,d
        cp 8
        jr nz,write_bank

        ld d,0
        ld hl,$7010
read_bank:
        ld a,d
        or $10
        out (c),a
        ld a,($fb00)
        ld (hl),a               ; retain actual readback, not the expectation
        ld e,a
        ld a,d
        add a,$a0
        cp e
        jr nz,failed
        inc hl
        inc d
        ld a,d
        cp 8
        jr nz,read_bank
        ld a,$10                ; restore RAM bank 0; no return into BASIC
        out (c),a

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
        ld a,$a5
        xor $ff
        ld ($7000),a
        inc a
        ld ($7001),a
complete:
        jr complete
failed: ld a,2
        out ($fe),a
        jr failed
        end start

; SPDX-License-Identifier: MIT
; Verify distinct banks, then prove bit 5 prevents RAM bank changes.
; Code stays in bank 2, stack below C000, observations in bank 5.
; Offset 3B00 aliases BB00 (bank 2) and 7B00 (bank 5), away from
; code, stack, screen, signature and observations.
lock_value equ $33              ; ROM 1, lock bit, RAM bank 3
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
        jp nz,failed
        inc hl
        inc d
        ld a,d
        cp 8
        jr nz,read_bank
        ld a,lock_value
        out (c),a               ; select bank 3 and lock further paging writes
        ld hl,$7020
        ld a,($fb00)
        ld (hl),a               ; record the selected bank before attempted changes
        inc hl
        ld d,0
try_bank:
        ld a,d
        or $10                  ; all eight selections, each with lock bit CLEAR
        out (c),a
        ld a,($fb00)
        ld (hl),a               ; record each actual read before judging success
        inc hl
        inc d
        ld a,d
        cp 8
        jr nz,try_bank
        ld a,$c3
        ld ($fb00),a            ; writes must still reach bank 3, not bank 7
        ld a,($fb00)
        ld (hl),a
        cp $c3
        jp nz,failed
        ld hl,$7020
        ld b,9
check_lock:
        ld a,(hl)
        cp $a3
        jp nz,failed
        inc hl
        djnz check_lock

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

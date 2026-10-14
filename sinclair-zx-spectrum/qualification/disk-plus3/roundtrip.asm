; SPDX-License-Identifier: MIT
; BASIC calls generate, clears after SAVE, then checks after LOAD.
; Preserve BASIC's stack and IY when returning. No ROM calls are intercepted.
        org $8000
        jp generate
        jp clear_buffer
        jp verify

generate:
        di
        xor a
        ld ($7000),a
        ld ($7001),a
        ld hl,$9000
        ld bc,1024
fill:
        ld a,h
        xor l
        xor $5a
        ld (hl),a
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,fill
        ld a,1
        ld ($7002),a
generated:
        ei
        ret

clear_buffer:
        di
        ld hl,$9000
        ld de,$9001
        ld bc,1023
        ld (hl),0
        ldir
        ld a,2
        ld ($7002),a
cleared:
        ei
        ret

verify:
        di
        ld hl,$9000
        ld bc,1024
check_byte:
        ld a,h
        xor l
        xor $5a
        cp (hl)
        jr nz,failed
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,check_byte
        ld a,3
        ld ($7002),a
verified:
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
failed:
        ld a,2
        out ($fe),a
failure_loop:
        jr failure_loop
        end $8000

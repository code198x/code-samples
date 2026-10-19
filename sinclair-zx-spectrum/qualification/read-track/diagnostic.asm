; SPDX-License-Identifier: MIT
; Cold-loaded by +3DOS. case.inc supplies only the nine command bytes.
; Poll the public FDC ports; never call a host controller API.
        org $8000
        di
        ld sp,$7fff
        xor a
        ld ($7000),a
        ld ($7001),a
        ld ($7002),a
        ld ($7003),a
        ld ($7004),a
        ld bc,$1ffd
        ld a,$0c             ; motor on; normal ROM/RAM configuration
        out (c),a
        ld a,$0f             ; Seek A to cylinder 39, outside boot files
        call send
        xor a
        call send
        ld a,39
        call send
        ld de,0              ; bounded seek settlement; CPU executes throughout
settle:
        dec de
        ld a,d
        or e
        jr nz,settle
        ld a,8               ; drain Seek Sense Interrupt Status
        call send
        call receive
        call receive
        ld hl,command
        ld e,9
send_command:
        ld a,(hl)
        call send
        inc hl
        dec e
        jr nz,send_command
        ld hl,$a000
        ld ix,$7010
        ld bc,$2ffd
poll:
        in a,(c)
        jp p,poll            ; frame/host deadline bounds the entire guest
        bit 5,a
        jr z,result_byte
        ld b,$3f
        ini                  ; one guest I/O read and RAM write
        ld b,$2f
        ld a,h
        cp $e0               ; 16 KiB hard payload bound
        jp nc,failed
        jp poll
result_byte:
        ld a,($7004)
        cp 7
        jp nc,failed
        inc a
        ld ($7004),a
        ld bc,$3ffd
        in a,(c)
        ld (ix+0),a
        inc ix
        ld bc,$2ffd
        ld a,($7004)
        cp 7
        jp nz,poll
finished:
        ld de,$a000
        or a
        sbc hl,de
        ld ($7002),hl
        ld a,($7004)
        cp 7
        jp nz,failed
        ld a,4               ; real next command: Sense Drive Status A
        call send
        xor a
        call send
        call receive
        ld ($7017),a
        ld a,$a5             ; constructed by execution, never stored as a pair
        ld ($7000),a
        cpl
        ld ($7001),a
complete:
        jr complete
failed:
        ld a,$ee
        ld ($7000),a
        jr failed
; Bounded command/read helpers preserve HL, DE, IX.
send:
        push de
        push af
        ld de,0
send_wait:
        ld bc,$2ffd
        in a,(c)
        and $c0
        cp $80
        jr z,send_ready
        dec de
        ld a,d
        or e
        jr nz,send_wait
        jp failed
send_ready:
        pop af
        ld bc,$3ffd
        out (c),a
        pop de
        ret
receive:
        push de
        ld de,0
read_wait:
        ld bc,$2ffd
        in a,(c)
        and $c0
        cp $c0
        jr z,read_ready
        dec de
        ld a,d
        or e
        jr nz,read_wait
        jp failed
read_ready:
        ld bc,$3ffd
        in a,(c)
        pop de
        ret
command:
        include "case.inc"

        end $8000

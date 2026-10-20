; SPDX-License-Identifier: MIT
; Cold +3DOS load. Observe mounted-A READY for motor on/off/on.
; Trace: stage, result length, ST3 (or setup ST0), PCN-or-255, following MSR.
        org $8000
        di
        ld sp,$7fff
        xor a
        ld ($7000),a
        ld ($7001),a
        ld ($7002),a
        ld ($7003),a
        ld ix,$7010
        ld bc,$1ffd
        ld a,12
        out (c),a
        call settle
        call drain          ; stage0: ROM and motor/READY residue
        ld a,15
        call send
        xor a
        call send
        ld a,9
        call send           ; move physical A off track zero
        call settle
        call drain          ; acknowledge Seek before any SDS command
        ld a,1
        ld ($7003),a        ; motor already on: first READY sample
        call sample_a
        ld bc,$1ffd
        ld a,4             ; retain ROM/paging, stop motor (bit3 clear)
        out (c),a
        call settle
        ld a,2
        ld ($7003),a        ; motor off: READY must clear
        call sample_a
        ld bc,$1ffd
        ld a,12            ; same mapping, motor on (bit3 set)
        out (c),a
        call settle
        ld a,3
        ld ($7003),a        ; motor on again: READY must reassert
        call sample_a
        ld hl,$4000
        ld (hl),$aa
        ld de,$4001
        ld bc,6143
        ldir
        ld hl,$5800
        ld (hl),$47
        ld de,$5801
        ld bc,767
        ldir
        ld a,$a5
        ld ($7000),a
        cpl
        ld ($7001),a
complete:
        jr complete
failed:
        ld a,$ee
        ld ($7000),a
        jr failed
sample_a:
        ld a,4
        call send
        xor a
        call send
        jp record
sis_record:
        ld a,8
        call send
        jp record
; Bounded drain includes its terminal Invalid record in the evidence.
drain:
        ld d,8
more:
        call sis_record
        cp $80
        ret z
        dec d
        jr nz,more
        jp failed
record:
        push de
        ld a,($7002)
        cp 32
        jp nc,failed
        ld a,($7003)
        ld (ix+0),a
        ld (ix+1),1
        ld (ix+3),255
        call receive
        ld (ix+2),a
        ld bc,$2ffd
        in a,(c)
        bit 4,a
        jr z,record_end
        call receive
        ld (ix+3),a
        ld (ix+1),2
record_end:
        ld bc,$2ffd
        in a,(c)
        ld (ix+4),a
        and $d0
        cp $80
        jp nz,failed
        ld a,(ix+2)
        push af
        ld de,5
        add ix,de
        ld a,($7002)
        inc a
        ld ($7002),a
        pop af
        pop de
        ret
settle:
        push de
        ld d,2
settle_outer:
        ld hl,0
settle_inner:
        dec hl
        ld a,h
        or l
        jr nz,settle_inner
        dec d
        jr nz,settle_outer
        pop de
        ret
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
        end $8000

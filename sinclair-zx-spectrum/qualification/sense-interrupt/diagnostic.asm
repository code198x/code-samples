; SPDX-License-Identifier: MIT
; Normal +3DOS cold load. Every FDC transaction is executed by this Z80 program.
; Trace records: stage,length,ST0-or-ST3,PCN-or-255,following MSR.
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
        call drain          ; stage0 records and drains ROM/READY residue
        ld a,1
        ld ($7003),a
        call sis_record     ; no pending: one-byte Invalid
        ld a,2
        ld ($7003),a
        ld a,15
        call send
        xor a
        call send
        ld a,5
        call send
        call settle
        call sis_record     ; logical0 PCN5
        ld a,3
        ld ($7003),a
        call sis_record
        ld a,4
        ld ($7003),a
        ld a,15
        call send
        ld a,2
        call send
        ld a,3
        call send
        call settle
        call sis_record     ; logical2 PCN3, same physical drive A
        ld a,5
        ld ($7003),a
        ld bc,$1ffd
        ld a,4
        out (c),a
        call settle
        call drain          ; motor off: READY falls
        ld a,6
        ld ($7003),a
        ld bc,$1ffd
        ld a,12
        out (c),a
        call settle
        call drain          ; motor on: READY rises
        ld a,7
        ld ($7003),a
        ld a,15
        call send
        xor a
        call send
        ld a,9
        call send
        call settle
        ld a,4              ; deliberately before SIS: documented Invalid
        call send
        ld bc,$2ffd         ; observe early opcode rejection before parameter
        in a,(c)
        and $c0
        cp $c0
        jr z,ordering_result
        xor a               ; reference may consume the complete command first
        call send
ordering_result:
        call record
        ld a,8
        ld ($7003),a
        call sis_record     ; rejected command must not lose PCN9/status
        ld a,9
        ld ($7003),a
        call sis_record
        ld a,10
        ld ($7003),a
        ld a,4
        call send
        xor a
        call send
        call record         ; valid following SDS, RY checked independently
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

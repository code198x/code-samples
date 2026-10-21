; SPDX-License-Identifier: MIT
; Cold +3DOS load. Format scratch track39, physical IDs5,2, filler6D.
; Five-byte trace rows record setup, seven-byte results and computed payload stats.
; No host injection, snapshot loading or disk mastering inside the guest.
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
        ld a,39
        call send
        call settle
        call drain          ; acknowledge Seek before issuing Format
        ld a,3
        call send
        ld a,$df
        call send
        ld a,3
        call send           ; non-DMA execution requests
        ld a,1
        ld ($7003),a
        ld hl,format_command
        ld e,6
        call command
        call write_ids      ; eight paced CHRN bytes, no payload injection
        call record_id

        ld a,2
        ld ($7003),a
        call read_id
        ld a,3
        ld ($7003),a
        call read_id

        ld a,4
        ld ($7003),a
        ld hl,read_five
        call read_payload
        ld a,5
        ld ($7003),a
        ld hl,read_two
        call read_payload
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
command:
        ld a,(hl)
        call send
        inc hl
        dec e
        jr nz,command
        ret
read_id:
        ld a,$4a
        call send
        xor a
        call send
        jp record_id
read_payload:
        ld e,9
        call command
        call read128
        call record_id
        xor a
        ld ($7004),a
        ld de,128           ; D=sum, E=remaining bytes
        ld hl,$b000
payload_byte:
        ld a,(hl)
        inc hl
        cp $6d
        jp nz,failed        ; check every received byte after the paced transfer
        ld b,a
        add a,d
        ld d,a
        ld a,($7004)
        xor b
        ld ($7004),a
        dec e
        jr nz,payload_byte
        ld a,($7003)
        ld (ix+0),a
        ld (ix+1),128
        ld (ix+2),128
        ld (ix+3),d
        ld a,($7004)
        ld (ix+4),a
        ld de,5
        add ix,de
        ld a,($7002)
        inc a
        ld ($7002),a
        ret
; Adapted from disk-plus3/fdc-commands.asm's tight port loops. DE supplies a
; fresh65536-poll deadline per byte. No calls or comparisons of payload bytes
; interrupt the 32us MFM service path. HL supplies the finite transfer bound.
write_ids:
        ld hl,format_ids
        ld bc,$2ffd
write_next:
        ld de,0
write_poll:
        in a,(c)
        and $c0
        cp $80
        jr z,write_ready
        dec de
        ld a,d
        or e
        jr nz,write_poll
        jp failed
write_ready:
        ld b,$3f
        outi
        ld b,$2f
        ld a,l
        cp format_ids_end & 255
        jr nz,write_next
        ret
read128:
        ld hl,$b000
        ld bc,$2ffd
read_next:
        ld de,0
payload_poll:
        in a,(c)
        and $c0
        cp $c0
        jr z,payload_ready
        dec de
        ld a,d
        or e
        jr nz,payload_poll
        jp failed
payload_ready:
        ld b,$3f
        ini
        ld b,$2f
        ld a,l
        cp 128
        jr nz,read_next
        ret
record_id:
        ld a,($7002)
        cp 30
        jp nc,failed
        ld a,($7003)
        ld (ix+0),a
        ld (ix+5),a
        call receive
        ld (ix+1),a         ; ST0
        call receive
        ld (ix+2),a         ; ST1
        call receive
        ld (ix+3),a         ; ST2
        call receive
        ld (ix+4),a         ; C
        call receive
        ld (ix+6),a         ; H
        call receive
        ld (ix+7),a         ; R
        call receive
        ld (ix+8),a         ; N
        ld bc,$2ffd
        in a,(c)
        ld (ix+9),a         ; MSR after exactly seven result bytes
        cp $80
        jp nz,failed
        ld de,10
        add ix,de
        ld a,($7002)
        add a,2
        ld ($7002),a
        ret
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
format_command:
        db $4d,0,0,2,$2a,$6d
format_ids:
        db 39,0,5,0,39,0,2,0
format_ids_end:
read_five:
        db $46,0,39,0,5,0,5,$2a,128
read_two:
        db $46,0,39,0,2,0,2,$2a,128
        end $8000

; SPDX-License-Identifier: MIT
; Cold ROM load, then Read Data single/multiple sectors and error recovery.
; The disk fixture seeds unused track9 sectors1..3. Read bytes become bitmap RAM.
; Trace: two five-byte records contain ST0/ST1/ST2/C/H/R/N/following MSR;
; a third contains stage, actual count low/high, destination low/high.
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
        call drain
        ld a,15
        call send
        xor a
        call send
        ld a,9
        call send
        call settle
        call drain
        ld a,3             ; SPECIFY: SRT/HUT=$df, HLT=2ms, non-DMA=1
        call send
        ld a,$df
        call send
        ld a,3
        call send
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
        ld hl,$4000
        ld ($7004),hl
        ld iy,commands
        ld a,1
        ld ($7003),a
next_command:
        ld b,9
send_command:
        ld a,(iy+0)
        inc iy
        push bc
        call send
        pop bc
        djnz send_command
        ld e,(iy+0)
        inc iy
        ld d,(iy+0)
        inc iy
        push iy
        ld iy,0            ; finite cumulative wait budget for this command
        ld hl,($7004)
        ld ($700a),hl
        ld a,d
        or e
        jr z,data_done
        ld bc,$2ffd
read_payload:
        in a,(c)
        and $f0
        cp $f0
        jr nz,payload_wait
payload_ready:
        ld b,$3f
        ini                 ; service plus RAM store in 16T, not three instructions
        dec de
        ld a,d
        or e
        jr z,data_done
        ld b,$2f
        jr read_payload
payload_wait:
        cp $d0
        jp z,failed         ; result before expected byte count
        dec iy
        ld a,iyh
        or iyl
        jr nz,read_payload
        jp failed
data_done:
        pop iy
        ld ($7004),hl
        ld de,($700a)
        or a
        sbc hl,de
        ld ($7008),hl       ; count actual delivered bytes, not result bytes
        call record_result
        ld a,($7003)
        inc a
        ld ($7003),a
        cp 6
        jr nz,next_command
        dec a
        ld ($7003),a
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
record_result:
        ld a,($7002)
        cp 29
        jp nc,failed
        ld a,($7003)
        ld (ix+0),a
        ld (ix+5),a
        ld (ix+10),a
        call receive
        ld (ix+1),a
        call receive
        ld (ix+2),a
        call receive
        ld (ix+3),a
        call receive
        ld (ix+4),a
        call receive
        ld (ix+6),a
        call receive
        ld (ix+7),a
        call receive
        ld (ix+8),a
        ld bc,$2ffd
        in a,(c)
        ld (ix+9),a
        cp $80
        jp nz,failed
        ld hl,($7008)
        ld (ix+11),l
        ld (ix+12),h
        ld hl,($7004)
        ld (ix+13),l
        ld (ix+14),h
        ld de,15
        add ix,de
        ld a,($7002)
        add a,3
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
        and $f0
        cp $d0
        jr z,read_ready
        cp $f0
        jp z,failed
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

commands:
        db $46,0,9,0,1,2,1,$2a,$ff
        dw 512
        db $46,2,9,0,1,2,3,$2a,$ff
        dw 1536
        db $46,0,9,0,2,2,2,$2a,$ff
        dw 512
        db $46,2,9,0,10,2,10,$2a,$ff
        dw 0
        db $46,0,9,0,3,2,3,$2a,$ff
        dw 512
        end $8000

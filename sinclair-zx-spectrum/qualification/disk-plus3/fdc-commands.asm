; SPDX-License-Identifier: MIT
; ROM Loader loads this program. Only this guest accesses the FDC ports.
; Destructive in-memory writes use track 39, outside the small loader/CODE files.
; Polling is bounded by the qualification runner's frame and host deadlines.
; Result CHRN is retained, not treated as proof of disputed no-TC hardware rules.
        org $8000
        di
        ld sp,$7ff0
        xor a
        ld ($7000),a
        ld ($7001),a
        ld ($7002),a
        ld ($7003),a
        ld hl,$7020
        ld de,$7021
        ld bc,41
        ld (hl),a
        ldir
        ld bc,$1ffd
        ld a,8
        out (c),a

; Seed a normal data sector from computed guest bytes, then write a DDAM sector.
        ld hl,seek_command
        ld e,3
        call command
        call wait_seek

        ld a,$24
        xor $66
        call fill_buffer
        ld hl,normal_command
        call command9
        ld hl,$a000
        call write512
        ld hl,$7060
        call result7
        call clean_data_status

        ld a,$5a
        xor $ff
        call fill_buffer
        ld hl,deleted_command
        call command9
        ld hl,$a000
        call write512
        ld hl,$7020
        call result7
        call clean_data_status
        ld hl,read_deleted_command
        call command9
        ld hl,$b000
        ld de,512
        call read_bytes
        ld hl,$7027
        call result7
        call clean_data_status
        ld hl,$b000
        ld de,512
        ld a,$a5
        call compare_bytes
        ld a,1
        ld ($7002),a

; This standard track stores IDs 1,2,...9 in physical order. This case checks
; two returned payloads, not unusual physical order or reconstructed raw gaps.
; Requested R=2 matches the final returned ID; it is not a start-sector selector.
        ld hl,track_command
        call command9
        ld hl,$b000
        ld de,1024
        call read_bytes
        ld hl,$702e
        call result7
        ld a,($702f)
        and $7f
        jp nz,failed
        ld a,($7030)
        and $bf
        jp nz,failed
        ld hl,$b000
        ld de,512
        ld a,$a5
        call compare_bytes
        ld de,512
        ld a,$42
        call compare_bytes
        ld a,2
        ld ($7002),a

; NEC December 1978 p15/Table4 compares disk bytes with processor bytes.
; Disk sector2 is $42: equal to $42, <= $43 and >= $41.
        ld a,$42
        call fill_buffer
        ld hl,equal_command
        call command9
        ld hl,$a000
        call write512
        ld hl,$7035
        call result7
        ld hl,$7035
        ld a,8
        call scan_status
        ld a,3
        ld ($7002),a

        ld a,$43
        call fill_buffer
        ld hl,low_command
        call command9
        ld hl,$a000
        call write512
        ld hl,$703c
        call result7
        ld hl,$703c
        xor a
        call scan_status
        ld a,4
        ld ($7002),a

        ld a,$41
        call fill_buffer
        ld hl,high_command
        call command9
        ld hl,$a000
        call write512
        ld hl,$7043
        call result7
        ld hl,$7043
        xor a
        call scan_status
        ld a,5
        ld ($7002),a

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
        jp complete

; Poll actual completion. Sense's no-pending $80 is one byte on the
; controller/reference. Emu's existing $80,$00 representation is drained using
; MSR CB, without pretending it is a completed seek or a fixed physical delay.
wait_seek:
        ld hl,sense_command
        ld e,1
        call command
        ld hl,$7060
        ld e,1
        call read_result
        ld a,($7060)
        cp $80
        jr z,seek_no_pending
        ld e,1
        call read_result
        ld bc,$2ffd
        in a,(c)
        bit 4,a
        jp nz,failed
        ld a,($7060)
        and 3
        jr nz,seek_retry
        ld a,($7060)
        and $f8
        cp $20
        jp nz,failed
        ld a,($7061)
        cp 39
        jp nz,failed
        ret
seek_no_pending:
        ld bc,$2ffd
seek_drain_poll:
        in a,(c)
        bit 4,a
        jr z,seek_retry
        bit 7,a
        jr z,seek_drain_poll
        bit 6,a
        jp z,failed
        ld e,1
        call read_result
        in a,(c)
        bit 4,a
        jp nz,failed
seek_retry:
        ; Short polling backoff, not an assumed drive step/seek duration.
        ld b,0
seek_backoff:
        djnz seek_backoff
        jr wait_seek

; HL points to the just-read seven-byte result. Ignore only IC and EOT;
; preserve every raw result for the host rather than claiming hardware CHRN.
clean_data_status:
        dec hl
        dec hl
        dec hl
        dec hl
        dec hl
        dec hl
        dec hl
        ld a,(hl)
        and $3f
        jp nz,failed
        inc hl
        ld a,(hl)
        and $7f
        jp nz,failed
        inc hl
        ld a,(hl)
        or a
        jp nz,failed
        ret

scan_status:
        ld d,a
        ld a,(hl)
        or a
        jp nz,failed
        inc hl
        ld a,(hl)
        or a
        jp nz,failed
        inc hl
        ld a,(hl)
        cp d
        jp nz,failed
        ret

fill_buffer:
        ld hl,$a000
        ld de,$a001
        ld bc,511
        ld (hl),a
        ldir
        ret

compare_bytes:
        ld b,a
compare_loop:
        ld a,(hl)
        cp b
        jp nz,failed
        inc hl
        dec de
        ld a,d
        or e
        jr nz,compare_loop
        ret

command9:
        ld e,9
command:
        ld bc,$2ffd
command_poll:
        in a,(c)
        jp p,command_poll
        bit 6,a
        jp nz,failed
        set 4,b
        ld a,(hl)
        out (c),a
        res 4,b
        inc hl
        dec e
        jr nz,command_poll
        ret

write512:
        ld de,512
        ld bc,$2ffd
write_poll:
        in a,(c)
        jp p,write_poll
        bit 6,a
        jp nz,failed
        set 4,b
        ld a,(hl)
        out (c),a
        res 4,b
        inc hl
        dec de
        ld a,d
        or e
        jr nz,write_poll
        ret

read_bytes:
        ld bc,$2ffd
read_poll:
        in a,(c)
        jp p,read_poll
        bit 6,a
        jp z,failed
        set 4,b
        in a,(c)
        res 4,b
        ld (hl),a
        inc hl
        dec de
        ld a,d
        or e
        jr nz,read_poll
        ret

result7:
        ld e,7
read_result:
        ld bc,$2ffd
result_poll:
        in a,(c)
        jp p,result_poll
        bit 6,a
        jp z,failed
        set 4,b
        in a,(c)
        res 4,b
        ld (hl),a
        inc hl
        dec e
        jr nz,result_poll
        ret

failed:
        ld a,1
        ld ($7003),a
        ld a,2
        out ($fe),a
failure_loop:
        jr failure_loop

seek_command:         db $0f,0,39
sense_command:        db $08
normal_command:       db $45,0,39,0,2,2,2,$2a,$ff
deleted_command:      db $49,0,39,0,1,2,1,$2a,$ff
read_deleted_command: db $4c,0,39,0,1,2,1,$2a,$ff
track_command:        db $42,0,39,0,2,2,2,$2a,$ff
equal_command:        db $51,0,39,0,2,2,2,$2a,1
low_command:          db $59,0,39,0,2,2,2,$2a,1
high_command:         db $5d,0,39,0,2,2,2,$2a,1

        defs $8ff0-$,0
complete:
        jr complete
        end $8000

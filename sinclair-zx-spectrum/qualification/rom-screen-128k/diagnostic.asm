; SPDX-License-Identifier: MIT
; 128K ROM and display selection, then bit-5 lock with both selectors set.
; The host observes each phase's computed ROM sum and actual rendered pixels.
; No firmware bytes are embedded. Code/stack stay in fixed bank 2.
lock_value equ $3f              ; lock, ROM 1, shadow screen, RAM bank 7
        org $8000
start:  di
        ld sp,$bf00
        xor a
        ld ($7000),a
        ld ($7001),a
        ld ($7002),a
        out ($fe),a
        ld bc,$7ffd
        ld a,$17               ; map bank 7 for preparing its screen
        out (c),a
        ld hl,$4000
        ld de,$4001
        ld bc,6143
        ld (hl),$aa             ; primary: white/black alternating columns
        ldir
        ld hl,$5800
        ld de,$5801
        ld bc,767
        ld (hl),$47
        ldir
        ld hl,$c000
        ld de,$c001
        ld bc,6143
        ld (hl),$55             ; shadow: black/white alternating columns
        ldir
        ld hl,$d800
        ld de,$d801
        ld bc,767
        ld (hl),$47
        ldir

        ld a,$07               ; ROM 0, primary
        call select
        ld a,1
        ld ($7002),a
phase1: call hold
        ld a,$1f               ; ROM 1, shadow
        call select
        ld a,2
        ld ($7002),a
phase2: call hold
        ld a,$07               ; both selectors can return to zero
        call select
        ld a,3
        ld ($7002),a
phase3: call hold
        ld a,lock_value        ; lock ROM 1 and shadow
        call select
        ld a,4
        ld ($7002),a
phase4: call hold
        ld a,$0f               ; try to clear ROM selector only
        call select
        ld a,5
        ld ($7002),a
phase5: call hold
        ld a,$17               ; try to clear display selector only
        call select
        ld a,6
        ld ($7002),a
phase6: call hold
        ld a,$07               ; try to clear both
        call select
        ld a,7
        ld ($7002),a
phase7: call hold
        ld a,$a5
        xor $ff
        ld ($7000),a
        inc a
        ld ($7001),a
complete:
        jr complete

; Sum every byte visible in the ROM window modulo 65536. This distinguishes
; the named ROM pair; firmware identity itself uses SHA-256 outside the machine.
select: ld bc,$7ffd
        out (c),a
        ld hl,0
        ld de,0
        ld bc,$4000
sum:    ld a,(hl)
        add a,e
        ld e,a
        jr nc,no_carry
        inc d
no_carry:
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,sum
        ld ($7003),de
        ret

; Allow several full display frames for observation without interrupts or
; host writes. This delay is a capture window, not a timing calibration test.
hold:   ld d,4
outer:  ld bc,12000
inner:  dec bc
        ld a,b
        or c
        jr nz,inner
        dec d
        jr nz,outer
        ret
        end start

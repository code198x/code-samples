; Isolate the interrupt counter before coupling it to movement.
 org 32768
start:
 di
 ld sp,$FCF0
 ; A minimal IM2 interrupt avoids borrowing the ROM keyboard/timing service.
 ld hl,$FE00
 ld de,$FE01
 ld bc,256
 ld (hl),$FD
 ldir
 ld a,$C3
 ld ($FDFD),a
 ld hl,interrupt
 ld ($FDFE),hl
 ld a,$FE
 ld i,a
 im 2
 xor a
 out ($FE),a
 ei
 jp main_loop
interrupt:
 push af
 ld a,(frames)
 inc a
 ld (frames),a
 pop af
 ei
 reti

main_loop:
 halt
 ld a,(frames)
 and 1
 jr nz,main_loop
 ld hl,(updates)
 inc hl
 ld (updates),hl
 ; A display change every 32 updates: easy to see, separate from timing.
 ld a,l
 rrca
 rrca
 rrca
 rrca
 rrca
 and 7
 out ($FE),a
 jp main_loop
frames: defb 0
updates: defw 0
 end start

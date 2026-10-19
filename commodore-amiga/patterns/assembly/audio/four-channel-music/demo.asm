; Boot ADF, A500 OCS PAL/Kickstart1.3. Reset to leave. No OS-return claim.
    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    bclr #7,$bfe201
    move.w #$cafe,ready
wait_for_fire:
    bsr wait_frame
    btst #7,$bfe001
    bne wait_for_fire
    bsr music_init
main_loop:
    bsr wait_frame
    bsr music_tick
    addq.w #1,updates
    bra main_loop
signature: dc.b "198XMUSICAUDIT!",0
    even
ready: dc.w 0
updates: dc.w 0
    include "music.inc"
    include "../../framework/game-loop/frame.inc"
program_end:

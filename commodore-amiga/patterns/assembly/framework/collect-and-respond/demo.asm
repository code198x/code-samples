; A500 OCS PAL/KS1.3; boot ADF. Digital joystick port2, fire restarts.
; Exclusive custom chips and CIA-A bit7. Reset to leave; no OS return.
    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5)
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5)
    bclr #7,$bfe201
    lea plane,a0
    move.l a0,d0
    lea copbpl,a1
    move.w d0,6(a1)
    swap d0
    move.w d0,2(a1)
    lea copperlist,a0
    move.l a0,$080(a5)
    move.w #0,$088(a5)
    move.w #$8380,$096(a5)
    bsr reset_game
    move.w #$cafe,ready
main_loop:
    bsr wait_frame
    bsr read_controls
    bsr detect_edges
    bsr service_sound
    bsr update_player
    bsr draw_screen
    addq.w #1,updates
frame_done:
    bra main_loop
signature: dc.b "198XCOLLECTAMIGA!"
    even
ready: dc.w 0
updates: dc.w 0
previous: dc.w 0
pressed: dc.w 0
released: dc.w 0
player_x: dc.w 2
player_y: dc.w 5
item_active: dc.w 1
score: dc.w 0
move_delay: dc.w 0
sound_ticks: dc.w 0
old_x: dc.w 0
old_y: dc.w 0
    include "rules.inc"
    include "draw.inc"
    include "sound.inc"
    include "../game-loop/frame.inc"
    include "../input-to-sound/input.inc"
    include "../../audio/playing-a-sample/paula-sample.inc"
    even
copperlist:
    dc.w $08e,$2c81,$090,$2cc1,$092,$0038,$094,$00d0
    dc.w $100,$1200,$102,0,$104,0,$108,0,$10a,0
    dc.w $180,$012,$182,$fff
copbpl:
    dc.w $0e0,0,$0e2,0
    dc.w $ffff,$fffe
    even
wave: dc.b 0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
plane: dcb.b 10240,0
    include "collision.inc"
program_end:

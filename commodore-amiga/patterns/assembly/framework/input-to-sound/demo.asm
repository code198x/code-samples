; A500 OCS PAL, Kickstart 1.3. Boot the generated ADF. Port 2 Fire starts
; the looping sample, release stops it. Background changes per new press.
; Takes over the machine, including interrupts/DMA/channel 0; reset to leave.
    section code,code_c
start:
    lea $dff000,a5
    move.w #$7fff,$09a(a5) ; disable custom interrupts
    move.w #$7fff,$09c(a5)
    move.w #$7fff,$096(a5) ; all DMA off, including channel 0
    clr.w trigger_count
    clr.w updates
    lea press_counts,a0
    moveq #4,d1
clear_press_counts:
    clr.w (a0)+
    dbra d1,clear_press_counts
    bsr initialise_input
    bsr wait_frame         ; channel off longer than two periods
    move.w #$cafe,ready
wait_update:
    bsr wait_frame
    bsr update_input
    ; Count each direction/fire edge so the normal running demo is inspectable.
    move.w new_presses,d0
    btst #8,d0
    beq.s count_down
    addq.w #1,press_counts
count_down:
    btst #0,d0
    beq.s count_left
    addq.w #1,press_counts+2
count_left:
    btst #9,d0
    beq.s count_right
    addq.w #1,press_counts+4
count_right:
    btst #1,d0
    beq.s count_fire
    addq.w #1,press_counts+6
count_fire:
    btst #4,d0
    beq.s count_done
    addq.w #1,press_counts+8
count_done:
    btst #4,new_presses+1
    beq.s show_state
    addq.w #1,trigger_count
show_state:
    move.w trigger_count,d0
    and.w #$000f,d0
    or.w #$0030,d0
    move.w d0,$180(a5)
    addq.w #1,updates
frame_done:
    bra.s wait_update
wait_frame:
    move.w #$0020,$09c(a5)
wait_vertical:
    move.w $01e(a5),d6
    and.w #$0020,d6
    beq.s wait_vertical
    rts
; One chip-memory hunk lets the verifier relocate labels from this signature.
signature: dc.b "198XINPUTAMIGA!",0,0
    even
ready: dc.w 0
trigger_count: dc.w 0
updates: dc.w 0
press_counts: dc.w 0,0,0,0,0
    include "input.inc"
    include "presses.inc"
    include "../../audio/playing-a-sample/paula-sample.inc"
    include "use.inc"
    even
waveform: dc.b 0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
program_end:

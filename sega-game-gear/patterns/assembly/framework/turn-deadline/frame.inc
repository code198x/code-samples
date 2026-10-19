; wait_frame: fresh VDP frame-status announcement, AF clobbered.
; Interrupts remain disabled. Caller owns all status/control-port reads.
; Reading status clears flags AND resets the control-port command latch.
; No other reader/IRQ may consume status or interleave register writes.
; Missed announcements collapse into a latch; there is no catch-up counter.
wait_frame:
    in a,($bf)                 ; discard pending announcement
wait_new_frame:
    in a,($bf)
    and $80
    jr z,wait_new_frame
    ret

; AF clobbered. Owns status flag and command latch; no VDP interrupt reader.
wait_frame:
    in a,($bf)                ; discard any already-latched field
wait_new:
    in a,($bf)
    and $80
    jr z,wait_new
    ret

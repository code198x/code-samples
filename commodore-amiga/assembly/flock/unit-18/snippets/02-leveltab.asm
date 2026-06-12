; One row per level: tractor, cart, Rover (16.16 — halves are
; real speeds now), duck paddle frames, bolt threshold.
leveltab:
            dc.l    2<<16,  -1<<16,    -3<<16
            dc.w    220, 250
            dc.l    (5<<16)/2, -(3<<16)/2, -(7<<16)/2
            dc.w    190, 220
            dc.l    3<<16,  -2<<16,    -4<<16
            dc.w    160, 190
            dc.l    (7<<16)/2, -(5<<16)/2, -(9<<16)/2
            dc.w    130, 160


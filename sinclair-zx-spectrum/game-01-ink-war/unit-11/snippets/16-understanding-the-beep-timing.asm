.delay1:
        dec de          ; 6 T-states
        ld a, d         ; 4 T-states
        or e            ; 4 T-states
        jr nz, .delay1  ; 12/7 T-states (taken/not taken)

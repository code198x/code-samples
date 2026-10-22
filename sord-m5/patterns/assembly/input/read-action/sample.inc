    in a,($30)                ; keyboard row Y0, DIRECT ACTIVE-HIGH read
    and $40                   ; Space is bit 6; no inversion
    ld b,a

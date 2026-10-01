; A = border/MIC output (bits 0-3), H = half-period delay (1-255),
; L = complete cycles (1-255). Call with maskable interrupts disabled.
; Returns with the speaker bit low and bits 0-3 preserved.
; Clobbers AF, B, D, L. Preserves C, E, H, IX, IY and interrupt state.
sound_beep:
    and     $0f
    ld      d,a
beep_cycle:
    ld      a,d
    or      $10
    out     ($fe),a
    ld      b,h
beep_high_wait:
    djnz    beep_high_wait
    ld      a,d
    out     ($fe),a
    ld      b,h
beep_low_wait:
    djnz    beep_low_wait
    dec     l
    jr      nz,beep_cycle
    ret

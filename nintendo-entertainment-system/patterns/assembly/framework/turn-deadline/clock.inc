; Existing game-loop frame_clock is low byte. NMI calls clock_tick once.
; Zero clock bytes before NMI; one owner must not reset them during use.
.segment "BSS"
frame_high: .res 1
clock_high_copy: .res 1
.segment "CODE"
clock_tick:
    inc frame_clock
    bne clock_tick_done
    inc frame_high
clock_tick_done:
    rts
; Coherent word: A=low X=high. A/X/flags/scratch change; Y survives.
; Retry if an NMI carry split the read. One private scratch, not re-entrant.
read_clock:
    lda frame_high
    sta clock_high_copy
    lda frame_clock
    ldx frame_high
    cpx clock_high_copy
    bne read_clock
    rts
read_clock_end:

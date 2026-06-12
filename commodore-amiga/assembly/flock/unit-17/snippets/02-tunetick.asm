;══════════════════════════════════════════════════════════════
; TUNETICK — the sequencer soundtick was always going to need
;
; A melody is a table: period, frames, period, frames... and a
; zero to loop. Each entry is one playsound call; the tick just
; watches the clock and serves the next note. Unit 11 played
; one sound at a time; this plays one sound at a time, forever,
; in order — that's all a jingle is. A zero period is a rest.
;══════════════════════════════════════════════════════════════

tunetick:
            tst.w   jingletimer
            beq.s   .next
            subq.w  #1,jingletimer
            rts
.next:
            move.l  jinglep,a0
            move.w  (a0)+,d0            ; Period (0 = rest, -1 = loop)
            bmi.s   .loop
            move.w  (a0)+,d2            ; Frames
            move.w  d2,jingletimer
            move.l  a0,jinglep
            tst.w   d0
            beq.s   .rest
            move.w  d0,d1               ; Steady pitch: both periods
            move.w  #JINGLE_VOL,d3      ;   the same, no slide
            bra     playsound
.rest:
            move.w  #$0001,DMACON(a5)   ; Silence is a note too
            rts
.loop:
            lea     jingle,a0
            move.l  a0,jinglep
            rts

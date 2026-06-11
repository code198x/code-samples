playsound:
            lea     squarewave,a0
            move.l  a0,AUD0LC(a5)       ; The wave to loop
            move.w  #4,AUD0LEN(a5)      ; Four words = eight samples
            move.w  d0,AUD0PER(a5)      ; Pitch now...
            move.w  d1,sndper2          ; ...pitch later
            move.w  d3,AUD0VOL(a5)
            move.w  d2,sndtimer
            lsr.w   #1,d2
            move.w  d2,sndhalf          ; Where the wobble happens
            move.w  #$8001,DMACON(a5)   ; SET + AUD0EN: sing
            rts

;──────────────────────────────────────────────────────────────
; soundtick — once per frame: wobble at halfway, stop on time
;──────────────────────────────────────────────────────────────
soundtick:
            tst.w   sndtimer
            beq.s   .quiet
            subq.w  #1,sndtimer
            bne.s   .wobble
            move.w  #$0001,DMACON(a5)   ; CLR + AUD0EN: hush
            move.w  #0,AUD0VOL(a5)
            rts
.wobble:
            move.w  sndtimer,d0
            cmp.w   sndhalf,d0          ; Halfway through?
            bne.s   .quiet
            move.w  sndper2,AUD0PER(a5) ; The second note
.quiet:
            rts

; Main-loop only: no interrupt calls this routine or changes its state.
; d0/d1: periods; d2: positive duration; d3: volume; d4: priority 1 or 2.
; Clobbers: a0, d2, condition codes (as playsound does). No queued requests.
requestsound:
            ifne    USE_PRIORITY
            tst.w   sndtimer
            beq.s   .accept             ; Idle: no owner to displace
            cmp.w   sndpriority,d4
            bhi.s   .accept             ; Higher unsigned priority wins
            addq.w  #1,rejected         ; Equal/lower: leave ALL sound state alone
            rts
            endc
.accept:
            move.w  d4,sndpriority
            addq.w  #1,accepted
            bra     playsound           ; Existing playback setup, unchanged

; Spaced requests; same player, periods, volumes and durations as unit 11.
; soundtick precedes this routine: expiry is processed before a new request.
experiment:
            addq.w  #1,trialframe
            cmp.w   #151,trialframe
            beq     .finish
            cmp.w   #1,trialframe
            beq     .at1
            cmp.w   #7,trialframe
            beq     .at7
            cmp.w   #13,trialframe
            beq     .at13
            cmp.w   #31,trialframe
            beq     .at31
            cmp.w   #61,trialframe
            beq     .at61
            cmp.w   #67,trialframe
            beq     .at67
            cmp.w   #73,trialframe
            beq     .at73
            cmp.w   #91,trialframe
            beq     .at91
            cmp.w   #97,trialframe
            beq     .at97
            cmp.w   #121,trialframe
            beq     .at121
            cmp.w   #139,trialframe
            beq     .at139
            rts
.at1:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbleat
            bra     recordtrial
.at7:
            bsr     trialbaa
            bra     recordtrial
.at13:
            bsr     trialbaa
            bra     recordtrial
.at31:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbaa
            bra     recordtrial
.at61:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbleat
            bra     recordtrial
.at67:
            bsr     trialbleat
            bra     recordtrial
.at73:
            bsr     trialbleat
            bra     recordtrial
.at91:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbaa
            bra     recordtrial
.at97:
            bra     recordtrial
.at121:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbleat
            bra     recordtrial
.at139:
            bra     recordtrial
.finish:
            move.w  #1,trialdone
            rts
recordtrial:
            lea     observations,a1
            adda.w  recordoffset,a1
            move.w  sndtimer,(a1)+
            move.w  sndpriority,(a1)+
            move.w  accepted,(a1)+
            move.w  rejected,(a1)+
            move.w  sndper2,(a1)+
            add.w   #10,recordoffset
            move.w  accepted,d0
            mulu    #100,d0
            add.w   rejected,d0
            move.w  d0,score             ; HUD: AA RR, not game points
            bsr     drawscore
            rts
trialbaa:
            move.w  #BAA_PER1,d0
            move.w  #BAA_PER2,d1
            move.w  #BAA_FRAMES,d2
            move.w  #BAA_VOL,d3
            moveq   #1,d4
            bra     requestsound
trialbleat:
            move.w  #BLEAT_PER1,d0
            move.w  #BLEAT_PER2,d1
            move.w  #BLEAT_FRAMES,d2
            move.w  #BLEAT_VOL,d3
            moveq   #2,d4
            bra     requestsound

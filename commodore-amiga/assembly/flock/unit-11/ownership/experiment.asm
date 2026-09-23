; A fixed experiment replaces input/game updates, not the normal game.
; soundtick runs BEFORE requests here. Unit 11's game calls it afterwards.
experiment:
            addq.w  #1,trialframe
            cmp.w   #181,trialframe
            beq     .finish
            cmp.w   #1,trialframe
            beq.s   .forward
            cmp.w   #61,trialframe
            beq.s   .reverse
            cmp.w   #121,trialframe
            beq.s   .tie
            rts
.forward:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbaa
            bsr     trialbleat
            bra.s   .record
.reverse:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbleat
            bsr     trialbaa
            bra.s   .record
.tie:
            clr.w   accepted
            clr.w   rejected
            bsr     trialbleat
            bsr     trialbleat
.record:
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
.finish:
            move.w  #1,trialdone
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

; =============================================================================
; Verification probe for paula-sample.inc. Not a learner listing.
;   1. CPU cost: count a chip-RAM polling loop for 10 frames with no DMA,
;      with all four audio channels fetching at period 124 (volume 0), and,
;      as a control the count must notice, with six low-res bitplanes.
;   2. Interrupt timing: play_sample, then acknowledge six AUD0 requests by
;      polling INTREQR. The host reads the acknowledgement times.
;   3. One shot: play an 8-cycle burst, and on the first AUD0 request queue a
;      one-word silent loop. The host counts the cycles that sound.
; Results go in a table after the marker PAULAPROBE-V1.
; =============================================================================

CUSTOM          equ $dff000
INTREQR         equ $01e
INTENA          equ $09a
INTREQ          equ $09c
INTF_VERTB      equ $0020
INTF_AUD0       equ $0080

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)
            lea     results,a4

            ; --- 1a. Loop count, no DMA ---
            bsr     count_frames
            move.l  d5,(a4)+

            ; --- 1b. Loop count, four channels at period 124, silent ---
            lea     silence,a0
            move.l  a0,$a0(a5)
            move.l  a0,$b0(a5)
            move.l  a0,$c0(a5)
            move.l  a0,$d0(a5)
            moveq   #1,d0
            move.w  d0,$a4(a5)
            move.w  d0,$b4(a5)
            move.w  d0,$c4(a5)
            move.w  d0,$d4(a5)
            move.w  #124,d0
            move.w  d0,$a6(a5)
            move.w  d0,$b6(a5)
            move.w  d0,$c6(a5)
            move.w  d0,$d6(a5)
            moveq   #0,d0
            move.w  d0,$a8(a5)
            move.w  d0,$b8(a5)
            move.w  d0,$c8(a5)
            move.w  d0,$d8(a5)
            move.w  #$820f,DMACON(a5)   ; SET | DMAEN | AUD0-3
            bsr     count_frames
            move.l  d5,(a4)+
            move.w  #$000f,DMACON(a5)

            ; --- 1c. Control: six low-resolution bitplanes take CPU slots ---
            move.w  #$6200,$100(a5)     ; BPLCON0: six planes, colour on
            move.w  #$2c81,$08e(a5)     ; DIWSTRT
            move.w  #$2cc1,$090(a5)     ; DIWSTOP
            move.w  #$0038,$092(a5)     ; DDFSTRT
            move.w  #$00d0,$094(a5)     ; DDFSTOP
            move.w  #$8300,DMACON(a5)   ; SET | DMAEN | BPLEN
            bsr     count_frames
            move.l  d5,(a4)+
            move.w  #$0100,DMACON(a5)
            move.w  #$0200,$100(a5)
            moveq   #24,d7
            bsr     wait_frames

            ; --- 2. Six AUD0 requests from a looping 16-byte sample ---
            move.w  #INTF_AUD0,INTREQ(a5)
            lea     wave16,a0
            moveq   #8,d0
            move.w  #424,d1
            moveq   #64,d2
            bsr     play_sample
            moveq   #5,d7
.irq:       bsr     wait_aud0
            dbra    d7,.irq
            bsr     stop_sample
            moveq   #24,d7
            bsr     wait_frames

            ; --- 3. One shot: queue silence on the first request ---
            move.w  #INTF_AUD0,INTREQ(a5)
            lea     burst,a0
            move.w  #(burst_end-burst)/2,d0
            bsr     play_sample         ; d1 = 424, d2 = 64 still
            bsr     wait_aud0           ; LC/LEN now copied: rewrite them
            lea     silence,a0
            move.l  a0,AUD0LC(a5)
            move.w  #1,AUD0LEN(a5)
            moveq   #24,d7
            bsr     wait_frames
            bsr     stop_sample

            move.w  #1,(a4)+            ; done
hold:       bra.s   hold

; count_frames - d5 = polling-loop passes during 10 frames
count_frames:
            moveq   #0,d7
            bsr.s   wait_frames         ; align to a frame start
            moveq   #0,d5
            moveq   #9,d7
.frame:     move.w  #INTF_VERTB,INTREQ(a5)
.poll:      addq.l  #1,d5
            move.w  INTREQR(a5),d6
            and.w   #INTF_VERTB,d6
            beq.s   .poll
            dbra    d7,.frame
            rts

; wait_frames - wait d7+1 frame starts
wait_frames:
            move.w  #INTF_VERTB,INTREQ(a5)
.poll:      move.w  INTREQR(a5),d6
            and.w   #INTF_VERTB,d6
            beq.s   .poll
            dbra    d7,wait_frames
            rts

; wait_aud0 - wait for channel 0's request, then acknowledge it
wait_aud0:
            move.w  INTREQR(a5),d6
            and.w   #INTF_AUD0,d6
            beq.s   wait_aud0
            move.w  #INTF_AUD0,INTREQ(a5)
            rts

            include "../paula-sample.inc"

            section data,data_c
            even
marker:     dc.b    "PAULAPROBE-V1",0,0,0
results:    dc.l    0,0,0
            dc.w    0
silence:    dc.w    0
wave16:     dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
burst:
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
            dc.b    0,49,90,117,127,117,90,49,0,-49,-90,-117,-127,-117,-90,-49
burst_end:

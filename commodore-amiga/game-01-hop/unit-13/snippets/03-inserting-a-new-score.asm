insert_high_score:
; d0 = position to insert at (0-4)
; Inserts current score at position, shifts others down
            movem.l d0-d2/a0-a2,-(sp)

            ; Calculate address of insertion point
            lea     high_scores,a0
            move.w  d0,d1
            mulu    #HS_SIZE,d1
            lea     (a0,d1.w),a1    ; a1 = insertion point

            ; Shift entries down from bottom
            ; Start at entry 4, copy from entry 3, etc.
            lea     high_scores+(HS_SIZE*4),a0  ; Entry 4 (destination)
            lea     high_scores+(HS_SIZE*3),a2  ; Entry 3 (source)

            move.w  #NUM_SCORES-1,d2
            sub.w   d0,d2           ; How many to shift
            subq.w  #1,d2
            blt.s   .no_shift

.shift_loop:
            ; Copy entry from a2 to a0
            move.l  HS_SCORE(a2),HS_SCORE(a0)
            move.l  HS_NAME(a2),HS_NAME(a0)     ; Copy all 4 bytes
            lea     -HS_SIZE(a0),a0
            lea     -HS_SIZE(a2),a2
            dbf     d2,.shift_loop

.no_shift:
            ; Insert new score at a1
            move.l  score,HS_SCORE(a1)
            ; Name will be filled in by entry routine
            move.b  #'?',HS_NAME(a1)
            move.b  #'?',HS_NAME+1(a1)
            move.b  #'?',HS_NAME+2(a1)

            movem.l (sp)+,d0-d2/a0-a2
            rts

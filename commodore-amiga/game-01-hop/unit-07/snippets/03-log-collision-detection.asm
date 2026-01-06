check_on_log:
            ; Returns: D0 = log speed if on log, 0 if not
            lea     objects,a2
            move.w  #NUM_OBJECTS-1,d7
.loop:
            ; Only check logs
            cmp.w   #TYPE_LOG,OBJ_TYPE(a2)
            bne.s   .next

            ; Check Y overlap (frog on same row as log)
            move.w  frog_y,d1
            move.w  OBJ_Y(a2),d2
            sub.w   d2,d1               ; D1 = frog_y - log_y
            bmi.s   .next               ; Frog above log
            cmp.w   #LOG_HEIGHT,d1      ; Frog below log?
            bge.s   .next

            ; Check X overlap
            move.w  frog_x,d1
            move.w  OBJ_X(a2),d2
            sub.w   d2,d1               ; D1 = frog_x - log_x
            cmp.w   #-FROG_WIDTH,d1     ; Frog too far left?
            blt.s   .next
            cmp.w   #LOG_PIXELS,d1      ; Frog too far right?
            bge.s   .next

            ; On this log! Return its speed
            move.w  OBJ_SPEED(a2),d0
            rts

.next:      lea     OBJ_SIZE(a2),a2
            dbf     d7,.loop

            ; Not on any log
            moveq   #0,d0
            rts

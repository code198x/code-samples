; Check if frog overlaps object
; a0 = pointer to object
; Returns: d0 = 1 if collision, 0 if not
check_collision:
            ; Get frog bounds
            move.w  frog_x,d0           ; Frog left
            move.w  d0,d1
            add.w   #FROG_WIDTH,d1      ; Frog right
            move.w  frog_y,d2           ; Frog top
            move.w  d2,d3
            add.w   #FROG_HEIGHT,d3     ; Frog bottom

            ; Get object bounds
            move.w  OBJ_X(a0),d4        ; Object left
            move.w  d4,d5
            add.w   #OBJ_WIDTH,d5       ; Object right
            move.w  OBJ_Y(a0),d6        ; Object top
            move.w  d6,d7
            add.w   #OBJ_HEIGHT,d7      ; Object bottom

            ; Check for separation (any true = no collision)
            cmp.w   d5,d0               ; Frog left >= obj right?
            bge.s   .no_hit
            cmp.w   d1,d4               ; Obj left >= frog right?
            bge.s   .no_hit
            cmp.w   d7,d2               ; Frog top >= obj bottom?
            bge.s   .no_hit
            cmp.w   d3,d6               ; Obj top >= frog bottom?
            bge.s   .no_hit

            moveq   #1,d0               ; Collision!
            rts
.no_hit:
            moveq   #0,d0               ; No collision
            rts

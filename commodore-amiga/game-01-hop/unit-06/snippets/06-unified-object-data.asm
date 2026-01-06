NUM_OBJECTS equ 7           ; 4 cars + 3 logs

objects:
            ; Cars (road zone)
            dc.w    0,122,2,TYPE_CAR        ; Lane 1, right
            dc.w    300,138,-3,TYPE_CAR     ; Lane 2, left
            dc.w    100,154,1,TYPE_CAR      ; Lane 3, right
            dc.w    200,170,-2,TYPE_CAR     ; Lane 4, left

            ; Logs (water zone)
            dc.w    0,66,1,TYPE_LOG         ; Water lane 1, right
            dc.w    200,82,-1,TYPE_LOG      ; Water lane 2, left
            dc.w    100,98,2,TYPE_LOG       ; Water lane 3, right

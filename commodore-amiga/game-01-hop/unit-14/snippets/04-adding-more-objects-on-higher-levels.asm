; Extended object array (12 objects instead of 8)
MAX_OBJECTS     equ     12

; Active object count increases with level
get_active_objects:
; Returns d0 = number of active objects
            move.w  level,d0
            addq.w  #7,d0           ; Level 1 = 8, Level 2 = 9, etc.
            cmpi.w  #MAX_OBJECTS,d0
            ble.s   .no_cap
            move.w  #MAX_OBJECTS,d0
.no_cap:
            rts

; Home slot structure
SLOT_X          equ 0           ; X position of slot
SLOT_FILLED     equ 2           ; 0 = empty, 1 = filled
SLOT_SIZE       equ 4
NUM_SLOTS       equ 5

; Home slot data
home_slots:
            dc.w    24,0        ; Slot 1: X=24, empty
            dc.w    88,0        ; Slot 2: X=88, empty
            dc.w    152,0       ; Slot 3: X=152, empty
            dc.w    216,0       ; Slot 4: X=216, empty
            dc.w    280,0       ; Slot 5: X=280, empty

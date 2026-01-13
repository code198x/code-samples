; Car Data Structure
; 8 bytes per car: X position, row, speed, padding

; Constants
NUM_CARS        equ 10          ; Total cars
CAR_STRUCT_SIZE equ 8           ; Bytes per car

; Structure layout:
;   Offset 0: X position (word) - pixel position 0-319
;   Offset 2: Row (word) - grid row 7-11 (road lanes)
;   Offset 4: Speed (word) - signed: positive=right, negative=left
;   Offset 6: Reserved (word) - padding for alignment

car_data:
            ; Lane 1 (row 7) - moving right, speed 1
            dc.w    0,7,1,0
            dc.w    160,7,1,0

            ; Lane 2 (row 8) - moving left, speed -2
            dc.w    100,8,-2,0
            dc.w    250,8,-2,0

            ; Lane 3 (row 9) - moving right, speed 2
            dc.w    50,9,2,0
            dc.w    200,9,2,0

            ; Lane 4 (row 10) - moving left, speed -1
            dc.w    80,10,-1,0
            dc.w    220,10,-1,0

            ; Lane 5 (row 11) - moving right, speed 3
            dc.w    30,11,3,0
            dc.w    180,11,3,0

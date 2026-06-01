; Copper List Zone Structure
; Each zone uses WAIT + MOVE to change background colour

            ; === HOME ZONE (Row 1, line $2C = 44) ===
            dc.w    $2c07,$fffe          ; WAIT for line 44
            dc.w    COLOR00,COLOUR_HOME  ; Set background

            ; === WATER ZONE (Rows 2-6) ===
            ; Alternating blues for wave effect
            dc.w    $3c07,$fffe          ; Row 2, line 60
            dc.w    COLOR00,COLOUR_WATER1
            dc.w    $4c07,$fffe          ; Row 3, line 76
            dc.w    COLOR00,COLOUR_WATER2
            ; ... rows 4-6 continue pattern

            ; === MEDIAN (Row 7, line $8C = 140) ===
            dc.w    $8c07,$fffe
            dc.w    COLOR00,COLOUR_MEDIAN

            ; === ROAD ZONE (Rows 8-12) ===
            ; Alternating greys for lane definition
            dc.w    $9c07,$fffe          ; Row 8, line 156
            dc.w    COLOR00,COLOUR_ROAD1
            dc.w    $ac07,$fffe          ; Row 9, line 172
            dc.w    COLOR00,COLOUR_ROAD2
            ; ... rows 10-12 continue pattern

            ; === START ZONE (Row 13, line $EC = 236) ===
            dc.w    $ec07,$fffe
            dc.w    COLOR00,COLOUR_START

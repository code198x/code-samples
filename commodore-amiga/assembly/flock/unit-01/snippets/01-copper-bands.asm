            ; --- THE FOLD (from the top of the frame) ---
            dc.w    COLOR00,COLOUR_FOLD_GRASS
            dc.w    COLOR01,COLOUR_FENCE        ; Pixels here are fence

            ; --- HEDGEROW (row 40) ---
            dc.w    $5401,$fffe                 ; Wait: line $2C+40 = $54
            dc.w    COLOR00,COLOUR_HEDGE
            dc.w    COLOR01,COLOUR_TUFT

            ; --- THE STREAM (row 48) ---
            dc.w    $5c01,$fffe                 ; Wait: line $2C+48 = $5C
            dc.w    COLOR00,COLOUR_WATER
            dc.w    COLOR01,COLOUR_WOOD         ; Pixels here are bridge

            ; --- THE BANK (row 80) ---
            dc.w    $7c01,$fffe                 ; Wait: line $2C+80 = $7C
            dc.w    COLOR00,COLOUR_BANK
            dc.w    COLOR01,COLOUR_TUFT

            ; --- THE LANE (row 96) ---
            dc.w    $8c01,$fffe                 ; Wait: line $2C+96 = $8C
            dc.w    COLOR00,COLOUR_LANE
            dc.w    COLOR01,COLOUR_DASH         ; Pixels here are markings

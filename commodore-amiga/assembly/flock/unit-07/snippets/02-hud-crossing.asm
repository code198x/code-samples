            ; --- THE HUD STRIP (row 240) ---
            ; Row 240 is beam line $11C — past 255, which the Copper's
            ; 8-bit comparator can't name directly. The classic trick:
            ; wait for the very end of line 255, THEN wait for the low
            ; byte. The first wait carries you across the boundary.
            dc.w    $ffdf,$fffe                 ; To the end of line 255
            dc.w    $1c01,$fffe                 ; Then line $11C & $FF = $1C
            dc.w    COLOR00,COLOUR_HUD
            dc.w    COLOR01,COLOUR_ICON

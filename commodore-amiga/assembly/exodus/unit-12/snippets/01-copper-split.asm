            ; --- Panel screen split ---
            ; Wait for panel scanline ($2c + 200 = $E4)
            dc.w    $e401,$fffe
            dc.w    COLOR00,COLOUR_PANEL_BG     ; New background colour
            dc.w    COLOR01,COLOUR_PANEL_FG     ; New foreground colour
            dc.w    BPL1PTH                     ; Switch bitplane pointer
panel_bpl1pth_val:
            dc.w    $0000
            dc.w    BPL1PTL
panel_bpl1ptl_val:
            dc.w    $0000

            dc.w    $ffff,$fffe                 ; End of Copper list

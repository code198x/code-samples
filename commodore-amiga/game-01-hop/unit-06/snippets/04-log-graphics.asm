LOG_WIDTH   equ 2           ; Words (32 pixels)
LOG_HEIGHT  equ 8           ; Lines

log_gfx:
            dc.w    $ffff,$ffff         ; Line 0
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff
            dc.w    $ffff,$ffff         ; Line 7

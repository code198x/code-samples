copperlist:
            dc.w    COLOR00,$0000       ; Black border at top

            ; === HOME ZONE (green) ===
            dc.w    $2c07,$fffe
            dc.w    COLOR00,$0080       ; Green

            ; === WATER ZONE (blue stripes) ===
            dc.w    $4007,$fffe
            dc.w    COLOR00,$0048       ; Dark blue

            dc.w    $4c07,$fffe
            dc.w    COLOR00,$006b       ; Medium blue

            dc.w    $5407,$fffe
            dc.w    COLOR00,$0048       ; Dark blue

            dc.w    $5c07,$fffe
            dc.w    COLOR00,$006b       ; Medium blue

            dc.w    $6407,$fffe
            dc.w    COLOR00,$0048       ; Dark blue

            ; === MEDIAN (safe zone) ===
            dc.w    $6c07,$fffe
            dc.w    COLOR00,$0080       ; Green

            ; === ROAD ZONE (grey stripes) ===
            dc.w    $7807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey

            dc.w    $8407,$fffe
            dc.w    COLOR00,$0666       ; Light grey (lane marker)

            dc.w    $8807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey

            dc.w    $9407,$fffe
            dc.w    COLOR00,$0666       ; Light grey

            dc.w    $9807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey

            dc.w    $a407,$fffe
            dc.w    COLOR00,$0666       ; Light grey

            dc.w    $a807,$fffe
            dc.w    COLOR00,$0444       ; Dark grey

            ; === START ZONE (green) ===
            dc.w    $b407,$fffe
            dc.w    COLOR00,$0080       ; Green

            dc.w    $c007,$fffe
            dc.w    COLOR00,$0070       ; Darker green

            ; === BOTTOM BORDER ===
            dc.w    $f007,$fffe
            dc.w    COLOR00,$0000       ; Black

            ; End copper list
            dc.w    $ffff,$fffe

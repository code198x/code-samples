            ; --- Fill terrain into bitplane ---
            ; Sky area is already 0 (transparent — shows COLOR00)
            ; Fill from TERRAIN_START to bottom with $FF (solid — shows COLOR01)
            lea     bitplane,a0
            add.l   #TERRAIN_START*BYTES_PER_ROW,a0
            move.w  #(SCREEN_HEIGHT-TERRAIN_START)*BYTES_PER_ROW/4-1,d0
.fill:
            move.l  #$ffffffff,(a0)+
            dbra    d0,.fill

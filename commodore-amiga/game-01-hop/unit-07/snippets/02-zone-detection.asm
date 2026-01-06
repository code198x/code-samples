move.w  frog_y,d0
            cmp.w   #WATER_TOP,d0
            blt.s   .safe               ; Above water = home
            cmp.w   #WATER_BOT,d0
            blt.s   .in_water           ; In water zone
            cmp.w   #ROAD_TOP,d0
            blt.s   .safe               ; Median
            cmp.w   #ROAD_BOT,d0
            blt.s   .on_road            ; Road zone
.safe:      ; Safe zone

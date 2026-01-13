; Check Home Zone
; Detect which home frog has reached (if any)

check_home:
            ; Only check if at top row
            move.w  frog_grid_y,d0
            tst.w   d0
            bne     .not_home

            ; At top row - determine which home
            move.w  frog_grid_x,d0

            ; Check home 0 (X = 2-3)
            cmp.w   #HOME_0_X,d0
            blt.s   .not_home
            cmp.w   #HOME_0_X+2,d0
            blt.s   .home_0

            ; Check home 1 (X = 6-7)
            cmp.w   #HOME_1_X,d0
            blt.s   .not_home
            cmp.w   #HOME_1_X+2,d0
            blt.s   .home_1

            ; (continue for homes 2, 3, 4...)

            ; Between homes - death!
            bra     .death_between

.home_0:    moveq   #0,d1
            bra.s   .check_filled
.home_1:    moveq   #1,d1
            bra.s   .check_filled
            ; (etc...)

.check_filled:
            ; D1 = home index (0-4)
            lea     home_filled,a0
            add.w   d1,d1               ; *2 for word offset
            tst.w   0(a0,d1.w)
            bne.s   .death_filled       ; Already filled - death!

            ; Home is empty - fill it!
            move.w  #1,0(a0,d1.w)
            add.l   #POINTS_PER_HOME,score
            bsr     update_home_display
            bsr     reset_frog
            rts

.death_filled:
.death_between:
            bsr     trigger_death
            rts

.not_home:
            rts

; Draw All Cars with Blitter
; Loop through car data, skip offscreen, draw visible cars

draw_all_cars:
            lea     car_data,a2
            moveq   #NUM_CARS-1,d7

.loop:
            move.w  (a2),d0             ; X position
            move.w  2(a2),d1            ; Row

            ; Skip if offscreen
            cmp.w   #-32,d0
            blt.s   .next
            cmp.w   #320,d0
            bge.s   .next

            ; Calculate screen address and draw
            bsr     calc_screen_addr
            bsr     wait_blit

            ; Set up Blitter for A→D copy
            move.l  #car_gfx,BLTAPTH(a5)
            move.l  a0,BLTDPTH(a5)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.w  #0,BLTAMOD(a5)
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)
            move.w  #$09f0,BLTCON0(a5)  ; A→D copy
            move.w  #0,BLTCON1(a5)
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)

.next:
            lea     CAR_STRUCT_SIZE(a2),a2
            dbf     d7,.loop
            rts

draw_object:
            ; D0=X, D1=Y, A2=object pointer
            tst.w   d0
            bmi.s   .done
            cmp.w   #320,d0
            bge.s   .done

            bsr     wait_blit

            ; Calculate destination
            lea     screen_plane1,a0
            mulu    #SCREEN_W,d1
            add.l   d1,a0
            move.w  d0,d2
            lsr.w   #3,d2
            ext.l   d2
            add.l   d2,a0

            ; Select graphics and width based on type
            move.w  OBJ_TYPE(a2),d3
            beq.s   .car
            ; Log
            lea     log_gfx,a3
            move.w  #LOG_WIDTH,d4
            bra.s   .blit
.car:
            lea     car_gfx,a3
            move.w  #CAR_WIDTH,d4
.blit:
            move.l  a3,BLTAPTH(a5)
            move.l  a0,BLTDPTH(a5)
            move.w  #$09f0,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)
            move.w  #0,BLTAMOD(a5)

            ; Modulo depends on width
            move.w  #SCREEN_W,d5
            sub.w   d4,d5
            sub.w   d4,d5
            move.w  d5,BLTDMOD(a5)

            ; Size: 8 lines, variable width
            lsl.w   #6,d4               ; Width in low 6 bits... wait, it's already there
            ; Actually BLTSIZE = (height << 6) | width
            move.w  OBJ_TYPE(a2),d3
            beq.s   .car_size
            move.w  #(LOG_HEIGHT<<6)|LOG_WIDTH,BLTSIZE(a5)
            bra.s   .done
.car_size:
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)
.done:
            rts

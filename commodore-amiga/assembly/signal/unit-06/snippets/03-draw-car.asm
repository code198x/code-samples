; Draw Car with Blitter
; A→D copy: source graphics to screen

draw_car:
            bsr     wait_blit

            ; Calculate screen destination
            move.w  car_x,d0
            move.w  #CAR_ROW,d1
            bsr     calc_screen_addr        ; A0 = destination

            ; Set up channels
            move.l  #car_gfx,BLTAPTH(a5)    ; A = source graphics
            move.l  a0,BLTDPTH(a5)          ; D = screen

            ; Masks: no masking needed (full words)
            move.w  #$ffff,BLTAFWM(a5)
            move.w  #$ffff,BLTALWM(a5)

            ; Modulos
            move.w  #0,BLTAMOD(a5)                      ; Source: no gaps
            move.w  #SCREEN_W-CAR_WIDTH*2,BLTDMOD(a5)   ; Dest: screen stride

            ; BLTCON0: A→D copy, D=A minterm
            ; $09f0 = use A+D channels, minterm F0 (copy A)
            move.w  #$09f0,BLTCON0(a5)
            move.w  #0,BLTCON1(a5)

            ; Size: 12 lines × 2 words wide
            move.w  #(CAR_HEIGHT<<6)|CAR_WIDTH,BLTSIZE(a5)

            rts

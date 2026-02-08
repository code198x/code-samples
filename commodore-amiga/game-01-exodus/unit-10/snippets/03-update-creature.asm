;──────────────────────────────────────────────────────────────
; update_creature — Update one creature (A2 = creature data)
;──────────────────────────────────────────────────────────────
update_creature:
            move.w  CR_STATE(a2),d0
            cmp.w   #STATE_FALLING,d0
            beq     .do_fall

            ; --- Walking ---
            move.w  CR_X(a2),d0
            add.w   CR_DX(a2),d0
            add.w   #FOOT_OFFSET_X,d0
            move.w  CR_Y(a2),d1
            add.w   #FOOT_OFFSET_Y,d1
            bsr     check_pixel

            tst.b   d0
            beq.s   .walk_no_floor

            ; Floor ahead — move forward
            move.w  CR_X(a2),d0
            add.w   CR_DX(a2),d0
            move.w  d0,CR_X(a2)

            ; ...floor check and falling logic...

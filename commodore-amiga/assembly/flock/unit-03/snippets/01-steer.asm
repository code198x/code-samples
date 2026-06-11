steer:
            tst.w   cooldown
            beq.s   .ready
            subq.w  #1,cooldown         ; Still mid-hop rhythm — wait
            rts
.ready:
            move.w  JOY1DAT(a5),d0      ; Read the stick
            move.w  d0,d1
            lsr.w   #1,d1
            eor.w   d0,d1               ; Now: bit 0 = down, bit 8 = up

            btst    #8,d1               ; Up?
            beq.s   .notup
            sub.w   #STEP,sheepy
            bra.s   .stepped
.notup:
            btst    #0,d1               ; Down?
            beq.s   .notdown
            add.w   #STEP,sheepy
            bra.s   .stepped
.notdown:
            btst    #9,d0               ; Left?
            beq.s   .notleft
            sub.w   #STEP,sheepx
            bra.s   .stepped
.notleft:
            btst    #1,d0               ; Right?
            beq.s   .done               ; Stick centred — no hop
            add.w   #STEP,sheepx
.stepped:
            move.w  #COOLDOWN,cooldown  ; Set the hop rhythm

            ; --- Hold her inside the farm ---
            tst.w   sheepx
            bge.s   .xlow
            clr.w   sheepx
.xlow:      cmp.w   #320-16,sheepx
            ble.s   .xhigh
            move.w  #320-16,sheepx
.xhigh:     tst.w   sheepy
            bge.s   .ylow
            clr.w   sheepy
.ylow:      cmp.w   #256-16,sheepy
            ble.s   .done
            move.w  #256-16,sheepy
.done:
            rts

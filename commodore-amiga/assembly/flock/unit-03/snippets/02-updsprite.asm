updsprite:
            lea     sheep,a0
            move.w  sheepy,d0
            add.w   #$2c,d0             ; D0 = VSTART (beam line)
            move.w  d0,d1
            add.w   #16,d1              ; D1 = VSTOP (16 rows tall)
            move.w  sheepx,d2
            add.w   #$80,d2             ; D2 = HSTART (beam position)

            ; POS = VSTART[7:0] << 8 | HSTART[8:1]
            move.w  d0,d3
            lsl.w   #8,d3
            move.w  d2,d4
            lsr.w   #1,d4
            and.w   #$ff,d4
            or.w    d4,d3
            move.w  d3,(a0)             ; Write POS

            ; CTL = VSTOP[7:0] << 8 | V8START<<2 | V8STOP<<1 | H0START
            move.w  d1,d3
            and.w   #$ff,d3
            lsl.w   #8,d3
            btst    #8,d0               ; VSTART's ninth bit
            beq.s   .nv8s
            or.w    #%100,d3
.nv8s:      btst    #8,d1               ; VSTOP's ninth bit
            beq.s   .nv8e
            or.w    #%010,d3
.nv8e:      btst    #0,d2               ; HSTART's odd-pixel bit
            beq.s   .nh0
            or.w    #%001,d3
.nh0:       move.w  d3,2(a0)            ; Write CTL
            rts

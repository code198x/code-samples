TIMER_BAR_X     equ     8
TIMER_BAR_Y     equ     14
TIMER_BAR_MAX   equ     100         ; Maximum width in pixels

draw_timer_bar:
            movem.l d0-d5/a0-a1,-(sp)

            ; Check for warning state - flash the bar
            cmpi.w  #TIMER_WARNING,timer_value
            bge.s   .no_flash

            ; Flash based on timer value (every 8 frames)
            move.w  timer_value,d0
            andi.w  #8,d0
            beq     .skip_draw      ; Don't draw on even phases

.no_flash:
            ; Calculate bar width
            move.w  timer_value,d0
            mulu    #TIMER_BAR_MAX,d0
            divu    #TIMER_START,d0
            andi.w  #$ff,d0         ; Width in pixels

            ; Calculate screen address
            move.w  #TIMER_BAR_Y,d1
            mulu    #40,d1
            move.w  #TIMER_BAR_X,d2
            lsr.w   #3,d2
            add.w   d2,d1

            lea     screen,a0
            lea     (a0,d1.w),a0

            ; Clear the bar area first (13 bytes = 104 pixels)
            moveq   #12,d4
.clear_loop:
            clr.b   (a0,d4.w)
            dbf     d4,.clear_loop

            ; Draw filled portion
            move.w  d0,d1           ; Width to draw
            lsr.w   #3,d1           ; Full bytes
            subq.w  #1,d1
            blt.s   .partial_only

            moveq   #0,d2
.fill_loop:
            move.b  #$FF,(a0,d2.w)
            addq.w  #1,d2
            dbf     d1,.fill_loop

.partial_only:
            ; Handle partial byte
            move.w  d0,d1
            andi.w  #7,d1           ; Remaining bits
            beq.s   .done

            ; Create mask for partial byte
            move.w  d0,d2
            lsr.w   #3,d2           ; Byte offset
            moveq   #-1,d3          ; Start with all 1s
            lsr.b   d1,d3           ; Shift right by remaining bits
            not.b   d3              ; Invert for left-justified mask
            lsl.b   #1,d3           ; Adjust
            or.b    d3,(a0,d2.w)

.done:
.skip_draw:
            movem.l (sp)+,d0-d5/a0-a1
            rts

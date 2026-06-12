;══════════════════════════════════════════════════════════════
; TENDDUCK — the paddle / tail-up / gone cycle
;
; A timer and three states, and the sprite POINTER is the
; state: paddling art, warning art, or the null sprite. While
; she feeds there are no pixels — and no pixels means no
; collision evidence, so the water's law needs no special
; case for a vanished ferry. Her rider is simply adrift.
;══════════════════════════════════════════════════════════════

tendduck:
            subq.w  #1,ducktimer
            bgt.s   .done               ; Still mid-state
            move.w  duckstate,d0
            addq.w  #1,d0
            cmp.w   #3,d0
            blt.s   .store
            moveq   #0,d0               ; ...and up she pops again
.store:
            move.w  d0,duckstate
            lea     duck,a0             ; 0: paddling, deck open
            move.w  #DUCK_PADDLE,ducktimer
            tst.w   d0
            beq.s   .point
            lea     duckwarn,a0         ; 1: tail up — fair warning
            move.w  #DUCK_WARN,ducktimer
            cmp.w   #1,d0
            beq.s   .point
            lea     nullspr,a0          ; 2: under. No pixels, no deck.
            move.w  #DUCK_UNDER,ducktimer
.point:
            lea     copsprites+56,a1    ; Sprite 7's pointer words
            move.l  a0,d0
            move.w  d0,6(a1)
            swap    d0
            move.w  d0,2(a1)
.done:      rts

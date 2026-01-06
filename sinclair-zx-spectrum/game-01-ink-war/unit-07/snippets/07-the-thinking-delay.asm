;───────────────────────────────────────
; Pause to show AI is "thinking"
;───────────────────────────────────────
ai_think_delay:
        ld b, 25                ; 25 frames = half a second
.delay_loop:
        halt
        djnz .delay_loop
        ret

; Neon Nexus - Lesson 1: Your First Game World
; Step 2: Change border color to red
; Assemble with: acme -f cbm -o neon1.prg step2-border-color.s

*= $c000

start:
        lda #$02        ; Load red color value
        sta $d020       ; Store to border color register
        rts             ; Return to BASIC
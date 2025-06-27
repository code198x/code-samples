; Neon Nexus - Lesson 1: Your First Game World
; Step 1: Minimal program that does nothing
; Assemble with: acme -f cbm -o neon1.prg step1-minimal.s

*= $c000               ; Tell C64 to load at $c000 (49152)

start:
        rts             ; Return to BASIC
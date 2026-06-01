; Chip RAM and Section Directives
; The Amiga has two types of RAM:
;
; - Chip RAM: The first 512K (or more) that custom chipset can access
;   The Copper, Blitter, sprites, and audio MUST be here
;
; - Fast RAM: Additional RAM only the CPU can see (faster for CPU)
;
; The "_c" suffix in section names means "Chip RAM"

            section code,code_c     ; Code + data in Chip RAM
                                    ; Required for Copper lists and sprites

            section bss,bss_c       ; Uninitialised data in Chip RAM
                                    ; Good for screen buffers

; Without "_c", data goes to Fast RAM - invisible to custom chipset!
; A sprite in Fast RAM simply won't appear.

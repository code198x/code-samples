; DEC (HL) vs DEC HL — flags
;
; DEC HL (16-bit) does NOT set flags. You need the
; three-instruction idiom: DEC HL / LD A,H / OR L.
;
; DEC (HL) (8-bit memory) DOES set flags. Z is set
; when the byte at HL reaches zero. One instruction
; to decrement and test.

            ld      hl, lives
            dec     (hl)                ; Decrement byte, set Z if zero
            jr      z, .game_over       ; Lives exhausted

; Compare:
;   DEC HL   — 16-bit, no flags    (Unit 12: testing HL counter)
;   DEC (HL) — 8-bit memory, flags (this unit: testing lives)
;   DEC A    — 8-bit register, flags

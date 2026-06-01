; Sound Data - 8-bit Signed Samples
; Simple square waves for game effects

            even

; Hop sound - short square wave burst (32 bytes)
sound_hop:
            dc.b    $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f     ; High (+127)
            dc.b    $80,$80,$80,$80,$80,$80,$80,$80     ; Low  (-128)
            dc.b    $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f     ; High
            dc.b    $80,$80,$80,$80,$80,$80,$80,$80     ; Low
HOP_LEN     equ     *-sound_hop

; Death sound - descending tone (variable wavelength)
sound_death:
            dc.b    $7f,$7f,$7f,$7f,$80,$80,$80,$80     ; Fast cycle (high)
            dc.b    $7f,$7f,$7f,$7f,$80,$80,$80,$80
            dc.b    $7f,$7f,$7f,$7f,$7f,$80,$80,$80,$80,$80  ; Slower
            dc.b    $7f,$7f,$7f,$7f,$7f,$7f,$80,$80,$80,$80,$80,$80  ; Even slower
            dc.b    $7f,$7f,$7f,$7f,$7f,$7f,$7f,$7f     ; Slowest (low)
            dc.b    $80,$80,$80,$80,$80,$80,$80,$80
DEATH_LEN   equ     *-sound_death

; Home sound - bright chirp (ascending)
sound_home:
            dc.b    $7f,$80,$7f,$80,$7f,$80,$7f,$80     ; Very fast (high pitch)
            dc.b    $7f,$80,$7f,$80,$7f,$80,$7f,$80
            dc.b    $7f,$7f,$80,$80,$7f,$7f,$80,$80     ; Medium
            dc.b    $7f,$7f,$80,$80,$7f,$7f,$80,$80
            dc.b    $7f,$7f,$7f,$80,$80,$80,$7f,$7f,$7f,$80,$80,$80  ; Lower
            dc.b    $00,$00,$00,$00                     ; Silence
HOME_LEN    equ     *-sound_home

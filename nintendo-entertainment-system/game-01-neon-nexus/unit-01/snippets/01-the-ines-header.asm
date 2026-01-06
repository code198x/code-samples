;──────────────────────────────────────────────────────────────
; NEON NEXUS
; A fixed-screen action game for the Nintendo Entertainment System
; Unit 1: The Grid
;──────────────────────────────────────────────────────────────

.segment "HEADER"
    .byte "NES", $1a        ; iNES magic number
    .byte 2                 ; 2 x 16KB PRG ROM = 32KB
    .byte 1                 ; 1 x 8KB CHR ROM
    .byte $01               ; Mapper 0, vertical mirroring
    .byte $00               ; Mapper 0 continued
    .byte 0,0,0,0,0,0,0,0   ; Padding

.segment "HEADER"
    .byte "NES", $1A        ; Magic number — every NES ROM starts with this
    .byte 2                 ; 2 x 16KB PRG-ROM = 32KB
    .byte 1                 ; 1 x 8KB CHR-ROM = 8KB
    .byte $01               ; Vertical mirroring, Mapper 0
    .byte $00               ; Mapper 0 (NROM)
    .byte 0,0,0,0,0,0,0,0  ; Padding

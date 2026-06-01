; ============================================================================
; SONG DATA FORMAT
; ============================================================================
; Each note entry is 3 bytes:
;   byte 0: beat number (0-63, when note spawns)
;   byte 1: track number (1=Z high, 2=X mid, 3=C low)
;   byte 2: note frequency high byte
;
; End of song marker: $FF
;
; Note frequency table (high byte only):
; C3=$11  D3=$13  E3=$16  F3=$17  G3=$1A  A3=$1D  B3=$21
; C4=$23  D4=$27  E4=$2C  F4=$2F  G4=$35  A4=$3B  B4=$42
; C5=$47  D5=$4F  E5=$58  F5=$5E  G5=$6A  A5=$77  B5=$85
; ============================================================================

song_data:
            ; Bar 1 - Opening phrase
            !byte 0, 1, $47     ; Beat 0, Track 1 (Z), C5
            !byte 2, 2, $2C     ; Beat 2, Track 2 (X), E4
            !byte 4, 3, $11     ; Beat 4, Track 3 (C), C3

            ; Bar 2 - Descending
            !byte 8, 1, $3B     ; A4
            !byte 10, 2, $27    ; D4
            !byte 12, 3, $13    ; D3

            ; ... more bars ...

            !byte $FF           ; End of song marker

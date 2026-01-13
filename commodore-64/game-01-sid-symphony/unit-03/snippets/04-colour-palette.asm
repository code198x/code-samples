; C64 Colour Palette (16 colours)
;
; Value  Colour       Notes
; -----  -----------  ---------------------------------
;   0    Black        Background, shadows
;   1    White        Highlights, text
;   2    Red          Danger, track 1
;   3    Cyan         Cool, water
;   4    Purple       Rich, royal
;   5    Green        Nature, track 2, success
;   6    Blue         Sky, calm, track 3
;   7    Yellow       Warning, attention, hit zone
;   8    Orange       Warm, energy
;   9    Brown        Earth, wood
;  10    Light Red    Pink, softer danger
;  11    Dark Grey    Subtle, inactive
;  12    Grey         Neutral, disabled
;  13    Light Green  Bright nature, success
;  14    Light Blue   Sky, highlight
;  15    Light Grey   Soft neutral
;
; Use colour for meaning:
; - Hit zone in yellow (attention, "hit here!")
; - Track lines in dark grey (background, don't distract)
; - Notes in bright colours (important, focus here)
; - Flash colours matching note colours

TRACK1_NOTE_COL = 10            ; Light red - danger zone
TRACK2_NOTE_COL = 13            ; Light green - go zone
TRACK3_NOTE_COL = 14            ; Light blue - cool zone

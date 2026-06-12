; Phrases: period low, period high, frames. 0,0 = rest.
; Terminators: frames $FF = loop, $FE = stop. (NTSC pulse periods.)

; Camptown Races — what else would a game called Dash play?
camptown_phrase:
    .byte $1C,$01, 8        ; G  Camp-
    .byte $1C,$01, 8        ; G  town
    .byte $52,$01, 8        ; E  la-
    .byte $1C,$01, 8        ; G  dies
    .byte $FD,$00, 8        ; A  sing
    .byte $1C,$01, 8        ; G  dis
    .byte $52,$01, 16       ; E  song
    .byte $00,$00, 8        ;    (breath)
    .byte $52,$01, 8        ; E  doo-
    .byte $7C,$01, 16       ; D  dah
    .byte $00,$00, 6        ;    (breath)
    .byte $52,$01, 8        ; E  doo-
    .byte $7C,$01, 16       ; D  dah
    .byte $00,$00, 10       ;    (breath)
    .byte $1C,$01, 8        ; G  Camp-
    .byte $1C,$01, 8        ; G  town
    .byte $52,$01, 8        ; E  race-
    .byte $1C,$01, 8        ; G  track
    .byte $FD,$00, 8        ; A  five
    .byte $1C,$01, 8        ; G  miles
    .byte $52,$01, 16       ; E  long
    .byte $00,$00, 8        ;    (breath)
    .byte $7C,$01, 8        ; D  oh
    .byte $52,$01, 8        ; E  doo-
    .byte $7C,$01, 8        ; D  dah
    .byte $AB,$01, 24       ; C  day
    .byte $00,$00, 30       ;    (and round again)
    .byte $00,$00, $FF      ; loop

; The level fanfare — a rising run, played once
fanfare_phrase:
    .byte $AB,$01, 7        ; C
    .byte $52,$01, 7        ; E
    .byte $1C,$01, 7        ; G
    .byte $D5,$00, 22       ; C, an octave up, held
    .byte $00,$00, $FE      ; stop

; The lose sting — two steps down, then the floor
lose_phrase:
    .byte $52,$01, 10       ; E
    .byte $7C,$01, 10       ; D
    .byte $AB,$01, 10       ; C
    .byte $39,$02, 30       ; G below, long
    .byte $00,$00, $FE      ; stop

; Song data format using parallel arrays
;
; Each note needs three pieces of information:
;   1. When to appear (beat number)
;   2. Which track (1, 2, or 3)
;   3. What note to play (SID frequency)
;
; Parallel arrays are efficient on 6502:
; - Quick comparison of beats (just index into song_beats)
; - Load track/note only when needed
; - Easy to extend or modify

END_MARKER      = $ff           ; Marks end of song data

; Beat numbers - when each note appears
song_beats:
                !byte 0             ; Note 0 on beat 0
                !byte 2             ; Note 1 on beat 2
                !byte 4             ; Note 2 on beat 4
                !byte 6             ; etc.
                !byte 8
                !byte 10
                !byte 12
                !byte 14
                !byte END_MARKER    ; End of song

; Track assignments - which track (1=X, 2=C, 3=V)
song_tracks:
                !byte 1             ; Note 0: Track 1 (X key)
                !byte 2             ; Note 1: Track 2 (C key)
                !byte 3             ; Note 2: Track 3 (V key)
                !byte 2
                !byte 1
                !byte 3
                !byte 2
                !byte 1

; SID frequency values (high byte only for simplicity)
; Full values: C4=$1167, D4=$1389, E4=$15ed, F4=$173b, G4=$1a13, A4=$1d45, B4=$20da, C5=$22ce
song_notes:
                !byte $11           ; C4
                !byte $13           ; D4
                !byte $15           ; E4
                !byte $17           ; F4
                !byte $1a           ; G4
                !byte $1d           ; A4
                !byte $20           ; B4
                !byte $22           ; C5

; To read song data:
;   ldx song_position
;   lda song_beats,x      ; Get beat for note X
;   cmp #END_MARKER       ; Check for end
;   beq .song_ended
;   cmp current_beat      ; Compare with current beat
;   bne .not_yet          ; Not time for this note yet
;   lda song_tracks,x     ; Get track
;   lda song_notes,x      ; Get note value

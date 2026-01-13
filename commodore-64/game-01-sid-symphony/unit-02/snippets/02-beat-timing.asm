; Beat timing with frame counting
; PAL C64 runs at 50Hz (50 frames per second)
; At 120 BPM, we get 2 beats per second = 25 frames per beat

FRAMES_PER_BEAT = 25            ; 50Hz / 2 beats per second

frame_count = $02               ; Current frame within beat (0-24)
beat_count  = $03               ; Current beat in song (0-255)

main_loop:
            ; Wait for raster sync (once per frame)
            lda #$FF
wait_raster:
            cmp $D012
            bne wait_raster

            ; Increment frame counter
            inc frame_count
            lda frame_count
            cmp #FRAMES_PER_BEAT
            bcc no_new_beat

            ; New beat!
            lda #0
            sta frame_count
            jsr check_spawn_note  ; Spawn notes for this beat
            inc beat_count

no_new_beat:
            ; ... rest of game loop

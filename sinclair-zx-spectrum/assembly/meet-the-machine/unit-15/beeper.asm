; ============================================================================
; Meet the Machine - Unit 15: The Machine Speaks Back
; ============================================================================
; The 48K Spectrum has NO sound chip. Sound is the CPU's own job: flip bit 4 of
; port $FE to push the speaker, wait, flip it back, wait, over and over. That
; square wave IS the tone. The pitch is the length of the wait; the CPU does
; nothing else while it plays - it is the sound chip.
; ============================================================================

            org     32768

start:
            di                       ; no interrupts - they would jitter the tone

            ; --- clear the screen to a flat colour, so the shot is clean ---
            ld      hl, $4000
            ld      (hl), 0
            ld      de, $4001
            ld      bc, $17ff
            ldir                     ; blank every pixel
            ld      hl, $5800
            ld      (hl), $2d        ; paper cyan + ink cyan -> a flat field
            ld      de, $5801
            ld      bc, $02ff
            ldir

            ; ----------------------------------------------- YOUR CODE START
loop:
            ld      a, $15           ; speaker bit (4) HIGH, border cyan (bits 0-2)
            out     ($fe), a
            call    delay            ; hold...

            ld      a, $05           ; speaker bit LOW, border still cyan
            out     ($fe), a
            call    delay            ; ...hold

            jr      loop             ; forever - the toggling is the tone

delay:
            ld      bc, 200          ; the wait length - bigger is a lower note
.wait:      dec     bc
            ld      a, b
            or      c
            jr      nz, .wait
            ret
            ; ------------------------------------------------- YOUR CODE END

            end     start

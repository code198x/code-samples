; Title screen structure
;
; The title screen displays:
;   - Game title (animated colours)
;   - Subtitle (static)
;   - "Press SPACE to play" (blinking)
;   - Credits (static)
;
; Called BEFORE init, so charset must be set up first.

start:
                jsr setup_charset
                jsr title_screen        ; Show title BEFORE game init
                jsr init                ; Then initialise game

title_screen:
                ; Clear screen to black
                lda #COL_BLACK
                sta BORDER_COLOUR
                sta BACKGROUND

                ldx #0
-               lda #$20                ; Space character
                sta SCREEN,x
                sta SCREEN+$100,x
                sta SCREEN+$200,x
                sta SCREEN+$2e8,x
                lda #COL_BLACK
                sta COLOUR,x
                sta COLOUR+$100,x
                sta COLOUR+$200,x
                sta COLOUR+$2e8,x
                inx
                bne -

                ; Draw title elements
                ; ... (see other snippets)

                ; Animation loop until SPACE pressed
.title_loop:
                jsr wait_raster
                jsr animate_title       ; Colour cycle
                jsr animate_prompt      ; Blink prompt
                jsr check_space         ; Check for start
                bne .title_loop         ; Keep looping until pressed

                ; Brief pause before starting
                ldx #30
-               jsr wait_raster
                dex
                bne -

                rts

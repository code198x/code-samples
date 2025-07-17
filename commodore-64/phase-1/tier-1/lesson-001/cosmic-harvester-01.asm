; cosmic-harvester-lesson-01.asm
; Lesson 1: Creating Your First Game World
; Create animated starfield for Cosmic Harvester

        * = $0801           ; BASIC start address

        ; BASIC header: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e
        !text "2064"
        !byte $00,$00,$00

        * = $0810           ; Our code starts here ($0810 = 2064 decimal)

start:
        jsr clear_screen
        jsr create_starfield
        jmp animate_stars       ; Jump directly to animation (no return)

clear_screen:
        ; Set border and background colors to black
        lda #$00            ; Black color
        sta $d020           ; Border color
        sta $d021           ; Background color
        
        ; Clear screen memory (1000 bytes total)
        lda #$20            ; Space character (PETSCII 32)
        ldx #$00
clear_loop1:
        sta $0400,x         ; Screen memory page 1
        sta $0500,x         ; Screen memory page 2  
        sta $0600,x         ; Screen memory page 3
        sta $0700,x         ; Screen memory page 4 (partial)
        inx
        bne clear_loop1
        
        ; Clear remaining screen memory (40*25 = 1000 bytes, we've done 1024)
        ; Clear color memory (1000 bytes total)
        lda #$00            ; Black color
        ldx #$00
clear_loop2:
        sta $d800,x         ; Color memory page 1
        sta $d900,x         ; Color memory page 2
        sta $da00,x         ; Color memory page 3
        sta $db00,x         ; Color memory page 4 (partial)
        inx
        bne clear_loop2
        rts

create_starfield:
        lda #$2A            ; Asterisk character (PETSCII 42)
        
        ; Place stars at various screen positions
        sta $0420           ; Row 1, column 0
        sta $0445           ; Row 1, column 37
        sta $04a3           ; Row 4, column 3
        sta $0502           ; Row 6, column 18
        sta $0567           ; Row 8, column 39
        sta $05c8           ; Row 11, column 16
        sta $0623           ; Row 13, column 27
        sta $0691           ; Row 16, column 17
        sta $06f5           ; Row 19, column 5
        sta $0738           ; Row 20, column 24
        
        ; Set star colors (white and light gray)
        lda #$01            ; White color
        sta $d820           ; Color for star at $0420
        sta $d845           ; Color for star at $0445
        sta $d8a3           ; Color for star at $04a3
        sta $d902           ; Color for star at $0502
        sta $d967           ; Color for star at $0567
        
        lda #$0F            ; Light gray color
        sta $d9c8           ; Color for star at $05c8
        sta $da23           ; Color for star at $0623
        sta $da91           ; Color for star at $0691
        sta $daf5           ; Color for star at $06f5
        sta $db38           ; Color for star at $0738
        rts

animate_stars:
        ldx #$00            ; Color index
        ldy #$00            ; Frame counter
animate_loop:
        ; Wait for vertical blank (raster line 255)
        jsr wait_vblank
        
        ; Only change colors every 15 frames (about 3 times per second)
        iny
        cpy #$0F            ; Have we waited 15 frames?
        bne animate_loop    ; If not, just wait another frame
        
        ldy #$00            ; Reset frame counter
        
        ; Cycle through colors for twinkling effect
        lda twinkle_colors,x
        sta $d820           ; First star
        sta $d845           ; Second star
        sta $d8a3           ; Third star
        sta $d902           ; Fourth star
        sta $d967           ; Fifth star
        sta $d9c8           ; Sixth star
        sta $da23           ; Seventh star
        sta $da91           ; Eighth star
        sta $daf5           ; Ninth star
        sta $db38           ; Tenth star
        
        inx
        cpx #$04            ; Check if we've gone through all 4 colors
        bne animate_loop    ; If not, continue with next color
        ldx #$00            ; Reset to first color
        jmp animate_loop    ; Continue looping forever

wait_vblank:
        ; Wait for raster line 255 (start of vertical blank)
wait_vb1:
        lda $d012           ; Read current raster line
        cmp #$ff            ; Are we at line 255?
        bne wait_vb1        ; If not, keep waiting
        
        ; Wait for raster line to change (ensures we catch the transition)
wait_vb2:
        lda $d012           ; Read current raster line
        cmp #$ff            ; Are we still at line 255?
        beq wait_vb2        ; If yes, keep waiting for it to change
        rts

twinkle_colors:
        !byte $01,$0F,$0C,$0B    ; White, Light Gray, Medium Gray, Dark Gray
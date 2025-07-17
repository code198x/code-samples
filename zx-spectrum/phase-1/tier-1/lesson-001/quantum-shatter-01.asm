; quantum-shatter-01.asm
; Lesson 1: Creating Your First Game World
; Create animated starfield for Quantum Shatter

        DEVICE ZXSPECTRUM48     ; Target device

        ORG     $8000           ; Start at 32768

; System constants
ATTRS   EQU     $5800           ; Attribute memory
BORDCR  EQU     $5C48           ; Border color system variable

; Entry point
start:
        di                      ; Disable interrupts
        
        ; Set border to black
        xor     a               ; A = 0 (black)
        out     ($FE),a         ; Set border color
        ld      (BORDCR),a      ; Update system variable
        
        ; Clear screen
        call    clear_screen
        
        ; Create starfield
        call    create_starfield
        
        ; Animate forever
animate_loop:
        halt                    ; Wait for interrupt (50Hz)
        call    animate_stars
        jr      animate_loop

; Clear screen to black
clear_screen:
        ; Clear display file
        ld      hl,$4000        ; Screen start
        ld      de,$4001
        ld      bc,$17FF        ; Screen size - 1
        ld      (hl),0          ; Clear first byte
        ldir                    ; Fill rest
        
        ; Clear attributes to black on black
        ld      hl,ATTRS
        ld      de,ATTRS+1
        ld      bc,767          ; 768 - 1
        ld      (hl),0          ; Black paper, black ink
        ldir
        
        ret

; Create the starfield
create_starfield:
        ; Place stars by setting individual pixels
        ; Using simple fixed positions for now
        
        ; Star 1
        ld      hl,$4020        ; Top area of screen
        ld      a,%10000000     ; Leftmost pixel
        ld      (hl),a
        
        ; Star 2
        ld      hl,$4048
        ld      a,%00100000
        ld      (hl),a
        
        ; Star 3
        ld      hl,$4090
        ld      a,%00000100
        ld      (hl),a
        
        ; Star 4
        ld      hl,$4820
        ld      a,%01000000
        ld      (hl),a
        
        ; Star 5
        ld      hl,$4850
        ld      a,%00001000
        ld      (hl),a
        
        ; Star 6
        ld      hl,$4888
        ld      a,%00010000
        ld      (hl),a
        
        ; Star 7
        ld      hl,$5020
        ld      a,%00000010
        ld      (hl),a
        
        ; Star 8
        ld      hl,$5040
        ld      a,%10000000
        ld      (hl),a
        
        ; Star 9
        ld      hl,$5070
        ld      a,%00100000
        ld      (hl),a
        
        ; Star 10
        ld      hl,$5090
        ld      a,%00000001
        ld      (hl),a
        
        ; Set initial star colors
        ld      a,$07           ; White on black
        ld      hl,ATTRS+33     ; Some attribute positions
        ld      (hl),a
        ld      hl,ATTRS+72
        ld      (hl),a
        ld      hl,ATTRS+145
        ld      (hl),a
        ld      hl,ATTRS+200
        ld      (hl),a
        ld      hl,ATTRS+280
        ld      (hl),a
        ld      hl,ATTRS+350
        ld      (hl),a
        ld      hl,ATTRS+420
        ld      (hl),a
        ld      hl,ATTRS+500
        ld      (hl),a
        ld      hl,ATTRS+580
        ld      (hl),a
        ld      hl,ATTRS+650
        ld      (hl),a
        
        ret

; Animate the stars
frame_counter:  DB 0

animate_stars:
        ; Increment frame counter
        ld      a,(frame_counter)
        inc     a
        and     15              ; Every 16 frames
        ld      (frame_counter),a
        ret     nz              ; Only update every 16th frame
        
        ; Cycle through star colors
        call    update_star_colors
        ret

; Update star colors for twinkling effect
color_index:    DB 0

update_star_colors:
        ; Get current color index
        ld      a,(color_index)
        inc     a
        and     3               ; 0-3
        ld      (color_index),a
        
        ; Select color based on index
        cp      0
        jr      z,use_white
        cp      1
        jr      z,use_bright_white
        cp      2
        jr      z,use_cyan
        
        ; Use yellow
        ld      e,$46           ; Bright yellow on black
        jr      apply_colors
        
use_white:
        ld      e,$07           ; White on black
        jr      apply_colors
        
use_bright_white:
        ld      e,$47           ; Bright white on black
        jr      apply_colors
        
use_cyan:
        ld      e,$45           ; Bright cyan on black
        
apply_colors:
        ; Apply color to star attributes
        ld      hl,ATTRS+33
        ld      (hl),e
        ld      hl,ATTRS+72
        ld      (hl),e
        ld      hl,ATTRS+145
        ld      (hl),e
        ld      hl,ATTRS+200
        ld      (hl),e
        ld      hl,ATTRS+280
        ld      (hl),e
        ld      hl,ATTRS+350
        ld      (hl),e
        ld      hl,ATTRS+420
        ld      (hl),e
        ld      hl,ATTRS+500
        ld      (hl),e
        ld      hl,ATTRS+580
        ld      (hl),e
        ld      hl,ATTRS+650
        ld      (hl),e
        
        ret

; Data section
program_end:

; Create TAP file with BASIC loader
        EMPTYTAP "build/quantum-shatter-01.tap"
        
        ; BASIC loader
        SAVETAP "build/quantum-shatter-01.tap", BASIC, "loader", 10, 1, 10
        
        ; Machine code
        SAVETAP "build/quantum-shatter-01.tap", CODE, "quantum", start, program_end-start, start
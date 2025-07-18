; cosmic-harvester-lesson-03.asm
; Add shooting mechanics to player ship
; Cosmic Harvester: Lesson 3 - Laser Weaponry

        * = $0801           ; BASIC start address

        ; BASIC header: 10 SYS 2064
        !byte $0c,$08,$0a,$00,$9e
        !text "2064"
        !byte $00,$00,$00

        * = $0810           ; Our code starts here

start:
        jsr clear_screen
        jsr create_starfield
        jsr setup_ship
        jsr setup_bullets
        jmp game_loop       ; Main game loop

game_loop:
        jsr wait_vblank
        jsr update_stars
        jsr read_keyboard
        jsr update_ship
        jsr update_bullets
        jmp game_loop

; Ship position variables
ship_x: !byte $A0          ; Ship X position (160 - center)
ship_y: !byte $80          ; Ship Y position (128 - center)

; Star animation variables
star_frame_counter: !byte $00
star_color_index: !byte $00

; Bullet system variables
MAX_BULLETS = 8            ; Maximum simultaneous bullets
BULLET_SPEED = 3           ; Bullet movement speed per frame

; Bullet data arrays (parallel arrays)
bullet_active:  !fill MAX_BULLETS, 0    ; 0 = inactive, 1 = active
bullet_x:       !fill MAX_BULLETS, 0    ; X positions
bullet_y:       !fill MAX_BULLETS, 0    ; Y positions

; Bullet cooldown system
bullet_cooldown: !byte $00  ; Frames until next bullet can be fired
BULLET_COOLDOWN_TIME = 5    ; Frames between bullets

; Temporary variables for calculations - place in zero page
temp_low = $02
screen_addr_low = $03
screen_addr_high = $04
color_addr_low = $05
color_addr_high = $06
bullet_index = $07

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

setup_ship:
        ; Copy ship sprite data to sprite memory location
        ; We'll use sprite data area at $2000
        ldx #$00
copy_ship_loop:
        lda ship_sprite,x
        sta $2000,x
        inx
        cpx #$3F            ; 63 bytes per sprite
        bne copy_ship_loop
        
        ; Set sprite pointer for sprite 0
        ; Screen memory + $3F8 = $07F8
        lda #$80            ; $2000 / 64 = $80
        sta $07F8
        
        ; Enable sprite 0
        lda #$01
        sta $D015
        
        ; Set sprite color (cyan for better visibility)
        lda #$03
        sta $D027
        
        ; Initial ship position (center of screen)
        lda ship_x
        sta $D000           ; X position
        lda ship_y
        sta $D001           ; Y position
        
        ; Clear X position high bit
        lda $D010
        and #%11111110      ; Clear bit 0 (sprite 0 X high bit)
        sta $D010
        
        rts

setup_bullets:
        ; Initialize bullet system
        ldx #$00
init_bullet_loop:
        lda #$00
        sta bullet_active,x
        sta bullet_x,x
        sta bullet_y,x
        inx
        cpx #MAX_BULLETS
        bne init_bullet_loop
        
        ; Initialize cooldown
        lda #$00
        sta bullet_cooldown
        rts

read_keyboard:
        ; Classic C64 keyboard controls: Q/A/O/P + SPACE
        ; Q = Up, A = Down, O = Left, P = Right, SPACE = Fire
        
        ; Check 'O' key (row 4, bit 6)
        lda #$EF            ; Select row 4
        sta $DC00
        lda $DC01
        and #$40            ; Bit 6 = O
        bne check_p
        
        ; O pressed - move left
        lda ship_x
        sec
        sbc #$02
        cmp #$18            ; Left boundary
        bcc check_p
        sta ship_x
        
check_p:
        ; Check 'P' key (row 5, bit 1)
        lda #$DF            ; Select row 5
        sta $DC00
        lda $DC01
        and #$02            ; Bit 1 = P
        bne check_q
        
        ; P pressed - move right
        lda ship_x
        clc
        adc #$02
        cmp #$E0            ; Right boundary
        bcs check_q
        sta ship_x
        
check_q:
        ; Check 'Q' key (row 7, bit 6)
        lda #$7F            ; Select row 7
        sta $DC00
        lda $DC01
        and #$40            ; Bit 6 = Q
        bne check_a
        
        ; Q pressed - move up
        lda ship_y
        sec
        sbc #$02
        cmp #$32            ; Top boundary
        bcc check_a
        sta ship_y
        
check_a:
        ; Check 'A' key (row 1, bit 2)
        lda #$FD            ; Select row 1
        sta $DC00
        lda $DC01
        and #$04            ; Bit 2 = A
        bne check_space
        
        ; A pressed - move down
        lda ship_y
        clc
        adc #$02
        cmp #$E0            ; Bottom boundary
        bcs check_space
        sta ship_y
        
check_space:
        ; Check SPACE key (row 7, bit 4)
        lda #$7F            ; Select row 7
        sta $DC00
        lda $DC01
        and #$10            ; Bit 4 = SPACE
        bne keyboard_done
        
        ; SPACE pressed - fire bullet
        jsr fire_bullet
        
keyboard_done:
        rts

fire_bullet:
        ; Check if we're still in cooldown period
        lda bullet_cooldown
        bne fire_done
        
        ; Find an inactive bullet slot
        ldx #$00
find_bullet_slot:
        lda bullet_active,x
        beq found_slot
        inx
        cpx #MAX_BULLETS
        bne find_bullet_slot
        
        ; No free slots available
        rts
        
found_slot:
        ; Activate bullet
        lda #$01
        sta bullet_active,x
        
        ; Set bullet position (centered on ship)
        lda ship_x
        clc
        adc #$0C            ; Center horizontally on ship
        sta bullet_x,x
        
        lda ship_y
        sec
        sbc #$08            ; Start slightly above ship
        sta bullet_y,x
        
        ; Set cooldown period
        lda #BULLET_COOLDOWN_TIME
        sta bullet_cooldown
        
fire_done:
        rts

update_bullets:
        ; Update bullet cooldown
        lda bullet_cooldown
        beq update_bullet_positions
        dec bullet_cooldown
        
update_bullet_positions:
        ldx #$00
bullet_update_loop:
        lda bullet_active,x
        beq next_bullet
        
        ; Store bullet index for subroutines
        stx bullet_index
        
        ; Move bullet up
        lda bullet_y,x
        sec
        sbc #BULLET_SPEED
        cmp #$20            ; Check if off screen
        bcc deactivate_bullet
        sta bullet_y,x
        
        ; Draw bullet at new position
        jsr draw_bullet
        jmp next_bullet
        
deactivate_bullet:
        lda #$00
        sta bullet_active,x
        
next_bullet:
        inx
        cpx #MAX_BULLETS
        bne bullet_update_loop
        rts

draw_bullet:
        ; Draw bullet at position (bullet_x[X], bullet_y[X])
        ; Convert pixel coordinates to screen coordinates
        
        ; Get bullet index
        ldx bullet_index
        
        ; Calculate screen row (Y / 8)
        lda bullet_y,x
        lsr
        lsr
        lsr                 ; Divide by 8
        tay                 ; Y = row number
        
        ; Calculate screen column (X / 8)
        lda bullet_x,x
        lsr
        lsr
        lsr                 ; Divide by 8
        tax                 ; X = column number
        
        ; Calculate screen address: $0400 + (row * 40) + column
        ; Row * 40 = Row * 32 + Row * 8
        tya                 ; Get row number
        asl                 ; row * 2
        asl                 ; row * 4
        asl                 ; row * 8
        sta temp_low
        
        tya                 ; Get row number again
        asl                 ; row * 2
        asl                 ; row * 4
        asl                 ; row * 8
        asl                 ; row * 16
        asl                 ; row * 32
        clc
        adc temp_low        ; row * 40
        
        ; Add base address
        clc
        adc #$00
        sta screen_addr_low
        lda #$04
        adc #$00
        sta screen_addr_high
        
        ; Add column offset
        txa
        clc
        adc screen_addr_low
        sta screen_addr_low
        lda #$00
        adc screen_addr_high
        sta screen_addr_high
        
        ; Draw bullet character
        ldy #$00
        lda #124            ; Vertical bar character (PETSCII 124)
        sta (screen_addr_low),y
        
        ; Set bullet color (bright red)
        ; Calculate color address: $D800 + (screen_addr - $0400)
        lda screen_addr_low
        sta color_addr_low
        lda screen_addr_high
        clc
        adc #212            ; Add 212 decimal = $D4 hex to get from $04xx to $D8xx
        sta color_addr_high
        
        lda #10             ; Light red color
        sta (color_addr_low),y
        
        rts

update_ship:
        ; Update sprite 0 position
        lda ship_x
        sta $D000           ; X position low byte
        
        ; For now, we keep X position < 255 so no high bit needed
        ; Clear high bit
        lda $D010
        and #$FE
        sta $D010
        
        lda ship_y
        sta $D001           ; Y position
        rts

update_stars:
        ; Only change colors every 15 frames
        inc star_frame_counter
        lda star_frame_counter
        cmp #$0F
        bne stars_done
        
        ; Reset frame counter
        lda #$00
        sta star_frame_counter
        
        ; Update star colors
        ldx star_color_index
        lda twinkle_colors,x
        sta $d820           ; All star colors
        sta $d845
        sta $d8a3
        sta $d902
        sta $d967
        sta $d9c8
        sta $da23
        sta $da91
        sta $daf5
        sta $db38
        
        ; Next color
        inc star_color_index
        lda star_color_index
        cmp #$04
        bne stars_done
        lda #$00
        sta star_color_index
        
stars_done:
        rts

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

; Ship sprite data - Retro Classic with Twin Engines
ship_sprite:
        !byte %00000000,%00000000,%00000000    ; Row 1
        !byte %00000000,%00000000,%00000000    ; Row 2
        !byte %00000000,%00000000,%00000000    ; Row 3
        !byte %00000001,%10001100,%00000000    ; Row 4  - Twin engines
        !byte %00000011,%11001111,%00000000    ; Row 5  - Engine exhausts
        !byte %00000011,%11111111,%00000000    ; Row 6  - Main body top
        !byte %00000111,%11111111,%10000000    ; Row 7
        !byte %00000111,%11111111,%10000000    ; Row 8
        !byte %00001111,%11111111,%11000000    ; Row 9
        !byte %00001100,%11111111,%00110000    ; Row 10 - Side indents
        !byte %01111111,%11111111,%11111110    ; Row 11 - Wide center
        !byte %00001100,%11111111,%00110000    ; Row 12 - Side indents
        !byte %00001111,%11111111,%11000000    ; Row 13
        !byte %00000111,%11111111,%10000000    ; Row 14
        !byte %00000111,%11111111,%10000000    ; Row 15
        !byte %00000011,%11111111,%00000000    ; Row 16
        !byte %00000001,%10001100,%00000000    ; Row 17 - Bottom engines
        !byte %00000001,%10001100,%00000000    ; Row 18 - Engine trails
        !byte %00000000,%00000000,%00000000    ; Row 19
        !byte %00000000,%00000000,%00000000    ; Row 20
        !byte %00000000,%00000000,%00000000    ; Row 21

twinkle_colors:
        !byte $01,$0F,$0C,$0B    ; White, Light Gray, Medium Gray, Dark Gray
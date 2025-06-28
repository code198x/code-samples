; Byte Blaster - Lesson 1 Complete
; Full NES game arena with sprites, background, and controller input

; iNES header for emulators
.segment "HEADER"
        .byte "NES", $1A    ; Magic number
        .byte 2             ; 2 × 16KB PRG ROM banks
        .byte 1             ; 1 × 8KB CHR ROM bank  
        .byte $01           ; Mapper 0, vertical mirroring
        .byte $00, $00, $00, $00, $00, $00, $00, $00

.include "nes.inc"

; Variables in zero page
.segment "ZEROPAGE"
player_x:       .res 1
player_y:       .res 1
scroll_x:       .res 1
scroll_y:       .res 1
buttons:        .res 1
buttons_prev:   .res 1
vblank_flag:    .res 1
frame_counter:  .res 1
enemy_x:        .res 1
enemy_y:        .res 1
enemy_dir:      .res 1

; Main program code
.segment "CODE"

RESET:
        ; Initialize the NES
        SEI             ; Disable interrupts
        CLD             ; Clear decimal mode
        LDX #$40
        STX $4017       ; Disable APU frame IRQ
        LDX #$FF
        TXS             ; Set up stack
        INX             ; X = 0
        STX $2000       ; Disable NMI
        STX $2001       ; Disable rendering
        STX $4010       ; Disable DMC IRQ

        ; Wait for PPU to stabilize
        WAIT_VBLANK
        
        ; Clear RAM
clrmem:
        LDA #0
        STA $0000, X
        STA $0100, X
        STA $0200, X
        STA $0300, X
        STA $0400, X
        STA $0500, X
        STA $0600, X
        STA $0700, X
        INX
        BNE clrmem

        ; Wait for second VBlank
        WAIT_VBLANK

        ; Initialize game
        JSR load_palettes
        JSR load_background
        JSR init_sprites
        JSR init_game_vars
        
        ; Enable rendering
        LDA #%10010000  ; Enable NMI, use sprite pattern table 1
        STA $2000
        LDA #%00011110  ; Enable sprites and background
        STA $2001

game_loop:
        ; Wait for NMI to set vblank_flag
        LDA vblank_flag
        BEQ game_loop
        LDA #0
        STA vblank_flag

        ; Game logic
        JSR read_controller
        JSR update_player
        JSR update_enemy
        JSR update_sprites

        JMP game_loop

load_palettes:
        SET_PPU_ADDR PPU_PALETTE

        ; Background palette 0 - empty space
        LDA #$0F        ; Black
        STA PPUDATA
        LDA #$21        ; Blue
        STA PPUDATA
        LDA #$11        ; Light blue
        STA PPUDATA
        LDA #$01        ; Dark blue
        STA PPUDATA

        ; Background palette 1 - walls
        LDA #$0F        ; Black
        STA PPUDATA
        LDA #$16        ; Red
        STA PPUDATA
        LDA #$26        ; Pink
        STA PPUDATA
        LDA #$36        ; Light pink
        STA PPUDATA

        ; Background palette 2 - decorative
        LDA #$0F        ; Black
        STA PPUDATA
        LDA #$1A        ; Green
        STA PPUDATA
        LDA #$2A        ; Light green
        STA PPUDATA
        LDA #$3A        ; Very light green
        STA PPUDATA

        ; Background palette 3 - special
        LDA #$0F        ; Black
        STA PPUDATA
        LDA #$18        ; Yellow
        STA PPUDATA
        LDA #$28        ; Light yellow
        STA PPUDATA
        LDA #$30        ; White
        STA PPUDATA

        ; Sprite palette 0 - player
        LDA #$0F        ; Black (transparent)
        STA PPUDATA
        LDA #$1A        ; Green
        STA PPUDATA
        LDA #$2A        ; Light green
        STA PPUDATA
        LDA #$30        ; White
        STA PPUDATA

        ; Sprite palette 1 - enemy
        LDA #$0F        ; Black (transparent)
        STA PPUDATA
        LDA #$16        ; Red
        STA PPUDATA
        LDA #$26        ; Pink
        STA PPUDATA
        LDA #$36        ; Light pink
        STA PPUDATA

        ; Sprite palette 2 - items
        LDA #$0F        ; Black (transparent)
        STA PPUDATA
        LDA #$12        ; Blue
        STA PPUDATA
        LDA #$22        ; Light blue
        STA PPUDATA
        LDA #$32        ; Very light blue
        STA PPUDATA

        ; Sprite palette 3 - effects
        LDA #$0F        ; Black (transparent)
        STA PPUDATA
        LDA #$18        ; Yellow
        STA PPUDATA
        LDA #$28        ; Light yellow
        STA PPUDATA
        LDA #$30        ; White
        STA PPUDATA

        RTS

load_background:
        ; Load nametable (background tiles)
        SET_PPU_ADDR PPU_NAMETBL_0

        ; Draw game arena
        LDY #0          ; Row counter
bg_row_loop:
        LDX #0          ; Column counter
bg_col_loop:
        ; Determine tile based on position
        CPY #0          ; Top row?
        BEQ draw_top_wall
        CPY #29         ; Bottom row?
        BEQ draw_bottom_wall
        CPX #0          ; Left column?
        BEQ draw_left_wall
        CPX #31         ; Right column?
        BEQ draw_right_wall
        
        ; Interior decorations
        LDA frame_counter
        AND #$07
        CMP #0
        BNE check_corners
        
        ; Occasionally place decorative tiles
        TXA
        EOR TYA
        AND #$0F
        CMP #$0C
        BEQ draw_decoration
        
check_corners:
        ; Check for corner decorations
        CPY #2
        BNE empty_space
        CPX #2
        BEQ draw_corner
        CPX #29
        BEQ draw_corner
        JMP empty_space
        
draw_top_wall:
        LDA #$01        ; Wall tile
        JMP write_tile
        
draw_bottom_wall:
        LDA #$01        ; Wall tile
        JMP write_tile
        
draw_left_wall:
        LDA #$01        ; Wall tile
        JMP write_tile
        
draw_right_wall:
        LDA #$01        ; Wall tile
        JMP write_tile
        
draw_decoration:
        LDA #$02        ; Decoration tile
        JMP write_tile
        
draw_corner:
        LDA #$03        ; Corner decoration
        JMP write_tile
        
empty_space:
        LDA #$00        ; Empty tile
        
write_tile:
        STA PPUDATA
        
        INX
        CPX #32         ; 32 columns
        BNE bg_col_loop
        
        INY
        CPY #30         ; 30 rows
        BNE bg_row_loop

        ; Load attribute table (palette assignments)
        SET_PPU_ADDR PPU_ATTR_0
        
        LDY #0          ; Row counter (8 rows)
attr_row_loop:
        LDX #0          ; Column counter (8 columns)
attr_col_loop:
        ; Calculate attribute based on position
        CPY #0          ; Top row of attributes?
        BEQ attr_walls
        CPY #7          ; Bottom row of attributes?
        BEQ attr_walls
        CPX #0          ; Left column of attributes?
        BEQ attr_walls
        CPX #7          ; Right column of attributes?
        BEQ attr_walls
        
        ; Interior gets different palettes
        TXA
        EOR TYA
        AND #$01
        BNE attr_decoration
        
        LDA #%00000000  ; Palette 0 for most interior
        JMP write_attr
        
attr_walls:
        LDA #%01010101  ; Palette 1 for walls
        JMP write_attr
        
attr_decoration:
        LDA #%10101010  ; Palette 2 for decorations
        
write_attr:
        STA PPUDATA
        
        INX
        CPX #8          ; 8 attribute columns
        BNE attr_col_loop
        
        INY
        CPY #8          ; 8 attribute rows
        BNE attr_row_loop

        RTS

init_sprites:
        ; Clear all sprites off-screen
        LDX #0
        LDA #$FF        ; Y position off-screen
clear_sprites:
        STA OAM_BUFFER, X    ; Sprite Y position
        INX
        INX
        INX
        INX
        BNE clear_sprites

        ; Initialize player sprite
        LDA #120        ; Y position (center screen)
        STA OAM_BUFFER + 0   ; Sprite 0 Y
        LDA #$01        ; Tile number (player character)
        STA OAM_BUFFER + 1   ; Sprite 0 tile
        LDA #%00000000  ; Attributes (palette 0, no flip)
        STA OAM_BUFFER + 2   ; Sprite 0 attributes  
        LDA #128        ; X position (center screen)
        STA OAM_BUFFER + 3   ; Sprite 0 X

        ; Initialize enemy sprite
        LDA #80         ; Y position
        STA OAM_BUFFER + 4   ; Sprite 1 Y
        LDA #$02        ; Tile number (enemy character)
        STA OAM_BUFFER + 5   ; Sprite 1 tile
        LDA #%00000001  ; Attributes (palette 1, no flip)
        STA OAM_BUFFER + 6   ; Sprite 1 attributes  
        LDA #64         ; X position
        STA OAM_BUFFER + 7   ; Sprite 1 X

        RTS

init_game_vars:
        ; Initialize player position variables
        LDA #128
        STA player_x
        LDA #120  
        STA player_y
        
        ; Initialize enemy variables
        LDA #64
        STA enemy_x
        LDA #80
        STA enemy_y
        LDA #1
        STA enemy_dir   ; 0=left, 1=right
        
        ; Initialize other variables
        LDA #0
        STA scroll_x
        STA scroll_y
        STA frame_counter
        STA buttons
        STA buttons_prev

        RTS

read_controller:
        ; Save previous button state
        LDA buttons
        STA buttons_prev
        
        ; Strobe controller to latch button states
        LDA #1
        STA JOY1
        LDA #0
        STA JOY1

        ; Read 8 buttons
        LDX #8
controller_loop:
        LDA JOY1        ; Read button state
        LSR A           ; Shift right, button in carry
        ROL buttons     ; Rotate into buttons variable
        DEX
        BNE controller_loop

        RTS

update_player:
        ; Check for movement input
        LDA buttons
        AND #BUTTON_UP
        BEQ check_down
        
        ; Move up
        LDA player_y
        SEC
        SBC #2          ; Move 2 pixels up
        CMP #24         ; Top boundary (leave room for walls)
        BCC no_move_up  ; Don't move if too high
        STA player_y
no_move_up:

check_down:
        LDA buttons
        AND #BUTTON_DOWN
        BEQ check_left
        
        ; Move down
        LDA player_y
        CLC
        ADC #2          ; Move 2 pixels down
        CMP #216        ; Bottom boundary
        BCS no_move_down ; Don't move if too low
        STA player_y
no_move_down:

check_left:
        LDA buttons
        AND #BUTTON_LEFT
        BEQ check_right
        
        ; Move left
        LDA player_x
        SEC
        SBC #2          ; Move 2 pixels left
        CMP #16         ; Left boundary
        BCC no_move_left ; Don't move if too far left
        STA player_x
no_move_left:

check_right:
        LDA buttons
        AND #BUTTON_RIGHT
        BEQ movement_done
        
        ; Move right
        LDA player_x
        CLC
        ADC #2          ; Move 2 pixels right
        CMP #240        ; Right boundary
        BCS no_move_right ; Don't move if too far right
        STA player_x
no_move_right:

movement_done:
        RTS

update_enemy:
        ; Simple enemy AI - move back and forth
        LDA frame_counter
        AND #$03        ; Move every 4 frames
        BNE enemy_done
        
        LDA enemy_dir
        BNE enemy_move_right
        
enemy_move_left:
        LDA enemy_x
        SEC
        SBC #1          ; Move 1 pixel left
        CMP #16         ; Left boundary
        BCC enemy_turn_right
        STA enemy_x
        JMP enemy_done
        
enemy_turn_right:
        LDA #1
        STA enemy_dir
        JMP enemy_done
        
enemy_move_right:
        LDA enemy_x
        CLC
        ADC #1          ; Move 1 pixel right
        CMP #240        ; Right boundary
        BCS enemy_turn_left
        STA enemy_x
        JMP enemy_done
        
enemy_turn_left:
        LDA #0
        STA enemy_dir
        
enemy_done:
        RTS

update_sprites:
        ; Update player sprite position
        LDA player_y
        STA OAM_BUFFER + 0   ; Sprite 0 Y
        LDA player_x
        STA OAM_BUFFER + 3   ; Sprite 0 X
        
        ; Update enemy sprite position
        LDA enemy_y
        STA OAM_BUFFER + 4   ; Sprite 1 Y
        LDA enemy_x
        STA OAM_BUFFER + 7   ; Sprite 1 X
        
        ; Animate player sprite based on movement
        LDA buttons
        AND #(BUTTON_LEFT | BUTTON_RIGHT | BUTTON_UP | BUTTON_DOWN)
        BEQ player_idle
        
        ; Player is moving - animate
        LDA frame_counter
        AND #$08        ; Change frame every 8 frames
        BEQ player_frame_0
        LDA #$03        ; Walking frame
        JMP set_player_tile
player_frame_0:
        LDA #$01        ; Standing frame
        JMP set_player_tile
        
player_idle:
        LDA #$01        ; Standing frame
        
set_player_tile:
        STA OAM_BUFFER + 1   ; Sprite 0 tile
        
        ; Animate enemy sprite
        LDA frame_counter
        AND #$10        ; Change frame every 16 frames
        BEQ enemy_frame_0
        LDA #$04        ; Enemy alternate frame
        JMP set_enemy_tile
enemy_frame_0:
        LDA #$02        ; Enemy base frame
        
set_enemy_tile:
        STA OAM_BUFFER + 5   ; Sprite 1 tile

        RTS

NMI:
        ; Save registers
        PHA
        TXA
        PHA
        TYA
        PHA

        ; Set VBlank flag for main loop
        LDA #1
        STA vblank_flag

        ; Update sprite positions via DMA
        LDA #$00        ; Low byte of sprite RAM
        STA OAMADDR     ; Set OAM address
        LDA #$02        ; High byte ($0200)
        STA OAMDMA      ; Start DMA transfer

        ; Update scrolling (currently disabled)
        LDA scroll_x
        STA PPUSCROLL   ; Set X scroll
        LDA scroll_y  
        STA PPUSCROLL   ; Set Y scroll

        ; Increment frame counter
        INC frame_counter

        ; Restore registers
        PLA
        TAY
        PLA
        TAX
        PLA
        RTI

IRQ:
        ; IRQ not used in this example
        RTI

; Interrupt vectors
.segment "VECTORS"
        .word NMI       ; NMI vector
        .word RESET     ; Reset vector
        .word IRQ       ; IRQ vector

; Character ROM data
.segment "CHARS"
        .incbin "graphics.chr"
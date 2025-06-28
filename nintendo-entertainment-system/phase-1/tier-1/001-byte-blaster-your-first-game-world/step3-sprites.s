; Byte Blaster - Lesson 1 Step 3
; Sprite system implementation

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
buttons:        .res 1
vblank_flag:    .res 1

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
        JSR load_palette
        JSR clear_background
        JSR init_sprites
        
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
        
        JMP game_loop

load_palette:
        SET_PPU_ADDR PPU_PALETTE

        ; Background palette 0
        LDA #$0F        ; Black
        STA PPUDATA
        LDA #$21        ; Blue
        STA PPUDATA
        LDA #$11        ; Light blue
        STA PPUDATA
        LDA #$30        ; White
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

        ; Skip remaining background palettes
        LDX #8
skip_bg_pal:
        LDA #$0F
        STA PPUDATA
        DEX
        BNE skip_bg_pal

        ; Sprite palette 0 - player
        LDA #$0F        ; Black (transparent)
        STA PPUDATA
        LDA #$1A        ; Green
        STA PPUDATA
        LDA #$2A        ; Light green
        STA PPUDATA
        LDA #$30        ; White
        STA PPUDATA

        ; Skip remaining sprite palettes
        LDX #12
skip_spr_pal:
        LDA #$0F
        STA PPUDATA
        DEX
        BNE skip_spr_pal

        RTS

clear_background:
        ; Clear nametable with pattern
        SET_PPU_ADDR PPU_NAMETBL_0

        ; Create simple arena layout
        LDY #0          ; Row counter
bg_row_loop:
        LDX #0          ; Column counter
bg_col_loop:
        ; Check if this is a border position
        CPY #0          ; Top row?
        BEQ draw_wall
        CPY #29         ; Bottom row?
        BEQ draw_wall
        CPX #0          ; Left column?
        BEQ draw_wall
        CPX #31         ; Right column?
        BEQ draw_wall
        
        ; Interior - empty space
        LDA #$00        ; Empty tile
        JMP write_tile
        
draw_wall:
        LDA #$01        ; Wall tile
        
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
        
        LDX #64         ; 8×8 attribute grid
attr_loop:
        LDA #%01010101  ; Use palette 1 for walls, 0 for interior
        STA PPUDATA
        DEX
        BNE attr_loop

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

        ; Initialize player position variables
        LDA #128
        STA player_x
        LDA #120  
        STA player_y

        RTS

read_controller:
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
        CMP #16         ; Top boundary (8 pixels margin)
        BCC no_move_up  ; Don't move if too high
        STA player_y
        STA OAM_BUFFER + 0   ; Update sprite Y
no_move_up:

check_down:
        LDA buttons
        AND #BUTTON_DOWN
        BEQ check_left
        
        ; Move down
        LDA player_y
        CLC
        ADC #2          ; Move 2 pixels down
        CMP #224        ; Bottom boundary
        BCS no_move_down ; Don't move if too low
        STA player_y
        STA OAM_BUFFER + 0   ; Update sprite Y
no_move_down:

check_left:
        LDA buttons
        AND #BUTTON_LEFT
        BEQ check_right
        
        ; Move left
        LDA player_x
        SEC
        SBC #2          ; Move 2 pixels left
        CMP #8          ; Left boundary
        BCC no_move_left ; Don't move if too far left
        STA player_x
        STA OAM_BUFFER + 3   ; Update sprite X
no_move_left:

check_right:
        LDA buttons
        AND #BUTTON_RIGHT
        BEQ movement_done
        
        ; Move right
        LDA player_x
        CLC
        ADC #2          ; Move 2 pixels right
        CMP #248        ; Right boundary
        BCS no_move_right ; Don't move if too far right
        STA player_x
        STA OAM_BUFFER + 3   ; Update sprite X
no_move_right:

movement_done:
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
; nes.inc - Standard NES definitions
; Common constants and memory addresses

; PPU Registers
PPUCTRL     = $2000    ; PPU Control Register
PPUMASK     = $2001    ; PPU Mask Register  
PPUSTATUS   = $2002    ; PPU Status Register
OAMADDR     = $2003    ; OAM Address Register
OAMDATA     = $2004    ; OAM Data Register
PPUSCROLL   = $2005    ; PPU Scroll Register
PPUADDR     = $2006    ; PPU Address Register
PPUDATA     = $2007    ; PPU Data Register

; APU and I/O Registers
SQ1_VOL     = $4000    ; Square Wave 1 Volume
SQ1_SWEEP   = $4001    ; Square Wave 1 Sweep
SQ1_LO      = $4002    ; Square Wave 1 Low Frequency
SQ1_HI      = $4003    ; Square Wave 1 High Frequency
SQ2_VOL     = $4004    ; Square Wave 2 Volume
SQ2_SWEEP   = $4005    ; Square Wave 2 Sweep  
SQ2_LO      = $4006    ; Square Wave 2 Low Frequency
SQ2_HI      = $4007    ; Square Wave 2 High Frequency
TRI_LINEAR  = $4008    ; Triangle Linear Counter
TRI_LO      = $400A    ; Triangle Low Frequency
TRI_HI      = $400B    ; Triangle High Frequency
NOISE_VOL   = $400C    ; Noise Volume
NOISE_LO    = $400E    ; Noise Low Frequency
NOISE_HI    = $400F    ; Noise High Frequency
DMC_FREQ    = $4010    ; DMC Frequency
DMC_RAW     = $4011    ; DMC Raw Delta
DMC_START   = $4012    ; DMC Start Address
DMC_LEN     = $4013    ; DMC Length
OAMDMA      = $4014    ; OAM DMA Register
SND_CHN     = $4015    ; Sound Channel Register
JOY1        = $4016    ; Controller 1 Register
JOY2        = $4017    ; Controller 2 Register

; Controller Bit Patterns
BUTTON_A      = %10000000
BUTTON_B      = %01000000
BUTTON_SELECT = %00100000
BUTTON_START  = %00010000
BUTTON_UP     = %00001000
BUTTON_DOWN   = %00000100
BUTTON_LEFT   = %00000010
BUTTON_RIGHT  = %00000001

; PPUCTRL Bit Flags
PPUCTRL_NMI       = %10000000  ; Enable NMI
PPUCTRL_MASTER    = %01000000  ; Master/Slave select
PPUCTRL_SPR_SIZE  = %00100000  ; Sprite size (0=8x8, 1=8x16)
PPUCTRL_BG_ADDR   = %00010000  ; Background pattern table (0=$0000, 1=$1000)
PPUCTRL_SPR_ADDR  = %00001000  ; Sprite pattern table (0=$0000, 1=$1000)
PPUCTRL_INC_MODE  = %00000100  ; VRAM increment (0=across, 1=down)
PPUCTRL_NAME_TBL  = %00000011  ; Nametable select (0-3)

; PPUMASK Bit Flags  
PPUMASK_BLUE      = %10000000  ; Blue emphasis
PPUMASK_GREEN     = %01000000  ; Green emphasis
PPUMASK_RED       = %00100000  ; Red emphasis
PPUMASK_SPR_SHOW  = %00010000  ; Show sprites
PPUMASK_BG_SHOW   = %00001000  ; Show background
PPUMASK_SPR_LEFT  = %00000100  ; Show sprites in leftmost 8 pixels
PPUMASK_BG_LEFT   = %00000010  ; Show background in leftmost 8 pixels
PPUMASK_GREYSCALE = %00000001  ; Greyscale mode

; PPUSTATUS Bit Flags
PPUSTATUS_VBLANK  = %10000000  ; VBlank flag
PPUSTATUS_SPR0    = %01000000  ; Sprite 0 hit flag
PPUSTATUS_OVRFLW  = %00100000  ; Sprite overflow flag

; Common Memory Addresses
OAM_BUFFER = $0200             ; Sprite data buffer (256 bytes)
STACK      = $0100             ; Stack page

; PPU Memory Addresses
PPU_PATTERN_0   = $0000        ; Background pattern table
PPU_PATTERN_1   = $1000        ; Sprite pattern table
PPU_NAMETBL_0   = $2000        ; Nametable 0
PPU_NAMETBL_1   = $2400        ; Nametable 1  
PPU_NAMETBL_2   = $2800        ; Nametable 2
PPU_NAMETBL_3   = $2C00        ; Nametable 3
PPU_ATTR_0      = $23C0        ; Attribute table 0
PPU_ATTR_1      = $27C0        ; Attribute table 1
PPU_ATTR_2      = $2BC0        ; Attribute table 2
PPU_ATTR_3      = $2FC0        ; Attribute table 3
PPU_PALETTE     = $3F00        ; Palette RAM
PPU_BG_PAL      = $3F00        ; Background palette
PPU_SPR_PAL     = $3F10        ; Sprite palette

; Color Palette Constants
COLOR_BLACK     = $0F
COLOR_WHITE     = $30
COLOR_GRAY      = $00
COLOR_RED       = $16
COLOR_PINK      = $24
COLOR_PURPLE    = $14
COLOR_BLUE      = $12
COLOR_CYAN      = $2C
COLOR_GREEN     = $1A
COLOR_YELLOW    = $28
COLOR_ORANGE    = $18
COLOR_BROWN     = $17

; Screen Dimensions
SCREEN_WIDTH    = 32           ; 32 tiles wide
SCREEN_HEIGHT   = 30           ; 30 tiles tall
TILE_SIZE       = 8            ; 8x8 pixels per tile

; Sprite Limits
MAX_SPRITES     = 64           ; Maximum total sprites
SPRITES_PER_LINE = 8           ; Maximum sprites per scanline

; Common Macros

; Wait for VBlank
.macro WAIT_VBLANK
    BIT PPUSTATUS
:   BIT PPUSTATUS
    BPL :-
.endmacro

; Set PPU address
.macro SET_PPU_ADDR addr
    LDA PPUSTATUS    ; Reset latch
    LDA #>addr       ; High byte
    STA PPUADDR
    LDA #<addr       ; Low byte
    STA PPUADDR
.endmacro

; Load palette data
.macro LOAD_PALETTE source, count
    SET_PPU_ADDR PPU_PALETTE
    LDX #0
:   LDA source,X
    STA PPUDATA
    INX
    CPX #count
    BNE :-
.endmacro

; Clear nametable
.macro CLEAR_NAMETABLE table
    SET_PPU_ADDR table
    LDA #0
    LDX #4              ; 4 pages (1024 bytes)
    LDY #0
:   STA PPUDATA
    INY
    BNE :-
    DEX
    BNE :-
.endmacro

; Enable rendering
.macro ENABLE_RENDERING
    LDA #(PPUMASK_SPR_SHOW | PPUMASK_BG_SHOW)
    STA PPUMASK
.endmacro

; Disable rendering
.macro DISABLE_RENDERING
    LDA #0
    STA PPUMASK
.endmacro
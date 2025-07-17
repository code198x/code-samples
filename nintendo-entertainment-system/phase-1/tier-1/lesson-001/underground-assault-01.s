; underground-assault-01.s
; Lesson 1: Creating Your First Game World
; Create animated starfield for Underground Assault

;----------------------------------------------------------------
; iNES Header
;----------------------------------------------------------------
.segment "HEADER"
  .byte "NES", $1A      ; iNES header identifier
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01             ; Mapper 0, vertical mirroring

;----------------------------------------------------------------
; Variables (Zero Page)
;----------------------------------------------------------------
.segment "ZEROPAGE"
frameCount:     .res 1  ; Frame counter for animation
colorIndex:     .res 1  ; Current star color index
nmiFlag:        .res 1  ; NMI occurred flag

;----------------------------------------------------------------
; Constants
;----------------------------------------------------------------
PPUCTRL   = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
OAMDATA   = $2004
PPUSCROLL = $2005
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

BUTTON_A      = $80
BUTTON_B      = $40
BUTTON_SELECT = $20
BUTTON_START  = $10
BUTTON_UP     = $08
BUTTON_DOWN   = $04
BUTTON_LEFT   = $02
BUTTON_RIGHT  = $01

;----------------------------------------------------------------
; Program Start
;----------------------------------------------------------------
.segment "CODE"

.proc RESET
  sei             ; Disable IRQs
  cld             ; Disable decimal mode
  ldx #$40
  stx $4017       ; Disable APU frame IRQ
  ldx #$FF
  txs             ; Set up stack
  inx             ; Now X = 0
  stx PPUCTRL     ; Disable NMI
  stx PPUMASK     ; Disable rendering
  stx $4010       ; Disable DMC IRQs

  ; Wait for first vblank
vblankwait1:
  bit PPUSTATUS
  bpl vblankwait1

  ; Clear memory
clearmem:
  lda #$00
  sta $0000, x
  sta $0100, x
  sta $0300, x
  sta $0400, x
  sta $0500, x
  sta $0600, x
  sta $0700, x
  lda #$FE
  sta $0200, x    ; Move sprites off screen
  inx
  bne clearmem

  ; Wait for second vblank
vblankwait2:
  bit PPUSTATUS
  bpl vblankwait2

  ; Load palettes
  lda PPUSTATUS    ; Read PPU status to reset the high/low latch
  lda #$3F
  sta PPUADDR      ; Write the high byte of $3F00 address
  lda #$00
  sta PPUADDR      ; Write the low byte of $3F00 address
  
  ldx #$00
LoadPalettesLoop:
  lda palette, x
  sta PPUDATA
  inx
  cpx #$20
  bne LoadPalettesLoop

  ; Load initial starfield to nametable
  jsr LoadStarfield

  ; Set initial scroll
  lda #$00
  sta PPUSCROLL
  sta PPUSCROLL

  ; Enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  lda #%10010000
  sta PPUCTRL

  ; Enable sprites and background
  lda #%00011110
  sta PPUMASK

  ; Initialize variables
  lda #$00
  sta frameCount
  sta colorIndex

Forever:
  ; Wait for NMI
  lda #$00
  sta nmiFlag
WaitForNMI:
  lda nmiFlag
  beq WaitForNMI
  
  ; Update animation
  jsr UpdateAnimation
  
  jmp Forever
.endproc

;----------------------------------------------------------------
; Load starfield pattern to nametable
;----------------------------------------------------------------
.proc LoadStarfield
  lda PPUSTATUS    ; Read PPU status to reset the high/low latch
  lda #$20
  sta PPUADDR      ; Write the high byte of $2000 address
  lda #$00
  sta PPUADDR      ; Write the low byte of $2000 address

  ; Fill background with tile 0 (black)
  ldx #$00
  ldy #$00
FillBackground:
  lda #$00         ; Tile 0 = black
  sta PPUDATA
  inx
  cpx #$00
  bne FillBackground
  iny
  cpy #$04         ; 4 * 256 = 1024 tiles
  bne FillBackground

  ; Place stars at specific positions
  ; We'll write individual tiles to create a starfield pattern
  
  ; Star 1 at row 5, column 8
  lda PPUSTATUS
  lda #$20
  sta PPUADDR
  lda #$A8
  sta PPUADDR
  lda #$01         ; Tile 1 = star
  sta PPUDATA

  ; Star 2 at row 8, column 20
  lda PPUSTATUS
  lda #$21
  sta PPUADDR
  lda #$14
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 3 at row 12, column 10
  lda PPUSTATUS
  lda #$21
  sta PPUADDR
  lda #$8A
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 4 at row 15, column 25
  lda PPUSTATUS
  lda #$21
  sta PPUADDR
  lda #$F9
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 5 at row 18, column 5
  lda PPUSTATUS
  lda #$22
  sta PPUADDR
  lda #$45
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 6 at row 20, column 15
  lda PPUSTATUS
  lda #$22
  sta PPUADDR
  lda #$8F
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 7 at row 10, column 28
  lda PPUSTATUS
  lda #$21
  sta PPUADDR
  lda #$5C
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 8 at row 7, column 12
  lda PPUSTATUS
  lda #$20
  sta PPUADDR
  lda #$EC
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 9 at row 22, column 18
  lda PPUSTATUS
  lda #$22
  sta PPUADDR
  lda #$D2
  sta PPUADDR
  lda #$01
  sta PPUDATA

  ; Star 10 at row 25, column 8
  lda PPUSTATUS
  lda #$23
  sta PPUADDR
  lda #$28
  sta PPUADDR
  lda #$01
  sta PPUDATA

  rts
.endproc

;----------------------------------------------------------------
; Update animation
;----------------------------------------------------------------
.proc UpdateAnimation
  ; Increment frame counter
  inc frameCount
  lda frameCount
  and #$0F         ; Every 16 frames
  bne Done
  
  ; Change star colors by updating palette
  inc colorIndex
  lda colorIndex
  and #$03         ; Keep in range 0-3
  sta colorIndex
  
Done:
  rts
.endproc

;----------------------------------------------------------------
; NMI Handler
;----------------------------------------------------------------
.proc NMI
  pha              ; Save registers
  txa
  pha
  tya
  pha

  ; Update palette based on colorIndex
  lda PPUSTATUS    ; Read PPU status to reset the high/low latch
  lda #$3F
  sta PPUADDR      ; Write the high byte of $3F00 address
  lda #$01
  sta PPUADDR      ; Write the low byte of $3F01 address (BG palette 0, color 1)
  
  ; Select color based on index
  ldx colorIndex
  lda starColors, x
  sta PPUDATA
  
  ; Reset scroll
  lda #$00
  sta PPUSCROLL
  sta PPUSCROLL
  
  ; Reset PPU address
  lda #$20
  sta PPUADDR
  lda #$00
  sta PPUADDR
  
  ; Set NMI flag
  lda #$01
  sta nmiFlag

  pla              ; Restore registers
  tay
  pla
  tax
  pla
  rti
.endproc

;----------------------------------------------------------------
; Data
;----------------------------------------------------------------
.segment "RODATA"

palette:
  ; Background palette
  .byte $0F,$30,$30,$30  ; BG palette 0 (black, white variations)
  .byte $0F,$0F,$0F,$0F  ; BG palette 1
  .byte $0F,$0F,$0F,$0F  ; BG palette 2
  .byte $0F,$0F,$0F,$0F  ; BG palette 3
  
  ; Sprite palette
  .byte $0F,$30,$30,$30  ; Sprite palette 0
  .byte $0F,$0F,$0F,$0F  ; Sprite palette 1
  .byte $0F,$0F,$0F,$0F  ; Sprite palette 2
  .byte $0F,$0F,$0F,$0F  ; Sprite palette 3

starColors:
  .byte $30, $20, $11, $21  ; White, Light gray, Light blue, Light purple

;----------------------------------------------------------------
; Interrupt Vectors
;----------------------------------------------------------------
.segment "VECTORS"
  .addr NMI        ; When an NMI happens (once per frame) jump to NMI
  .addr RESET      ; When the processor first turns on or is reset
  .addr 0          ; External interrupt IRQ is not used

;----------------------------------------------------------------
; CHR-ROM Data (Pattern Tables)
;----------------------------------------------------------------
.segment "CHARS"

  ; Tile 0 - Empty (black)
  .byte $00,$00,$00,$00,$00,$00,$00,$00
  .byte $00,$00,$00,$00,$00,$00,$00,$00

  ; Tile 1 - Small star
  .byte %00000000
  .byte %00000000
  .byte %00010000
  .byte %00111000
  .byte %00111000
  .byte %00010000
  .byte %00000000
  .byte %00000000
  ; Bit plane 2 (for color)
  .byte %00000000
  .byte %00010000
  .byte %00101000
  .byte %01000100
  .byte %01000100
  .byte %00101000
  .byte %00010000
  .byte %00000000
  
  ; Fill rest with empty tiles
  .res 8160, $00   ; 8192 - 32 bytes already used
; underground-assault-03.s
; Lesson 3: Plasma Cannons
; Add sprite-based shooting mechanics to Underground Assault

;----------------------------------------------------------------
; iNES Header
;----------------------------------------------------------------
.segment "HEADER"
  .byte "NES", $1A      ; iNES header identifier
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01             ; Mapper 0, vertical mirroring

;----------------------------------------------------------------
; Constants
;----------------------------------------------------------------
; Bullet system constants
MAX_BULLETS         = 8  ; Maximum simultaneous bullets
BULLET_SPEED        = 4  ; Bullet movement speed per frame
BULLET_COOLDOWN_TIME = 8 ; Frames between shots
BULLET_TILE         = 3  ; Tile number for bullet sprite

;----------------------------------------------------------------
; Variables (Zero Page)
;----------------------------------------------------------------
.segment "ZEROPAGE"
frameCount:     .res 1  ; Frame counter for animation
colorIndex:     .res 1  ; Current star color index
nmiFlag:        .res 1  ; NMI occurred flag
player_x:       .res 1  ; Player X position
player_y:       .res 1  ; Player Y position
buttons:        .res 1  ; Controller input
buttons_old:    .res 1  ; Previous controller input

; Temporary variables (kept in zero page for speed)
temp:           .res 1  ; General purpose temporary variable
bulletIndex:    .res 1  ; Current bullet index for processing

;----------------------------------------------------------------
; Variables (Regular RAM)
;----------------------------------------------------------------
.segment "BSS"
; Bullet system variables
bullet_cooldown:  .res 1              ; Frames until next bullet can be fired
bullet_active:    .res MAX_BULLETS    ; 0 = inactive, 1 = active
bullet_x:         .res MAX_BULLETS    ; X positions
bullet_y:         .res MAX_BULLETS    ; Y positions

;----------------------------------------------------------------
; PPU and System Constants
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

; Controller
CONTROLLER1 = $4016
CONTROLLER2 = $4017

BUTTON_A      = $80
BUTTON_B      = $40
BUTTON_SELECT = $20
BUTTON_START  = $10
BUTTON_UP     = $08
BUTTON_DOWN   = $04
BUTTON_LEFT   = $02
BUTTON_RIGHT  = $01

; Player ship constants
PLAYER_START_X = 120    ; Starting X position (middle of screen)
PLAYER_START_Y = 200    ; Starting Y position (near bottom)
PLAYER_MIN_X   = 8      ; Minimum X position
PLAYER_MAX_X   = 240    ; Maximum X position
PLAYER_MIN_Y   = 16     ; Minimum Y position
PLAYER_MAX_Y   = 220    ; Maximum Y position
PLAYER_SPEED   = 2      ; Movement speed

; Sprite constants
SPRITE_PLAYER = 0       ; Player uses sprite 0
SPRITE_BULLETS = 1      ; Bullets start at sprite 1

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

  ; Initialize player
  jsr InitPlayer
  
  ; Initialize bullet system
  jsr InitBullets

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
  sta nmiFlag

Forever:
  ; Wait for NMI
  lda #$00
  sta nmiFlag
WaitForNMI:
  lda nmiFlag
  beq WaitForNMI
  
  ; Read controller input
  jsr ReadController
  
  ; Update player position
  jsr UpdatePlayer
  
  ; Update bullets
  jsr UpdateBullets
  
  ; Update animation
  jsr UpdateAnimation
  
  jmp Forever
.endproc

;----------------------------------------------------------------
; Initialize bullet system
;----------------------------------------------------------------
.proc InitBullets
  ; Clear all bullet data
  ldx #$00
ClearLoop:
  lda #$00
  sta bullet_active, x
  sta bullet_x, x
  sta bullet_y, x
  inx
  cpx #MAX_BULLETS
  bne ClearLoop
  
  ; Initialize cooldown
  lda #$00
  sta bullet_cooldown
  
  rts
.endproc

;----------------------------------------------------------------
; Initialize player sprite
;----------------------------------------------------------------
.proc InitPlayer
  ; Set starting position
  lda #PLAYER_START_X
  sta player_x
  lda #PLAYER_START_Y
  sta player_y
  
  ; Set up player sprite in OAM
  lda player_y
  sta $0200       ; Sprite 0 Y position
  lda #$02        ; Sprite tile (player ship)
  sta $0201       ; Sprite 0 tile
  lda #%00000001  ; Palette 1, no flip
  sta $0202       ; Sprite 0 attributes
  lda player_x
  sta $0203       ; Sprite 0 X position
  
  rts
.endproc

;----------------------------------------------------------------
; Read controller input
;----------------------------------------------------------------
.proc ReadController
  ; Store previous buttons
  lda buttons
  sta buttons_old
  
  ; Strobe controller
  lda #$01
  sta CONTROLLER1
  lda #$00
  sta CONTROLLER1
  
  ; Read 8 buttons
  ldx #$08
ReadLoop:
  lda CONTROLLER1
  lsr             ; Button state in carry
  rol buttons     ; Rotate into buttons
  dex
  bne ReadLoop
  
  rts
.endproc

;----------------------------------------------------------------
; Update player position based on input
;----------------------------------------------------------------
.proc UpdatePlayer
  ; Check for up movement
  lda buttons
  and #BUTTON_UP
  beq CheckDown
  
  ; Move up
  lda player_y
  cmp #PLAYER_MIN_Y
  bcc CheckDown   ; Already at minimum
  sec
  sbc #PLAYER_SPEED
  sta player_y
  
CheckDown:
  lda buttons
  and #BUTTON_DOWN
  beq CheckLeft
  
  ; Move down
  lda player_y
  cmp #PLAYER_MAX_Y
  bcs CheckLeft   ; Already at maximum
  clc
  adc #PLAYER_SPEED
  sta player_y
  
CheckLeft:
  lda buttons
  and #BUTTON_LEFT
  beq CheckRight
  
  ; Move left
  lda player_x
  cmp #PLAYER_MIN_X
  bcc CheckRight  ; Already at minimum
  sec
  sbc #PLAYER_SPEED
  sta player_x
  
CheckRight:
  lda buttons
  and #BUTTON_RIGHT
  beq CheckFire
  
  ; Move right
  lda player_x
  cmp #PLAYER_MAX_X
  bcs CheckFire   ; Already at maximum
  clc
  adc #PLAYER_SPEED
  sta player_x

CheckFire:
  ; Check A button for firing
  lda buttons
  and #BUTTON_A
  beq UpdateDone
  
  ; Fire bullet
  jsr FireBullet
  
UpdateDone:
  ; Update sprite position in OAM
  lda player_y
  sta $0200       ; Sprite 0 Y position
  lda player_x
  sta $0203       ; Sprite 0 X position
  
  rts
.endproc

;----------------------------------------------------------------
; Fire bullet
;----------------------------------------------------------------
.proc FireBullet
  ; Check cooldown
  lda bullet_cooldown
  bne Done        ; Still cooling down
  
  ; Find an inactive bullet slot
  ldx #$00
FindSlot:
  lda bullet_active, x
  beq FoundSlot   ; Found inactive slot
  inx
  cpx #MAX_BULLETS
  bne FindSlot
  rts             ; No free slots
  
FoundSlot:
  ; Activate bullet
  lda #$01
  sta bullet_active, x
  
  ; Set bullet position (centered on player)
  lda player_x
  clc
  adc #4          ; Center bullet on player sprite
  sta bullet_x, x
  
  lda player_y
  sec
  sbc #8          ; Start bullet above player
  sta bullet_y, x
  
  ; Set cooldown
  lda #BULLET_COOLDOWN_TIME
  sta bullet_cooldown
  
Done:
  rts
.endproc

;----------------------------------------------------------------
; Update bullets
;----------------------------------------------------------------
.proc UpdateBullets
  ; Update cooldown
  lda bullet_cooldown
  beq UpdatePositions
  dec bullet_cooldown
  
UpdatePositions:
  ; Process each bullet
  ldx #$00
BulletLoop:
  ; Store bullet index
  stx bulletIndex
  
  ; Check if bullet is active
  lda bullet_active, x
  beq NextBullet
  
  ; Move bullet up
  lda bullet_y, x
  sec
  sbc #BULLET_SPEED
  cmp #8          ; Check if off screen
  bcc DeactivateBullet
  
  ; Update position
  sta bullet_y, x
  jmp NextBullet
  
DeactivateBullet:
  ; Deactivate bullet
  lda #$00
  sta bullet_active, x
  
NextBullet:
  ldx bulletIndex
  inx
  cpx #MAX_BULLETS
  bne BulletLoop
  
  ; Update sprite positions
  jsr UpdateBulletSprites
  
  rts
.endproc

;----------------------------------------------------------------
; Update bullet sprites in OAM
;----------------------------------------------------------------
.proc UpdateBulletSprites
  ; Process each bullet
  ldx #$00        ; Bullet index
  
BulletLoop:
  ; Store bullet index in temp
  stx temp
  
  ; Calculate sprite index (bullet index + 1, since sprite 0 is player)
  txa
  clc
  adc #1
  tay             ; Y = sprite index
  
  ; Calculate OAM offset (sprite index * 4)
  tya
  asl
  asl
  tay             ; Y = OAM offset
  
  ; Restore bullet index
  ldx temp
  
  ; Check if bullet is active
  lda bullet_active, x
  beq HideSprite
  
  ; Set sprite data
  lda bullet_y, x
  sta $0200, y    ; Y position
  
  lda #BULLET_TILE
  sta $0201, y    ; Tile
  
  lda #%00000010  ; Palette 2, no flip
  sta $0202, y    ; Attributes
  
  lda bullet_x, x
  sta $0203, y    ; X position
  
  jmp NextSprite
  
HideSprite:
  ; Hide sprite by moving it off screen
  lda #$FE
  sta $0200, y    ; Y position (off screen)
  
NextSprite:
  ldx temp
  inx
  cpx #MAX_BULLETS
  bne BulletLoop
  
  rts
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

  ; Sprite DMA transfer
  lda #$00
  sta OAMADDR
  lda #$02
  sta OAMDMA       ; Transfer sprites from $0200

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
  .byte $0F,$0C,$2C,$3C  ; Sprite palette 0 (black, red, light blue, light purple)
  .byte $0F,$16,$26,$36  ; Sprite palette 1 (black, orange, green, cyan)
  .byte $0F,$07,$27,$37  ; Sprite palette 2 (black, white, light green, light cyan)
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
  
  ; Tile 2 - Player ship
  .byte %00001000
  .byte %00011100
  .byte %00111110
  .byte %01111111
  .byte %01111111
  .byte %00111110
  .byte %00100010
  .byte %01000001
  ; Bit plane 2 (for color)
  .byte %00000000
  .byte %00001000
  .byte %00011100
  .byte %00111110
  .byte %00111110
  .byte %00011100
  .byte %00011100
  .byte %00111110
  
  ; Tile 3 - Bullet/Plasma bolt
  .byte %00011000
  .byte %00111100
  .byte %01111110
  .byte %11111111
  .byte %11111111
  .byte %01111110
  .byte %00111100
  .byte %00011000
  ; Bit plane 2 (for color)
  .byte %00000000
  .byte %00011000
  .byte %00111100
  .byte %01111110
  .byte %01111110
  .byte %00111100
  .byte %00011000
  .byte %00000000
  
  ; Fill rest with empty tiles
  .res 8128, $00   ; 8192 - 64 bytes already used
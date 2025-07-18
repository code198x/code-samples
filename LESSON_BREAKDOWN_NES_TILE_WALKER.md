# Tile Walker (NES) - Lesson Breakdown

## Game Overview
- **System**: Nintendo Entertainment System
- **Genre**: Tile-based movement
- **Core Mechanic**: Character moves between background tiles
- **Unique Features**: Updates nametable as character moves, sprite on tile grid
- **Total Lessons**: 32

## Game Concept
8x8 sprite character moves in 16x16 tile increments across a tile-based playfield. Character snaps to tile boundaries. Collect tile-based items, avoid tile-based hazards. Pure tile-grid movement system.

## Lesson Progression

### Foundation (Lessons 1-8)

**Lesson 1: NES Setup and PPU**
- **Concepts**: PPU registers, nametables, palettes
- **Code Focus**: Initialize PPU, clear nametable
- **Outcome**: Black screen ready for tiles
- **Exercise**: Try different background colors

**Lesson 2: Pattern Tables and Tiles**
- **Concepts**: CHR-ROM, tile definitions
- **Code Focus**: Load simple character set
- **Outcome**: Tile graphics in VRAM
- **Exercise**: Design custom tiles

**Lesson 3: Draw Background Tiles**
- **Concepts**: Nametable layout, tile IDs
- **Code Focus**: Fill screen with tiles
- **Outcome**: Tiled background visible
- **Exercise**: Create patterns

**Lesson 4: Sprite Basics**
- **Concepts**: OAM memory, sprite attributes
- **Code Focus**: Display single sprite
- **Outcome**: Character sprite on screen
- **Exercise**: Change sprite appearance

**Lesson 5: Controller Input**
- **Concepts**: Controller port, button reading
- **Code Focus**: Read D-pad state
- **Outcome**: Detect player input
- **Exercise**: Add button support

**Lesson 6: Tile Position System**
- **Concepts**: Tile coordinates vs pixel coordinates
- **Code Focus**: Convert tile grid to sprite position
- **Outcome**: Sprite positioned on tile grid
- **Exercise**: Different grid sizes

**Lesson 7: Sprite Movement**
- **Concepts**: Update sprite position
- **Code Focus**: Move sprite by tile increments
- **Outcome**: Character moves in steps
- **Exercise**: Smooth vs instant movement

**Lesson 8: Movement Boundaries**
- **Concepts**: Screen limits, valid positions
- **Code Focus**: Constrain movement to playfield
- **Outcome**: Character stays on screen
- **Exercise**: Add screen wrapping

### Tile Interaction (Lessons 9-16)

**Lesson 9: Read Background Tiles**
- **Concepts**: Nametable reading, tile detection
- **Code Focus**: Get tile ID at position
- **Outcome**: Detect what tile player is on
- **Exercise**: Display current tile

**Lesson 10: Collision Tiles**
- **Concepts**: Wall tiles, movement blocking
- **Code Focus**: Check for solid tiles
- **Outcome**: Can't move through walls
- **Exercise**: Different wall types

**Lesson 11: Collectible Tiles**
- **Concepts**: Item tiles, tile replacement
- **Code Focus**: Replace tiles when collected
- **Outcome**: Items disappear when taken
- **Exercise**: Different item values

**Lesson 12: Nametable Updates**
- **Concepts**: PPU_DATA writes, timing
- **Code Focus**: Change tiles during gameplay
- **Outcome**: Dynamic tile changes
- **Exercise**: Animated tiles

**Lesson 13: Level Layout**
- **Concepts**: Level data, tile maps
- **Code Focus**: Load level from data
- **Outcome**: Designed level layouts
- **Exercise**: Create custom levels

**Lesson 14: Score System**
- **Concepts**: BCD scoring, display
- **Code Focus**: Update score display
- **Outcome**: Points for collecting
- **Exercise**: Bonus scoring

**Lesson 15: Player Lives**
- **Concepts**: Life system, hazard tiles
- **Code Focus**: Lose life on hazards
- **Outcome**: Death and respawn
- **Exercise**: Different hazard types

**Lesson 16: Level Completion**
- **Concepts**: Win conditions, progression
- **Code Focus**: Check for level complete
- **Outcome**: Advance to next level
- **Exercise**: Victory celebration

### Visual Enhancement (Lessons 17-24)

**Lesson 17: Sprite Animation**
- **Concepts**: Sprite frame switching
- **Code Focus**: Animate walking frames
- **Outcome**: Character animates
- **Exercise**: Direction-specific frames

**Lesson 18: Palette Control**
- **Concepts**: Background/sprite palettes
- **Code Focus**: Colorful tiles and sprites
- **Outcome**: Rich color schemes
- **Exercise**: Different level themes

**Lesson 19: Status Display**
- **Concepts**: HUD tiles, status bar
- **Code Focus**: Lives, score, level display
- **Outcome**: Game information visible
- **Exercise**: Custom status layout

**Lesson 20: Tile Animations**
- **Concepts**: Animated background tiles
- **Code Focus**: Cycle tile patterns
- **Outcome**: Living backgrounds
- **Exercise**: Different animation speeds

**Lesson 21: Special Effects**
- **Concepts**: Sprite flickering, hiding
- **Code Focus**: Flash effects on events
- **Outcome**: Visual feedback
- **Exercise**: Different effect types

**Lesson 22: Priority System**
- **Concepts**: Sprite vs background priority
- **Code Focus**: Sprites behind tiles
- **Outcome**: Layered graphics
- **Exercise**: Tunnel effects

**Lesson 23: Title Screen**
- **Concepts**: Graphics arrangement
- **Code Focus**: Attractive title layout
- **Outcome**: Professional presentation
- **Exercise**: Custom title art

**Lesson 24: Screen Transitions**
- **Concepts**: Fade in/out effects
- **Code Focus**: Palette manipulation
- **Outcome**: Smooth level changes
- **Exercise**: Different transition types

### Audio and Completion (Lessons 25-32)

**Lesson 25: APU Sound Basics**
- **Concepts**: Sound registers, pulse waves
- **Code Focus**: Simple beep sounds
- **Outcome**: Movement sounds
- **Exercise**: Different tones

**Lesson 26: Sound Effects**
- **Concepts**: Envelope control, effects
- **Code Focus**: Collection and collision sounds
- **Outcome**: Audio feedback
- **Exercise**: Sound effect library

**Lesson 27: Background Music**
- **Concepts**: Music engine, note sequences
- **Code Focus**: Simple tune player
- **Outcome**: Continuous music
- **Exercise**: Compose level music

**Lesson 28: Game Options**
- **Concepts**: Menu system, settings
- **Code Focus**: Difficulty and speed options
- **Outcome**: Customizable gameplay
- **Exercise**: Save preferences

**Lesson 29: High Score System**
- **Concepts**: Score persistence, SRAM
- **Code Focus**: Save and load scores
- **Outcome**: Competitive play
- **Exercise**: Name entry

**Lesson 30: Power-Up System**
- **Concepts**: Temporary abilities
- **Code Focus**: Speed boost, invincibility
- **Outcome**: Enhanced gameplay
- **Exercise**: New power-up types

**Lesson 31: Polish and Testing**
- **Concepts**: Bug fixes, optimization
- **Code Focus**: Edge case handling
- **Outcome**: Stable gameplay
- **Exercise**: Playtesting

**Lesson 32: Packaging**
- **Concepts**: ROM layout, mapper
- **Code Focus**: Final ROM assembly
- **Outcome**: Complete game
- **Exercise**: Cartridge label design

## Skills Learned
- PPU programming
- Tile-based graphics
- Sprite management
- Controller input
- APU sound programming
- Level design systems

## What Makes This Unique
- **NES Specific**: Tile-based movement system
- **Not Like C64**: No smooth pixel movement
- **Not Like Spectrum**: Pattern table graphics
- **Not Like Amiga**: Fixed tile grid

## Code Structure Overview
```assembly
; Memory layout
; $0000-$00FF: Zero page variables
; $0100-$01FF: Stack
; $0200-$02FF: OAM buffer
; $0300-$07FF: Game variables
; $8000-$FFFF: Program ROM

; Key variables (Zero page)
player_x:       .byte 8    ; Tile X position (0-31)
player_y:       .byte 8    ; Tile Y position (0-29)
sprite_x:       .byte 0    ; Sprite X pixel position
sprite_y:       .byte 0    ; Sprite Y pixel position
current_tile:   .byte 0    ; Tile player is on
score:          .word 0    ; Player score
lives:          .byte 3    ; Player lives
level:          .byte 1    ; Current level
input_bits:     .byte 0    ; Controller state
```
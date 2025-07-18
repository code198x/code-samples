# Copper Chase (Amiga) - Lesson Breakdown

## Game Overview
- **System**: Commodore Amiga
- **Genre**: Color bar movement
- **Core Mechanic**: Move color bar up/down using copper
- **Unique Features**: No sprites, pure copper list manipulation
- **Total Lessons**: 32

## Game Concept
Player controls a horizontal color bar that moves up and down the screen. The bar is created using the Amiga's copper coprocessor. Avoid other copper-generated obstacles, collect targets. Pure hardware demonstration of copper lists.

## Lesson Progression

### Foundation (Lessons 1-8)

**Lesson 1: Amiga System Setup**
- **Concepts**: Amiga memory map, custom chips
- **Code Focus**: Basic system initialization
- **Outcome**: Black screen, system ready
- **Exercise**: Change background color

**Lesson 2: Understanding Copper**
- **Concepts**: Copper coprocessor, copper lists
- **Code Focus**: Simple copper WAIT and MOVE
- **Outcome**: Single color bar on screen
- **Exercise**: Try different colors

**Lesson 3: Copper List Basics**
- **Concepts**: WAIT for position, MOVE to register
- **Code Focus**: Create static copper list
- **Outcome**: Horizontal color bar
- **Exercise**: Multiple bars

**Lesson 4: Vertical Positioning**
- **Concepts**: Raster line positions
- **Code Focus**: WAIT for specific line
- **Outcome**: Bar at chosen height
- **Exercise**: Different positions

**Lesson 5: Color Registers**
- **Concepts**: COLOR00-COLOR31 registers
- **Code Focus**: Change background color
- **Outcome**: Colorful bars
- **Exercise**: Color gradients

**Lesson 6: Keyboard Input**
- **Concepts**: CIA keyboard matrix
- **Code Focus**: Read cursor keys
- **Outcome**: Detect key presses
- **Exercise**: Multiple key detection

**Lesson 7: Dynamic Copper Lists**
- **Concepts**: Modify copper lists in real-time
- **Code Focus**: Update WAIT positions
- **Outcome**: Moving color bar
- **Exercise**: Smooth movement

**Lesson 8: Boundary Limits**
- **Concepts**: Screen limits, valid positions
- **Code Focus**: Constrain bar movement
- **Outcome**: Bar stays on screen
- **Exercise**: Screen wrapping

### Copper Programming (Lessons 9-16)

**Lesson 9: Multiple Copper Objects**
- **Concepts**: Complex copper lists
- **Code Focus**: Several bars with different colors
- **Outcome**: Multiple objects on screen
- **Exercise**: Different bar widths

**Lesson 10: Animated Copper Effects**
- **Concepts**: Cycling through copper lists
- **Code Focus**: Animate bar appearance
- **Outcome**: Pulsing color effects
- **Exercise**: Different animation patterns

**Lesson 11: Collision Detection**
- **Concepts**: Position comparison
- **Code Focus**: Check if bars overlap
- **Outcome**: Detect player hitting obstacles
- **Exercise**: Pixel-perfect collision

**Lesson 12: Score System**
- **Concepts**: Text display, font data
- **Code Focus**: Display score using blitter
- **Outcome**: Score counter visible
- **Exercise**: Different fonts

**Lesson 13: Game Objects**
- **Concepts**: Object-oriented copper
- **Code Focus**: Copper objects with behavior
- **Outcome**: Moving obstacles
- **Exercise**: Different movement patterns

**Lesson 14: Target Collection**
- **Concepts**: Special copper objects
- **Code Focus**: Collectible targets
- **Outcome**: Items to collect
- **Exercise**: Different target types

**Lesson 15: Level Progression**
- **Concepts**: Increasing difficulty
- **Code Focus**: More obstacles, faster movement
- **Outcome**: Progressive gameplay
- **Exercise**: Custom level design

**Lesson 16: Lives System**
- **Concepts**: Game state management
- **Code Focus**: Player lives, game over
- **Outcome**: Risk/reward gameplay
- **Exercise**: Different life indicators

### Visual Enhancement (Lessons 17-24)

**Lesson 17: Copper Gradients**
- **Concepts**: Color interpolation
- **Code Focus**: Smooth color transitions
- **Outcome**: Gradient backgrounds
- **Exercise**: Different gradient types

**Lesson 18: Copper Starfield**
- **Concepts**: Pseudo-random positioning
- **Code Focus**: Scattered color points
- **Outcome**: Starfield effect
- **Exercise**: Moving stars

**Lesson 19: Advanced Copper Effects**
- **Concepts**: Sine wave generation
- **Code Focus**: Wavy copper bars
- **Outcome**: Organic movement
- **Exercise**: Different wave patterns

**Lesson 20: Copper Sprites**
- **Concepts**: Sprite-like copper objects
- **Code Focus**: Shaped copper regions
- **Outcome**: Pseudo-sprites
- **Exercise**: Different shapes

**Lesson 21: Screen Transitions**
- **Concepts**: Copper-based wipes
- **Code Focus**: Level transition effects
- **Outcome**: Smooth level changes
- **Exercise**: Different transition types

**Lesson 22: Status Display**
- **Concepts**: Copper HUD elements
- **Code Focus**: Game info display
- **Outcome**: Informative interface
- **Exercise**: Custom HUD design

**Lesson 23: Title Screen**
- **Concepts**: Complex copper arrangements
- **Code Focus**: Attractive title display
- **Outcome**: Professional presentation
- **Exercise**: Animated title effects

**Lesson 24: Copper Particles**
- **Concepts**: Many small copper objects
- **Code Focus**: Particle system
- **Outcome**: Explosion effects
- **Exercise**: Different particle types

### Audio and Completion (Lessons 25-32)

**Lesson 25: Paula Audio Basics**
- **Concepts**: Audio hardware, DMA channels
- **Code Focus**: Simple tone generation
- **Outcome**: Movement sounds
- **Exercise**: Different tones

**Lesson 26: Sample Playback**
- **Concepts**: Audio samples, Paula DMA
- **Code Focus**: Sound effect samples
- **Outcome**: Rich audio feedback
- **Exercise**: Create custom samples

**Lesson 27: Paula Music**
- **Concepts**: 4-channel music
- **Code Focus**: Simple music player
- **Outcome**: Background music
- **Exercise**: Compose a tune

**Lesson 28: Game Options**
- **Concepts**: Menu system
- **Code Focus**: Difficulty and speed settings
- **Outcome**: Customizable gameplay
- **Exercise**: Save preferences

**Lesson 29: High Score System**
- **Concepts**: File I/O, disk access
- **Code Focus**: Save scores to disk
- **Outcome**: Persistent high scores
- **Exercise**: Score table display

**Lesson 30: Power-Up Effects**
- **Concepts**: Special copper modes
- **Code Focus**: Shield, speed boost effects
- **Outcome**: Enhanced gameplay
- **Exercise**: New power-up types

**Lesson 31: Performance Optimization**
- **Concepts**: Copper list efficiency
- **Code Focus**: Minimize copper usage
- **Outcome**: Smooth 50fps gameplay
- **Exercise**: Profiling tools

**Lesson 32: Packaging**
- **Concepts**: Disk creation, loading
- **Code Focus**: Final game assembly
- **Outcome**: Complete disk image
- **Exercise**: Custom loading screen

## Skills Learned
- Copper coprocessor programming
- Amiga custom chip architecture
- Paula audio system
- Hardware-based graphics
- System-level programming
- Demo scene techniques

## What Makes This Unique
- **Amiga Specific**: Pure copper coprocessor usage
- **Not Like C64**: No CPU-based graphics
- **Not Like Spectrum**: Hardware acceleration
- **Not Like NES**: No tile restrictions

## Code Structure Overview
```assembly
; Memory layout
; $000000-$07FFFF: Chip RAM
; $080000-$0FFFFF: Expansion RAM
; $C00000-$DFFFFF: Custom chips
; $F80000-$FFFFFF: Kickstart ROM

; Key variables (Chip RAM)
    section data,data_c
copper_list:        dc.l 0          ; Copper list pointer
player_pos:         dc.w 100        ; Player bar Y position
player_color:       dc.w $0F0F      ; Player bar color
obstacle_count:     dc.w 0          ; Number of obstacles
obstacle_pos:       dc.w 0,0,0,0    ; Obstacle positions
score:              dc.l 0          ; Player score
lives:              dc.w 3          ; Player lives

; Copper list structure
copper_data:
    dc.w $1001,$FFFE        ; Wait for line 16
    dc.w $0180,$0000        ; Set background to black
    dc.w $1801,$FFFE        ; Wait for line 24
    dc.w $0180,$0F00        ; Set background to red (player bar)
    dc.w $1901,$FFFE        ; Wait for line 25
    dc.w $0180,$0000        ; Set background to black
    dc.w $FFFF,$FFFE        ; End of copper list
```
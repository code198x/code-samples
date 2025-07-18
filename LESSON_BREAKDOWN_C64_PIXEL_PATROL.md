# Pixel Patrol (C64) - Lesson Breakdown

## Game Overview
- **System**: Commodore 64
- **Genre**: Grid movement
- **Core Mechanic**: Move sprite to specific grid positions
- **Unique Features**: Hardware sprite smooth movement between grid cells
- **Total Lessons**: 32

## Game Concept
A single sprite moves smoothly between grid positions (8x6 grid). Player controls movement with joystick/keys. Sprite animates during movement. Score for reaching target positions.

## Lesson Progression

### Foundation (Lessons 1-8)

**Lesson 1: C64 Setup and Display**
- **Concepts**: C64 memory map, VIC-II basics
- **Code Focus**: Clear screen, set colors, basic setup
- **Outcome**: Blue screen with white border
- **Exercise**: Try different color combinations

**Lesson 2: First Hardware Sprite**
- **Concepts**: Sprite pointers, sprite enable
- **Code Focus**: Enable sprite 0, set position
- **Outcome**: Static sprite appears
- **Exercise**: Change sprite position manually

**Lesson 3: Design a Sprite**
- **Concepts**: Sprite data format, 24x21 pixels
- **Code Focus**: Create simple character sprite
- **Outcome**: Custom sprite shape visible
- **Exercise**: Design your own sprite

**Lesson 4: Read Joystick Input**
- **Concepts**: CIA registers, joystick port
- **Code Focus**: Read joystick, display direction
- **Outcome**: Program detects joystick movement
- **Exercise**: Add keyboard alternative

**Lesson 5: Grid Position System**
- **Concepts**: Grid coordinates, position mapping
- **Code Focus**: Grid variables, position calculation
- **Outcome**: Internal grid tracking
- **Exercise**: Different grid sizes

**Lesson 6: Sprite Grid Movement**
- **Concepts**: Update sprite position from grid
- **Code Focus**: Convert grid to screen coordinates
- **Outcome**: Sprite jumps between grid positions
- **Exercise**: Adjust grid spacing

**Lesson 7: Movement Constraints**
- **Concepts**: Boundary checking, valid moves
- **Code Focus**: Limit movement to grid bounds
- **Outcome**: Sprite stays within grid
- **Exercise**: Add wrap-around option

**Lesson 8: Basic Game Loop**
- **Concepts**: Main loop structure, timing
- **Code Focus**: Game state, update cycle
- **Outcome**: Continuous play
- **Exercise**: Add frame counter

### Smooth Movement (Lessons 9-16)

**Lesson 9: Movement Animation Setup**
- **Concepts**: Animation states, interpolation
- **Code Focus**: Movement flags, target position
- **Outcome**: Framework for smooth movement
- **Exercise**: Plan movement speed

**Lesson 10: Linear Interpolation**
- **Concepts**: Smooth transitions, step calculation
- **Code Focus**: Calculate intermediate positions
- **Outcome**: Sprite moves smoothly
- **Exercise**: Try different speeds

**Lesson 11: Movement State Machine**
- **Concepts**: States (idle, moving), transitions
- **Code Focus**: State handling, input queueing
- **Outcome**: Proper movement control
- **Exercise**: Add diagonal movement

**Lesson 12: Sprite Animation Frames**
- **Concepts**: Multiple sprite definitions
- **Code Focus**: Sprite pointer switching
- **Outcome**: Sprite animates while moving
- **Exercise**: Create walk cycle

**Lesson 13: Target Positions**
- **Concepts**: Goal squares, visual feedback
- **Code Focus**: Draw target markers
- **Outcome**: Visible objectives
- **Exercise**: Animated targets

**Lesson 14: Score System**
- **Concepts**: Score display, BCD numbers
- **Code Focus**: Update and display score
- **Outcome**: Points for reaching targets
- **Exercise**: Bonus points for speed

**Lesson 15: Level Progression**
- **Concepts**: Multiple target patterns
- **Code Focus**: Level data, progression logic
- **Outcome**: Advancing difficulty
- **Exercise**: Create custom levels

**Lesson 16: Polish Movement**
- **Concepts**: Easing, acceleration
- **Code Focus**: Non-linear movement curves
- **Outcome**: Professional feel
- **Exercise**: Different easing types

### Visual Enhancement (Lessons 17-24)

**Lesson 17: Multicolor Sprite Mode**
- **Concepts**: 3-color sprites, color registers
- **Code Focus**: Enable multicolor, design sprite
- **Outcome**: Colorful character sprite
- **Exercise**: Color variations

**Lesson 18: Background Grid Display**
- **Concepts**: Character mode graphics
- **Code Focus**: Draw grid with PETSCII
- **Outcome**: Visible grid lines
- **Exercise**: Different grid styles

**Lesson 19: Color Ramp Effects**
- **Concepts**: Raster interrupts basics
- **Code Focus**: Simple raster color change
- **Outcome**: Gradient background
- **Exercise**: Multiple color bars

**Lesson 20: Sprite Shadows**
- **Concepts**: Second sprite as shadow
- **Code Focus**: Offset shadow sprite
- **Outcome**: Depth effect
- **Exercise**: Dynamic shadows

**Lesson 21: Particle Effects**
- **Concepts**: Simple sprite particles
- **Code Focus**: Movement trail sparkles
- **Outcome**: Visual feedback
- **Exercise**: Different particle types

**Lesson 22: Screen Border Design**
- **Concepts**: Border sprites, decoration
- **Code Focus**: Position border elements
- **Outcome**: Polished display
- **Exercise**: Animated borders

**Lesson 23: Title Screen**
- **Concepts**: Screen modes, text display
- **Code Focus**: Title and menu system
- **Outcome**: Professional start
- **Exercise**: Custom logo

**Lesson 24: Transition Effects**
- **Concepts**: Screen wipes, fades
- **Code Focus**: Level transition animations
- **Outcome**: Smooth level changes
- **Exercise**: Different transitions

### Audio and Polish (Lessons 25-32)

**Lesson 25: SID Chip Basics**
- **Concepts**: SID registers, waveforms
- **Code Focus**: Simple tone generation
- **Outcome**: Movement sounds
- **Exercise**: Different pitches

**Lesson 26: Sound Effects**
- **Concepts**: ADSR envelopes, effects
- **Code Focus**: Target reached sound
- **Outcome**: Audio feedback
- **Exercise**: Create new sounds

**Lesson 27: Background Music**
- **Concepts**: Simple music player
- **Code Focus**: Note sequences, timing
- **Outcome**: Continuous music
- **Exercise**: Compose a tune

**Lesson 28: Difficulty Settings**
- **Concepts**: Game options, menu system
- **Code Focus**: Variable speed, grid size
- **Outcome**: Customizable play
- **Exercise**: Save preferences

**Lesson 29: High Score Table**
- **Concepts**: Data persistence, sorting
- **Code Focus**: Score entry and display
- **Outcome**: Competitive element
- **Exercise**: Initials entry

**Lesson 30: Performance Timer**
- **Concepts**: CIA timers, precision timing
- **Code Focus**: Level completion times
- **Outcome**: Speedrun support
- **Exercise**: Best time tracking

**Lesson 31: Final Polish**
- **Concepts**: Bug fixes, optimization
- **Code Focus**: Code cleanup, comments
- **Outcome**: Release quality
- **Exercise**: Find edge cases

**Lesson 32: Loading Screen**
- **Concepts**: Koala format, loading
- **Code Focus**: Custom loading picture
- **Outcome**: Professional package
- **Exercise**: Create artwork

## Skills Learned
- Hardware sprite basics
- Smooth movement interpolation
- Grid-based game logic
- Raster effects introduction
- SID sound programming
- Professional game structure

## What Makes This Unique
- **C64 Specific**: Hardware sprites with smooth movement
- **Not Like Spectrum**: No attribute clash issues
- **Not Like NES**: Direct sprite positioning
- **Not Like Amiga**: Single sprite focus

## Code Structure Overview
```assembly
; Memory layout
; $0801-$0FFF: BASIC stub and init
; $1000-$1FFF: Main game code  
; $2000-$2FFF: Sprite data
; $3000-$3FFF: Level data
; $4000-$4FFF: Music and sound

; Key variables
grid_x:         .byte 4    ; Current grid X (0-7)
grid_y:         .byte 3    ; Current grid Y (0-5)  
target_x:       .byte 0    ; Target grid X
target_y:       .byte 0    ; Target grid Y
sprite_x:       .word 0    ; Actual sprite X
sprite_y:       .byte 0    ; Actual sprite Y
move_state:     .byte 0    ; 0=idle, 1=moving
move_progress:  .byte 0    ; Movement interpolation
```
# Cursor Quest (Spectrum) - Lesson Breakdown

## Game Overview
- **System**: ZX Spectrum
- **Genre**: Text navigation
- **Core Mechanic**: Move cursor character through text positions
- **Unique Features**: Attribute-based trail effect, character movement
- **Total Lessons**: 32

## Game Concept
Navigate a cursor character (@) through a field of text characters. Leave a colored trail using attributes. Find and reach specific letter targets. Pure character-based movement, no sprites.

## Lesson Progression

### Foundation (Lessons 1-8)

**Lesson 1: Spectrum Screen Basics**
- **Concepts**: Screen memory at 16384, attribute memory
- **Code Focus**: Clear screen, set border
- **Outcome**: Black screen with border
- **Exercise**: Try different INK/PAPER colors

**Lesson 2: Character Display**
- **Concepts**: Character codes, screen positioning
- **Code Focus**: Print single character at position
- **Outcome**: Display @ symbol
- **Exercise**: Print different characters

**Lesson 3: Calculate Screen Addresses**
- **Concepts**: Y*32+X positioning, screen layout
- **Code Focus**: Position to memory address
- **Outcome**: Place character anywhere
- **Exercise**: Draw a pattern

**Lesson 4: Keyboard Input**
- **Concepts**: IN ports, key scanning
- **Code Focus**: Read QAOP keys
- **Outcome**: Detect keypresses
- **Exercise**: Add cursor key support

**Lesson 5: Cursor Movement Logic**
- **Concepts**: Position variables, boundaries
- **Code Focus**: Update position from input
- **Outcome**: Track cursor position
- **Exercise**: Add screen wrap

**Lesson 6: Move Cursor Character**
- **Concepts**: Erase and redraw technique
- **Code Focus**: Clear old, draw new position
- **Outcome**: Moving @ symbol
- **Exercise**: Prevent flicker

**Lesson 7: Boundary Checking**
- **Concepts**: Screen limits (0-31, 0-23)
- **Code Focus**: Constrain movement
- **Outcome**: Cursor stays on screen
- **Exercise**: Add wall boundaries

**Lesson 8: Game State Structure**
- **Concepts**: Game loop, state tracking
- **Code Focus**: Main loop with input/update
- **Outcome**: Continuous gameplay
- **Exercise**: Add pause function

### Attribute Effects (Lessons 9-16)

**Lesson 9: Understanding Attributes**
- **Concepts**: Attribute bytes, INK/PAPER/BRIGHT
- **Code Focus**: Set attribute for position
- **Outcome**: Colored cursor
- **Exercise**: Rainbow cursor

**Lesson 10: Trail Effect Setup**
- **Concepts**: Remember previous positions
- **Code Focus**: Position history array
- **Outcome**: Track cursor path
- **Exercise**: Variable trail length

**Lesson 11: Draw Color Trail**
- **Concepts**: Set attributes without changing chars
- **Code Focus**: Color previous positions
- **Outcome**: Colored trail behind cursor
- **Exercise**: Gradient trail

**Lesson 12: Fading Trail**
- **Concepts**: Time-based color changes
- **Code Focus**: Cycle trail colors over time
- **Outcome**: Trail fades away
- **Exercise**: Different fade speeds

**Lesson 13: Target Letters**
- **Concepts**: Random positioning, target display
- **Code Focus**: Place letter targets
- **Outcome**: Letters to collect
- **Exercise**: Multiple targets

**Lesson 14: Collision Detection**
- **Concepts**: Character comparison
- **Code Focus**: Check cursor meets target
- **Outcome**: Detect collection
- **Exercise**: Sound on collect

**Lesson 15: Score Display**
- **Concepts**: Print numbers, screen zones
- **Code Focus**: Score area and update
- **Outcome**: Points for letters
- **Exercise**: Combo scoring

**Lesson 16: Level Progression**
- **Concepts**: Increasing difficulty
- **Code Focus**: More targets, patterns
- **Outcome**: Progressive gameplay
- **Exercise**: Time limits

### Visual Polish (Lessons 17-24)

**Lesson 17: Border Effects**
- **Concepts**: OUT to port 254
- **Code Focus**: Flash border on events
- **Outcome**: Visual feedback
- **Exercise**: Color patterns

**Lesson 18: Character Animation**
- **Concepts**: Cycle through characters
- **Code Focus**: Animate cursor symbol
- **Outcome**: Spinning cursor
- **Exercise**: Custom animations

**Lesson 19: Maze Generation**
- **Concepts**: Wall characters, level layout
- **Code Focus**: Draw maze walls
- **Outcome**: Navigate around obstacles
- **Exercise**: Random mazes

**Lesson 20: Special Zones**
- **Concepts**: Area attributes
- **Code Focus**: Color coded zones
- **Outcome**: Visual variety
- **Exercise**: Zone effects

**Lesson 21: Particle Characters**
- **Concepts**: Background animation
- **Code Focus**: Moving star field
- **Outcome**: Living background
- **Exercise**: Different patterns

**Lesson 22: Status Display**
- **Concepts**: Screen layout design
- **Code Focus**: Lives, time, level display
- **Outcome**: Full game HUD
- **Exercise**: Custom fonts

**Lesson 23: Title Screen Design**
- **Concepts**: ASCII art, menu system
- **Code Focus**: Attractive title display
- **Outcome**: Professional start
- **Exercise**: Animated title

**Lesson 24: Transition Effects**
- **Concepts**: Attribute wipes
- **Code Focus**: Screen transitions
- **Outcome**: Level transitions
- **Exercise**: Custom effects

### Audio and Completion (Lessons 25-32)

**Lesson 25: Beeper Basics**
- **Concepts**: OUT 254, bit 4 speaker
- **Code Focus**: Simple beep routine
- **Outcome**: Movement sounds
- **Exercise**: Different tones

**Lesson 26: Sound Effects**
- **Concepts**: Frequency and duration
- **Code Focus**: Collection sounds
- **Outcome**: Audio feedback
- **Exercise**: Sound library

**Lesson 27: Beeper Music**
- **Concepts**: Note tables, timing
- **Code Focus**: Simple tune player
- **Outcome**: Background music
- **Exercise**: Compose melody

**Lesson 28: Difficulty Options**
- **Concepts**: Game settings
- **Code Focus**: Speed, trail options
- **Outcome**: Customizable game
- **Exercise**: Save settings

**Lesson 29: High Score Entry**
- **Concepts**: Text input, sorting
- **Code Focus**: Name entry system
- **Outcome**: Competitive play
- **Exercise**: Score table

**Lesson 30: Power-Ups**
- **Concepts**: Special characters
- **Code Focus**: Speed boost, trail modes
- **Outcome**: Enhanced gameplay
- **Exercise**: New power-ups

**Lesson 31: Polish and Debug**
- **Concepts**: Edge cases, optimization
- **Code Focus**: Bug fixes, cleanup
- **Outcome**: Stable game
- **Exercise**: Beta testing

**Lesson 32: Loading Screen**
- **Concepts**: SCREEN$ format
- **Code Focus**: Custom loader
- **Outcome**: Professional look
- **Exercise**: Design screen

## Skills Learned
- Character-based graphics
- Attribute manipulation
- Keyboard input handling
- Screen memory layout
- Beeper sound programming
- Text mode game design

## What Makes This Unique
- **Spectrum Specific**: Attribute-based effects
- **Not Like C64**: No sprites, pure characters
- **Not Like NES**: Direct screen memory access
- **Not Like Amiga**: Text mode focus

## Code Structure Overview
```assembly
; Memory map
; 16384-22527: Screen display
; 22528-23295: Attributes
; 23296-23551: System variables  
; 25000+: Our game code

; Key variables
        org 25000
cursor_x:       defb 15    ; X position (0-31)
cursor_y:       defb 12    ; Y position (0-23)
old_x:          defb 0     ; Previous X
old_y:          defb 0     ; Previous Y
trail_len:      defb 5     ; Trail length
trail_x:        defs 20    ; Trail X positions
trail_y:        defs 20    ; Trail Y positions
score:          defw 0     ; Player score
target_x:       defb 0     ; Target letter X
target_y:       defb 0     ; Target letter Y
target_char:    defb 65    ; Target character (A)
```
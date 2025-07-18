# Quantum Shatter - Lesson Breakdown

## Game Overview
- **System**: ZX Spectrum
- **Genre**: Breakout/Paddle game
- **Unique Features**: Power-ups, multi-ball, special bricks, attribute effects
- **Total Lessons**: 64 (2 tiers)

## Core Mechanics (Not Space Shooter!)
- Paddle moves left/right only
- Ball bounces off paddle, walls, and bricks
- Bricks disappear when hit
- Power-ups fall when special bricks are hit
- Lives system (lose life when ball goes off bottom)
- Score increases for each brick

## Lesson Progression

### Tier 1: Basic Breakout (Lessons 1-32)

#### Foundation (Lessons 1-8)

**Lesson 1: Spectrum Setup**
- **Concepts**: Spectrum memory map, display file structure
- **Code Focus**: Clear screen, set border, basic setup
- **Outcome**: Black screen with colored border
- **Exercise**: Change border colors

**Lesson 2: Draw the Paddle**
- **Concepts**: Character-based graphics, screen positioning
- **Code Focus**: Paddle data, position calculation, draw routine
- **Outcome**: Static paddle at bottom of screen
- **Exercise**: Change paddle size and appearance

**Lesson 3: Paddle Movement**
- **Concepts**: Keyboard input (O/P keys), boundary checking
- **Code Focus**: Read keys, update position, redraw
- **Outcome**: Paddle moves left/right with keys
- **Exercise**: Add Q/A as alternative controls

**Lesson 4: Add the Ball**
- **Concepts**: Ball position (X,Y), sprite representation
- **Code Focus**: Ball variables, draw routine
- **Outcome**: Static ball appears on screen
- **Exercise**: Make ball start at different positions

**Lesson 5: Ball Movement**
- **Concepts**: Velocity (DX,DY), frame timing
- **Code Focus**: Update ball position, animation loop
- **Outcome**: Ball moves diagonally
- **Exercise**: Try different speeds

**Lesson 6: Wall Bouncing**
- **Concepts**: Collision detection, velocity reversal
- **Code Focus**: Check boundaries, reverse DX/DY
- **Outcome**: Ball bounces off walls
- **Exercise**: Add sound on bounce

**Lesson 7: Paddle Collision**
- **Concepts**: Paddle-ball collision, angle calculation
- **Code Focus**: Collision check, bounce angle based on hit position
- **Outcome**: Ball bounces off paddle
- **Exercise**: Make center hits bounce straight up

**Lesson 8: Lives System**
- **Concepts**: Game state, lives counter
- **Code Focus**: Detect ball off bottom, decrement lives, reset ball
- **Outcome**: Lose lives when missing ball
- **Exercise**: Add game over screen

#### Brick System (Lessons 9-16)

**Lesson 9: Brick Data Structure**
- **Concepts**: 2D array for brick field, memory organization
- **Code Focus**: Define brick array, initialize pattern
- **Outcome**: Brick data in memory
- **Exercise**: Create different patterns

**Lesson 10: Drawing Bricks**
- **Concepts**: Nested loops, attribute colors
- **Code Focus**: Loop through array, draw each brick
- **Outcome**: Colorful brick field appears
- **Exercise**: Use different characters for bricks

**Lesson 11: Brick Collision Detection**
- **Concepts**: Ball-to-brick position mapping
- **Code Focus**: Calculate which brick was hit
- **Outcome**: Detect which brick ball hits
- **Exercise**: Flash brick on hit

**Lesson 12: Brick Removal**
- **Concepts**: Array updates, screen clearing
- **Code Focus**: Remove brick from array and screen
- **Outcome**: Bricks disappear when hit
- **Exercise**: Add brick hit sound

**Lesson 13: Scoring System**
- **Concepts**: Score display, BCD arithmetic
- **Code Focus**: Update score, display routine
- **Outcome**: Score increases as bricks break
- **Exercise**: Different brick values

**Lesson 14: Level Completion**
- **Concepts**: Win condition, brick counting
- **Code Focus**: Check for all bricks gone
- **Outcome**: Level complete detection
- **Exercise**: Add victory sound

**Lesson 15: Multiple Levels**
- **Concepts**: Level data, progression
- **Code Focus**: Level array, loading next level
- **Outcome**: Progress through levels
- **Exercise**: Create custom level

**Lesson 16: Ball Speed Increase**
- **Concepts**: Difficulty progression
- **Code Focus**: Increase speed per level
- **Outcome**: Game gets harder
- **Exercise**: Add speed display

#### Polish & Features (Lessons 17-32)

**Lesson 17-24: Visual Effects**
- Attribute effects for impacts
- Paddle animation
- Ball trail effect
- Brick break particles
- Screen flash on life loss
- Border effects
- Smooth movement
- Title screen

**Lesson 25-32: Audio & Gameplay**
- Beeper music
- Sound effects
- High score table
- Pause function
- Options menu
- Keyboard customization
- Speed settings
- Polish and optimization

### Tier 2: Advanced Features (Lessons 33-64)

#### Power-Up System (Lessons 33-40)

**Lesson 33: Power-Up Design**
- Types of power-ups
- Fall mechanics
- Collection detection

**Lesson 34: Expand Paddle**
- Make paddle wider
- Visual feedback
- Duration timer

**Lesson 35: Slow Ball**
- Reduce ball speed
- Visual indicator
- Temporary effect

**Lesson 36: Multi-Ball**
- Spawn extra balls
- Track multiple balls
- Chaos management

**Lesson 37: Laser Paddle**
- Shoot upward
- Destroy bricks directly
- Limited shots

**Lesson 38: Catch Mode**
- Ball sticks to paddle
- Manual release
- Strategic play

**Lesson 39: Power-Up Combinations**
- Multiple active powers
- Interaction effects
- Visual indicators

**Lesson 40: Special Bricks**
- Unbreakable bricks
- Multi-hit bricks
- Power-up bricks

#### Advanced Mechanics (Lessons 41-56)

**Lessons 41-48: Enhanced Physics**
- Spin effects
- Variable bounce angles
- Acceleration zones
- Gravity wells
- Moving bricks
- Brick patterns
- Boss bricks
- Environmental hazards

**Lessons 49-56: Game Modes**
- Time attack mode
- Endless mode
- Puzzle mode
- Two-player mode
- Challenge levels
- Achievement system
- Statistics tracking
- Replay system

#### Final Polish (Lessons 57-64)

**Lessons 57-64: Professional Quality**
- Interrupt-driven timing
- Optimized rendering
- Memory management
- Loading screen
- Credits sequence
- Easter eggs
- Bug fixes
- Final optimization

## Skill Progression
- Lessons 1-8: Basic Spectrum programming
- Lessons 9-16: Game logic and data structures
- Lessons 17-24: Visual and audio polish
- Lessons 25-32: User interface and options
- Lessons 33-40: Complex game systems
- Lessons 41-48: Advanced mechanics
- Lessons 49-56: Multiple game modes
- Lessons 57-64: Professional techniques

## Platform-Specific Techniques
- **Attribute system**: Lessons 10, 17-19
- **Beeper sound**: Lessons 6, 12, 25-26
- **Memory banking (128K)**: Lesson 41
- **Interrupt handling**: Lesson 57
- **Border effects**: Lesson 21
- **Color clash management**: Throughout

## What Makes This NOT a Space Shooter
- ❌ No shooting upward
- ❌ No enemy ships
- ❌ No scrolling
- ✅ Paddle moves horizontally only
- ✅ Ball physics
- ✅ Brick breaking
- ✅ Power-ups fall down
- ✅ Lives lost when ball drops

## Code Structure Plan
```
; Memory Map
; 16384-22527: Screen display
; 22528-23295: Attributes  
; 23296-23551: System variables
; 23552+: Our game code

; Main Variables
paddle_x:       defb 12  ; paddle position
ball_x:         defb 16  ; ball x position
ball_y:         defb 20  ; ball y position
ball_dx:        defb 1   ; ball x velocity
ball_dy:        defb -1  ; ball y velocity
lives:          defb 3   ; player lives
score:          defw 0   ; player score
brick_array:    defs 8*14 ; 8 rows, 14 columns
```

## Verification Checklist
- ✅ Pure breakout mechanics
- ✅ No space theme required
- ✅ Spectrum-specific features used
- ✅ Different from C64 implementation
- ✅ Progressive difficulty
- ✅ 64 lessons mapped out
- ✅ Each lesson builds on previous
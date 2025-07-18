# Phase 1 Game Designs - All Systems

## Overview
16 games per system, 32 lessons each, teaching one core mechanic per game. Each game in the same slot across systems has a different genre.

---

## Game Slot 1: Basic Movement

### C64: "Pixel Patrol"
- **Genre**: Grid movement
- **Mechanic**: Move sprite to specific grid positions
- **Unique**: Hardware sprite smooth movement between grid cells
- **Visual**: Single multicolor sprite on black background
- **NOT**: Free movement, scrolling

### Spectrum: "Cursor Quest"
- **Genre**: Text navigation
- **Mechanic**: Move cursor character through text positions
- **Unique**: Attribute-based trail effect
- **Visual**: Character movement with color attributes
- **NOT**: Sprite-based, smooth movement

### NES: "Tile Walker"
- **Genre**: Tile-based movement
- **Mechanic**: Character moves between background tiles
- **Unique**: Updates nametable as character moves
- **Visual**: 8x8 sprite on tile-based grid
- **NOT**: Pixel-perfect movement

### Amiga: "Copper Chase"
- **Genre**: Color bar movement
- **Mechanic**: Move color bar up/down using copper
- **Unique**: No sprites, pure copper list manipulation
- **Visual**: Gradient bar controlled by player
- **NOT**: Sprite or character based

---

## Game Slot 2: Collection

### C64: "Dot Gather"
- **Genre**: Static collection
- **Mechanic**: Collect stationary dots
- **Unique**: Sprite-to-sprite collision detection
- **Visual**: Multiple single-color sprites
- **NOT**: Moving targets, enemies

### Spectrum: "Symbol Search"
- **Genre**: Pattern finding
- **Mechanic**: Find and collect specific characters
- **Unique**: Full screen character search
- **Visual**: Various ASCII symbols to find
- **NOT**: Movement challenge, time pressure

### NES: "Coin Corners"
- **Genre**: Platform collection
- **Mechanic**: Jump to collect items on platforms
- **Unique**: Basic gravity and platform collision
- **Visual**: Collectible sprites on tile platforms
- **NOT**: Enemies, complex physics

### Amiga: "Bit Harvest"
- **Genre**: Mouse collection
- **Mechanic**: Click to collect with mouse pointer
- **Unique**: Hardware mouse cursor
- **Visual**: Blitter objects to click
- **NOT**: Joystick control, movement challenge

---

## Game Slot 3: Avoidance

### C64: "Meteor Dodge"
- **Genre**: Vertical dodging
- **Mechanic**: Avoid falling objects
- **Unique**: Smooth sprite movement left/right
- **Visual**: Ship sprite, falling rock sprites
- **NOT**: Shooting, collection

### Spectrum: "Wall Weaver"
- **Genre**: Maze navigation
- **Mechanic**: Navigate through narrow passages
- **Unique**: Character-based maze with dead ends
- **Visual**: Attribute-colored walls
- **NOT**: Enemies, scrolling

### NES: "Spike Jumper"
- **Genre**: Platform avoidance
- **Mechanic**: Jump over floor hazards
- **Unique**: Pattern-based hazard timing
- **Visual**: Animated spike tiles
- **NOT**: Collectibles, combat

### Amiga: "Wave Rider"
- **Genre**: Sine wave navigation
- **Mechanic**: Follow a moving sine wave path
- **Unique**: Copper-generated wave pattern
- **Visual**: Dynamic copper background effect
- **NOT**: Discrete obstacles, platforms

---

## Game Slot 4: Timing

### C64: "Beat Box"
- **Genre**: Rhythm action
- **Mechanic**: Press button on musical beats
- **Unique**: SID music synchronization
- **Visual**: Color flash on beat using sprites
- **NOT**: Movement, spatial challenge

### Spectrum: "Flash Match"
- **Genre**: Memory timing
- **Mechanic**: Repeat flashing color sequences
- **Unique**: BRIGHT attribute flashing
- **Visual**: Flashing colored blocks
- **NOT**: Music-based, movement

### NES: "Switch Sprint"
- **Genre**: Speed switching
- **Mechanic**: Toggle switches before timer expires
- **Unique**: Tile palette swapping for switches
- **Visual**: On/off switch tiles
- **NOT**: Rhythm-based, pattern memory

### Amiga: "Pulse Rider"
- **Genre**: Waveform matching
- **Mechanic**: Match oscilloscope-style waves
- **Unique**: Real-time waveform drawing
- **Visual**: Copper-drawn waveforms
- **NOT**: Discrete timing events

---

## Game Slot 5: Projectiles

### C64: "Orb Launcher"
- **Genre**: Trajectory aiming
- **Mechanic**: Launch orbs at targets
- **Unique**: Parabolic sprite movement
- **Visual**: Animated orb sprite with trail
- **NOT**: Direct shooting, enemies

### Spectrum: "Arrow Path"
- **Genre**: Turn-based shooting
- **Mechanic**: Calculate arrow paths on grid
- **Unique**: Character-based trajectory display
- **Visual**: ASCII arrows showing path
- **NOT**: Real-time action, moving targets

### NES: "Bubble Pop"
- **Genre**: Upward shooting
- **Mechanic**: Shoot bubbles that float up
- **Unique**: Sprite animation and float physics
- **Visual**: Animated bubble sprites
- **NOT**: Horizontal shooting, gravity

### Amiga: "Beam Trace"
- **Genre**: Laser reflection
- **Mechanic**: Reflect beams off mirrors
- **Unique**: Line drawing with blitter
- **Visual**: Real-time beam calculation
- **NOT**: Projectile sprites, physics

---

## Game Slot 6: Pattern Matching

### C64: "Color Code"
- **Genre**: Color sequence matching
- **Mechanic**: Match color patterns
- **Unique**: Multicolor sprite patterns
- **Visual**: Colorful sprite combinations
- **NOT**: Spatial puzzles, timing

### Spectrum: "Grid Logic"
- **Genre**: Spatial pattern completion
- **Mechanic**: Complete grid patterns
- **Unique**: Attribute-based pattern rules
- **Visual**: Colored grid squares
- **NOT**: Moving pieces, time pressure

### NES: "Tile Twins"
- **Genre**: Memory matching
- **Mechanic**: Find matching tile pairs
- **Unique**: CHR bank switching for reveals
- **Visual**: Flipping tile animations
- **NOT**: Pattern sequences, color matching

### Amiga: "Gradient Match"
- **Genre**: Color gradient puzzles
- **Mechanic**: Arrange gradient strips
- **Unique**: Copper gradient generation
- **Visual**: Smooth color transitions
- **NOT**: Discrete colors, tile-based

---

## Game Slot 7: Simple Physics

### C64: "Gravity Well"
- **Genre**: Orbital mechanics
- **Mechanic**: Navigate gravity fields
- **Unique**: Sprite acceleration vectors
- **Visual**: Ship sprite with particle trail
- **NOT**: Platform physics, collision

### Spectrum: "Block Drop"
- **Genre**: Stacking physics
- **Mechanic**: Stack falling blocks
- **Unique**: Character-based stacking rules
- **Visual**: ASCII block characters
- **NOT**: Rotation, complex shapes

### NES: "Spring Board"
- **Genre**: Bounce physics
- **Mechanic**: Bounce to reach platforms
- **Unique**: Variable jump heights
- **Visual**: Squash/stretch sprite animation
- **NOT**: Projectile physics, gravity wells

### Amiga: "Pendulum Path"
- **Genre**: Swing mechanics
- **Mechanic**: Swing on pendulums
- **Unique**: Sine/cosine calculations
- **Visual**: Smooth pendulum animation
- **NOT**: Platform physics, bouncing

---

## Game Slot 8: Resource Management

### C64: "Energy Grid"
- **Genre**: Power distribution
- **Mechanic**: Route power through grid
- **Unique**: Character set for circuit pieces
- **Visual**: Custom character set circuits
- **NOT**: Real-time action, combat

### Spectrum: "Tank Fill"
- **Genre**: Container filling
- **Mechanic**: Fill containers optimally
- **Unique**: Character-based liquid levels
- **Visual**: ASCII gauge displays
- **NOT**: Physics simulation, movement

### NES: "Garden Grow"
- **Genre**: Growth management
- **Mechanic**: Water plants to grow
- **Unique**: Tile animation for growth
- **Visual**: Animated plant tiles
- **NOT**: Combat, time pressure

### Amiga: "Data Stream"
- **Genre**: Bandwidth allocation
- **Mechanic**: Route data streams
- **Unique**: Scrolling copper bars
- **Visual**: Moving gradient streams
- **NOT**: Discrete resources, turn-based

---

## Game Slot 9: Simple AI

### C64: "Ghost Chase"
- **Genre**: Pursuit AI
- **Mechanic**: Evade pursuing enemy
- **Unique**: Simple sprite chase logic
- **Visual**: Ghost sprite follows player
- **NOT**: Multiple enemies, combat

### Spectrum: "Guard Patrol"
- **Genre**: Pattern AI
- **Mechanic**: Avoid patrolling guards
- **Unique**: Predictable movement patterns
- **Visual**: Character-based guard symbols
- **NOT**: Dynamic AI, pursuit

### NES: "Pet Trainer"
- **Genre**: Following AI
- **Mechanic**: Lead pet through maze
- **Unique**: Sprite follows with delay
- **Visual**: Cute pet sprite animation
- **NOT**: Enemy AI, aggression

### Amiga: "Flock Flow"
- **Genre**: Swarm behavior
- **Mechanic**: Guide flocking objects
- **Unique**: Multiple blitter objects
- **Visual**: Smooth swarm movement
- **NOT**: Individual AI, pathfinding

---

## Game Slot 10: Transformation

### C64: "Shape Shift"
- **Genre**: Form changing
- **Mechanic**: Change shape to fit gaps
- **Unique**: Sprite definition swapping
- **Visual**: Morphing sprite shapes
- **NOT**: Color changes only, power-ups

### Spectrum: "Phase Walk"
- **Genre**: State toggling
- **Mechanic**: Phase between solid/ghost
- **Unique**: Attribute flashing for phase
- **Visual**: BRIGHT toggle for phasing
- **NOT**: Shape changes, size changes

### NES: "Element Switch"
- **Genre**: Property swapping
- **Mechanic**: Switch between elements
- **Unique**: Palette swapping effects
- **Visual**: Same sprite, different colors
- **NOT**: Shape morphing, size changes

### Amiga: "Wave Transform"
- **Genre**: Waveform modulation
- **Mechanic**: Transform wave properties
- **Unique**: Real-time copper updates
- **Visual**: Dynamic waveform shapes
- **NOT**: Sprite-based, discrete states

---

## Game Slot 11: Territory Control

### C64: "Zone Defense"
- **Genre**: Area protection
- **Mechanic**: Defend bordered zones
- **Unique**: Character-based borders
- **Visual**: Custom charset zones
- **NOT**: Unit combat, resource gathering

### Spectrum: "Color Claim"
- **Genre**: Area painting
- **Mechanic**: Paint areas your color
- **Unique**: Attribute-based claiming
- **Visual**: Color spread mechanics
- **NOT**: Combat, unit control

### NES: "Tile Take"
- **Genre**: Territory flipping
- **Mechanic**: Convert tiles to your type
- **Unique**: Background tile updates
- **Visual**: Tile pattern changes
- **NOT**: Unit movement, borders

### Amiga: "Sector Sweep"
- **Genre**: Radar territory
- **Mechanic**: Sweep areas with radar
- **Unique**: Copper beam sweep effect
- **Visual**: Radial gradient sweeps
- **NOT**: Grid-based, units

---

## Game Slot 12: Combo Mechanics

### C64: "Chain Spark"
- **Genre**: Chain reactions
- **Mechanic**: Create sprite chain reactions
- **Unique**: Sprite spawning chains
- **Visual**: Explosion sprite chains
- **NOT**: Puzzle solving, turn-based

### Spectrum: "Link Letters"
- **Genre**: Word chains
- **Mechanic**: Connect letter sequences
- **Unique**: Character-based word paths
- **Visual**: ASCII letter grids
- **NOT**: Action-based, real-time

### NES: "Combo Colors"
- **Genre**: Color combinations
- **Mechanic**: Combine colors for effects
- **Unique**: Palette manipulation
- **Visual**: Color mixing results
- **NOT**: Shape matching, positioning

### Amiga: "Wave Harmony"
- **Genre**: Frequency combining
- **Mechanic**: Combine wave frequencies
- **Unique**: Audio/visual synthesis
- **Visual**: Waveform interference
- **NOT**: Discrete combinations

---

## Game Slot 13: Navigation Challenge

### C64: "Sprite Maze"
- **Genre**: Scrolling maze
- **Mechanic**: Navigate large maze
- **Unique**: Screen-by-screen scrolling
- **Visual**: Sprite in character maze
- **NOT**: Smooth scrolling, enemies

### Spectrum: "Path Finder"
- **Genre**: Route planning
- **Mechanic**: Find optimal path
- **Unique**: Full-screen path visibility
- **Visual**: Character-based paths
- **NOT**: Real-time movement, scrolling

### NES: "Platform Path"
- **Genre**: Platforming routes
- **Mechanic**: Find platform sequences
- **Unique**: Multi-screen platforming
- **Visual**: Varied platform tiles
- **NOT**: Enemies, time limits

### Amiga: "Vector Voyage"
- **Genre**: 3D navigation
- **Mechanic**: Navigate 3D wireframe
- **Unique**: Line-drawn 3D maze
- **Visual**: Vector graphics
- **NOT**: 2D maze, tile-based

---

## Game Slot 14: Defensive Play

### C64: "Shield Zone"
- **Genre**: Barrier defense
- **Mechanic**: Position shields
- **Unique**: Sprite collision blocking
- **Visual**: Shield sprites block shots
- **NOT**: Offensive play, movement

### Spectrum: "Wall Builder"
- **Genre**: Construction defense
- **Mechanic**: Build defensive walls
- **Unique**: Character placement strategy
- **Visual**: ASCII wall characters
- **NOT**: Direct combat, units

### NES: "Tower Block"
- **Genre**: Vertical defense
- **Mechanic**: Block falling threats
- **Unique**: Tile-based barriers
- **Visual**: Animated barrier tiles
- **NOT**: Shooting, horizontal play

### Amiga: "Wave Shield"
- **Genre**: Frequency blocking
- **Mechanic**: Generate counter-waves
- **Unique**: Waveform cancellation
- **Visual**: Interfering wave patterns
- **NOT**: Physical shields, sprites

---

## Game Slot 15: Speed Challenge

### C64: "Velocity Run"
- **Genre**: Speed collection
- **Mechanic**: Collect items quickly
- **Unique**: Sprite speed increases
- **Visual**: Motion blur effects
- **NOT**: Racing, obstacles

### Spectrum: "Quick Keys"
- **Genre**: Typing speed
- **Mechanic**: Type sequences fast
- **Unique**: Keyboard input focus
- **Visual**: Character prompts
- **NOT**: Movement speed, racing

### NES: "Dash Dots"
- **Genre**: Speed navigation
- **Mechanic**: Hit checkpoints fast
- **Unique**: Timer pressure
- **Visual**: Checkpoint animations
- **NOT**: Racing opponents, combat

### Amiga: "Scan Speed"
- **Genre**: Visual scanning
- **Mechanic**: Find targets quickly
- **Unique**: Full screen search
- **Visual**: Blitter object hiding
- **NOT**: Movement speed, racing

---

## Game Slot 16: Final Challenge

### C64: "Sprite Symphony"
- **Genre**: Multi-mechanic combo
- **Mechanic**: Combine 3 previous mechanics
- **Unique**: Sprites + sound + raster
- **Visual**: Full demo of C64 basics
- **NOT**: New mechanics, complex game

### Spectrum: "Spectrum Showcase"
- **Genre**: Attribute showcase
- **Mechanic**: Use all color effects
- **Unique**: Every attribute trick
- **Visual**: Full color demonstration
- **NOT**: Complex gameplay, scrolling

### NES: "Tile Master"
- **Genre**: Tile manipulation
- **Mechanic**: All tile techniques
- **Unique**: CHR switching demo
- **Visual**: Dynamic tile updates
- **NOT**: Advanced scrolling, sprites

### Amiga: "Copper Crown"
- **Genre**: Effects showcase
- **Mechanic**: Copper mastery demo
- **Unique**: Multiple copper effects
- **Visual**: Gradient/wave combo
- **NOT**: Game complexity, sprites

---

## Verification Notes

- Each slot has 4 different genres across systems
- Each game teaches exactly ONE core mechanic
- No clones of existing games
- All names are original and non-derivative
- Each showcases system-specific features
- Complexity appropriate for 32 lessons
- Clear learning progression within each system
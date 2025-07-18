# Game Uniqueness Verification Template

## Purpose
Ensure each game implementation is unique and platform-appropriate, preventing the template replication disaster.

## Phase 1 Tier 1 Comparison: Breakout Games

### C64: "Paddle Power"
- **Graphics**: Sprite-based paddle and ball
- **Colors**: Multi-color sprites, colorful bricks
- **Sound**: SID chip music and effects
- **Controls**: Joystick or keyboard
- **Special**: Smooth sprite movement, raster effects
- **Power-ups**: Speed changes, multi-ball
- **Code Style**: Sprite multiplexing focus

### ZX Spectrum: "Quantum Shatter"  
- **Graphics**: Character-based paddle and ball
- **Colors**: Attribute-based, careful clash management
- **Sound**: Beeper effects and music
- **Controls**: Keyboard only (O/P, Q/A)
- **Special**: Attribute effects on impact
- **Power-ups**: Paddle size, laser mode
- **Code Style**: Attribute manipulation focus

### NES: "Block Buster"
- **Graphics**: Tile-based paddle, sprite ball
- **Colors**: 4-color sprites, detailed brick tiles
- **Sound**: 5-channel music and effects
- **Controls**: D-pad precise control
- **Special**: Smooth scrolling bonus rooms
- **Power-ups**: Power pellets, shields
- **Code Style**: PPU and sprite priority focus

### Amiga: "Copper Break"
- **Graphics**: Blitter objects, copper backgrounds
- **Colors**: 32 colors, gradient effects
- **Sound**: 4-channel MOD music, samples
- **Controls**: Mouse or joystick
- **Special**: Copper sky effects, parallax
- **Power-ups**: Gravity wells, magnetism
- **Code Style**: Hardware features focus

## Key Differences Enforced

### Graphics Implementation
- **C64**: Hardware sprites (24x21 pixels)
- **Spectrum**: Character graphics (8x8)
- **NES**: Pattern table tiles + sprites
- **Amiga**: Blitter objects (any size)

### Color Usage
- **C64**: Per-sprite colors, no clash
- **Spectrum**: Per-character attributes, clash
- **NES**: Per-tile palettes
- **Amiga**: Per-pixel from palette

### Sound Approach
- **C64**: SID synthesis
- **Spectrum**: 1-bit beeper (or AY)
- **NES**: APU channels
- **Amiga**: Sample playback

### Memory Layout
- **C64**: $0801-$9FFF BASIC, $C000+ free
- **Spectrum**: $4000-$5AFF display, $8000+ free
- **NES**: PRG-ROM + CHR-ROM banks
- **Amiga**: Chip RAM vs Fast RAM

## Implementation Verification Checklist

### Before Starting:
- [ ] Review platform hardware capabilities
- [ ] Check memory map differences
- [ ] Plan platform-specific features
- [ ] Ensure different code structure

### Variable Names Must Differ:
```
; BAD - Same across platforms
player_x: defb 0
player_y: defb 0

; GOOD - Platform specific
; C64:
sprite_x_pos: .byte 0
sprite_y_pos: .byte 0

; Spectrum:  
paddle_char_x: defb 0
ball_pixel_y: defb 0

; NES:
paddle_tile_x: .byte 0
ball_sprite_y: .byte 0

; Amiga:
paddle_bob_x: dc.w 0
ball_object_y: dc.w 0
```

### Code Structure Must Differ:

#### C64 Approach:
```
; Interrupt-driven sprite multiplexer
; Raster effects for colors
; SID player integrated
```

#### Spectrum Approach:
```
; Frame-based updates
; Attribute management
; Beeper routines inline
```

#### NES Approach:
```
; NMI-based updates
; PPU register management
; APU sound queue
```

#### Amiga Approach:
```
; Copper list setup
; Blitter queues
; Audio DMA channels
```

## Genre-Specific Verification

### For Breakout Games:
- ✅ Paddle moves horizontally only
- ✅ Ball bounces (physics)
- ✅ Bricks break on impact
- ✅ No shooting mechanics
- ✅ No enemy entities
- ❌ No scrolling
- ❌ No free movement

### For Space Shooters:
- ✅ Ship can shoot projectiles
- ✅ Enemies appear and move
- ✅ Scrolling (optional)
- ✅ Power-up weapons
- ❌ No paddle mechanics
- ❌ No brick breaking
- ❌ No bouncing ball

### For Platformers:
- ✅ Jump mechanics
- ✅ Gravity simulation  
- ✅ Platform collision
- ✅ Horizontal scrolling
- ❌ No space shooting
- ❌ No paddle/ball
- ❌ No top-down view

### For Racing Games:
- ✅ Vehicle movement
- ✅ Track/road display
- ✅ Speed mechanics
- ✅ Opponent AI
- ❌ No shooting
- ❌ No platforms
- ❌ No puzzle elements

## Common Mistakes to Avoid

### 1. Template Copying
```
; WRONG - C64 code copied to Spectrum
lda sprite_x
sta $d000

; RIGHT - Platform appropriate
ld a,(paddle_char_x)
call draw_paddle_char
```

### 2. Wrong Genre Elements
```
; WRONG - Shooting in breakout
call fire_laser_up

; RIGHT - Breakout mechanics
call check_ball_brick_collision
```

### 3. Ignoring Platform Strengths
```
; WRONG - Not using hardware
; Generic software sprites everywhere

; RIGHT - Platform features
; C64: Hardware sprites
; Spectrum: Attribute effects
; NES: Pattern animations
; Amiga: Copper/Blitter
```

## Verification Process

1. **Initial Design Review**
   - Compare against genre requirements
   - Check platform feature usage
   - Verify unique implementation

2. **Code Review at Lesson 5**
   - Ensure different structure
   - Check variable naming
   - Verify platform idioms

3. **Mid-Project Review (Lesson 16)**
   - Compare across platforms
   - Ensure genre adherence
   - Check for template drift

4. **Final Review (Lesson 32/64)**
   - Complete uniqueness check
   - Platform optimization review
   - Genre purity verification

## Sign-Off Requirements

Before marking a game complete:
- [ ] Lead developer review
- [ ] Cross-platform comparison
- [ ] Genre expert approval
- [ ] Student testing
- [ ] Documentation complete
- [ ] No template copying detected
- [ ] Platform features utilized
- [ ] Unique implementation verified
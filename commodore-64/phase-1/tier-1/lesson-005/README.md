# Grid Protocol - Lesson 5: Sector Grid Navigation

This lesson introduces the Grid Protocol - a 12×8 sector navigation system that demonstrates proper VIC-II sprite positioning with MSB (9th bit) handling.

### What You'll Learn

- Grid-based movement with lookup tables
- VIC-II MSB sprite positioning ($D010 register)
- Professional sprite positioning for screen edge coverage
- Authentic 1980s optimization techniques
- Constrained movement within sector boundaries

### New Concepts Introduced

#### Grid Protocol System
```assembly
GRID_WIDTH = 12                ; 12 columns (reaches screen edge with MSB)
GRID_HEIGHT = 8                ; 8 rows (maximum screen coverage)

; Grid covers 96 total positions (12 × 8)
; X range: 28 to 316 pixels (perfect screen coverage)
; Y range: 55 to 209 pixels (leaves space for UI elements)
```

The Grid Protocol provides discrete sector positions across the entire C64 screen, demonstrating how real games handle sprite positioning.

#### Position Lookup Tables
```assembly
; X positions with perfect screen coverage
x_positions:
    !byte 28, 54, 80, 106, 132, 158, 184, 210, 236, 6, 32, 58

; MSB flags for positions >= 256
x_msb_flags:
    !byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1

; Y positions with proper spacing
y_positions:
    !byte 55, 77, 99, 121, 143, 165, 187, 209
```

Lookup tables were the standard approach for performance-critical positioning in 1980s games.

### Technical Details

#### VIC-II MSB Handling
- **9-bit X Coordinates**: VIC-II uses 9 bits for X positioning (0-511)
- **$D000**: Lower 8 bits of sprite X position
- **$D010**: MSB (9th bit) for all 8 sprites
- **Automatic MSB**: Grid system handles MSB transitions seamlessly
- **Screen Edge Coverage**: Sprites reach actual screen boundaries

#### Grid Navigation
- **12 Columns**: Perfect horizontal coverage with MSB demonstration
- **8 Rows**: Maximum vertical screen utilization
- **Constrained Movement**: Cannot move beyond sector boundaries
- **Instant Positioning**: Grid jumps, not pixel movement
- **Wait for Release**: Prevents rapid repeated movement

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
make help   # Show all available targets
```

### Controls
- **Joystick Port 2**: Navigate grid sectors
- **Up/Down/Left/Right**: Move one sector at a time
- **Movement**: Instant sector jumps with boundary constraints

### What You'll Experience

When you run this program, you'll see:
- **Grid Navigation**: Entity moves in discrete sector jumps
- **Screen Edge Coverage**: Entity reaches actual screen boundaries
- **MSB Demonstration**: Automatic handling of positions > 255
- **Status Display**: "GRID NAVIGATION ACTIVE" message
- **Cyan Border**: Normal operational state

### Grid Protocol Technical Notes

- **X Range**: 28 to 316 pixels (288-pixel span with equal margins)
- **Y Range**: 55 to 209 pixels (154-pixel span with UI space)
- **MSB Positions**: Last 3 columns use MSB (positions 9, 10, 11)
- **Sprite Size**: Accommodates 24×21 pixel sprites
- **Screen Coverage**: 96 distinct positions across entire display

### Foundation for Advanced Lessons

This Grid Protocol system enables:
- **Lesson 6**: Boundary detection and alert systems
- **Lesson 7**: Movement state tracking with visual feedback
- **Lesson 8**: Complete patrol systems with timing
- **Future**: Game mechanics, collision detection, AI navigation

### Code Architecture

```
grid_init()
    ├── initialize_grid()      # Set center position (6,4)
    ├── deploy_entity()        # Load sprite pattern
    └── update_position()      # Apply lookup table positioning

control_loop()
    ├── read_interface()       # Get joystick input
    ├── move_grid_constrained() # Process movement with boundaries
    ├── update_position()      # Update VIC-II registers
    └── wait_frame()          # 50Hz timing synchronization
```

### Professional Patterns

1. **Lookup Tables**: Pre-calculated positions for performance
2. **MSB Abstraction**: Hardware complexity hidden from game logic
3. **Boundary Constraints**: Professional movement handling
4. **Input Debouncing**: Wait-for-release prevents rapid fire
5. **Modular Design**: Clear separation of concerns

This lesson establishes the foundation for all advanced Grid Protocol operations while demonstrating authentic C64 sprite positioning techniques.
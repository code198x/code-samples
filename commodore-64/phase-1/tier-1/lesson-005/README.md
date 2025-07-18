# Pixel Patrol - Lesson 5: Grid Position System

This lesson introduces a grid coordinate system that tracks the sprite's logical position on an 8×6 grid while maintaining pixel-based movement.

### What You'll Learn

- Creating a logical grid coordinate system
- Mapping pixel positions to grid coordinates
- Integer division using bit shifting
- Tracking dual position systems
- Displaying grid information

### New Concepts Introduced

#### Grid System
```assembly
GRID_WIDTH = 8                 ; 8 columns
GRID_HEIGHT = 6                ; 6 rows

; Each grid cell is 32×32 pixels
; Grid position calculated from pixel position
```

The grid provides a logical coordinate system overlaid on the pixel display, preparing for game logic that needs discrete positions.

#### Position Calculation
```assembly
calculate_grid_position:
        ; grid_x = sprite_x / 32
        lda sprite_x
        lsr                    ; Divide by 2
        lsr                    ; Divide by 4
        lsr                    ; Divide by 8
        lsr                    ; Divide by 16
        lsr                    ; Divide by 32
        sta grid_x
```

Using bit shifts for division by powers of 2 is fast and efficient on the 6502.

### Technical Details

#### Dual Position Tracking
- **Pixel Position**: sprite_x, sprite_y (0-255 range)
- **Grid Position**: grid_x, grid_y (0-7, 0-5 range)
- **Cell Size**: 32×32 pixels per grid cell
- **Automatic Update**: Grid position calculated each frame

#### Display Features
- Shows current grid position (e.g., "POS: 4,3")
- Shows pixel position for debugging
- Displays grid dimensions
- Updates in real-time

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
```

### Controls
- **Joystick Port 2**: Move sprite (same as lesson 4)
- **Q/A/O/P Keys**: Alternative keyboard controls
- **Movement**: Still pixel-based (2 pixels/frame)

### What You'll Experience

When you run this program, you'll see:
- **Grid Position Display**: Shows current grid coordinates
- **Pixel Position Display**: Shows exact pixel location
- **Smooth Movement**: Sprite still moves smoothly by pixels
- **Grid Updates**: Grid position changes as sprite crosses boundaries

### Exercise Suggestions

1. **Change Grid Size**: Try 10×8 or 16×12 grid
2. **Add Grid Visualization**: Draw grid lines on screen
3. **Snap Movement**: Make sprite jump to grid centers
4. **Color Grid Cells**: Change color based on grid position

### Foundation for Future Lessons

This grid system enables:
- **Lesson 6**: Converting grid back to sprite position
- **Lesson 7**: Constraining movement to grid bounds
- **Future**: Collision detection, level design, AI pathfinding

### Code Architecture

The program demonstrates:
- **Separation of Concerns**: Pixel vs grid positioning
- **Efficient Math**: Bit shifting for division
- **Real-time Calculation**: Grid updated every frame
- **Debug Display**: Shows both coordinate systems

This lesson establishes the foundation for grid-based game logic while maintaining smooth pixel movement.
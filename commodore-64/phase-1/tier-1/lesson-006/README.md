# Pixel Patrol - Lesson 6: Sprite Grid Movement

This lesson reverses the grid calculation from lesson 5. Now the sprite jumps between grid positions, converting grid coordinates to pixel positions for display.

### What You'll Learn

- Converting grid coordinates to pixel positions
- Implementing discrete grid-based movement
- Using bit shifting for multiplication
- Creating one-move-per-press controls
- Sprite positioning from grid data

### New Concepts Introduced

#### Grid to Sprite Conversion
```assembly
grid_to_sprite_position:
        ; sprite_x = GRID_START_X + (grid_x * GRID_CELL_WIDTH)
        lda grid_x
        asl                    ; × 2
        asl                    ; × 4
        asl                    ; × 8
        asl                    ; × 16
        asl                    ; × 32
        clc
        adc #GRID_START_X
        sta sprite_x
```

Using ASL (Arithmetic Shift Left) to multiply by powers of 2 is the reverse of the division we did in lesson 5.

#### Discrete Movement
```assembly
move_grid:
        ; Move up one grid position
        lda grid_y
        beq check_grid_down    ; Already at top
        dec grid_y
        jsr wait_for_release   ; Prevent repeat
```

The sprite now jumps entire grid cells instead of moving smoothly by pixels.

### Technical Details

#### Movement Characteristics
- **Grid-Based**: Movement by whole cells only
- **Instant**: Sprite jumps to new position
- **One-Per-Press**: Must release joystick between moves
- **Boundary Aware**: Can't move beyond grid edges

#### Position Calculation
- Grid position (0-7, 0-5) is primary
- Pixel position calculated from grid
- Sprite centered in each grid cell
- No intermediate positions

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
```

### Controls
- **Joystick Port 2**: Move between grid cells
- **Q/A/O/P Keys**: Alternative keyboard controls
- **Movement**: One cell per press (not continuous)

### What You'll Experience

When you run this program, you'll see:
- **Grid Movement**: Sprite jumps between cells
- **Instant Positioning**: No smooth animation
- **Clear Boundaries**: Can't move off grid
- **Position Display**: Shows both grid and pixel coordinates

### Exercise Suggestions

1. **Smooth Animation**: Add movement between grid positions
2. **Wrap Around**: Allow movement to wrap edges
3. **Visual Grid**: Draw grid lines on screen
4. **Different Speeds**: Variable movement delays

### Key Differences from Lesson 5

| Lesson 5 | Lesson 6 |
|----------|----------|
| Pixel movement primary | Grid movement primary |
| Grid calculated from pixels | Pixels calculated from grid |
| Smooth continuous motion | Discrete jumping motion |
| Grid position derived | Grid position controlled |

### Foundation for Future Lessons

This grid movement system enables:
- **Lesson 7**: Movement constraints and validation
- **Future**: Turn-based games, puzzle mechanics
- **Future**: Tile-based level design
- **Future**: Strategic positioning

### Code Architecture

The program demonstrates:
- **Reverse Calculation**: Grid → Pixel conversion
- **State Management**: One-move-per-press logic
- **Clean Boundaries**: Built-in edge detection
- **Modular Design**: Clear separation of systems

This lesson completes the grid system foundation, showing both directions of coordinate conversion.
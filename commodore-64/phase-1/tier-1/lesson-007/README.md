# Pixel Patrol - Lesson 7: Movement Constraints

This lesson adds boundary checking to keep the sprite within valid grid positions, with visual feedback when hitting edges.

### What You'll Learn

- Implementing movement validation
- Creating boundary constraints
- Adding visual feedback for collisions
- Building configurable movement modes
- Professional constraint handling

### New Concepts Introduced

#### Boundary Constants
```assembly
; Movement constraints
MIN_GRID_X = 0                 ; Leftmost column
MAX_GRID_X = GRID_WIDTH - 1    ; Rightmost column (7)
MIN_GRID_Y = 0                 ; Top row
MAX_GRID_Y = GRID_HEIGHT - 1   ; Bottom row (5)
```

Define clear boundaries for valid movement using constants for maintainability.

#### Movement Validation
```assembly
try_move_up:
        lda grid_y
        cmp #MIN_GRID_Y        ; At top edge?
        beq check_wrap_up      ; Check wrap mode
        
        ; Can move up
        dec grid_y
        jsr wait_for_release
        rts
```

Check if movement is valid before executing it.

### Technical Details

#### Constraint System
- **Boundary Checking**: Validates moves before execution
- **Edge Detection**: Compares position against limits
- **Visual Feedback**: Red border flash on collision
- **Configurable**: WRAP_MODE constant controls behavior

#### Wrap-Around Mode
- Set `WRAP_MODE = 1` to enable wrapping
- Moving off one edge brings sprite to opposite edge
- Classic game mechanic (Pac-Man, Asteroids)

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
```

### Controls
- **Joystick Port 2**: Move within grid bounds
- **Q/A/O/P Keys**: Alternative keyboard controls
- **Movement**: Constrained to 8×6 grid

### What You'll Experience

When you run this program, you'll see:
- **Boundary Enforcement**: Can't move beyond grid edges
- **Red Border Flash**: Visual feedback when hitting boundary
- **Position Display**: Shows current grid coordinates
- **Smooth Constraints**: Natural feeling boundaries

### Exercise: Enable Wrap Mode

Change line 41 in the source code:
```assembly
WRAP_MODE = 1                  ; Enable wrap-around
```

Rebuild and see how movement wraps around edges!

### Visual Feedback System

The border color provides immediate feedback:
- **White**: Normal movement
- **Red Flash**: Hit boundary (when not wrapping)

This helps players understand the game space without frustration.

### Foundation for Future Features

Movement constraints enable:
- **Level Boundaries**: Define playable areas
- **Obstacle Detection**: Check for walls/blocks
- **Game Rules**: Restrict movement based on game state
- **AI Pathfinding**: Define valid AI movements

### Code Architecture

The program demonstrates:
- **Validation Pattern**: Check before moving
- **Configuration Options**: Easy to modify behavior
- **Visual Feedback**: Professional user experience
- **Clean Structure**: Separate validation functions

### Comparison: Constrain vs Wrap

| Feature | Constrain Mode | Wrap Mode |
|---------|---------------|-----------|
| At Edge | Stop movement | Jump to opposite |
| Feedback | Red border flash | Smooth transition |
| Use Case | Puzzle games | Action games |
| Feel | Bounded space | Infinite space |

This lesson completes the movement system with professional boundary handling!
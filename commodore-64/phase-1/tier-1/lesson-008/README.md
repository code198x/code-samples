# Pixel Patrol - Lesson 8: Basic Game Loop

This lesson creates a proper game loop structure with initialization, update cycle, and frame-based timing.

### What You'll Learn

- Implementing game initialization phases
- Creating a main update loop
- Adding frame-based timing system
- Tracking game statistics
- Professional code organization

### New Concepts Introduced

#### Game States
```assembly
; Game states
STATE_INIT = 0                 ; Initialization
STATE_PLAYING = 1              ; Main game
STATE_PAUSED = 2               ; Paused (future)
```

Define clear states to control game flow and enable features like pause/resume.

#### Frame Synchronization
```assembly
wait_frame_start:
        lda $d012              ; Current raster line
        cmp #251               ; Wait for line 251
        bne wait_top
```

Synchronize game updates with display refresh for smooth, consistent gameplay.

### Technical Details

#### Game Structure
- **Initialization**: One-time setup of hardware and variables
- **Main Loop**: Continuous update cycle
- **State Management**: Control flow with game states
- **Timing System**: Frame counting and statistics

#### Update Cycle
1. Wait for frame start (vsync)
2. Update timing counters
3. Read player input
4. Update game logic
5. Update display
6. Repeat

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
```

### Controls
- **Joystick Port 2**: Move sprite in grid
- **Q/A/O/P Keys**: Alternative keyboard controls
- **Movement**: Grid-based with constraints

### What You'll Experience

When you run this program, you'll see:
- **Smooth Updates**: Consistent 50Hz frame rate
- **Time Display**: Elapsed seconds counter
- **Move Counter**: Total moves made
- **Professional Feel**: Proper game structure

### Frame Timing Details

The C64 PAL system runs at 50Hz (50 frames per second):
- Each frame = 20 milliseconds
- Raster beam takes 1 frame to draw screen
- Synchronizing ensures consistent timing

### Statistics System

The game tracks:
- **Frame Counter**: 0-49, resets each second
- **Seconds Counter**: Total elapsed time
- **Move Counter**: Player moves made

### Foundation for Future Features

This structure enables:
- **Pause/Resume**: Using STATE_PAUSED
- **Game Over**: Using STATE_GAME_OVER
- **Menus**: Additional states
- **Difficulty Levels**: Speed adjustments
- **High Scores**: Time/move tracking

### Code Architecture

```
game_init()
    ├── init_screen()
    ├── init_sprites()
    ├── init_game_vars()
    └── display_game_ui()

game_loop()
    ├── wait_frame_start()
    ├── update_timing()
    └── [if STATE_PLAYING]
        ├── read_input()
        ├── update_game()
        └── update_display()
```

### Professional Patterns

1. **Separation of Concerns**: Init vs Loop
2. **Modular Functions**: Single responsibility
3. **State Management**: Flexible control flow
4. **Consistent Timing**: Frame-based updates

### Exercise: Add Pause Feature

Add pause functionality:
1. Check for SPACE key in input routine
2. Toggle between STATE_PLAYING and STATE_PAUSED
3. Skip game updates when paused
4. Display "PAUSED" on screen

This completes the Foundation phase - you now have all the basics for C64 game development!
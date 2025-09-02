# Grid Protocol - Lesson 8: Complete Patrol System

This lesson implements a complete patrol system with timing, state management, and real-time statistics - demonstrating professional game loop architecture and authentic C64 development patterns.

### What You'll Learn

- Complete game loop architecture
- Real-time timing systems with frame synchronization  
- Professional initialization and state management
- Statistics tracking and display systems
- Authentic 1980s game development patterns

### New Concepts Introduced

#### Game State Management
```assembly
; System states
STATE_INIT = 0                 ; Initialization phase
STATE_PATROL = 1               ; Active patrol operations
STATE_ALERT = 2                ; Alert/emergency mode (future)

; Main game structure
main:
        jsr initialize_grid
        lda #STATE_PATROL
        sta system_state
        
main_loop:
        jsr update_timing
        jsr update_game
        jsr update_display
        jsr wait_frame
        jmp main_loop
```

Professional game architecture with clear phases and responsibilities.

#### Real-Time Timing System
```assembly
; Timing constants
FRAMES_PER_SECOND = 50         ; PAL C64 refresh rate
FRAME_COUNTER_RESET = 50       ; Frames per second

update_timing:
        inc frame_counter
        lda frame_counter
        cmp #FRAME_COUNTER_RESET
        bne timing_done
        
        ; One second elapsed
        lda #0
        sta frame_counter
        inc seconds_counter
        
timing_done:
        rts
```

Precise timing using the C64's 50Hz PAL refresh rate for accurate time tracking.

#### Statistics Display System  
```assembly
update_display:
        lda seconds_counter
        
        ; Convert binary to decimal for display
        ldx #0                 ; Tens digit
        sec
div10:  sbc #10
        bcc done_div
        inx
        jmp div10
done_div:
        adc #10               ; A = ones digit, X = tens digit
        
        ; Display both digits on screen
        ; Shows elapsed patrol time in real-time
```

Professional binary-to-decimal conversion for real-time statistics display.

### Technical Details

#### Complete Game Loop
- **Initialization Phase**: One-time hardware and system setup
- **Main Loop**: Continuous 50Hz update cycle
- **Timing Management**: Frame-perfect synchronization with display
- **State Processing**: Conditional logic based on current system state
- **Display Updates**: Real-time information presentation

#### Frame Synchronization
- **50Hz Operation**: Matches PAL C64 display refresh rate
- **Precise Timing**: Frame counter ensures accurate second tracking
- **No Drift**: Timing locked to hardware refresh, prevents accumulation errors
- **Performance**: Minimal CPU overhead for timing operations

#### Professional Architecture
- **Modular Design**: Clear separation between initialization and operation
- **State-Driven**: Easy to add new states (pause, menu, game over)
- **Extensible**: Framework ready for additional features
- **Maintainable**: Clean code structure for long-term development

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
make clean  # Clean build files
make help   # Show all available targets
```

### Controls
- **Joystick Port 2**: Navigate patrol sectors
- **Up/Down/Left/Right**: Move one sector at a time
- **Real-time Operation**: No pause - continuous patrol simulation

### What You'll Experience

When you run this program, you'll see:
- **Complete Patrol System**: Professional game feel and operation
- **Real-Time Timer**: Accurate seconds counter showing patrol duration
- **Status Display**: "GRID PATROL SYSTEM ACTIVE" header message
- **Time Tracking**: "TIME ELAPSED: XX" display (bottom left)
- **Smooth Operation**: 50Hz frame-perfect timing
- **Border Feedback**: Red alerts when hitting patrol boundaries

### System Architecture

#### Initialization Phase
```
initialize_grid()
├── Hardware Setup
│   ├── Set border/background colors
│   ├── Clear screen memory
│   └── Configure sprites
├── Display Setup
│   ├── Show system header
│   ├── Show time label
│   └── Position UI elements
├── Variable Initialization
│   ├── Set center grid position (6,4)
│   ├── Reset timing counters
│   └── Clear state flags
└── Entity Deployment
    ├── Load sprite pattern
    ├── Set initial position
    └── Enable sprite display
```

#### Main Game Loop
```
main_loop (50Hz)
├── update_timing()
│   ├── Increment frame counter
│   ├── Check for second rollover
│   └── Update seconds counter
├── update_game() [if STATE_PATROL]
│   ├── Read joystick input
│   ├── Process movement with constraints
│   ├── Update entity position
│   └── Handle boundary feedback
├── update_display()
│   ├── Convert seconds to decimal
│   ├── Display tens digit
│   └── Display ones digit
└── wait_frame()
    └── Synchronize to raster line 251
```

### Professional Game Patterns

#### Frame-Perfect Timing
- **Hardware Sync**: Timing locked to display refresh
- **Consistent Performance**: Same speed on all PAL C64 systems
- **No Frame Skipping**: Every frame processed and displayed
- **Predictable Behavior**: Exact timing enables precise game mechanics

#### Modular Architecture
- **Single Responsibility**: Each function has one clear purpose
- **Clean Interfaces**: Functions communicate through well-defined variables
- **Easy Testing**: Individual components can be tested separately
- **Scalable Design**: Framework supports additional features without restructuring

#### Professional UI Design
- **Persistent Information**: Status always visible during operation
- **Real-Time Updates**: Information refreshes every frame
- **Clear Hierarchy**: Important information prominently positioned
- **Consistent Layout**: UI elements positioned for easy reading

### Grid Protocol Statistics

#### Patrol Coverage Analysis
- **Total Sectors**: 96 positions (12×8 grid)  
- **Patrol Area**: 288×154 pixel coverage (X: 28-316, Y: 55-209)
- **MSB Demonstration**: 3 rightmost columns use VIC-II MSB positioning
- **Edge Coverage**: 100% screen boundary coverage with proper margins

#### Timing Specifications
- **Frame Rate**: 50 FPS (PAL standard)
- **Timer Resolution**: 1 second accuracy
- **Update Frequency**: 50Hz continuous operation
- **Display Refresh**: Real-time counter updates

### Foundation for Advanced Systems

This complete patrol system enables:
- **Mission Systems**: Timed objectives and goals
- **Performance Metrics**: Movement analysis and efficiency tracking
- **Alert Systems**: Emergency state transitions
- **Save/Load**: Game state persistence
- **Multiplayer**: Synchronized timing for network play

### Code Excellence

1. **Professional Structure**: Industry-standard game loop architecture
2. **Hardware Optimization**: Uses C64-specific timing and display features
3. **Maintainable Code**: Clear organization enables long-term development
4. **Performance Focus**: Minimal overhead, maximum responsiveness
5. **Authentic Approach**: Real 1980s development patterns and techniques

This lesson completes the Grid Protocol foundation, providing a robust platform for advanced C64 game development with professional timing, state management, and user interface systems.
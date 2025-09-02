# Grid Protocol - Lesson 7: Movement State Tracking

This lesson introduces comprehensive movement state tracking with enhanced visual feedback, demonstrating how professional games communicate system states to players.

### What You'll Learn

- Advanced state management systems
- Multi-state visual feedback with color coding
- Movement tracking and analysis
- Professional game state architecture
- Enhanced player communication through visuals

### New Concepts Introduced

#### Movement State System
```assembly
; Movement states
STATE_IDLE = 0                 ; No input detected
STATE_MOVING = 1               ; Valid movement executed
STATE_BLOCKED = 2              ; Movement blocked by boundary

; State evaluation logic
movement_state:  !byte 0       ; Current system state
moved_flag:      !byte 0       ; Movement success flag
boundary_hit:    !byte 0       ; Boundary collision flag
```

The system tracks not just position, but the nature of each movement attempt.

#### Enhanced Visual Feedback
```assembly
update_visual_feedback:
        lda movement_state
        
        cmp #STATE_IDLE
        bne check_moving
        lda #$03               ; Cyan for idle
        sta $d020
        sta $d027              ; Both border and sprite color
        rts
        
check_moving:
        cmp #STATE_MOVING
        bne check_blocked
        lda #$05               ; Green for moving
        sta $d020
        sta $d027
        rts
        
check_blocked:
        lda #$02               ; Red for blocked
        sta $d020
        sta $d027
        rts
```

Color-coded feedback provides instant understanding of system state.

### Technical Details

#### State Management Logic
- **Input Detection**: System recognizes joystick input vs no input
- **Movement Analysis**: Distinguishes successful moves from blocked attempts
- **State Priority**: Blocked state overrides moving state when boundaries hit
- **Continuous Tracking**: State updated every frame based on current conditions

#### Visual Language System
- **Cyan (Idle)**: No input detected, system ready
- **Green (Moving)**: Valid movement executed successfully  
- **Red (Blocked)**: Movement attempted but blocked by boundary
- **Unified Colors**: Both border and sprite use same color for clarity

### Movement State Flow

#### State Determination Process
```
Input Detected?
    ↓ NO                     ↓ YES
STATE_IDLE              Boundary Check
(Cyan)                       ↓
                    Valid Movement?
                    ↓ YES        ↓ NO
              STATE_MOVING   STATE_BLOCKED
               (Green)         (Red)
```

#### Frame-by-Frame Analysis
1. **Reset Flags**: Clear movement and boundary flags
2. **Input Check**: Detect joystick state
3. **State Assignment**: Set initial state based on input presence
4. **Movement Processing**: Execute movement if valid
5. **State Refinement**: Adjust state based on movement results
6. **Visual Update**: Apply color coding to match final state

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
- **No Input**: Idle state (cyan)
- **Valid Movement**: Moving state (green)
- **Blocked Movement**: Blocked state (red)

### What You'll Experience

When you run this program, you'll see:
- **State Visualization**: Real-time color feedback for every action
- **Movement Analysis**: Instant understanding of why movements succeed/fail
- **Professional Feel**: Polished feedback system like commercial games
- **Status Display**: "STATE TRACKING ACTIVE" message
- **Enhanced Communication**: Clear visual language for all states

### State Behavior Details

#### Idle State (Cyan)
- **Trigger**: No joystick input detected
- **Behavior**: System ready, waiting for input
- **Visual**: Cyan border and sprite color
- **Duration**: Continues until input detected

#### Moving State (Green)
- **Trigger**: Valid movement executed successfully
- **Behavior**: Entity moved to new grid position
- **Visual**: Green border and sprite color
- **Duration**: Brief flash, then returns based on next input

#### Blocked State (Red)
- **Trigger**: Movement attempted but blocked by boundary
- **Behavior**: Entity remains in current position
- **Visual**: Red border and sprite color
- **Duration**: Continues until successful movement or idle

### Professional Game Design Patterns

#### Communication Through Color
- **Consistent Language**: Same colors always mean same states
- **Immediate Feedback**: No delay between action and visual response
- **Universal Understanding**: Color coding transcends language barriers
- **System Transparency**: Players always know what's happening

#### State-Driven Architecture
- **Clean Logic**: States clearly defined and mutually exclusive
- **Predictable Behavior**: Same inputs produce same state changes
- **Extensible Design**: Easy to add new states (pause, menu, etc.)
- **Debug Friendly**: Visual states make issues immediately apparent

### Foundation for Advanced Systems

This state tracking enables:
- **Lesson 8**: Complete patrol systems with timing and statistics
- **Future Features**: Animation states, combo systems, special abilities
- **Game Mechanics**: Turn-based systems, action queues, state machines
- **Player Analytics**: Movement pattern tracking and analysis

### Code Architecture

```
process_movement()
    ├── Reset state flags
    ├── Check for input presence
    ├── Set initial state (IDLE or MOVING)
    ├── Process movement attempts
    │   ├── Check boundaries
    │   ├── Execute valid movements  
    │   └── Set moved_flag
    ├── Refine state based on results
    │   ├── BLOCKED if boundary hit
    │   ├── MOVING if moved_flag set
    │   └── IDLE otherwise
    └── Return final state

update_visual_feedback()
    ├── Read movement_state
    ├── Select appropriate color
    ├── Apply to border ($d020)
    └── Apply to sprite ($d027)
```

### Technical Excellence

1. **Real-Time Analysis**: State determined fresh each frame
2. **Multi-Factor Logic**: Considers input, boundaries, and results
3. **Unified Visuals**: Consistent color application
4. **Performance Optimized**: Minimal overhead for maximum clarity
5. **Maintainable Code**: Clear state logic easy to extend

This lesson demonstrates how professional games communicate complex system states through elegant visual design, creating intuitive player understanding without words or tutorials.
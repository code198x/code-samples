# Grid Protocol - Lesson 6: Sector Boundary Alerts

This lesson adds boundary detection and visual feedback to the Grid Protocol system, demonstrating how games provide player feedback when reaching sector limits.

### What You'll Learn

- Boundary detection in grid-based systems
- Visual feedback with border color changes
- Hit detection and state management
- Alert systems for constraint violations
- Combining movement logic with feedback systems

### New Concepts Introduced

#### Boundary Detection System
```assembly
; Boundary hit detection for each direction
try_move_up:
        lda grid_y
        beq hit_boundary      ; Already at top boundary
        dec grid_y            ; Move up one sector
        jsr wait_for_release
        rts

hit_boundary:
        lda #1
        sta boundary_hit      ; Set boundary hit flag
        rts
```

The system detects when movement would exceed grid boundaries and sets appropriate flags.

#### Visual Alert System
```assembly
update_border_alert:
        lda boundary_hit
        beq normal_border
        
        ; Flash red for boundary hit
        lda #$02              ; Red
        sta $d020             ; Border color register
        rts
        
normal_border:
        lda #$03              ; Cyan
        sta $d020
        rts
```

Border color provides immediate visual feedback when boundaries are hit.

### Technical Details

#### Boundary Checking Logic
- **Pre-Movement Check**: Test boundaries before attempting movement
- **Flag System**: `boundary_hit` tracks collision state
- **Per-Direction Logic**: Each direction has specific boundary tests
- **Immediate Feedback**: Visual response happens same frame as detection

#### Alert Color System
- **Normal State**: Cyan border (#$03) during regular navigation
- **Alert State**: Red border (#$02) when hitting any boundary
- **Instant Response**: Color changes immediately upon boundary contact
- **Persistent Alert**: Red remains until successful movement occurs

### Grid Boundary Specifications

#### Exact Boundaries
- **Left Boundary**: grid_x = 0 (X position 28 pixels)
- **Right Boundary**: grid_x = 11 (X position 316 pixels)
- **Top Boundary**: grid_y = 0 (Y position 55 pixels)
- **Bottom Boundary**: grid_y = 7 (Y position 209 pixels)
- **Total Sectors**: 96 positions (12×8 grid)

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
- **Boundary Contact**: Triggers red border alert

### What You'll Experience

When you run this program, you'll see:
- **Boundary Detection**: Red border flash when hitting sector limits
- **Normal Navigation**: Cyan border during free movement
- **Edge Coverage**: Entity can reach all screen boundaries
- **Status Display**: "BOUNDARY DETECTION ACTIVE" message
- **Immediate Feedback**: Visual response to constraint violations

### Boundary Alert Behavior

#### Normal Navigation
- **Free Movement**: Entity moves smoothly between sectors
- **Cyan Border**: Visual indicator of normal operational state
- **No Constraints**: Movement allowed in all valid directions

#### Boundary Contact
- **Detection**: System recognizes when movement would exceed limits
- **Prevention**: Entity remains in current valid position
- **Alert**: Border instantly changes to red
- **Recovery**: Returns to cyan when valid movement resumes

### Technical Implementation

#### Movement Flow
```
Read Input → Check Boundary → Execute Movement → Update Visual Feedback
     ↓              ↓              ↓                    ↓
  Joystick    Grid Position   Position Update      Border Color
  Register      Validation     (if valid)           Update
```

#### State Management
- **boundary_hit**: Flag indicating constraint violation
- **grid_x, grid_y**: Current sector coordinates
- **control_state**: Current input state
- **Visual state**: Reflected in border color

### Foundation for Advanced Features

This boundary system enables:
- **Lesson 7**: Movement state tracking with enhanced feedback
- **Lesson 8**: Complete patrol systems with timing constraints
- **Future Features**: Collision detection, level boundaries, safe zones

### Professional Game Patterns

1. **Immediate Feedback**: Players instantly understand constraints
2. **Visual Language**: Color coding for different system states  
3. **Non-Blocking Alerts**: Feedback doesn't interrupt gameplay flow
4. **Clear Boundaries**: Consistent edge behavior across all directions
5. **State Recovery**: System returns to normal after constraint resolution

### Code Architecture

```
Main Loop:
    ├── read_interface()           # Get player input
    ├── move_with_boundary_check() # Process movement with detection
    │   ├── clear boundary_hit flag
    │   ├── check each direction
    │   ├── set boundary_hit if blocked
    │   └── execute valid movements
    ├── update_position()          # Apply new coordinates
    ├── update_border_alert()      # Set visual feedback
    └── wait_frame()              # Maintain timing
```

This lesson demonstrates how professional games provide clear, immediate feedback for system constraints while maintaining smooth gameplay flow.
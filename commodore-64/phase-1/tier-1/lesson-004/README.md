# Lesson 4: Collision Detection

## Cosmic Harvester - C64 Assembly Programming

In this lesson, we add collision detection to create interactive gameplay. When bullets hit asteroids, both objects are destroyed and an explosion animation plays.

### What You'll Learn

- Implementing efficient collision detection algorithms
- Managing interactions between multiple game objects
- Creating visual feedback with explosion animations
- Understanding game state management
- Working with object arrays and relationships

### New Concepts Introduced

#### Collision Detection Algorithm
```assembly
check_object_collision:
    ; Check X collision
    lda object1_x
    sec
    sbc object2_x
    ; ... check if within range
    
    ; Check Y collision
    lda object1_y
    sec
    sbc object2_y
    ; ... check if within range
```

The collision system uses simple bounding box detection, checking if objects are within 2 characters of each other.

#### Object Management
- **Asteroids**: 8 moving obstacles that scroll from right to left
- **Collision Response**: Deactivate both bullet and asteroid on hit
- **Visual Feedback**: Explosion animation at collision point
- **Object Recycling**: Asteroids respawn on the right side

#### Explosion Animation
```assembly
explosion_colors:
    !byte COLOR_YELLOW, COLOR_ORANGE, COLOR_PURPLE, COLOR_WHITE
```

Simple frame-based animation cycles through colors to create an explosion effect.

### Technical Details

#### Memory Layout
- **Zero Page**: Extended usage for collision detection variables ($f0-$f7)
- **Object Arrays**: Parallel arrays for asteroids (active, x, y)
- **Animation State**: Explosion position and frame counter

#### Game Loop Additions
1. Update asteroids (movement and wrapping)
2. Check all bullet-asteroid pairs for collisions
3. Handle collision responses (deactivation, explosions)
4. Update explosion animations

#### Performance Considerations
- Nested loops for collision checking (bullets × asteroids)
- Early exit when collision found
- Only check active objects
- Simple distance calculation without multiplication

### Building and Running

```bash
make        # Build the program
make run    # Build and run in VICE emulator
```

### Controls
- **Q**: Move ship up
- **A**: Move ship down
- **SPACE**: Fire bullets

### Gameplay Elements
- Ship fires bullets that travel right
- Asteroids move from right to left
- Bullets destroy asteroids on contact
- Explosion animation plays at impact point
- Asteroids respawn after leaving screen

### Next Steps
In the next lesson, we'll add:
- Score tracking for destroyed asteroids
- Different asteroid types
- Power-ups and special weapons
- More complex collision interactions

### Code Architecture
The collision system demonstrates:
- **Separation of Concerns**: Collision detection separate from response
- **Object Pooling**: Reusing asteroid and bullet objects
- **State Management**: Tracking active/inactive states
- **Visual Feedback**: Immediate response to player actions

This lesson establishes the foundation for interactive gameplay, where player actions have consequences and the game world responds dynamically.
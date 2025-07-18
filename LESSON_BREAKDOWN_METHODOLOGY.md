# Lesson Breakdown Methodology

## Overview
Each game must be broken down into individual 30-45 minute lessons BEFORE any code is written. This prevents template replication and ensures each game is unique.

## Lesson Structure Rules

### Lesson Size
- **Target**: 30-45 minutes of content
- **Code**: 50-150 lines per lesson (depending on complexity)
- **Concepts**: 1-2 new concepts maximum per lesson
- **Practice**: Each lesson includes exercises

### Lesson Types

#### 1. Foundation Lessons (First 25%)
- Setup and basic structure
- Core game loop
- Basic rendering
- Simple input handling

#### 2. Mechanic Lessons (Next 50%)
- Game-specific mechanics
- Unique features for this game
- Platform-specific techniques
- Gradual complexity increase

#### 3. Polish Lessons (Final 25%)
- Audio integration
- Visual effects
- Game state management
- Optimization

### Lesson Dependencies
- Each lesson builds on previous ones
- Clear prerequisite chain
- No forward references
- Complete runnable code at each step

## Example: Breaking Down "Quantum Shatter" (Spectrum Breakout)

### Phase 1, Tier 1-2 (64 lessons total)

#### Lessons 1-8: Foundation
1. **Setup and Display**
   - Initialize Spectrum display
   - Set border color
   - Clear screen
   - Basic color attributes

2. **Draw Paddle**
   - Character-based paddle
   - Position variables
   - Display routine
   - Color selection

3. **Paddle Movement**
   - Read keyboard input
   - Update paddle position
   - Boundary checking
   - Smooth movement

4. **Draw Ball**
   - Ball position variables
   - Ball display routine
   - Initial positioning
   - Ball color

5. **Ball Movement**
   - Velocity variables
   - Update position
   - Basic animation
   - Frame timing

6. **Wall Collisions**
   - Screen boundary detection
   - Bounce calculations
   - Sound effects (beeper)
   - Edge cases

7. **Paddle Collisions**
   - Collision detection
   - Bounce angles
   - Speed variations
   - Hit feedback

8. **Game States**
   - Start screen
   - Playing state
   - Game over
   - State transitions

#### Lessons 9-24: Brick System
9. **Brick Data Structure**
   - Array setup
   - Brick states
   - Position mapping
   - Memory layout

10. **Draw Bricks**
    - Loop through array
    - Character graphics
    - Color attributes
    - Screen layout

11. **Brick Collisions**
    - Detection algorithm
    - Brick removal
    - Score updating
    - Sound feedback

12. **Brick Patterns**
    - Level layouts
    - Pattern data
    - Loading patterns
    - Visual variety

[Continue for all 64 lessons...]

## Lesson Breakdown Template

```markdown
# [Game Name] - Lesson Breakdown

## Game Overview
- **System**: [Platform]
- **Genre**: [Type]
- **Unique Features**: [What makes this different]
- **Total Lessons**: [Number]

## Lesson Progression

### Foundation (Lessons 1-X)
[Number] lessons establishing core systems

#### Lesson 1: [Title]
- **Concepts**: [New concepts introduced]
- **Code Focus**: [What code is written]
- **Outcome**: [What works after this lesson]
- **Exercise**: [Practice task]

#### Lesson 2: [Title]
[Same structure...]

### Mechanics (Lessons X-Y)
[Number] lessons implementing game-specific features

[Continue pattern...]

### Polish (Lessons Y-Z)
[Number] lessons refining the experience

[Continue pattern...]

## Skill Progression
- Lesson 1-10: [Basic skills learned]
- Lesson 11-20: [Intermediate skills]
- [etc...]

## Platform-Specific Techniques
- [Technique 1]: Introduced in Lesson X
- [Technique 2]: Introduced in Lesson Y
- [etc...]
```

## Pre-Code Checklist

Before writing ANY code for a game:

1. **Game Design Document**
   - [ ] Core mechanics defined
   - [ ] Unique features listed
   - [ ] Platform-specific elements identified
   - [ ] Different from all other games

2. **Lesson Breakdown**
   - [ ] All lessons outlined
   - [ ] Each lesson has clear goals
   - [ ] Dependencies mapped
   - [ ] No concept introduced before taught

3. **Technical Plan**
   - [ ] Memory map designed
   - [ ] Data structures defined
   - [ ] Platform features utilized
   - [ ] Performance considerations

4. **Asset Plan**
   - [ ] Graphics requirements
   - [ ] Sound effects needed
   - [ ] Memory budget
   - [ ] Creation timeline

5. **Verification**
   - [ ] Compare against other games
   - [ ] Ensure uniqueness
   - [ ] Check feasibility
   - [ ] Review learning progression

## Red Flags to Avoid

### Template Replication
- ❌ Same variable names across games
- ❌ Identical code structure
- ❌ Copy-paste gameplay
- ✅ Unique implementation per game

### Genre Confusion
- ❌ Breakout game with shooting
- ❌ Racing game with platforms
- ❌ Mixing unrelated mechanics
- ✅ Pure genre implementation

### Complexity Creep
- ❌ Advanced features too early
- ❌ Multiple concepts per lesson
- ❌ Incomplete examples
- ✅ Gradual skill building

## Implementation Order

1. **Create Game Design Doc**
2. **Create Lesson Breakdown**
3. **Review and Verify Uniqueness**
4. **Create Lesson 1 Code**
5. **Test Lesson 1**
6. **Create Lesson 2 Code**
7. **Verify Lessons Build Properly**
8. **Continue Sequentially**

## Quality Metrics

Each lesson should:
- Take 30-45 minutes to complete
- Introduce 1-2 new concepts max
- Build on previous lessons
- Result in runnable code
- Include practice exercises
- Be engaging and fun

## Avoiding Past Mistakes

### The Space Shooter Disaster
What went wrong:
- Started coding without lesson plans
- Used C64 template for all systems
- Lost track of genre requirements
- No verification between systems

### Prevention:
- Lesson breakdown BEFORE code
- Unique plan per game
- Regular verification
- Genre-appropriate mechanics only

This methodology ensures each game is properly planned, unique, and educational before any code is written.
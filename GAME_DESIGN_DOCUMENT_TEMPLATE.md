# Game Design Document Template

## Purpose
This template ensures each game is properly specified to prevent genre drift and maintain system-unique implementations.

## Required Sections for Each Game

### 1. Game Identity
- **Game Name**: [Unique name]
- **System**: [C64/Spectrum/NES/Amiga]
- **Phase/Tier**: [e.g., Phase 1, Game 3]
- **Lesson Count**: [32/64/128/256/512]
- **Genre**: [MUST be different from other systems in same tier]

### 2. Core Concept (One Paragraph)
Brief description that clearly differentiates this game from all others.

### 3. Unique Selling Point
What makes this game different from:
- Other games in the same phase
- Same-tier games on other systems
- Similar genres on the same system

### 4. Core Mechanics (Prioritized List)
1. Primary mechanic (the ONE thing the game teaches)
2. Secondary mechanics (if any)
3. Explicitly what this game does NOT include

### 5. Visual Design
- **Graphics mode**: [Specific to system]
- **Color palette**: [System-appropriate]
- **Sprite/character usage**: [Detailed breakdown]
- **Why this couldn't work on other systems**: [Key differentiator]

### 6. Controls
- **Input device**: [Joystick/keyboard/paddle/mouse]
- **Button mappings**: [Specific actions]
- **Control feel**: [Responsive/floaty/precise]

### 7. Technical Requirements
- **Memory**: [Base/expanded]
- **Hardware features used**: [Specific chips/capabilities]
- **Performance targets**: [FPS/smoothness]

### 8. Lesson Breakdown
- Lessons 1-8: [What we teach]
- Lessons 9-16: [What we build]
- Lessons 17-24: [What we polish]
- Lessons 25-32: [What we master]

### 9. Legal Compliance
□ Original game concept (not a clone)
□ Original name (not derivative of existing IP)
□ No trademarked terms or characters
□ No copyrighted game mechanics
□ Educational fair use only

### 10. Verification Checklist
□ Is this game's genre unique to this system in this phase?
□ Does it showcase system-specific features?
□ Is the core mechanic clearly defined?
□ Could this be confused with another game?
□ Does it fit the phase's complexity level?
□ Is it legally compliant?

### 11. Anti-Patterns (What This Game Is NOT)
Explicitly list what this game should not become to prevent drift.

---

## Legal Guidelines

### Naming Requirements
- **Must be original** (not "Super [existing game]" or "[existing game] 64")
- **Avoid similar names** (not "Pac-Guy" or "Asteroid Field")
- **No trademark conflicts** (check TESS database)
- **Generic descriptive names OK** ("Block Puzzle", "Space Shooter")

### Gameplay Requirements
- **Inspired by genre conventions**: OK ✓
- **Direct clone of specific game**: NOT OK ✗
- **Using game mechanics**: OK ✓ (can't copyright mechanics)
- **Copying level designs**: NOT OK ✗

### Examples of Compliance

**GOOD Examples**:
- "Pixel Defender" - Space shooter (genre is fine)
- "Crystal Caves" - Platform game with gem collection
- "Velocity Rush" - Racing game
- "Quantum Shift" - Puzzle game with unique mechanic

**BAD Examples**:
- "Pac-Runner" - Too close to Pac-Man
- "Super Mario-style Platformer" - References trademark
- "Tetris Clone" - Explicitly copying
- "Sonic-Speed Racing" - Uses trademark

### Safe Approaches
1. **Focus on mechanics**: "A game where you collect gems while avoiding enemies"
2. **Create original fiction**: New characters, stories, worlds
3. **Combine genres**: Puzzle-platformer, racing-shooter
4. **Add unique twists**: Standard genre + one new mechanic

---

## Example: Phase 1, Game 3 Comparison

### C64: "Star Dodge"
- **Genre**: Vertical avoidance
- **Mechanic**: Smooth sprite movement avoiding falling sprites
- **Visual**: Hardware sprites with smooth 50Hz movement
- **NOT**: A shooter (no firing), not character-based
- **Legal**: Original name, common mechanic, no IP conflicts

### Spectrum: "Maze Runner"
- **Genre**: Maze navigation  
- **Mechanic**: Character-based movement through corridors
- **Visual**: Attribute-colored walls, no sprites
- **NOT**: Not smooth scrolling, not sprite-based
- **Legal**: Generic name (not the movie), original maze designs

### NES: "Block Push"
- **Genre**: Puzzle
- **Mechanic**: Push blocks onto targets using tile manipulation
- **Visual**: Background tiles that change, sprite character
- **NOT**: Not physics-based, not an action game
- **Legal**: Generic mechanic, no specific game copied

### Amiga: "Color Cycle"
- **Genre**: Rhythm/timing
- **Mechanic**: Match colors using copper timing
- **Visual**: Copper list color changes, no sprites needed
- **NOT**: Not a match-3, not sprite-based
- **Legal**: Original concept using hardware features

---

## Minimum Documentation Levels

### Phase 1 Games (32 lessons each)
- 1 page per game
- Focus on core mechanic
- Clear genre statement
- Visual mockup
- Legal compliance check

### Phase 2-4 Games (64-128 lessons)
- 2-3 pages per game
- Detailed mechanics
- Level progression
- Technical architecture
- Originality statement

### Phase 5-6 Games (256 lessons)
- 5-10 pages per game
- Complete game systems
- Content pipeline
- Performance analysis
- Full legal review

### Phase 7-8 Games (512 lessons)
- 15-20 pages per game
- Full design document
- Technical design document
- Art bible
- Implementation plan
- Trademark search results

---

## Red Flags to Avoid

1. **Generic descriptions** like "action game" or "arcade game"
2. **Copy-paste mechanics** between systems
3. **"It's like X but..."** descriptions (suggests cloning)
4. **Using any existing game names** even partially
5. **Referencing commercial games** in design docs
6. **Ignoring system limitations** for convenience
7. **Feature creep** beyond phase complexity

## Validation Process

Before implementation begins:
1. Review all 4 system designs for the same tier
2. Ensure no two are the same genre
3. Verify system-specific features are used
4. Confirm complexity matches phase
5. Check against anti-patterns
6. **Legal compliance review**:
   - Name search (Google, TESS)
   - Gameplay originality check
   - No trademark conflicts
   - Educational purpose clear

## Safe Harbor Statement

All games created in this curriculum are:
- Original works for educational purposes
- Not intended for commercial distribution
- Designed to teach programming concepts
- Using only original assets and code
- Respecting all intellectual property rights

This level of detail should prevent both genre convergence and legal issues while keeping documentation manageable.
# Lesson 005: Knowledge Master

Menu-driven quiz with categories, procedures, and high score tracking.

## Files

- `knowledge-master.amos` - Multi-category quiz with menu system and high score

## Concepts

- **Menu system**: Do...Loop with choices
- **Procedures**: Separate procedures for each category
- **Procedure parameters**: Pass category name to generic quiz procedure
- **Restore command**: Reset data pointer to specific label
- **Data labels**: Named locations in data (`HistoryData:`)
- **High score tracking**: Persistent variable across quiz attempts
- **Exit statement**: Break from Do...Loop

## Programme Flow

1. Display main menu
2. User chooses category or views high score
3. Restore data pointer to that category's label
4. Call quiz procedure
5. Procedure reads 3 questions from current data section
6. Check if new high score
7. Return to menu
8. Repeat until user quits

## Key Points

**Menu-driven architecture:**
- Main loop displays options
- Input branches to appropriate procedure
- Exit breaks from loop cleanly
- Procedures use Restore to access different data sections

**High score management:**
- Variable persists across quiz attempts
- Compare after each quiz
- Display current high score from menu

## Running

1. Load AMOS Professional
2. Load `knowledge-master.amos`
3. Press F1 to run
4. Choose a category from menu (1-3)
5. Answer 3 questions
6. Try to beat your high score!
7. View high score from menu (4)
8. Quit when done (5)

## Extensions

Try adding:
- More categories (Literature, Sports)
- 5 questions per category instead of 3
- Player name for high score
- Difficulty levels (easy/hard questions)
- Timer for each question
- Different point values for different categories
- "Challenge mode" with random questions from all categories
- Save high score to disk

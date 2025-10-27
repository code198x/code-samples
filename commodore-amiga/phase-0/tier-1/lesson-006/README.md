# Lesson 006: Data-Driven Quiz

Expandable quiz engine with categories using Restore and labels.

## Files

- `data-driven-quiz.amos` - Multi-category quiz with menu system

## Concepts

- **Restore command**: Reset data pointer to specific label
- **Data labels**: Named locations in data (`MathQuestions:`)
- **Menu system**: Loop with choices
- **Reusable procedures**: RunQuiz works for any category
- **Multiple data sections**: Separate question banks
- **End statement**: Terminate programme

## Data Organization

**Labeled data sections:**
```amos
MathQuestions:
Data "question",answer
Data "question",answer

ScienceQuestions:
Data "question",answer
Data "question",answer
```

**Restore resets pointer:**
```amos
Restore MathQuestions    ' Next Read gets math data
Restore ScienceQuestions  ' Next Read gets science data
```

## Programme Flow

1. Display category menu
2. User chooses category
3. Restore data pointer to that category's label
4. Call RunQuiz procedure
5. Procedure reads 5 questions from current data section
6. Return to menu
7. Repeat until user quits

## Key Points

Advanced data handling:
- Labels (name followed by colon) mark data locations
- Restore sets where next Read will retrieve from
- Same procedure works with different data sources
- Easy to add new categories (new label + 5 Data lines)
- Menu system with Do...Loop and Exit

## Running

1. Load AMOS Professional
2. Load `data-driven-quiz.amos`
3. Press F1 to run
4. Choose a category from menu
5. Answer 5 questions
6. Return to menu or quit

## Extensions

Try adding:
- More categories (history, literature)
- 10 questions per category instead of 5
- Random question selection
- Overall high score across all categories
- Timer for each question
- Different point values for different categories
- "Challenge mode" with mixed categories
- Question difficulty levels

# Lesson 004: Quiz Master

Simple quiz programme using Data statements.

## Files

- `quiz-master.amos` - Five-question maths quiz with scoring

## Concepts

- **Data statements**: Store question/answer pairs
- **Read command**: Retrieve data sequentially
- **Sequential access**: Data items read in order
- **String and numeric data**: Mixed data types in Data lines
- **Else If**: Multiple conditional branches
- **Score tracking**: Accumulate correct answers

## Question Structure

**Data format:**
```amos
Data "Question text",answer_number
```

**Reading pattern:**
```amos
Read question$    ' Read string
Read answer       ' Read number
```

## Key Points

Data statements in AMOS:
- Define data anywhere in programme (usually at end)
- Mix strings and numbers in same Data line
- Data read in order from first to last
- Use Read to retrieve next item
- No automatic reset - reads continue sequentially

## Running

1. Load AMOS Professional
2. Load `quiz-master.amos`
3. Press F1 to run
4. Answer five maths questions
5. View your final score

## Extensions

Try adding:
- More questions (add more Data lines)
- Different question categories (geography, science)
- Restore command to replay quiz
- Random question order
- Timer for each question
- Different difficulty levels
- Percentage score calculation

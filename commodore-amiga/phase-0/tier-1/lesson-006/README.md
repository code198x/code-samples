# Lesson 006: Data Bank

Arrays with Dim for flexible question storage, search, and browsing.

## Files

- `data-bank.amos` - Quiz system using arrays for random access and search

## Concepts

- **Dim statement**: Declare arrays (`Dim question$(20)`)
- **Zero-based indexing**: Arrays start at 0 (question$(0) is first element)
- **Loading arrays**: Read Data into arrays for flexible access
- **Array search**: Loop through array checking each element
- **Count tracking**: Variable to track how many items loaded
- **Instr function**: Find substring within string
- **Random access**: Access any question by index

## Array Structure

**Two parallel arrays:**
```amos
Dim question$(20)    ' 20 question strings
Dim answer$(20)      ' 20 corresponding answers
count=0              ' Track how many actually loaded
```

**Relationship:** question$(3) and answer$(3) belong to the same Q&A pair.

## Programme Flow

1. Load questions from Data into arrays
2. Count how many questions loaded (stops at "END" marker)
3. Display menu with options
4. User chooses:
   - Full quiz (iterate all questions)
   - Search questions (find matching substring)
   - Browse all questions (paginated display)
5. Return to menu
6. Repeat until user quits

## Key Points

**AMOS array features:**
- Declared with Dim (dimension)
- Indices start at 0 (not 1 like C64 BASIC)
- String arrays use $ suffix
- Access elements with subscript: array$(index)
- Can use variables as index: array$(i)

**Data structure:**
- Fixed-size arrays (20 elements max)
- "END" sentinel value marks end of data
- Count variable tracks actual number of questions
- Same data used for all operations (quiz, search, browse)

## Running

1. Load AMOS Professional
2. Load `data-bank.amos`
3. Press F1 to run
4. Watch questions load into arrays
5. Choose from menu:
   - Take full quiz (all 15 questions)
   - Search for questions containing text
   - Browse all questions
6. Quit when done

## Extensions

Try adding:
- Increase array size (50+ questions)
- Random question order for quiz
- Multiple choice answers (arrays of arrays)
- Case-insensitive search (convert to uppercase first)
- Edit/add questions during runtime
- Save/load question bank to disk
- Categories stored in third array
- Filter by category in search
- Sort questions alphabetically

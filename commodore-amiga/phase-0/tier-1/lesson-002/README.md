# Lesson 002: Interactive Oracle

Interactive program with user input and conditional responses.

## Files

- `interactive-oracle.amos` - Name greeting and number guessing game

## Concepts

- **Input$**: Get text input from user
- **If...Then...End If**: Structured conditionals (no line numbers)
- **String comparison**: Compare user input with expected values
- **Else**: Alternative execution path
- **String concatenation**: Combine strings with `+`
- **Ink**: Change text colour (0-15)

## Key Points

AMOS structured conditionals:
- Must use `If...Then` (not just `If`)
- Always close with `End If`
- Can include `Else` for alternative path
- Multiple commands allowed in each branch
- No line numbers needed

## Running

1. Load AMOS Professional
2. Load `interactive-oracle.amos`
3. Press F1 to run
4. Type your name when prompted
5. Enter a number 1-10
6. Press any key to exit

## Extensions

Try adding:
- Multiple questions in sequence
- Score tracking across questions
- Different responses for different names
- Range checking (reject numbers outside 1-10)
- Use `Rnd(10)+1` for random answer
- Add more colour with Ink commands

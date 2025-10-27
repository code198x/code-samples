# Lesson 005: High Score Hall

Top 5 leaderboard with array management and sorting.

## Files

- `high-score-hall.amos` - Interactive leaderboard with score insertion

## Concepts

- **Dim statement**: Declare arrays
- **Array indexing**: Access elements with subscript (1-based)
- **Parallel arrays**: name$(i) and scores(i) hold related data
- **For...Next loops**: Iterate through array elements
- **Insertion logic**: Shift elements to make space
- **Step -1**: Loop backwards
- **Exit**: Leave loop early

## Array Structure

**Two parallel arrays:**
```amos
Dim name$(5)     ' 5 player names
Dim scores(5)    ' 5 corresponding scores
```

**Relationship:** name$(3) and scores(3) belong to the same player.

## Insertion Algorithm

1. Find insertion position (where new score beats existing)
2. Shift lower scores down one position (loop backwards)
3. Insert new name and score at found position
4. Display updated leaderboard with highlighting

## Key Points

AMOS array features:
- Arrays declared with Dim (dimension)
- Indices start at 1 (not 0)
- String arrays use $ suffix
- For...Next with Step -1 loops backwards
- Exit leaves loop immediately

## Running

1. Load AMOS Professional
2. Load `high-score-hall.amos`
3. Press F1 to run
4. View current top 5
5. Enter your name and score
6. See if you made the leaderboard!

## Extensions

Try adding:
- Top 10 instead of top 5
- Save scores to disk
- Multiple leaderboards (different games)
- Date/time stamp for each score
- Full bubble sort for any new scores
- Prevent duplicate names
- Score validation (reject negative scores)

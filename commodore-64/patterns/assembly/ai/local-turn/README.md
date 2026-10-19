# Target selection and a legal local turn

Original 6502 code and board, motivated by the Pac-Man study. Include local-turn.inc and use.asm once in writable program memory. Call move_one_turn at a decision tick, not independently in every consumer. The file comments define coordinate bounds, state, register changes, tie order and the no-move result.

choose_target updates the target. choose_turn returns choice without moving. move_one_turn is the optional caller that applies the chosen adjacent step. A new target rule can reuse the chooser. The current two-row offset assumes Up; direction-sensitive anticipation is a further extension.

No original maze, characters, historical ghost quirks, scatter clock or route search. This greedy rule can cycle. Coordinates must stay within the 9×7 board; the table arithmetic assumes those bounds.

Run python3 scripts/check-pattern-library-prototype.py from the repository root. The assembled chooser is executed on every open actor tile for both target rules in VICE, and compared to an independent distance/tie calculation: 58 cases. This does not claim exhaustive testing of all possible player coordinates, boards or rule changes.

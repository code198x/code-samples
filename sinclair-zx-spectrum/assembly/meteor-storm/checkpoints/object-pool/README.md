# Trace independent records

Replace the one-meteor variables with twenty four-byte slots: x, y, active, speed. Only three events are supplied: (80,2,20), (116,3,20), (170,4,20). Each event is X, downward speed and delay until the next event. Follow IX through two occupied records and one empty one. The final event is not completion: its meteor still has to leave.

O/P steer; Q restarts during play. R retries a result; Q also restarts there.

This is a complete program, not a fragment to paste into an unseen engine. See
the [module build instructions](../../README.md) and [routine contracts](../../contracts.md).

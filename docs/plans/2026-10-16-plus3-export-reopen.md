# Self-contained +3 export/reopen fixture

Add `sinclair-zx-spectrum/qualification/disk-plus3/export.bas`, reusing the
MIT `roundtrip.asm`. Keep `format.bas` and earlier evidence unchanged.

The existing same-session reload keeps verifier code in RAM. Fresh reopening
must instead load that code from disk. Save generated data as `ROUND.BIN`,
verifier code as `VERIFY.BIN`, and BASIC as `RESUME` autorunning at line 100.
Line 100 reloads verifier code before data and execution. Check a three-file
catalogue, NEW, and cold-ROM `LOAD "RESUME"` in fresh processes.

Verify BASIC lint/tokenisation, existing fixture tests and normal assembly
builds. The umbrella owns runtime/export qualification and machine-readable
evidence; do not claim this source file alone qualifies export. Push/review/
merge the owning fixture PR, then remove the clean retained task worktree.

# Amiga BASIC-family loop tranche

1. Verify and rebase-merge samples #160 at the reviewed head; retain the full gate.
2. Rerun website #923 Browser tests after the source merge. Merge only when all checks pass at its reviewed head; verify publication.
3. Inspect existing AMOS and Blitz samples, native runtime records and original manuals. Reuse their load paths and keep the two dialects distinct.
4. Add reusable loop routines, caller/customisation/error examples and native verification evidence under commodore-amiga/patterns, with matching website entries and language inventory. Exact files follow runtime qualification.
5. Run source evidence checks and website checks, update the machine/language matrix and issue #117, push review PRs, then clean task worktrees and processes.

Verification: guarded GitHub merge checks; guest execution with actual input and observed output; falsified evidence controls; existing website unit, content/build and focused browser checks. Do not claim runtime coverage from source inspection alone.

## Qualified implementation scope

- AMOS Professional 2.00: `commodore-amiga/patterns/amos/framework/command-loop/{caller,routines,demo,customise}.amos` and `mistakes/reset-each-command.amos`. Reuse the maintained fresh-key reader; one accepted A advances a bounded counter.
- Blitz BASIC 2.1/Ted: analogous `.bb2` source under `patterns/blitz/framework/command-loop/`; line-based Edit$(1) command input, signed long integer globals, Amiga-mode console ownership. This is independent of AmiBlitz/PED and does not inherit its verification.
- Native phases and captures retain exact source/media/tool hashes and test idle/invalid/accepted/repeated/boundary/custom/wrong/fixed behaviour.
- Website paths `commodore-amiga/{amos,blitz}/framework/command-loop.mdx`; update only language labelling in the pattern route/directory if needed. Keep assembly and both BASIC dialects separate.

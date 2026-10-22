# Publish Atari loops; fill the first language-specific loop gaps

1. Recheck exact heads and all applicable CI. Merge samples #158 by guarded
   rebase. Inspect #919's missing-source failure, rerun website CI, then merge
   only when all checks succeed. Verify merged files, deployment and live code.
2. Start the first actual library-topic column (Loops; I/O probes remain evidence,
   not a substitute entry). Fill the earliest missing language implementations:
   Atom assembly, BBC Micro BASIC, Electron BASIC, CPC assembly. Inspect existing
   callers/loaders first; preserve their operating-system and timing contracts.
3. Add callable state routines, complete callers, customisation and bounded
   faulty/fixed examples. Reuse the existing MOS game-loop wait where useful.
   Verify all four independently through the family tools, real input and native
   guest state/output, with source/tool/firmware identities and failing controls.
4. Add CodeFromFile entries and useful comparison links. Verify code, discovery,
   captures and narrow layouts; push source-first review PRs. Do not merge the
   new tranche without a further instruction.
5. Keep the machine/language matrix format, mark published vs review accurately,
   and update issue117/language inventory. Missing BASIC runtime/compiler paths
   on consoles remain unqualified work, not unsupported-hardware claims.
6. Retain evidence and remotely retained commits; inspect and remove task-owned
   worktrees, caches and processes before the final report.

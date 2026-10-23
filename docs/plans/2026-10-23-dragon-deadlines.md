# Dragon deadlines and following batches

Continue above samples #187 and website #978; create paired native GitHub stack layers, without merging.

1. Qualify Dragon BASIC: add `dragon-32/patterns/basic/framework/turn-deadline/{caller.bas,routines.bas,clock.bas,customise.bas,mistakes/reset-baseline.bas,Makefile,README.md,verification/*}`. Reuse the existing countdown arithmetic and observer transport, preserving Dragon TIMER modulo and INKEY$ semantics. Add `scripts/{verify,check}-dragon-deadlines.py` and falsification checks. Verify normal, custom, wrong, repaired, wrap/equality/overshoot/disabled and arbitration fixtures in released native Dragon emulation; inspect loaded BASIC lines and captures.
2. Add Dragon 6809 countdown implementation and independent assembly caller/fixtures under `dragon-32/patterns/assembly/framework/turn-deadline/`; retain firmware IRQ ownership and preserve interpreter entry/exit. Verify assembled/loaded bytes and independent native cases before publication.
3. Select a further deadline batch from audited existing routines, prioritising different hardware/language coverage. Record any capability blocker rather than inventing a timer.
4. For each qualified set, add code-first website entries, source/verification links, Maths links and focused browser checks. Verify exact rendered code, source artefacts and desktop/phone overflow. Push source before paired website PR; link native stacks #184 and #974 and child issues.
5. Update parent/child issue progress and stack order, retain evidence outside disposable worktrees, and remove all task workspaces/tools/processes after remote retention checks.

No new dependencies, no API unification, no weakening checks, no publication/merge this turn. Website CI remains dependent on unmerged source stack; retain exact failures.

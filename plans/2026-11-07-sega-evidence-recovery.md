# Finish the Sega evidence batch

Continue the approved byte-check plan's batch 8b after the interrupted
cherry-pick of #457 onto main containing #456. Preserve both recorder
registrations and both sets of failure controls; no emulator observations
are changed by the conflict resolution.

1. Review the resolutions in `scripts/check-probe-coverage.py`,
   `scripts/test_probe_coverage.py` and
   `plans/2026-11-07-evidence-recorders.json`. Keep the hardware-input and
   Sega entries. Verify JSON parses and no conflict markers remain.
2. Verify the Sega records' three `record_sha256` entries in
   `docs/probe-coverage.json` match the records in this cherry-pick.
   Run `test_probe_coverage.py`, `check-probe-coverage.py` against the
   registry named by the manifest, Ruff and `git diff --check`. The tests
   must reject a changed operand, forged program and changed observation,
   while accepting comments.
3. Finish the existing cherry-pick, push the replacement branch and open a
   replacement PR for #457. Read fresh CI before any merge. Leave the
   hardware-capability and game-loop PRs to separate follow-up changes.

The existing temporary worktree remains necessary until its replacement PR
is verified and merged; remove it only after checking unique changes and
retention of its commits.

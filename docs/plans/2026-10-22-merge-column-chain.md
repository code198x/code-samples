# Publish the language-separated Pattern Library expansion

1. Merge samples #165, then preserve the input/audio CI job while bringing its rebased parent into #166. Verify the workflow contains both jobs, run retained evidence checks and falsification tests, push, and wait for every applicable CI check.
2. Bring the same main history into #167 without removing its BASIC rendering job. Rerun its checks before merging.
3. Rerun website CI on #937, #938 and #941 against merged samples; resolve only chain conflicts, retain all checks, then merge in order after green CI.
4. Verify main content and publication, update the language-separated coverage matrix and tracker.
5. Inventory remaining map, region and pixel gaps; select reusable language-specific ports, document exact source files and emulator checks before implementation. Preserve separate BASIC, FORTH and assembly rows.
6. Remove task worktrees and stop task processes after retaining commits and evidence.

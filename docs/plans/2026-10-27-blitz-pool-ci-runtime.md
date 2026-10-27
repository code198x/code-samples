# Let the complete Blitz pool evidence job finish

The retained pool checker passes all twelve original imports, then the
five-minute CI job limit cancels the remaining tests. Two integration attempts
show the same sequence: the positive checker takes about three minutes on
these runners, leaving too little time for the native and corruption tests.
The same commands have completed on a faster PR runner and locally.

1. Change only `blitz-object-pool-records.timeout-minutes` in
   `.github/workflows/pattern-evidence.yml` from 5 to 15, matching the existing
   AMOS object-pool job. Keep the checker and both unittest commands unchanged.
2. Verify the exact workflow delta and unchanged sample, verifier and test
   blobs. Run the normal hooks and require the complete fresh PR workflows,
   all checks and attempts, including successful completion of the full Blitz
   pool job. A cancellation or test failure still blocks publication.
3. Review the exact head, ordinary-stack guard and actual-main candidate tree;
   merge by guarded rebase and verify the resulting tree. Recheck the merged
   integration workflow before publishing the paired pages.

This changes the CI wall-clock budget, not native evidence, test coverage,
guest runtime limits, dependencies or the sample API. The job remains bounded.

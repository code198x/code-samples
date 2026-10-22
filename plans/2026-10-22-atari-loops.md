# Merge BASIC turns; fill Atari console loop gaps

1. Recheck exact reviewed heads and every applicable CI result. Rebase-merge
   samples #157 first; verify merged tree. Diagnose the old website failure,
   rerun its workflow against merged samples and merge #918 only when green.
   Retain receipts, verify deployment and the published code/captures.
2. Reuse the existing atari-2600/5200/7800 input-loop probes, native verifier,
   rendering entries and documented hardware sources. Create separate callable
   turn/edge routines and machine-owned display service, complete callers,
   customisation and a measured fault/fix for each. Keep 2600 scanline production,
   5200 VCOUNT polling and 7800 MARIA blanking distinct.
3. Qualify all three with pinned family tools and independent native execution;
   retain bounded state/field observations and source/tool/firmware/capture
   identities. Evidence gates must reject missing data and faulty controls.
4. Add three website entries via CodeFromFile, link the existing comparison and
   drawing patterns, and verify code, discovery, images and phone layouts.
   Push source-first review PRs; new work is not pre-authorised for merging.
5. Track BASIC and assembly separately where a usable language path exists.
   Inventory current coverage, keep missing language implementations visible,
   and distinguish an unsupported/unqualified language route from a missing
   routine. Do not imply a BASIC entry fills the assembly gap. Update issue117
   and matrix with published Atom/CPC and in-review Atari work.
6. Retain evidence and remotely pushed commits, stop previews, inspect and
   remove task-owned worktrees, tools and caches before reporting completion.

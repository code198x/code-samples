# Commodore command-loop tranche

1. Merge source #161, rerun browser CI and gate website #925 on every applicable check. Verify publication before upgrading its matrix cells.
2. Reuse PET/VIC BASIC probes and C64 lessons. Add a reusable byte-counter command loop to C64 BASIC, PET BASIC/assembly and unexpanded PAL VIC-20 BASIC/assembly. Preserve firmware IRQs. Commands A/X/Q demonstrate accepted, ignored and quit decisions; no forced frame wait in an untimed game.
3. Maintain caller/routines/demo, step-three customisation and reset-each-command mistake in each machine/language folder under patterns/{track}/framework/command-loop. Assembly uses firmware GETIN/CHROUT, separately qualified addresses and BASIC loader. Keep state away from firmware workspace.
4. Add scripts/verify-commodore-command-loops.py, retained native screen/state records and a checker with deliberate failing controls. Test idle, invalid, two accepted commands, modulo wrap, nonzero initialisation, step three, mistake and repair on all five routes. Retain emulator, ROM, source and tool identities. Never inject counter state as proof of input execution.
5. Add five website MDX entries with exact CodeFromFile includes and Figures, contracts, load instructions, common mistakes, customisations and advanced alternatives. Extend loop comparison without discarding existing links. Check production build, relevant browser assertions, 320px overflow and image/listing bytes.
6. Publish source and website review PRs, update docs#117, language inventory and coverage matrix. Keep the new tranche in review. Preserve durable evidence, stop task processes and remove verified disposable worktrees/caches.

Temporary resources: /private/tmp/commodore-loops-{samples,site,tools}; preview ports 4387/4388. Durable logs and records: task outputs/commodore-loops. No new dependencies or emulator changes are commissioned.

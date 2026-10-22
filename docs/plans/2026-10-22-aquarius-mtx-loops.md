# Aquarius and MTX: next Loops rows

Status: authorised implementation, new tranche requires review before merge.

1. Reuse Aquarius BASIC command-loop and MTX stock BASIC READ/POKE/USR loader and assembly input-loop. Source-check firmware/display/input contracts, then qualify released Emu198x 0.44.1 and Asm198x 0.0.71 producer locks.
2. Add separate BASIC callers and reusable rule routines for both machines under `{mattel-aquarius,memotech-mtx}/patterns/basic/framework/command-loop/`: caller.bas, routines.bas, reusable.bas, customise.bas and mistakes/reset-each-command.bas. Preserve the older Aquarius demo/probe. Verify actual line entry, screen output, idle/accepted/ignored/nonzero/custom/wrong/fixed runs.
3. Add assembly caller/settings/update/input/presentation includes under each machine's patterns/assembly/framework/command-loop. Reuse existing loader routes; keep machine differences explicit. Native keyboard must drive persistent byte state; held input must not repeat; custom and wrap/nonzero variants plus wrong/fixed and no-edge controls must fail/pass the same observers. Do not manufacture an OS-coexistence claim for a takeover caller.
4. Add scripts/build-aquarius-mtx-loops.py, verify-aquarius-mtx-loops.py, check-aquarius-mtx-loops.py and falsification tests. Bind source, loaded bytes, registers/state, actual display memory and native captures to each independent route. Retain an additive docs/aquarius-mtx-loops.json inventory; preserve original baseline records.
5. After website #931 publishes, add four matching website entries using CodeFromFile and native figures; extend loop comparison. Production/unit/type and targeted desktop/phone/listing/image/accessibility checks; source-first review PRs.
6. Update docs#117 and canonical coverage matrix with separate language routes and exact publication/review status. Preserve evidence/remote commits, then remove owned temporary worktrees/tools/processes.

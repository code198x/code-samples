# Make the prototype names valid in AMOS

Native Merge ASCII and F1 through Emu198x reproduce a syntax error at
`Gosub READ_FRESH`. A reduced six-line example reproduces the token split into
`Read _FRESH`. AMOS's naming rules prohibit names beginning with command words.
`DRAW_STATE`, `REMAIN`, `MAXTURN` and `TOTAL` also begin with command words.
Whole-program retries stopped after the naming fault recurred. An isolated
`BR_` naming probe printed the expected values and both subroutine markers.

1. Give all game identifiers the checked `BR_` prefix in
   `commodore-amiga/amos/bank-or-risk/prototype/bank-or-risk.amos` without
   changing the input or scoring logic. Update the generator
   anchors to the same names; removing the prefixes must reproduce the original
   source bytes exactly.
2. Regenerate the fixed-roll sources into an empty directory and check their
   exact transformation and hashes. Import the corrected source through AMOS,
   qualify syntax and run the prepared cases as native access permits.
3. Update the sample README with the precise evidence and remaining limits;
   retain detailed captures/scripts in the Code198x docs audit.
4. Run diff and applicable generator checks, commit and push the draft branch.
   Verify retention and clean the temporary worktree after preserving evidence.

Source: AMOS Professional Manual, chapter 5.1, Naming variables, and chapter
5.4, control structures. Do not file a naming-rule violation as an emulator bug.

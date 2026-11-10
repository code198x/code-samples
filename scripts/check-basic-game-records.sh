#!/usr/bin/env bash
# Run the Spectrum BASIC games' own record checks, then require that none of
# them changed a tracked file.
#
# INTERIM. The plan (plans/2026-11-06-evidence-byte-check.md, item 4) replaces
# this, game by game, with strict checks that rebuild each record's program.
# Until then these audits still accept a record made from an earlier listing
# when source-lineage links the two texts. Remove a game's lines here when its
# strict check lands, and delete this script with the last one.
#
# Each audit reads only committed files. The derive.py regenerators and host
# models rewrite their tracked outputs, so `git diff` catches a listing that
# moved without its derived lessons or model record.
#
# Not run here:
# - WAV analysis checks whose inputs are not committed, so they can only run
#   after their recorder replays the game: bright-spark prototype pitches.py
#   and audio_separation.py, and meet-basic completion check_audio.py.
# - tail-chase teaching/comparison/compare.py, which fails: its results.json
#   names listings that have since changed (item 4 re-records them).
# - The recorders below, whose records no check reads yet (item 4):
#     brick-bash prototype build.py, check.py
#     bright-spark opening completion.py, cue-comparison.py,
#       finish-experiments.py, handover.py, sequence.py, verify.py,
#       wrong-note.py; prototype input_audio.py, pause.py, playback.py,
#       verify.py
#     crates prototype timing.py; teaching boundaries.py, fresh_tape.py,
#       graphics.py, timing.py, verify.py
#     drift prototype build.py, check.py
#     meet-basic completion-verification experiments.py, verify.py;
#       lucky-number verify.py, verify_experiments.py; opening verify.py,
#       verify_input.py, verify_named_story.py, verify_story.py
#     night-patrol prototype capture.py; teaching capture.py
#     sonar prototype bands.py, rounds.py, verify.py
#     tail-chase prototype build.py, verify.py
#     touchdown prototype build.py, capture.py, edges.py, flight.py,
#       opening.py, quit.py; teaching cases.py
#     volley prototype drawing.py, rally.py, spacing.py, verify.py
#
# Usage: scripts/check-basic-game-records.sh [VOLLEY_ROSTER]
#   VOLLEY_ROSTER is code198x/website's scripts/volley-roster.json; without
#   it the volley lesson check is skipped with a notice (CI always passes it).

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

GAMES=sinclair-zx-spectrum/basic
roster=${1:-}

run() {
    echo "::group::$*"
    "$@"
    echo "::endgroup::"
}

for game in brick-bash drift tail-chase; do
    run python3 "$GAMES/$game/teaching/verification/audit.py" \
        --evidence "$GAMES/$game/teaching/verification/evidence"
done
for game in cipher dice-roller locksmith night-patrol quickstep the-caverns three-in-a-row yearfall; do
    run python3 "$GAMES/$game/prototype/verification/audit.py"
done
for game in cipher crates dice-roller locksmith night-patrol quickstep sonar the-caverns three-in-a-row yearfall; do
    run python3 "$GAMES/$game/teaching/verification/audit.py"
done
for game in brick-bash crates drift locksmith quickstep sonar tail-chase; do
    run python3 "$GAMES/$game/teaching/verification/derive.py"
done
for game in night-patrol the-caverns three-in-a-row yearfall; do
    run python3 "$GAMES/$game/prototype/verification/model.py"
done
echo "::group::sonar deduction.py matches deduction.json"
python3 "$GAMES/sonar/prototype/verification/deduction.py" \
    | cmp - "$GAMES/sonar/prototype/verification/deduction.json"
echo "::endgroup::"
run python3 "$GAMES/touchdown/teaching/verification/lessons.py"
if [[ -n $roster ]]; then
    run python3 "$GAMES/volley/prototype/verification/lessons.py" --roster "$roster"
else
    echo "Skipping volley lessons.py: pass code198x/website's scripts/volley-roster.json"
fi

# A check that rewrote a tracked file, or left a new one, has found a record
# out of step with its listing.
git diff --exit-code -- "$GAMES"
untracked=$(git ls-files --others --exclude-standard -- "$GAMES")
if [[ -n $untracked ]]; then
    echo "Checks left untracked files:" >&2
    echo "$untracked" >&2
    exit 1
fi
echo "All BASIC game record checks passed and changed no file."

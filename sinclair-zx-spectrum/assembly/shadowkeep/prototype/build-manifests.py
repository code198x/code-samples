#!/usr/bin/env python3
"""Author capture/manifest.json for the woven Shadowkeep units (9-19).

Each manifest names a runnable step program and a boot+input+record timeline that
reproduces exactly the media its MDX references. The woven units boot to a title
(the state machine lands at Unit 9 step-02), so gameplay captures press SPACE to
enter; unit-09 step-01 boots straight into play. Routes are the ones proven to
win/lose in the code-chain verification, translated to hold/release/wait.

Run:  python3 build-manifests.py           # write all manifests
Then: cd code-samples && python3 _capture/capture.py \\
        sinclair-zx-spectrum/assembly/shadowkeep/unit-NN/capture/manifest.json \\
        --emu ~/Projects/198x/Emu198x/target/release/emu198x-spectrum
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]   # .../shadowkeep
REL = "sinclair-zx-spectrum/assembly/shadowkeep"


def enter():
    # boot -> title -> SPACE -> room drawn (draw_room ~18 frames)
    return [{"wait": 40}, {"hold": "Space"}, {"wait": 10}, {"release": "Space"}, {"wait": 24}]


def mv(k, n):
    return [{"hold": k}, {"wait": n}, {"release": k}]


def moves(seq):
    out = []
    for k, n in seq:
        out += mv(k, n)
    return out


HALL = [("A", 9), ("P", 11), ("O", 1), ("Q", 14), ("P", 1), ("P", 1), ("A", 5), ("P", 4)]
GALLERY = [("P", 23), ("O", 1), ("A", 9), ("P", 1), ("O", 9), ("Q", 20)]
VAULT = [("O", 5), ("Q", 2), ("A", 2), ("P", 10), ("Q", 2)]


def win_route():
    return moves(HALL) + [{"wait": 22}] + moves(GALLERY) + [{"wait": 22}] + moves(VAULT)


def to_vault():
    return moves(HALL) + [{"wait": 22}] + moves(GALLERY) + [{"wait": 22}]


MANIFESTS = {
    "unit-09": [
        {"id": "step-01-gold", "program": "steps/step-01.asm",
         "comment": "step-01 boots straight into play (no title yet); the Hall with its two coins.",
         "timeline": [{"wait": 40}, {"screenshot": "step-01-gold.png"}]},
        {"id": "step-02-clear", "program": "steps/step-02.asm",
         "comment": "All six coins across three rooms -> THE KEEP STANDS.",
         "timeline": enter() + [{"record_video": "step-02-clear.mp4"}] + win_route() + [{"wait": 70}, {"stop_video": True}]},
    ],
    "unit-10": [
        {"id": "step-01-warden", "program": "steps/step-02.asm",
         "comment": "The Warden gathering in the Hall on its column, between the coins.",
         "timeline": enter() + [{"screenshot": "step-01-warden.png"}]},
        {"id": "step-02-patrol", "program": "steps/step-02.asm",
         "comment": "The Warden walks its column up and back, reversing at walls (thief idle).",
         "timeline": enter() + [{"record_video": "step-02-patrol.mp4"}, {"wait": 260}, {"stop_video": True}]},
    ],
    "unit-11": [
        {"id": "step-02-keep-sleeps", "program": "steps/step-02.asm",
         "comment": "Thief onto the Warden's column; caught -> THE KEEP SLEEPS.",
         "timeline": enter() + moves([("Q", 1), ("P", 11)]) + [{"wait": 62}, {"screenshot": "step-02-keep-sleeps.png"}]},
        {"id": "step-02-caught", "program": "steps/step-02.asm",
         "comment": "Onto the column, the patrol arrives and catches -> THE KEEP SLEEPS.",
         "timeline": enter() + [{"record_video": "step-02-caught.mp4"}] + moves([("Q", 1), ("P", 11)]) + [{"wait": 70}, {"stop_video": True}]},
    ],
    "unit-12": [
        {"id": "step-02-vault", "program": "steps/step-02.asm",
         "comment": "The Vault, its own Warden pacing the row between the two coins.",
         "timeline": enter() + to_vault() + [{"screenshot": "step-02-vault.png"}]},
        {"id": "step-02-clear", "program": "steps/step-02.asm",
         "comment": "All six contested coins, all three guarded rooms -> THE KEEP STANDS.",
         "timeline": enter() + [{"record_video": "step-02-clear.mp4"}] + win_route() + [{"wait": 70}, {"stop_video": True}]},
    ],
    "unit-13": [
        {"id": "step-01-lit", "program": "steps/step-01.asm",
         "comment": "The Hall lit by one torch: a pool of light fading to shadow.",
         "timeline": enter() + [{"screenshot": "step-01-lit.png"}]},
        {"id": "step-01-into-dark", "program": "steps/step-01.asm",
         "comment": "From the lit pool under the torch, down into the deepening dark and back.",
         "timeline": enter() + [{"record_video": "step-01-into-dark.mp4"}] + moves([("Q", 5)]) + [{"wait": 15}] + moves([("A", 9)]) + [{"wait": 15}] + moves([("Q", 6)]) + [{"wait": 20}, {"stop_video": True}]},
    ],
    "unit-14": [
        {"id": "step-01-furnished", "program": "steps/step-01.asm",
         "comment": "The furnished Hall: statue in the torchlight, banners, rubble.",
         "timeline": enter() + [{"screenshot": "step-01-furnished.png"}]},
        {"id": "step-01-around-and-over", "program": "steps/step-01.asm",
         "comment": "Up to the statue (solid), then across the rubble (walkable) and off it.",
         "timeline": enter() + [{"record_video": "step-01-around-and-over.mp4"}] + moves([("Q", 6)]) + [{"wait": 18}] + moves([("O", 4)]) + [{"wait": 12}] + moves([("P", 8)]) + [{"wait": 18}, {"stop_video": True}]},
    ],
    "unit-15": [
        {"id": "step-01-vault", "program": "steps/step-01.asm",
         "comment": "The Vault as a crypt: one altar flame, a tight pool, the rest near-black.",
         "timeline": enter() + to_vault() + [{"screenshot": "step-01-vault.png"}]},
        {"id": "step-01-mood", "program": "steps/step-01.asm",
         "comment": "Broad Hall -> medium Gallery -> tight crypt Vault; the falloff changing under you.",
         "timeline": enter() + [{"record_video": "step-01-mood.mp4"}, {"wait": 30}] + moves(HALL) + [{"wait": 25}] + moves(GALLERY) + [{"wait": 52}, {"stop_video": True}]},
    ],
    "unit-16": [
        {"id": "step-01-hall", "program": "steps/step-01.asm",
         "comment": "The Hall lit by three sconces, pools overlapping into a broad wash.",
         "timeline": enter() + [{"screenshot": "step-01-hall.png"}]},
        {"id": "step-01-vault", "program": "steps/step-01.asm",
         "comment": "The Vault, one cold altar flame against the Hall's three: the opposite character.",
         "timeline": enter() + to_vault() + [{"screenshot": "step-01-vault.png"}]},
    ],
    "unit-17": [
        {"id": "step-01-hall", "program": "steps/step-01.asm",
         "comment": "The Hall, unchanged on screen; everything new here is heard.",
         "timeline": enter() + [{"screenshot": "step-01-hall.png"}]},
        {"id": "step-01-footsteps", "program": "steps/step-01.asm",
         "comment": "Walk the Hall floor (no doorway), recording the footfall under each step.",
         "timeline": enter() + [{"record_audio": "step-01-footsteps.wav"}] + moves([("A", 8)]) + [{"wait": 10}] + moves([("Q", 8)]) + [{"wait": 10}, {"stop_audio": True}]},
        {"id": "step-01-door", "program": "steps/step-01.asm",
         "comment": "Cross the Hall's east door, recording the creak as the room flicks.",
         "timeline": enter() + [{"record_audio": "step-01-door.wav"}] + moves([("P", 16)]) + [{"wait": 30}, {"stop_audio": True}]},
    ],
    "unit-18": [
        {"id": "step-01-title", "program": "steps/step-01.asm",
         "comment": "The title, the theme looping beneath it (no SPACE — we stay on the title).",
         "timeline": [{"wait": 40}, {"screenshot": "step-01-title.png"}]},
        {"id": "step-01-theme", "program": "steps/step-01.asm",
         "comment": "Record the looping D-minor title theme.",
         "timeline": [{"wait": 30}, {"record_audio": "step-01-theme.wav"}, {"wait": 320}, {"stop_audio": True}]},
    ],
    "unit-19": [
        {"id": "step-01-title", "program": "steps/step-01.asm",
         "comment": "The title crowned with stone battlements, the theme looping.",
         "timeline": [{"wait": 40}, {"screenshot": "step-01-title.png"}]},
        {"id": "step-01-both-endings", "program": "steps/step-01.asm",
         "comment": "A win read to THE KEEP STANDS, back to the title, then a run caught -> THE KEEP SLEEPS.",
         "timeline": [{"wait": 60}, {"record_video": "step-01-both-endings.mp4"}, {"wait": 30}]
                     + [{"hold": "Space"}, {"wait": 10}, {"release": "Space"}, {"wait": 24}]
                     + win_route() + [{"wait": 60}]
                     + [{"hold": "Space"}, {"wait": 10}, {"release": "Space"}, {"wait": 30}]
                     + [{"hold": "Space"}, {"wait": 10}, {"release": "Space"}, {"wait": 24}]
                     + moves([("Q", 1), ("P", 11)]) + [{"wait": 70}, {"stop_video": True}]},
    ],
}


def main():
    for unit, captures in MANIFESTS.items():
        d = ROOT / unit / "capture"
        d.mkdir(parents=True, exist_ok=True)
        manifest = {"machine": "sinclair-zx-spectrum", "image_dir": f"{REL}/{unit}", "captures": captures}
        (d / "manifest.json").write_text(json.dumps(manifest, indent=1) + "\n")
        print(f"{unit}/capture/manifest.json  ({len(captures)} captures)")


if __name__ == "__main__":
    main()

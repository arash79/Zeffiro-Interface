# scripts/data

## Folder purpose

Small **fixture data** sitting beside developer / documentation scripts under `scripts/`. It is **not** part of the runtime `data/` tree that `zeffiro_interface` opens by default (`data/example_projects`, `data/segmentations`, electrodes, etc.). Use this folder for offline experiment mats that scripts or notebooks load explicitly by path.

## Main contents

| File | Role |
|------|------|
| `SEP_synth_source_data.mat` | Synthetic SEP-style source fixture for offline experiments |
| `README.md` | This documentation |

### `SEP_synth_source_data.mat`

- Top-level variable: **`SEP_synth_source_data`**
- MATLAB class: object array sized **`(1, 9)`** (nine elements)
- Intended as synthetic source / SEP-oriented demo payload for scripts living next to `scripts/` — not a full Zeffiro project `.mat` (`zef` struct)

Adjacent `scripts/` items (not in this folder): `zeffiro_doc_pass.py`, contributing notes, and other developer utilities documented in `../README.md`.

## Code functionality

No loader API and no GUI entry point. Consumers `load` the mat explicitly. There is no first-party menu callback that requires this fixture for normal interface use.

Typical pattern:

```matlab
repo = fileparts(which('zeffiro_interface'));
S = load(fullfile(repo, 'scripts', 'data', 'SEP_synth_source_data.mat'));
obj = S.SEP_synth_source_data;   % 1×9 object array
```

Inspect fields with `properties(obj)` / `obj(1)` after load — regenerate documentation here if the object schema changes.

## Workflow context

```
scripts/                 ← developer utilities & doc tooling
  data/                  ← this folder (fixtures)
  *.py / notes           ← consumers may load fixtures
data/                    ← runtime projects, segmentations, media
  example_projects/      ← loadable Zeffiro projects
```

| Location | Use |
|----------|-----|
| `scripts/data` | Offline / script fixtures |
| `data/example_projects` | Official openable projects |
| `data/segmentations` | Mesh / compartment libraries |
| `+examples` | Packaged example workflows |

Prefer promoting a fixture into `data/` or `+examples` once it becomes part of an official demo path.

## Usage instructions

1. Ensure Zeffiro is on the path so `which('zeffiro_interface')` resolves (or substitute your repo root).
2. `load` the mat as shown above.
3. Document in the consuming script which of the nine objects / which properties are required.
4. Do not assume `zef_load` understands this file — it is not a project dump.

Example exploratory session:

```matlab
S = load(fullfile(fileparts(which('zeffiro_interface')), ...
    'scripts', 'data', 'SEP_synth_source_data.mat'));
whos('-file', fullfile(fileparts(which('zeffiro_interface')), ...
    'scripts', 'data', 'SEP_synth_source_data.mat'));
disp(S.SEP_synth_source_data);
```

## Important notes

- Orphan fixtures are easy to forget — keep field / object schema notes in the script that consumes them **and** refresh this README when regenerating the mat.
- Do not confuse with `data/segmentations` or `data/example_projects`.
- The `(1, 9)` object array is small on disk today; still avoid committing large derived copies beside it.
- No INI / plugin registration points at this path.

## Developer guidance

- If this mat becomes part of an official example, move it under `data/` or `+examples` and update all load paths.
- When regenerating `SEP_synth_source_data.mat`, record: variable name, array size, class/property list, and the script that built it.
- Add new fixtures as clearly named mats with a one-paragraph entry in **Main contents**; avoid dumping unrelated binary logs here (use `data/log/` for those).
- Keep `../README.md`’s table row for `data/` in sync when adding files.
- Prefer deterministic RNG seeds in generators so fixtures stay reviewable in git diffs (or document why a binary mat is expected to change).

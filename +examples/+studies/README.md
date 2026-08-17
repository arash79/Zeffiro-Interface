# +examples/+studies

## Folder purpose

Research / paper study trees (not CI). Each subpackage is a self-contained experiment that expects a configured `zef` and often hard-coded author paths — edit before running.

## Main contents

| Package | Entry | What it does |
|---------|-------|----------------|
| `+decision_making/` | `zef_decision_script_focal_epilepsy` (+ create/process/find) | Focal epilepsy Data Bank cluster + MNE/GMM-style callbacks; helpers in `+helpers/` |
| `+santtus_peeling_article/` | `main(...)` | Monte Carlo localization error vs noise (sLORETA/dSPM/MNE/dipole scan); EEG LF via `zef_eeg_lead_field` |
| `+tES_hyperparameter_optimization/` | `zef_ES_recursive_search(zef, num_lattice)` | Shrink ES-workbench α/ε lattice — **distinct** from plugin `tools/.../zef_ES_recursive_search` (GUI 3-arg) |

## Code functionality

Study scripts orchestrate mesh/LF/inverse/plugin calls, write figures or `.mat` results, and may open Data Bank or ES helpers. See each study’s README for parameters and outputs.

## Workflow context

Depends on `tools/plugins` (Data Bank, GMM, ES Workbench, …), `src/forward/lead_field`, and sometimes cluster utilities. Not started from default menus.

## Usage instructions

```matlab
% Example — read the study README first, then:
cd +examples/+studies/+santtus_peeling_article
% follow main(...) signature in that package
```

## Important notes

- Hard-coded paths and machine-local data are common — expect edits.
- Name clash: study vs plugin `zef_ES_recursive_search` (path order wins).
- Not part of `runtests('+tests')`.

## Developer guidance

- Keep paper-specific constants in the study package; upstream bugfixes belong in `src/` / plugins.
- Pitfall: committing large result dumps into the study folder.

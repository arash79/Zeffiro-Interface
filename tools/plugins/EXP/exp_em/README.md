# tools/plugins/EXP/exp_em

## Folder purpose

Legacy GUIDE plugin for **EXP EM MAP** estimation: exponential-prior EM / L1-style inverse for EEG–MEG. This is the single-resolution EM sibling of the EXP IAS / multiresolution tools under `tools/plugins/EXP/`. It is **not** on the default `multicompartment_head` Inverse-tools menu (that profile uses the App Designer Lasso / EXP app launch path).

## Main contents

| Path | Role |
|------|------|
| `m/exp_em_map_estimation.m` | Start script: open GUIDE fig + `zef_init_exp_em` |
| `m/zef_init_exp_em.m` | Defaults for `exp_em_*` / shared `inv_*`; bind widgets |
| `m/zef_update_exp_em.m` | Widgets → `zef` before Start |
| `m/exp_em_iteration.m` | Solver core (`zef_processLeadfields` → EM/L1 → post-process) |
| `fig/exp_em_map_estimation.fig` | GUIDE UI (Start → `exp_em_iteration`) |
| `fig/README.md` | Fig-specific notes |

## Code functionality

**Pipeline**

1. Open UI → initialize defaults / bind controls.
2. User edits SNR, time/band, `q`, iteration counts, etc.
3. Start runs `exp_em_iteration`: process lead fields → EM updates (closed form when `q==2`, else `L1_optimization`-style path) → `zef_postProcessInverse` / normalize.
4. Tag in `reconstruction_information`: `'EXP EM'`.

**Needs:** `zef.L`, `zef.measurements`, interpolation / source space, inv time & SNR fields.  
**Uses:** `evalin('base','zef…')` extensively (GUIDE-era).

## Workflow context

| Sibling | Difference |
|---------|------------|
| `EXP/exp_ias` | IAS MAP (not EM) |
| `EXP/exp_em_multires` | EM + multiresolution lattices |
| App Designer EXP / Lasso tools | Default head-profile Inverse-tools entries |
| `+inverse/@HALpRInverter` / GroupLasso | Class/cluster path — separate API |

Not listed in default `profile/multicompartment_head/zeffiro_plugins.ini`; launch manually or from profiles that still register it.

## Usage instructions

```matlab
% After GUI session with lead field + measurements:
exp_em_map_estimation;   % opens fig; press Start in UI
```

Ensure `tools/plugins/EXP/exp_em/m` is on the plugin path (normal Zeffiro startup via profile/plugins path setup).

## Important notes

- Distinct `exp_em_*` field namespace — do not mix casually with `exp_ias_*` or `exp_multires_*`.
- GUIDE figures need a display; unsuitable for pure nodisplay batch unless you call `exp_em_iteration` carefully.
- Requires lead field and measurements before Start.

## Developer guidance

- Prefer porting improvements to App Designer / `+inverse` rather than extending GUIDE callbacks.
- If editing the solver, keep `exp_em_iteration` numerically aligned with any class inverter cousin and add a `+tests` comparison when possible.
- Pitfall: running Start with empty `zef.L` or mismatched measurement size.

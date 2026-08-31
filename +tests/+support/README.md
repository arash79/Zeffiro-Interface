# `tests.support` — synthetic `zef` fixtures

## Folder purpose

Shared constructors for **minimal `zef` structs** used by inverse unit, integration, and smoke tests. These are not tests (`matlab.unittest` is not involved). Call as `tests.support.createSyntheticInverseZef` after the project root is on the path.

Parent map: [`../README.md`](../README.md).

## Main contents

| Function | Typical consumer | Geometry |
|----------|------------------|----------|
| `createSyntheticInverseZef` | Almost every inverse test | 4 sensors, 2 sources, `L` is `randn(4,6)` (mode 1: 3 components × 2 sources), 3 measurement frames |
| `createSyntheticUKFNMMZef` | UKFNMM unit + dispatch tests | Defaults: 8 sensors, 6 sources, 12 frames, `fs=100` Hz, Gaussian bumps in time + 2% noise. Name-value overrides for all of those |

## Code functionality

### `createSyntheticInverseZef`

Returns a **plain struct**, not a GUI session. Important fields:

| Field | Value / why it matters |
|-------|------------------------|
| `source_direction_mode` | `1` (Cartesian). Mode 1 expects 3 columns of `L` per source |
| `source_interpolation_ind{1}` | **Column** `(1:n_interp)'` so `zef_postProcessInverseClassObj` can expand xyz indices |
| `L` | `randn(n_sensors, 3*n_interp)` |
| `measurements` | `randn(n_sensors, n_frames)` |
| `inv_data_mode` | `'raw'` (bundle extraction skips extra data-mode conversion) |
| Band / time / SNR | `inv_low_cut_frequency=7`, `high=9`, `inv_sampling_frequency=1025`, `number_of_frames=3`, `inv_snr=30` |
| `use_gpu` | `false` |
| Legacy plugin fields | `csm_type`, `mne_*`, `filter_type`, `kf_*`, `standardization_exponent` so `legacy_*` dispatch can `feval` without missing-field errors |

There is **no** mesh (`nodes` / `tetra`), **no** `h_*` handles, **no** `compartment_tags`. Do not pass this struct to `zef_create_finite_element_mesh` or `zef_lead_field_matrix`.

### `createSyntheticUKFNMMZef`

Starts from `createSyntheticInverseZef`, then replaces `L` / sources / measurements. `rng(1,"twister")` is used inside so the bump time courses are repeatable. Bumps are placed on source 1 (and 3 / 5 when those indices exist) so k-means (`number_of_corrclusters+1`) and Jansen–Rit fitting have more than one spatial blob. Band cuts are set to `0` so the frame loop does not band-pass away the synthetic pulse.

Name-values (`arguments` block): `n_sensors`, `n_sources`, `n_frames`, `sampling_frequency`, `noise_level`.

## Workflow context

```
tests.support.*  →  tests.unit / tests.integration / tests.smoke.EndToEndSyntheticTest
                 →  zef_inverse_extract_bundle / invert / zef_inverse_run
```

Production converters (`utilities.fs2zef.run`) and `data/segmentations/` are unrelated. Do not mix this fixture with `data/example_projects/*.mat`.

## Usage instructions

```matlab
zef = tests.support.createSyntheticInverseZef();
[zef_out, r] = zef_inverse_run(zef, "eloreta", "execution", "local");

zef_nmm = tests.support.createSyntheticUKFNMMZef("n_frames", 20);
```

## Important notes

- `L` is unstructured random (or random with a known bump image). Reconstruction “looks” like noise except in UKFNMM bump tests.
- Interpolation index **must stay a column**. A row vector breaks post-process expansion and has caused false test failures.
- Fixtures do not set `source_model` / `lead_field_type`; class invert does not need them once `L` exists.

## Developer guidance

- Add a new fixture here when several tests would otherwise copy a 40-line struct. Keep it a function, not a script.
- Do not add GUI handles or `evalin('base')` to these helpers.
- If a solver needs extra `zef` fields, set them in the **test** after calling the fixture so the shared constructor stays minimal.
- Pitfall: growing `createSyntheticInverseZef` into a fake head model. Mesh/forward tests should use `+examples` or `data/`, not this package.

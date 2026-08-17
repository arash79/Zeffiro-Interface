# DipoleScan / m

## Folder purpose

App Designer plugin for **single-dipole scan** (goodness-of-fit map over sources). Inverse tools → Dipole Scan. Does not call `inverse.DipoleScanInverter`.

## Main contents

| File | Role |
|------|------|
| `zef_dipole_start.m` | INI callback → `zef_tool_start('zef_dipole_window')` |
| `zef_dipole_window.m` | Instantiates `dipole_app`, binds Start/Close |
| `zef_dipoleScan.m` | Scan solver per frame |

## Code functionality

- Window creates `zef.dipole_app`, seeds missing `inv_*` defaults, syncs app properties from `zef`, sets:
  - `StartButton` → `[zef.reconstruction, zef.reconstruction_information]=zef_dipoleScan(zef)`
  - `CloseButton` → `delete(zef.dipole_app)`
- Scan: `zef_processLeadfields`, `zef_getFilteredData` / `zef_getTimeStep`; per source (cortical-normal vs free orientation) fit via `InversionmethodDropDown` (`SVD` or `pinv`) and `regType` / `inv_leadfield_lambda`.
- Writes cell `z` (one vector per frame); `onlymax` is false as written (full GOF map). Info tag like `'Dipole' + invMethod`.

## Workflow context

Needs `zef.L` and measurements. Useful for localizing focal activity before sparse or distributed methods. Shares global `inv_snr`, time/filter fields with other inverse tools.

## Usage instructions

1. Build lead field and load measurements.
2. Open Dipole Scan (`zef_dipole_start`).
3. Set SNR, sampling, band, time windows, frames, inversion method / regularization.
4. Start; visualize `zef.reconstruction`.

## Important notes

- Relies on App Designer class `dipole_app` (sibling mlapp folder on path).
- Direction modes 1–2 treat cortical-normal indices (`procFile.s_ind_4`) with 1-column lead fields; free sources use multi-column SVD/pinv.
- Some L_reg_type branches disable lambda UI (commented paths remain in the window file).

## Developer guidance

Keep solver options read from `zef.dipole_app.*` in sync with app control Tags. Prefer `zef_dipoleScan` for algorithm changes; keep `zef_dipole_window` as UI glue only. Class path: `inverse.DipoleScanInverter` for non-GUI runs.

# DTI Conductivity Tool Plugin

Zeffiro Interface plugin providing a graphical user interface for importing FreeSurfer DTI data and applying anisotropic electrical conductivity to the finite element mesh.

## Overview

This plugin wraps the core DTI pipeline (`m/forward_simulation/dti/`) with a MATLAB `uifigure`-based GUI. It handles file selection, parameter configuration, data loading, compartment selection, and mesh application through an interactive workflow. Coordinate transformation matrices are automatically extracted from the input files — no manual matrix entry is required.

The plugin is registered in the Zeffiro plugin system and appears under **Forward Tools > DTI Conductivity Tool** in the menu.

## Prerequisites

- **MATLAB R2019a+** (for `uifigure` UI components)
- **FreeSurfer** installation with `mri_info` on PATH and `FREESURFER_HOME` set
- A Zeffiro project with a valid FEM mesh (nodes/tetra)
- FreeSurfer `dt_recon` output: `fa.nii.gz`, `register.dat`, optionally `v1.nii.gz`
- FreeSurfer `recon-all` output: a reference anatomical volume (e.g. `orig.mgz`)

## Plugin Registration

Registered in `profile/multicompartment_head/zeffiro_plugins.ini`:

```
DTI Conductivity Tool,forward_tools,zef_dti_conductivity_open
```

## File Reference

### Entry Point and Lifecycle

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_conductivity_open.m` | `zef_dti_conductivity_open` | **Plugin entry point.** Creates the GUI window, initializes default parameters, syncs GUI state from `zef`, and updates model-specific control visibility. |
| `zef_dti_conductivity_window.m` | `zef_dti_conductivity_window` | Builds the complete `uifigure` GUI with panels for file selection, conversion model parameters, interpolation settings, compartment selection, action buttons, and an information display. Supports responsive resizing. |
| `zef_dti_conductivity_init.m` | `zef_dti_conductivity_init` | Initializes all plugin-specific fields in the `zef` struct with sensible defaults if they do not already exist. Includes file paths, FreeSurfer data fields, conversion parameters, interpolation settings, transformation matrices, geometry structs, and status flags. |
| `zef_dti_conductivity_update.m` | `zef_dti_conductivity_update` | Synchronizes all GUI elements from current `zef` struct values. Called after data loading, parameter changes, or window reopening. Updates file paths, status labels, model controls, compartment lists, and information text. |
| `zef_dti_conductivity_clear.m` | `zef_dti_conductivity_clear` | Resets all FreeSurfer data fields, geometry structs, and transformation matrices to their initial state. Does not clear `zef.sigma` (preserving any applied conductivity). |

### Data Loading

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_conductivity_load_freesurfer.m` | `zef_dti_conductivity_load_freesurfer` | Loads all FreeSurfer data files specified in the GUI. Calls `zef_freesurfer_load_fa`, `zef_freesurfer_load_v1` (if path provided), `zef_freesurfer_read_register_dat`, and `zef_freesurfer_read_volume_geometry` for both FA and reference MRI. Stores all data and auto-extracted geometry in `zef`. |

### File Browsers

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_conductivity_browse_ref.m` | `zef_dti_conductivity_browse_ref` | Opens a file dialog for the reference MRI (`.mgz`, `.mgh`, `.nii`, `.nii.gz`) and stores the selected path in `zef.dti_ref_mri_file`. Geometry extraction is deferred to the Load step. |
| `zef_dti_conductivity_browse_fa.m` | `zef_dti_conductivity_browse_fa` | Opens a file dialog for `fa.nii.gz` and stores the selected path in `zef.freesurfer_fa_file`. |
| `zef_dti_conductivity_browse_v1.m` | `zef_dti_conductivity_browse_v1` | Opens a file dialog for `v1.nii.gz` (optional) and stores the selected path in `zef.freesurfer_v1_file`. |
| `zef_dti_conductivity_browse_register.m` | `zef_dti_conductivity_browse_register` | Opens a file dialog for `register.dat` and stores the selected path in `zef.freesurfer_register_file`. |

### Parameter Update Callbacks

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_conductivity_update_model.m` | `zef_dti_conductivity_update_model` | Syncs `zef.dti_conductivity_model` from the conversion model dropdown. |
| `zef_dti_conductivity_update_conversion_model.m` | `zef_dti_conductivity_update_conversion_model` | Syncs all conversion model parameters (volume fraction, extra/intra conductivity, scale factor, anisotropy threshold, model type) from GUI spinners and dropdown to `zef`. |
| `zef_dti_conductivity_update_interpolation_model.m` | `zef_dti_conductivity_update_interpolation_model` | Syncs interpolation mode and radius from GUI controls to `zef`. |
| `zef_dti_conductivity_update_compartments.m` | `zef_dti_conductivity_update_compartments` | Syncs `zef.dti_apply_to_compartments` from the multi-select compartment listbox. |

### Action

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_conductivity_apply_button_callback.m` | `zef_dti_conductivity_apply_button_callback` | Handles the "Apply to Mesh" button. Calls `zef_dti_apply_to_sigma` from the core DTI library to execute the full conversion-interpolation-assignment pipeline, then refreshes the GUI. |

### Utilities

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_empty_geometry_struct.m` | `zef_dti_empty_geometry_struct` | Returns an empty geometry struct matching the output format of `zef_freesurfer_read_volume_geometry`. Used by `zef_dti_conductivity_init` to initialize `zef.dti_fa_geometry` and `zef.dti_ref_geometry` so that dot-indexing does not error before data is loaded. |

## User Workflow

1. **Open the tool:** Forward Tools > DTI Conductivity Tool (or call `zef_dti_conductivity_open`).
2. **Select Reference MRI:** Click Browse next to "Reference MRI" and select `orig.mgz` (or similar).
3. **Select FA file:** Browse for `fa.nii.gz` from the `dt_recon` output directory.
4. **Select v1 file (optional):** Browse for `v1.nii.gz` to enable direction-aware anisotropy.
5. **Select register.dat:** Browse for `register.dat` from the `dt_recon` output directory.
6. **Click Load:** Imports all data, extracts reference MRI geometry, and computes transformation matrices.
7. **Configure conversion model:** Select a model from the dropdown and adjust parameters.
8. **Configure interpolation:** Choose mode (Nearest Neighbor or Radius Average) and set the averaging radius.
9. **Select compartments:** Choose which mesh compartments receive anisotropic conductivity (default: gray + white matter).
10. **Click Apply to Mesh:** Executes the pipeline and updates `zef.sigma_anisotropy`. A summary report prints to the command window.

## GUI Layout

```
+---------------------------------------------------------------+
|  ZEFFIRO Interface: DTI Conductivity Tool                     |
+---------------------------------------------------------------+
|  Status: [status message]                                     |
+---------------------------------------------------------------+
|  FreeSurfer Input Files                                       |
|    Reference MRI: [path]  [Browse...]                         |
|    FA File:       [path]  [Browse...]    [Load]               |
|    v1 File:       [path]  [Browse...]    [Clear]              |
|    register.dat:  [path]  [Browse...]                         |
+---------------------------------------------------------------+
|  Conversion Model                                             |
|    Model: [dropdown]                                          |
|    Volume Fraction: [spinner]  Extra: [spinner]  Intra: [sp]  |
|    Scale Factor: [spinner]                                    |
|    Anisotropy Threshold: [spinner]                            |
|    [Update Conversion Model Parameters]                       |
+---------------------------------------------------------------+
|  Interpolation                                                |
|    Mode: [dropdown]        Radius: [spinner] mm               |
|    [Update Interpolation Model]                               |
+---------------------------------------------------------------+
|  Compartment Selection                                        |
|    Apply to compartments: [multi-select listbox]  [Apply]     |
+---------------------------------------------------------------+
|  Information                                                  |
|    [read-only text area with current state and instructions]  |
+---------------------------------------------------------------+
```

## Development Guide

### Adding a New GUI Control

1. Add the UI element in `zef_dti_conductivity_window.m` with appropriate position, label, and `ValueChangedFcn` callback.
2. Add the default value in `zef_dti_conductivity_init.m`.
3. Add the sync logic in `zef_dti_conductivity_update.m` (from `zef` to GUI).
4. If the control modifies a conversion or interpolation parameter, add it to the respective `update_conversion_model` or `update_interpolation_model` function.
5. Read the parameter in `zef_dti_apply_to_sigma.m` from the `zef` struct.

### Adding a New File Browser

1. Create a new `zef_dti_conductivity_browse_<name>.m` following the pattern in existing browse functions.
2. Wire it into `zef_dti_conductivity_window.m` via a button's `ButtonPushedFcn`.
3. Add the field default in `zef_dti_conductivity_init.m`.

### Plugin Architecture

The plugin follows Zeffiro's standard pattern:
- **Entry:** `zef_dti_conductivity_open` (registered in `zeffiro_plugins.ini`)
- **State:** All state lives in the `zef` struct in the base workspace
- **GUI-to-data:** Callbacks write to `zef` fields and call `assignin('base','zef',zef)`
- **Data-to-GUI:** `zef_dti_conductivity_update` reads `zef` fields and sets GUI widget values
- **Computation:** Delegated to the core library in `m/forward_simulation/dti/`
- **Resizing:** Uses `zef_get_relative_size` / `zef_change_size_function` for proportional scaling

## Relationship to Kalman Filter DTI Integration

The DTI data loaded by this plugin (FA, v1, register.dat, reference MRI geometry) is also used by the **Kalman filter plugin** (`plugins/Kalman/`) for building structurally informed process noise covariance matrices. Once you have loaded DTI data via this tool (i.e., the `zef` struct contains `freesurfer_fa_data`, `freesurfer_v1_data`, `freesurfer_register_transform`, and `dti_ref_geometry`), you can enable DTI-informed Kalman filtering by setting:

```matlab
zef.kf_structural_Q_type = 1;   % FA-based structural Q
% or
zef.kf_structural_Q_type = 2;   % Tractography-based structural Q

zef = zef_KF(zef);              % Run Kalman filter with structural prior
```

The Kalman integration reads from the same `zef` fields populated by this plugin's Load button — no additional data loading is needed. See `plugins/Kalman/README.md` for full details.

### Key `zef` Fields

| Field | Type | Description |
|-------|------|-------------|
| `freesurfer_fa_file` | string | Path to `fa.nii.gz` |
| `freesurfer_v1_file` | string | Path to `v1.nii.gz` |
| `freesurfer_register_file` | string | Path to `register.dat` |
| `dti_ref_mri_file` | string | Path to reference MRI (e.g. `orig.mgz`) |
| `freesurfer_fa_data` | `[nx x ny x nz]` single | Loaded FA volume |
| `freesurfer_v1_data` | `[nx x ny x nz x 3]` single | Loaded v1 direction field |
| `freesurfer_register_transform` | `[4 x 4]` double | Parsed `register.dat` matrix |
| `freesurfer_fa_info` | struct | NIfTI info from `niftiinfo` |
| `dti_ref_geometry` | struct | Auto-extracted reference MRI geometry |
| `dti_conductivity_model` | 1, 2, or 3 | Selected conversion model |
| `dti_volume_fraction` | scalar | Volume fraction parameter |
| `dti_extra_conductivity` | scalar (S/m) | Extracellular conductivity |
| `dti_intra_conductivity` | scalar (S/m) | Intracellular conductivity |
| `dti_conductivity_scale` | scalar | Direct scaling factor |
| `dti_anisotropy_threshold` | scalar | Minimum FA for anisotropy |
| `dti_interpolation_mode` | string | `'nearest'` or `'radius_average'` |
| `dti_interpolation_radius` | scalar (mm) | Averaging radius |
| `dti_apply_to_compartments` | cell of strings | Compartment tags to update |
| `sigma_anisotropy` | `[M x 6]` | Per-tetrahedron conductivity tensor |
| `dti_applied` | logical | Whether conductivity has been applied |

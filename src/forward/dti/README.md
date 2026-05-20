# DTI Anisotropic Conductivity Pipeline

Core computation library for converting FreeSurfer diffusion tensor imaging (DTI) data into anisotropic electrical conductivity tensors and mapping them onto Zeffiro finite element meshes.

## Overview

This module implements the biophysical conversion from DTI-derived fractional anisotropy (FA) and principal eigenvector (v1) data to symmetric positive-definite conductivity tensors assigned per tetrahedron. It handles the full coordinate transformation chain between FreeSurfer's FA voxel space and Zeffiro's mesh display space, and provides streamline visualization capabilities.

The pipeline operates on FreeSurfer `dt_recon` outputs and does **not** require raw DWI volumes or re-computation of the diffusion tensor.

## Prerequisites

- **MATLAB R2017b+** (for `niftiread`, `niftiinfo`, `griddedInterpolant`)
- **FreeSurfer** installation with `mri_info` available on PATH (`FREESURFER_HOME` must be set)
- FreeSurfer `dt_recon` output directory containing:
  - `fa.nii.gz` — fractional anisotropy map
  - `v1.nii.gz` — principal eigenvector field (optional but recommended)
  - `register.dat` — affine registration matrix
- FreeSurfer `recon-all` output providing a reference anatomical volume (e.g. `orig.mgz`)

## File Reference

### Main Integration

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_apply_to_sigma.m` | `zef_dti_apply_to_sigma` | **Primary entry point.** Orchestrates the full FA-to-mesh conductivity pipeline: validates inputs, converts FA to conductivity, interpolates to mesh centroids, applies to selected compartments, and stores the result in `zef.sigma_anisotropy`. |

### FA-to-Conductivity Conversion

| File | Function | Description |
|------|----------|-------------|
| `zef_freesurfer_fa_to_conductivity.m` | `zef_freesurfer_fa_to_conductivity` | Converts an FA volume and optional v1 direction field into a `[nx x ny x nz x 6]` symmetric conductivity tensor volume. Supports three biophysical models: (1) Volume Fraction (Tuch et al. PNAS 2002), (2) Effective Medium Theory (Tuch linear relation), and (3) Direct Scaling. |

### Interpolation

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_tensor_interpolate_mesh_space.m` | `zef_dti_tensor_interpolate_mesh_space` | Interpolates conductivity tensors from the FA voxel grid to FEM mesh tetrahedron centroids. Computes the inverse transform `mesh_tkRAS -> FA_voxel` from the combined `register.dat` and NIfTI affine, then uses `griddedInterpolant` for O(M) trilinear interpolation. Enforces positive-definiteness via Sylvester criterion. |

### Coordinate Transformations

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_get_mesh2voxel.m` | `zef_dti_get_mesh2voxel` | Computes the 4x4 affine matrix transforming Zeffiro mesh display coordinates to FreeSurfer FA voxel coordinates (0-based). Implements the full chain: `mesh_display -> scanner_RAS -> T1_tkRAS -> DWI_tkRAS -> FA_voxel`. Extracts matrices from auto-populated `zef` fields with fallback to geometry structs and legacy GUI handles. |
| `zef_freesurfer_read_volume_geometry.m` | `zef_freesurfer_read_volume_geometry` | Extracts volume geometry (`vox2ras`, `vox2ras_tkr`, `center_ras`, dimensions, voxel sizes) by calling FreeSurfer's `mri_info` command. Accepts file paths (`.mgz`, `.mgh`, `.nii`, `.nii.gz`) or `niftiinfo` structs. |
| `zef_freesurfer_read_register_dat.m` | `zef_freesurfer_read_register_dat` | Parses a FreeSurfer `register.dat` file and returns the 4x4 affine matrix. The matrix maps from DWI/FA tkRAS to anatomical tkRAS. |

### Data Loading

| File | Function | Description |
|------|----------|-------------|
| `zef_freesurfer_load_fa.m` | `zef_freesurfer_load_fa` | Loads `fa.nii.gz` and returns the FA data volume (single precision, clamped to [0,1]) and the `niftiinfo` struct. |
| `zef_freesurfer_load_v1.m` | `zef_freesurfer_load_v1` | Loads `v1.nii.gz` (principal eigenvector) and returns the normalized `[nx x ny x nz x 3]` direction field. |

### Streamline Visualization

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_streamlines.m` | `zef_dti_streamlines` | Generates DTI streamlines from a seed point using principal eigenvector directions and FA-based stopping criteria. Seed directions are uniformly distributed on a sphere (Fibonacci lattice). Operates in FA voxel coordinates. |

### Reporting

| File | Function | Description |
|------|----------|-------------|
| `zef_dti_print_anisotropy_report.m` | `zef_dti_print_anisotropy_report` | Prints a per-compartment anisotropy summary table to the command window. Includes eigenvalue decomposition samples from the most anisotropic compartment. Called automatically after `zef_dti_apply_to_sigma`. |

## Downstream Consumers

This library serves two independent downstream pipelines:

### 1. Forward Model (Conductivity)

`zef_dti_apply_to_sigma` → `zef.sigma_anisotropy` → anisotropic lead field computation. This is the original purpose of the DTI pipeline.

### 2. Inverse Model (Kalman Filter Structural Priors)

The Kalman filter plugin (`plugins/Kalman/`) uses the DTI data loading and coordinate transformation functions from this library to build structurally informed process noise covariance matrices. The bridge functions live in `plugins/Kalman/m/`:

| Kalman bridge function | DTI functions used |
|---|---|
| `zef_dti_interpolate_to_sources` | `zef_dti_get_mesh2voxel` (coordinate transform) |
| `zef_dti_tractography_covariance` | `zef_dti_get_mesh2voxel`, accesses `zef.freesurfer_fa_data` and `zef.freesurfer_v1_data` |

The Kalman integration does **not** modify any functions in this directory. It reads the same `zef` fields populated by the data loading functions (`zef_freesurfer_load_fa`, `zef_freesurfer_load_v1`, `zef_freesurfer_read_register_dat`, `zef_freesurfer_read_volume_geometry`) and the coordinate transform (`zef_dti_get_mesh2voxel`).

See `plugins/Kalman/README.md` for full details on the DTI-Kalman integration.

## Coordinate Transformation Chain

The pipeline requires transforming between two coordinate systems:

```
Zeffiro mesh display space  <-->  FreeSurfer FA voxel space (0-based)
```

**Forward (FA_voxel -> mesh_display):**
1. `FA_voxel -> DWI_tkRAS`:       `T_dwi_vox2ras_tkr * voxel`
2. `DWI_tkRAS -> T1_tkRAS`:       `inv(T_register) * DWI_tkRAS`
3. `T1_tkRAS -> scanner_RAS`:     `T_ref_vox2ras * inv(T_ref_vox2ras_tkr) * T1_tkRAS`
4. `scanner_RAS -> mesh_display`:  `scanner - ref_center`

**Inverse (mesh_display -> FA_voxel):**

```
T_mesh2voxel = inv(T_dwi_vox2ras_tkr) * T_register
               * T_ref_vox2ras_tkr * inv(T_ref_vox2ras) * T_translate(+ref_center)
```

All matrices are automatically extracted from the input files by the DTI Conductivity Tool plugin.

## Conversion Models

`zef_freesurfer_fa_to_conductivity` implements three biophysically motivated FA→conductivity mappings. You select the model **programmatically** via the scalar field `zef.dti_conductivity_model`:

- **1** = Volume fraction
- **2** = Effective medium (Tuch linear)
- **3** = Direct scaling

Internally, all three models construct a conductivity tensor with the **same eigenvectors** as the diffusion tensor (principal direction `v1`) and FA‑dependent eigenvalues \(\sigma_\parallel\) and \(\sigma_\perp\). The final \(3\times 3\) tensor in voxel space is
\[
\Sigma = \sigma_\parallel\,\mathbf{v}_1\mathbf{v}_1^\top + \sigma_\perp\,(I - \mathbf{v}_1\mathbf{v}_1^\top)
\]
which is then stored in `[nx x ny x nz x 6]` format.

### Model 1: Volume Fraction (Tuch-style mixture model)

**Idea.** White matter is modeled as a mixture of intra‑axonal and extra‑axonal compartments with different isotropic conductivities. FA controls how strongly the conductivity becomes elongated along the principal fiber direction.

**Scalar eigenvalues**:

```
sigma_iso  = f * sigma_intra + (1 - f) * sigma_extra
sigma_par  = sigma_iso * (1 + 2 * FA)
sigma_perp = sigma_iso * (1 - FA)
```

For FA below a user‑defined threshold `fa_min`, the tensor is forced to be isotropic (\(\sigma_\parallel = \sigma_\perp = \sigma_\text{iso}\)).

- **Programmatic parameters (fields in `zef`)**
  - `zef.dti_conductivity_model      = 1;`
  - `zef.dti_volume_fraction         = f;      % default 0.7`
  - `zef.dti_intra_conductivity      = sigma_intra;  % default 0.6 S/m`
  - `zef.dti_extra_conductivity      = sigma_extra;  % default 1.0 S/m`
  - `zef.dti_anisotropy_threshold    = fa_min; % default 0.2`

**When to use.** Recommended default for **white‑matter dominated** applications where you want a conservative but interpretable anisotropy level controlled by compartment conductivities and FA.

Reference: Tuch et al., "Conductivity tensor mapping of the human brain using diffusion tensor MRI", PNAS 99(10):6667‑6672, 2002.

### Model 2: Effective Medium Theory (Tuch linear relationship)

**Idea.** Uses Tuch’s experimentally derived **linear mapping** from diffusion eigenvalues \(d_\nu\) to conductivity eigenvalues \(\sigma_\nu\):

```
sigma_nu = k * (d_nu - d_epsilon)
```

with constants

- `k       = 0.844` S·s/mm³  
- `d_eps   = 0.124` μm²/ms

When only FA and **mean diffusivity** \(MD\) are known (no full tensor), the diffusion eigenvalues are approximated as

```
d_par  = MD * (1 + 2 * FA)
d_perp = MD * (1 - FA)
```

FA below `fa_min` is treated as nearly isotropic; eigenvalues are clamped to a small positive floor for numerical stability.

- **Programmatic parameters (fields in `zef`)**
  - `zef.dti_conductivity_model      = 2;`
  - `zef.dti_mean_diffusivity        = MD;      % default 0.7 μm²/ms`
  - `zef.dti_anisotropy_threshold    = fa_min;  % default 0.2`

**When to use.** For studies where you want conductivity to track **quantitatively** with diffusion (e.g. comparing against diffusion‑based microstructure metrics), and where an effective‑medium assumption is acceptable.

### Model 3: Direct Scaling

**Idea.** Minimalistic model that turns FA into an anisotropic scaling of a user‑defined isotropic conductivity level. No explicit microstructural parameters are used.

Eigenvalues:

```
sigma_par  = scale * (1 + 2 * FA)
sigma_perp = scale * (1 - FA)
```

Again, FA below `fa_min` collapses to an isotropic tensor with eigenvalue `scale`.

- **Programmatic parameters (fields in `zef`)**
  - `zef.dti_conductivity_model      = 3;`
  - `zef.dti_conductivity_scale      = scale;   % default 0.33 S/m`
  - `zef.dti_anisotropy_threshold    = fa_min;  % default 0.2`

**When to use.** Quick sensitivity analyses, synthetic tests, or cases where you want to “dial in” a target anisotropy level without committing to a specific biophysical model.

### Programmatic selection of the conversion model

In all workflows (GUI and scripted), the model is read by `zef_dti_apply_to_sigma` from the `zef` struct:

```matlab
% Choose one of the three models:
%   1 = Volume fraction, 2 = Effective medium, 3 = Direct scaling
zef.dti_conductivity_model   = 1;

% Optionally override model-specific parameters:
zef.dti_volume_fraction      = 0.7;
zef.dti_extra_conductivity   = 1.0;   % S/m
zef.dti_intra_conductivity   = 0.6;   % S/m
zef.dti_conductivity_scale   = 0.33;  % used when model = 3
zef.dti_mean_diffusivity     = 0.7;   % μm²/ms, used when model = 2
zef.dti_anisotropy_threshold = 0.2;   % FA below this → isotropic
```

`zef_dti_apply_to_sigma` passes these values directly to `zef_freesurfer_fa_to_conductivity`, which computes the tensor volume before interpolation.

## Interpolation Modes

After FA→conductivity conversion in voxel space, `zef_dti_tensor_interpolate_mesh_space` interpolates tensors to tetrahedron centroids. The interpolation behavior is controlled **programmatically** via the string field `zef.dti_interpolation_mode`:

- `'radius_average'` — **default**, trilinear interpolation on the regular voxel grid using `griddedInterpolant`. Each mesh centroid is mapped to FA voxel coordinates and the 8 enclosing voxels are combined with distance‑based weights. This is smooth and the recommended choice for most neuroimaging pipelines.
- `'nearest'` — nearest‑neighbor lookup. Each mesh centroid snaps to the closest voxel center. This is the fastest option but can introduce blocky, piecewise‑constant regions; useful for debugging or when you want a literal “nearest voxel” interpretation.
- `'kdtree'` — legacy alias that currently behaves identically to `'radius_average'`. It is kept for backwards compatibility with older profiles; new code should prefer `'radius_average'` explicitly.

Out‑of‑bounds locations (outside the FA volume) are filled with an **isotropic fallback conductivity** given by `zef.dti_conductivity_scale`. The optional field `zef.dti_interpolation_radius` is accepted for API compatibility but is not used by the current regular‑grid implementation.

### Programmatic selection of the interpolation mode

Interpolation settings are read inside `zef_dti_apply_to_sigma`:

```matlab
% Interpolation mode for mapping voxel-space tensors to mesh centroids
zef.dti_interpolation_mode   = 'radius_average';  % or 'nearest', 'kdtree'

% Isotropic fallback if interpolation fails or goes out of bounds
zef.dti_conductivity_scale   = 0.33;              % S/m

% (Optional; reserved for future methods, currently unused by griddedInterpolant)
zef.dti_interpolation_radius = 2.0;               % mm
```

The call

```matlab
sigma_mesh = zef_dti_tensor_interpolate_mesh_space( ...
    tetra_centroids, conductivity_tensor, ...
    zef.freesurfer_fa_info, zef.freesurfer_register_transform, ...
    zef.dti_conductivity_scale, zef.dti_interpolation_radius, ...
    zef.dti_interpolation_mode, h_waitbar);
```

is issued from `zef_dti_apply_to_sigma` and uses these `zef` fields automatically; you typically do **not** call `zef_dti_tensor_interpolate_mesh_space` directly.

## Usage

### Programmatic (without GUI)

```matlab
% 1. Load FreeSurfer data (equivalent to the GUI "Load" button)
[zef.freesurfer_fa_data, zef.freesurfer_fa_info] = zef_freesurfer_load_fa('/path/to/fa.nii.gz');
[zef.freesurfer_v1_data, ~] = zef_freesurfer_load_v1('/path/to/v1.nii.gz');
zef.freesurfer_register_transform = zef_freesurfer_read_register_dat('/path/to/register.dat');

% 2. Extract reference MRI geometry (same information the GUI derives from the reference MRI)
ref_geom = zef_freesurfer_read_volume_geometry('/path/to/orig.mgz');
zef.dti_ref_vox2ras     = ref_geom.vox2ras;
zef.dti_ref_vox2ras_tkr = ref_geom.vox2ras_tkr;
zef.dti_ref_center      = ref_geom.center_ras;
zef.dti_ref_geometry    = ref_geom;

% 3. Configure conversion model and interpolation (mirrors the GUI "Conversion Model"
%    and "Interpolation" panels; these fields are read in STEP 2 of zef_dti_apply_to_sigma)
zef.dti_conductivity_model   = 1;               % 1, 2, or 3 (see Conversion Models)
zef.dti_volume_fraction      = 0.7;
zef.dti_extra_conductivity   = 1.0;             % S/m
zef.dti_intra_conductivity   = 0.6;             % S/m
zef.dti_mean_diffusivity     = 0.7;             % μm²/ms (used when model = 2)
zef.dti_anisotropy_threshold = 0.2;             % Minimum FA to apply anisotropy
zef.dti_conductivity_scale   = 0.33;            % Isotropic fallback / scale (model 3)
zef.dti_interpolation_mode   = 'radius_average';% or 'nearest', 'kdtree'
zef.dti_interpolation_radius = 2.0;             % mm (currently unused by griddedInterpolant)

% (Optional) Compartment selection: mirrors the GUI "Compartment Selection" panel.
% If omitted, anisotropy is applied to all tetrahedra.
zef.dti_apply_to_compartments = {'w', 'g'};     % example: white and gray matter

% 4. Apply to mesh
% Internally, zef_dti_apply_to_sigma executes the following steps in order:
%   STEP 1: Validate inputs (FA volume, register.dat, mesh).
%   STEP 2: Read conversion model + interpolation settings from the zef.* fields above.
%   STEP 3: Call zef_freesurfer_fa_to_conductivity (FA → tensor volume, using model_type).
%   STEP 4: Compute tetrahedron centroids.
%   STEP 5: Call zef_dti_tensor_interpolate_mesh_space (tensor volume → per-tetrahedron tensor,
%           using dti_interpolation_mode, dti_conductivity_scale, dti_interpolation_radius).
%   STEP 6: Restrict updates to selected compartments (dti_apply_to_compartments, if set).
%   STEP 7: Update zef.sigma_anisotropy and metadata, clear sigma_bypass, and print a report.
zef = zef_dti_apply_to_sigma(zef);

% 5. Visualize streamlines (optional, independent of conductivity mapping)
zef_visualize_dti_streamlines(zef);
```

This programmatic sequence exactly mirrors the ordering used by the **DTI Conductivity Tool** GUI: the GUI panels simply populate the same `zef.*` fields (files, conversion model, interpolation mode, compartments) before calling `zef_dti_apply_to_sigma` when you click **Apply to Mesh**.

### Via GUI

Use the DTI Conductivity Tool plugin (see `plugins/DTIConductivityTool/`).

## Development Guide

### Adding a New Conversion Model

1. Edit `zef_freesurfer_fa_to_conductivity.m`:
   - Add a new `model_type` value (e.g. `4`) in the `inputParser` validation.
   - Add a new `if model_type == 4` block that computes `sigma_par` and `sigma_perp` from `fa_flat`.
   - The tensor assembly code (lines computing `s11`...`s23`) is shared across all models.
2. Update `zef_dti_conductivity_window.m` in the plugin to add the new model to the dropdown `Items`.
3. Update `zef_dti_print_anisotropy_report.m` to include the model name in the report header.

### Modifying the Interpolation

The interpolation is performed in `zef_dti_tensor_interpolate_mesh_space.m`. The function:
- Computes `T_combined = register_transform * T_nifti` to map FA voxels to mesh space.
- Inverts this to get `mesh -> FA_voxel`.
- Uses `griddedInterpolant` (trilinear) for each of the 6 tensor components.
- Enforces positive-definiteness via eigenvalue clamping.

To add a new interpolation method, add a new `elseif strcmp(mode, 'your_mode')` branch.

### Key Data Structures

- `zef.sigma_anisotropy` — `[M x 6]` per-tetrahedron conductivity tensor (sigma_11, sigma_22, sigma_33, sigma_12, sigma_13, sigma_23)
- `zef.freesurfer_fa_data` — `[nx x ny x nz]` single-precision FA volume
- `zef.freesurfer_v1_data` — `[nx x ny x nz x 3]` single-precision unit direction field
- `zef.freesurfer_register_transform` — `[4 x 4]` affine from `register.dat`
- `zef.dti_ref_geometry` — struct with `vox2ras`, `vox2ras_tkr`, `center_ras`, `dimensions`, `voxel_sizes`
- `zef.dti_conductivity_metadata` — struct recording model type, parameters, compartments, and timestamp

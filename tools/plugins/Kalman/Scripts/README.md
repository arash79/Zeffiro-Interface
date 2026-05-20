# Kalman Plugin — Scripts

Analysis, visualization, and test scripts for the Kalman filter plugin. These scripts are intended to be run interactively from the MATLAB command window or editor, not called by the core pipeline.

## File Reference

### DTI Structural Covariance Test

| File | Description |
|------|-------------|
| `test_dti_structural_covariance.m` | **DTI integration test and visualization.** Loads FreeSurfer DTI data (FA, v1, register.dat, reference MRI), computes both FA-based and tractography-based structural covariance matrices, and generates an 8-panel comparison figure with matrix images, eigenvalue spectra, coupling profiles, distribution histograms, sparsity patterns, and a 3D FA scatter plot. Prints a formatted summary table to the command window. Prompts for file paths interactively if not pre-configured. |

### Reconstruction Visualization

| File | Description |
|------|-------------|
| `plot_butterfly.m` | Plots butterfly diagrams of EEG/MEG measurement time series. |
| `plot_cortex_component.m` | Visualizes cortical source reconstructions. |
| `plot_deep_component.m` | Visualizes deep source reconstructions. |
| `plot_sources.m` | General source visualization. |
| `plot_parcellation.m` | Plots parcellation-based reconstructions. |
| `plot_quantiles.m` | Quantile-based reconstruction visualization. |
| `ROIMedianCurves.m` | Computes and plots median time courses within regions of interest. |

### Utilities

| File | Description |
|------|-------------|
| `get_rec_from_project.m` | Extracts reconstruction data from a saved Zeffiro project file. |
| `mean_rec.m` | Computes mean reconstruction across multiple runs. |

## Running the DTI Structural Covariance Test

### Prerequisites

1. FreeSurfer installed with `FREESURFER_HOME` set
2. FreeSurfer `dt_recon` output files: `fa.nii.gz`, `v1.nii.gz`, `register.dat`
3. FreeSurfer reference MRI: `orig.mgz`
4. Either an existing Zeffiro project with mesh (optional — the script can generate source positions from the FA volume)

### Usage

```matlab
% Option 1: Set file paths in the script, then run
edit test_dti_structural_covariance
% Fill in fa_file, v1_file, register_file, ref_mri_file
% Then run the script

% Option 2: Run directly — interactive file dialogs will prompt for each file
test_dti_structural_covariance
```

### Output

1. **8-panel figure**: Matrix images, eigenvalue spectra, FA 3D scatter, coupling profiles, distribution histograms, and sparsity patterns for both FA-based and tractography-based approaches
2. **Command window summary**: Formatted table comparing non-zeros, density, eigenvalues, condition number, coupling statistics, and computation time
3. **Integration instructions**: How to enable each structural Q type in `zef_KF`

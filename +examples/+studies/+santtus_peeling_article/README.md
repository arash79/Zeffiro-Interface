# Santtu's Peeling Article — Sensitivity of EEG Inverse Methods

This module evaluates how different EEG inverse methods perform when the head model is simplified by “peeling” (removing superficial layers such as scalp or skull). It was used to produce results for the article:

**The Effects of Peeling on Finite Element Method–based EEG Source Reconstruction**

- [arXiv:2308.04908](https://doi.org/10.48550/arXiv.2308.04908)

## What Is “Peeling”?

In FEM-based EEG source reconstruction, the head is typically modeled with several compartments (e.g., scalp, skull, CSF, brain). *Peeling* means removing one or more outer layers from the model to reduce complexity. This module measures how that simplification affects reconstruction quality: position accuracy, orientation accuracy, magnitude, and spatial dispersion.

## What Will You Learn?

- How to load a project, build mesh and lead field, and run inverse methods from a script.
- How Zeffiro’s MNE, sLORETA, dSPM, and Dipole Scan tools work when called programmatically.
- How to quantify reconstruction quality (position error, direction error, dispersion) over many source positions and noise realizations.

## When to Use This Module

- You want to compare inverse methods under controlled conditions (known sources, added noise).
- You work with FEM head models and want to understand the impact of model simplification.
- You have finished the root-level examples and understand lead fields and inverse methods.

## How to Run

The main entry point is `main`. You provide a project path, inverse method name, and various options:

```matlab
[sensitivities_with_statistics, L] = examples.studies.santtus_peeling_article.main( ...
    project_path,           % Path to .zef or .mat project
    inverse_method,         % "sLORETA", "dSPM", "MNE", or "Dipole Scan"
    n_of_runs,             % Number of Monte Carlo runs for statistics
    noise_level_db,        % Noise level in dB (e.g. -30)
    diff_type,             % "L2" or "minabs" for position metric
    dispersion_radius,     % Radius (mm) for dispersion computation
    args                   % Struct: use_gpu, build_mesh, build_lead_field, etc.
);
```

Get full argument descriptions:

```matlab
help examples.studies.santtus_peeling_article.main
```

## Output Metrics

For each source position and inverse method, the script computes:

- **Position error**: Distance between true and reconstructed source (L2 or minabs).
- **Direction error**: Angular difference between true and reconstructed dipole orientation (degrees).
- **Magnitude**: Reconstructed dipole strength.
- **Dispersion**: Spatial spread of reconstructed activity within a region of interest (ROI).

## Supported Inverse Methods

- **MNE** — Minimum Norm Estimate
- **dSPM** — Dynamic Statistical Parametric Mapping
- **sLORETA** — Standardized Low-Resolution Electromagnetic Tomography
- **Dipole Scan** — Sequential dipole fitting

## Files in This Module

| File | Role |
|------|------|
| `main.m` | Entry point: loads project, builds mesh/lead field if requested, runs sensitivity analysis, returns results. |
| `zef_rec_diff.m` | Core routine: generates synthetic measurements for each source and direction, runs the inverse method, computes position/direction/magnitude/dispersion differences. |
| `zef_sensitivity_map_mne.m` | Sensitivity analysis for MNE, dSPM, sLORETA (Monte Carlo over noise). |
| `zef_sensitivity_map_dipoleScan.m` | Sensitivity analysis for Dipole Scan (Monte Carlo over noise). |

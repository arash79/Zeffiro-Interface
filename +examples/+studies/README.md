# Studies — Advanced Research Workflows

This folder contains modules from research studies that use Zeffiro Interface. They are more specialized than the root-level examples and show how the interface can be used for specific analyses: sensitivity evaluation, focal epilepsy source localization, and transcranial electrical stimulation (tES) optimization.

## Who Are These For?

These examples are for users who already understand the basics of Zeffiro (mesh, lead field, inverse methods) and want to see:

- How to compare multiple inverse methods and quantify their performance.
- How to structure a clinical workflow (e.g., epilepsy) with DataBank and clustering.
- How to optimize parameters for the electrical stimulation (ES) tool.

If you are new to Zeffiro, start with the root-level examples (`+examples/README.md`) before exploring these.

## How to Run Study Modules

Each module lives in a subfolder prefixed with `+`. From the Zeffiro project root:

```matlab
[results, …] = examples.studies.module_name.main(arguments…);
```

For usage and arguments:

```matlab
help examples.studies.module_name.main
doc examples.studies.module_name.main
```

---

## Module: `+santtus_peeling_article`

**Purpose:** Evaluate how different EEG inverse methods respond when superficial head layers are “peeled” (removed) in the FEM model. This helps understand the impact of head model simplification on source reconstruction accuracy.

**What you’ll learn about the interface:** How to build mesh and lead field programmatically, run MNE, sLORETA, dSPM, and Dipole Scan, and compute metrics (position error, direction error, dispersion) over many source positions and noise realizations.

**When to explore:** After you’ve run `lead_field_example` and understand what a lead field is. Useful if you work with FEM head models and inverse methods.

**Publication:** *The Effects of Peeling on Finite Element Method–based EEG Source Reconstruction* ([arXiv:2308.04908](https://doi.org/10.48550/arXiv.2308.04908))

---

## Module: `+decision_making`

**Purpose:** Focal epilepsy source localization using 11 inverse methods and credibility-based clustering. The workflow compares many methods (MNE, sLORETA, dSPM, MNE-RAMUS, Dipole Scan, Beamformer, IAS variants, EXP-L1) and selects the most credible reconstructions for a final estimate.

**What you’ll learn about the interface:** How the DataBank organizes data (EEG, MEG, MEEG), how to run multiple inverse methods in sequence, and how to combine results with clustering. The scripts show a full clinical-style pipeline.

**When to explore:** When you have (or can create) a DataBank project with lead fields and measurements. Requires familiarity with the DataBank structure.

**Prerequisites:** DataBank, patient project with EEG/MEG/MEEG lead fields, scripts in `zef.program_path/scripts` on the path.

---

## Module: `+tES_hyperparameter_optimization`

**Purpose:** Recursive search for tES hyperparameters (alpha, epsilon) in the Electrical Stimulation (ES) tool. The algorithm refines the parameter grid around the best objective value.

**What you’ll learn about the interface:** How the ES tool’s parameters (alpha, epsilon) affect current optimization, and how to run adaptive hyperparameter search from a script.

**When to explore:** When you use transcranial electrical stimulation (tES) in Zeffiro and want to tune parameters programmatically rather than by hand.

**Prerequisites:** ES tool configured in the project struct (zef).

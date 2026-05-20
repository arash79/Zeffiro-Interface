# Examples — Getting Familiar with Zeffiro Interface

This folder contains example scripts that demonstrate how to use Zeffiro Interface **from the MATLAB command line**—without relying on the graphical user interface (GUI). The examples are designed to help you understand the programmatic workflow: importing segmentations, building meshes, computing lead fields, and running inverse reconstructions.

## Why Use These Examples?

- **Learn the pipeline**: See the typical sequence of steps (import → mesh → lead field → inverse).
- **Reproducibility**: Scripts can be run in batch, modified, and version-controlled.
- **Customization**: Keyword arguments let you tune parameters without opening GUI dialogs.
- **Integration**: Call Zeffiro functions from your own MATLAB scripts or pipelines.

## Before You Start

1. **Install Zeffiro Interface** and ensure it is correctly configured.
2. **Start MATLAB** with the Zeffiro project folder as the current directory (or on the path).
3. **Required data**: Some examples expect segmentation or project files in standard locations (e.g. `data/segmentations/multicompartment_head_project/`). Check the default paths in each script.

## Suggested Order for Beginners

If you are new to Zeffiro, try the examples in this order:

1. **`zef_import_example`** — Simplest: loads a segmentation and shows how to start Zeffiro in headless mode.
2. **`zef_meshing_example`** — Builds a finite-element mesh; introduces mesh-related parameters.
3. **`zef_meshing_example_thalamus_refinement`** — Same idea, with subcortical (thalamic) refinement.
4. **`lead_field_example`** — Full pipeline: mesh + sensors + lead field; this is the foundation for inverse methods.
5. **`zef_KalmanDemo`** — Simulates data and runs a Kalman filter inverse; good for understanding forward + inverse workflow.

## Running Examples

Run from the Zeffiro installation folder:

```matlab
project_struct = examples.zef_import_example;
```

For examples that accept arguments:

```matlab
project_struct = examples.lead_field_example('mesh_resolution', 5, 'n_sources', 5000);
```

Get help and see available options:

```matlab
help examples.lead_field_example
```

## Root-Level Examples

### `zef_import_example.m`

**What you learn:** How to import a multi-compartment head segmentation and start Zeffiro without the GUI.

**Use when:** You want to load an existing project or segmentation from a script. The function returns a project struct for further processing.

---

### `zef_meshing_example.m`

**What you learn:** How to generate a finite-element mesh from a segmentation. You can control resolution, refinement, smoothing, and other meshing parameters via keyword arguments.

**Use when:** You need a tetrahedral mesh for EEG/MEG forward modeling. The mesh is saved to a `.mat` file.

**Reference:** Based on *Multi-compartment head modeling in EEG: unstructured boundary-fitted tetra meshing with subcortical structures* (see the script header for DOI).

---

### `zef_meshing_example_thalamus_refinement.m`

**What you learn:** How to refine specific compartments—here, the thalamus—for higher resolution where it matters.

**Use when:** Your analysis focuses on subcortical structures and you need finer elements there.

---

### `lead_field_example.m`

**What you learn:** The complete forward pipeline: build mesh, attach sensors, and compute the lead field matrix. This is the core of any inverse method—the lead field maps source activity to sensor measurements.

**Use when:** You need a lead field for EEG (or MEG, depending on settings). You can pass mesh and lead-field parameters; see `help examples.lead_field_example` for options.

**Further reading:** [Lead field generation (wiki)](https://github.com/sampsapursiainen/zeffiro_interface/wiki/Lead-field-generation)

---

### `zef_KalmanDemo.m`

**What you learn:** How to simulate synthetic EEG data (here, somatosensory P20/N20 with cortical and thalamic sources), then run Kalman filter–based inverse reconstruction.

**Use when:** You want to understand the full workflow: forward simulation + inverse method, without real data. Run section by section in the MATLAB editor.

---

## Subfolder: `+studies`

The `+studies` folder contains more advanced, research-oriented workflows used in published studies. They demonstrate specialized applications (sensitivity analysis, epilepsy localization, tES optimization) and require additional setup. See the `+studies` README for details and when to explore them.

## More Help

- **MATLAB help:** `help examples.function_name` or `doc examples.function_name`
- **Wiki:** [zeffiro_interface wiki](https://github.com/sampsapursiainen/zeffiro_interface/wiki)
- **Meshing:** [Finite-Element Mesh generation](https://github.com/sampsapursiainen/zeffiro_interface/wiki/Finite-Element-Mesh-generation)

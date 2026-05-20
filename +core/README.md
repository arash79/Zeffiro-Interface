# core

The **core** package provides shared type definitions, utilities, and subsystems used by central Zeffiro Interface functionality and by other top-level modules in the repository. By keeping these definitions under `+core`, they can be accessed without adding the legacy [`m/`](../m) folder to the MATLAB path.

## Package layout

| Path | Description |
|------|-------------|
| **ZefSourceModel.m** | Enumeration of source and interpolation models (Whitney, H(div), St. Venant, and continuous variants) used in forward and inverse solvers. |
| **+preconditioners/** | Linear-algebra preconditioners for iterative solvers (Jacobi, SSOR). |
| **+import/** | Electrode and sensor import from external file formats (.dat, .csv). |
| **+gui/+menu_tool/** | GUI callbacks for the menu-based tools (e.g. Import electrodes). |

## Contents overview

### ZefSourceModel

- **Purpose:** Single source of truth for the finite-element source and interpolation model identifiers used across the codebase (e.g. when loading projects or configuring solvers).
- **Main usage:** `core.ZefSourceModel.from(value)` to convert legacy numeric (1–6), string, or enum input into a `ZefSourceModel` member; `core.ZefSourceModel.variants()` to list all members; `core.ZefSourceModel.to_string(variant)` for display names.
- **Enumeration members:** `Hdiv`, `Whitney`, `StVenant`, `ContinuousHdiv`, `ContinuousWhitney`, `ContinuousStVenant`, and sentinel `Error`.

### +preconditioners

- **jacobi(A)** — Builds the Jacobi (diagonal) preconditioner for the system `A*x = b`.
- **ssor(A, coeff)** — Builds the symmetric successive over-relaxation (SSOR) preconditioner; optional `coeff` in (0, 2), default 1 (Gauss–Seidel).

Used by iterative linear solvers that need preconditioning for better convergence.

### +import

- **electrodes_from_dat(file)** — Imports electrode positions (and optional labels and CEM parameters) from a whitespace-separated text (.dat) file.
- **electrodes_from_csv(file)** — Imports from a CSV file with header columns `x`, `y`, `z`, and optionally `label`, `inner_radius`, `outer_radius`, `impedance`.

Both return `[electrode_data, electrode_labels]` in a form suitable for the Zeffiro central struct (e.g. `sensors`, `s_points`, `s_name_list`). See [+import/README.md](+import/README.md) for file formats and options.

### +gui/+menu_tool

- **import_electrodes_callback(zef)** — Callback for *Menu tool > Import > Import electrodes*. Opens a file dialog (.dat / .csv), reads electrodes via `core.import`, and updates `zef` with sensor data and optional CEM fields; on error, shows a dialog and returns without modifying `zef`.

## Usage note

From the Zeffiro Interface root folder, call package functions with the full namespace, for example:

```matlab
model = core.ZefSourceModel.from(2);
prec  = core.preconditioners.jacobi(A);
[data, labels] = core.import.electrodes_from_csv("electrodes.csv");
```

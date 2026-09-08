# Developer documentation (`docs/`)

Guides for people **changing** Zeffiro and for people reading the architecture without opening every folder. This is not the typeset scientific manual ([`documentation/`](../documentation/README.md)) and is not on the MATLAB path. Launch instructions stay in the repository [README.md](../README.md).

## Read in this order

```text
README.md                     what the software is, install, first command
  → getting-started.md        first import → mesh → lead field
    → glossary.md               words (lead field, CEM, reconstruction, …)
    → conventions.md            mm vs m, L orientation, indexing, PCG
    → zef-state.md              important fields of the zef struct
    → architecture.md           where code lives and how it boots
    → methods.md                why inverse methods exist; class formulas
    → developer-guide.md        where to put a new solver / plugin / test
    → upstream.md               numbers vs upstream zeffiro_interface
    → adr/                      why the layout is this way
    → folder README.md          how this directory works
    → MATLAB help               one function’s arguments and side effects
```

## Files in this folder

| Path | Role |
|------|------|
| [getting-started.md](getting-started.md) | Clone, launch, bundled head project, first mesh / `L` / inverse |
| [glossary.md](glossary.md) | Domain and project vocabulary |
| [conventions.md](conventions.md) | Units, coordinates, matrix layout, CEM columns, tet orientation, lead-field PCG |
| [zef-state.md](zef-state.md) | Session struct fields that mesh / forward / inverse actually use |
| [architecture.md](architecture.md) | Tree, bootstrap `addpath` order, module table, plugin INI vs class registry |
| [methods.md](methods.md) | Forward map \(y \approx Lx\), regularization, class solvers, dual tracks |
| [troubleshooting.md](troubleshooting.md) | Recurring failures (empty `L`, two inverse tracks, R2025a docking) |
| [developer-guide.md](developer-guide.md) | Where to add a solver, GUI window, class-solver dialog, importer, plugin, colormap, or test |
| [upstream.md](upstream.md) | Numerical and startup differences versus upstream `zeffiro_interface` |
| [adr/](adr/) | Accepted layout decisions (hybrid path, dual inverse tracks, plugins vs kernels, `utilities.*` name) |

If a folder README and `architecture.md` disagree, treat **implementation plus the folder README** as current and open a docs fix. ADRs change only when the decision changes.

The LaTeX manual under `documentation/` may lag the code. Folder READMEs and MATLAB `help` win for GUI paths and signatures.

The optional project homepage under [`website/`](../website/) copies these guides into its Docs section at build time. Edit files here, not the generated `website/content/docs/` copies.

## Notes that bite newcomers

- `src/app` is not `+core`. `plugins/` is not a `+package`. `inverse.gmm` / `inverse.kf` are not GUI plugins.
- Dual inverse tracks are intentional ([ADR-002](adr/ADR-002-dual-inverse-tracks.md)): Inverse-tools menus without **(class solver)** still call legacy `plugins/*` iterations; **(class solver)** menus and `zef_inverse_run` construct `inverse.*Inverter`.
- `location_unit` is `1` mm, `2` cm, `3` m (Mesh tool labels in `zef_mesh_tool`).
- `<tag>_sources` Activity: `-1` Bounding box / PML, `0` Inactive, `1` Constrained field, `2` Unconstrained field, `3` Active surface. Source placement uses `{1, 2}` only — `3` is **not** PML.
- Electrodes: `zef.sensors` is `N×3` (PEM) or `N×6` (CEM). FEM cores see PEM as snapped xyz in metres, and CEM as a **4-column index table** from `zef_attach_sensors_volume` — not metres. Details: [conventions.md](conventions.md).
- Lead-field PCG: GPU is Jacobi; CPU is SSOR or no-fill `ichol`. MEG/EIT do not call `zef_transfer_matrix`. The “preconditioner tolerance” widget is unused.

## When you change the tree

Move a public `zef_*` file → update `architecture.md`, the folder README, and `tests.smoke.ArchitectureLayoutTest` together. New lasting layout or public-name choice → add an ADR ([`adr/README.md`](adr/README.md)).

Git workflow for pull requests: [`CONTRIBUTING.md`](../CONTRIBUTING.md).

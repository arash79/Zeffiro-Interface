# Third-party notices

First-party Zeffiro code is licensed under the [GNU GPL v3](LICENSE). This file lists bundled or optional material that is **not** covered by that grant alone.

## Optional git submodules (`external/`)

`zeffiro_setup` can clone the repositories named in [`.gitmodules`](.gitmodules) into `external/`. Those trees keep their own licenses and citation requests. Do not treat files that appear there after clone as Zeffiro-owned. Integration notes: [`external/README.md`](external/README.md).

| Folder | Typical license (confirm in the cloned tree) |
|--------|-----------------------------------------------|
| `CVX/` | CVX’s own license (academic / commercial terms) |
| `SDPT3/`, `SeDuMi/` | GNU GPL (solver backends often used with CVX) |
| `OSQP/` | Apache-2.0 (osqp-matlab) |
| `SESAME/` | See the SESAME_core repository |
| `fieldtrip/` | GNU GPL |
| `spm12/` | GNU GPL |

Empty `external/<name>/` folders in a fresh clone are placeholders, not vendor source.

## Fonts for the printed manual (`documentation/fonts/`)

Erewhon and JuliaMono are bundled only so LuaLaTeX can compile [`documentation/`](documentation/README.md) without a system font install. They are **SIL Open Font License 1.1**. Full notices: [`documentation/fonts/LICENSE.md`](documentation/fonts/LICENSE.md). They are not used by the MATLAB GUI.

## Website typeface (not bundled)

The optional [`website/`](website/README.md) loads **Inter** from Google Fonts at runtime (`website/src/css/main.css`). Inter is SIL Open Font License 1.1. It is not shipped in this repository and is not used by the MATLAB GUI.

## Website illustrations (`website/assets/img/`)

Hero, pipeline, method, and feature images are original illustrations produced for this site (including generative-image tools). They are not MATLAB GUI screenshots and not third-party stock. Treat them as project artwork under the same GPL grant as the rest of this tree.

## SimNIBS Gmsh helper

`+utilities/+sn2zef/meshLoadGmsh4.m` is a SimNIBS-facing mesh reader. If you use that path, cite SimNIBS as requested in that file’s comments.

## Electrode layout tables (`data/electrodes/`)

The `.dat` files are coordinate tables (typically millimetres) named after public 10–20 / vendor montages. They are data, not vendor SDKs. Cite the cap manufacturer when a publication depends on a specific layout.

## Example anatomy and asteroid meshes (`data/`)

Head surfaces under `data/segmentations/multicompartment_head_project/` are a teaching segmentation, not a patient dataset. Itokawa STLs under `data/itokawa_model/` are demo geometry for the asteroid profiles. Do not add identifiable human research data to this folder.

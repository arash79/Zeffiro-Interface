# Tool figure templates and images (`fig/tools/`)

This subdirectory contains **MATLAB figure templates** (`.fig`) and **tool-specific images** (`.png`) used by Zeffiro Interface tools. For full documentation of the entire `fig` directory, path usage, and file descriptions, see the parent [README](../README.md).

---

## Contents summary

### Figure templates (`.fig`)

- **zef_find_synthetic_eit_data.fig** — Find synthetic EIT data tool (loaded by `m/zef_find_synthetic_eit_data.m`).
- **zef_find_synthetic_source.fig** — Find synthetic source tool layout.
- **zeffiro_interface_butterfly_plot.fig** — Butterfly plot window layout.
- **zeffiro_interface_figure_tool.fig** — Figure tool window layout.
- **zeffiro_interface_mesh_tool.fig** — Mesh tool window layout.
- **zeffiro_interface_parcellation_tool.fig** — Parcellation tool window layout.
- **zeffiro_interface_ramus_inversion_tool.fig** — RAMUS inversion tool layout.
- **zeffiro_interface_segmentation_tool.fig** — Segmentation tool window layout.

### Images (`.png`)

- **zeffiro_interface.png** — Interface/splash image.
- **zeffiro_logo.png** — Logo for tool windows.
- **zeffiro_small_logo.png** — Small logo for compact UI areas.

---

## Usage note

The `fig` directory (including `tools/`) is added to the MATLAB path at startup. Tools load these files by filename (e.g. `open('zef_find_synthetic_eit_data.fig')`). Do not rename or remove files without updating the corresponding loaders and the parent [README](../README.md).

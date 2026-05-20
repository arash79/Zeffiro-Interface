# MLAPP — MATLAB App Designer Applications

This directory contains the **MATLAB App Designer** (`.mlapp`) applications and their **exported** MATLAB class (`.m`) counterparts for the ZEFFIRO Interface. These apps provide the graphical user interface for project management, mesh and segmentation tools, visualization, and settings.

---

## Contents Overview

### File types

| Type | Description |
|------|-------------|
| **`.mlapp`** | App Designer source file (binary format). Edit these in MATLAB App Designer to change layout and callbacks. |
| **`*_exported.m`** | Exported class file generated from the corresponding `.mlapp`. Used for version control and deployment; do not edit by hand if you intend to re-export from App Designer. |

For each main tool there is typically one `.mlapp` and one `*_exported.m` sharing the same base name (e.g. `zef_menu_tool_app.mlapp` and `zef_menu_tool_app_exported.m`).

---

## Applications

### Main menu and multi-tools

| File | Purpose |
|------|---------|
| **zef_menu_tool_app** | Main menu window: Project (new/open/save/export/import), Edit (reset/merge), Inverse/Forward tools, Multi-tools (segmentation, mesh, visualization, figure, parcellation), Settings, Window management, Help. Singleton. |
| **zef_mesh_tool_app** | Mesh tool: create/postprocess FEM mesh, resample surfaces/field, source interpolation, mesh smoothing/refinement, forward simulation script and profile table. Singleton. |
| **zef_segmentation_tool_app** | Segmentation tool: compartment table (conductivity, visibility, merge, etc.), sensor sets, transforms, parameters, project info/notes, sensor names. Context menus for import (STL/DAT) and add/delete. Singleton. |
| **zef_mesh_visualization_tool_app** | Mesh visualization: volume/surface/frame–movie/DTI streamlines, clipping planes, colormap/scale/threshold, reconstruction type, parameter/graph listboxes and “Plot graph.” Singleton. |

### Settings and options

| File | Purpose |
|------|---------|
| **zef_forward_and_inverse_processing_options** | Options for forward and inverse processing (primary dialog). |
| **zef_forward_and_inverse_processing_options_2** | Secondary/alternate forward and inverse processing options. |
| **zef_graphics_processing_options** | Graphics and rendering options. |
| **zef_gaussian_prior_options** | Hierarchical (Gaussian) prior options for inverse methods. |
| **zef_system_settings** | System settings (e.g. `zeffiro_interface.ini`). |
| **zef_parameter_profile** | Parameter profile configuration. |
| **zef_segmentation_profile** | Segmentation profile configuration. |
| **zef_init_profile** | Pre-settings / initialization profile. |
| **zef_plugin_settings** | Plugin settings. |
| **zef_additional_options_app** | Additional application options. |

### Forward simulation and NSE

| File | Purpose |
|------|---------|
| **zef_forward_simulation_tool** | Forward simulation tool UI. |
| **zef_nse_app** | NSE (e.g. neural source estimation) application. |
| **zef_nse_tool_app** | NSE tool application. |

---

## Exported classes (source code)

The following exported `.m` files are the ones that contain documented, human-readable class definitions and can be inspected for structure and comments:

- **zef_menu_tool_app_exported.m** — Main menu UI class.
- **zef_mesh_tool_app_exported.m** — Mesh tool UI class.
- **zef_segmentation_tool_app_exported.m** — Segmentation tool UI class.
- **zef_mesh_visualization_tool_app_exported.m** — Mesh visualization tool UI class.

Each of these classes:

- Subclasses `matlab.apps.AppBase`.
- Implements a **singleton** pattern: only one instance runs at a time; reopening focuses the existing window.
- Builds its UI in a private `createComponents` method and registers the app in the constructor.

The remaining tools (settings, options, NSE, forward simulation) exist as `.mlapp` only in this directory; their logic and layout are maintained in App Designer.

---

## Directory structure

```
mlapp/
├── README.md                                    (this file)
├── zef_menu_tool_app.mlapp
├── zef_menu_tool_app_exported.m
├── zef_mesh_tool_app.mlapp
├── zef_mesh_tool_app_exported.m
├── zef_segmentation_tool_app.mlapp
├── zef_segmentation_tool_app_exported.m
├── zef_mesh_visualization_tool_app.mlapp
├── zef_mesh_visualization_tool_app_exported.m
├── zef_forward_and_inverse_processing_options.mlapp
├── zef_forward_and_inverse_processing_options_2.mlapp
├── zef_graphics_processing_options.mlapp
├── zef_gaussian_prior_options.mlapp
├── zef_system_settings.mlapp
├── zef_parameter_profile.mlapp
├── zef_segmentation_profile.mlapp
├── zef_init_profile.mlapp
├── zef_plugin_settings.mlapp
├── zef_additional_options_app.mlapp
├── zef_forward_simulation_tool.mlapp
├── zef_nse_app.mlapp
└── zef_nse_tool_app.mlapp
```

There are **no subdirectories**; all apps reside in this single folder.

---

## Usage notes

1. **Editing UI or callbacks**  
   Open the `.mlapp` file in MATLAB App Designer. After saving, re-export to `*_exported.m` if the project uses the exported version.

2. **Callback and startup logic**  
   For the four tools with exported `.m` files, the `.m` file defines the component hierarchy and layout. Callbacks and startup behavior are typically wired in the main application (e.g. `zeffiro_interface.m` or related entry points) or in the corresponding non-exported driver (e.g. `zef_menu_tool.m`), not in the exported class itself.

3. **Dependencies**  
   These apps expect to run within the ZEFFIRO Interface environment (correct path, `zeffiro_interface.m`, and supporting functions). Assets such as `zeffiro_logo_compass.png` are assumed to be on the path or in an expected location when the menu or segmentation tool is launched.

---

## See also

- **matlab.apps.AppBase** — Base class for App Designer apps.
- Main entry point: **zeffiro_interface.m** (root of the project).
- Tool launchers (e.g. `zef_menu_tool.m`, `zef_mesh_tool.m`, `zef_segmentation_tool.m`, `zef_mesh_visualization_tool.m`) that instantiate or show these apps.

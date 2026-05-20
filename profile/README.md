# Zeffiro Interface — Profile Directory

This directory contains **configuration profiles** for the Zeffiro Interface application. Each profile defines default settings for a specific use case (e.g. neuroimaging, gravity inversion, radar). The application loads these files at startup and when the user switches profiles via **System settings** or applies profile-specific settings from the **Menu** tool.

**Important:** The `.ini` files in this directory are **comma-separated value (CSV) tables**. They are read with MATLAB `readcell(..., 'FileType','text','Delimiter',',')` and must not contain comment lines or extra header rows, or the GUI tables and loaders will misinterpret the data.

---

## Directory Layout

```
profile/
├── zeffiro_interface.ini     # Global interface defaults (path, GPU, display, profile name, etc.)
├── README.md                 # This file
├── asteroid_gravity/         # Gravity/asteroid inversion profile
├── asteroid_radar/           # Radar/asteroid profile (EM, wireframe)
├── multicompartment_head/    # Main neuroimaging profile (EEG/MEG/EIT/tES)
├── multicompartment_head_legacy/  # Legacy head model with fixed compartment set
└── multicompartment_head_nse/    # Neuroimaging + NSE (e.g. haemodynamics)
```

Each subfolder (e.g. `multicompartment_head/`) is a **profile** and must contain the same set of INI files, as described below.

---

## Root File: `zeffiro_interface.ini`

Stored in `profile/zeffiro_interface.ini`. Defines **global** interface options, independent of the selected profile. Loaded by `zef_apply_system_settings`, `zef_open_system_settings`, `zef_save_system_settings`, and related functions.

**Format:** Each line is one setting:  
`Display name, value, field_name, type`

| Column meaning   | Description |
|------------------|-------------|
| Display name     | Label shown in the System settings dialog. |
| value            | Default value (number, string, or MATLAB expression). |
| field_name       | Corresponding field in the main `zef` struct (e.g. `use_gpu`, `profile_name`). |
| type             | Data type: `number` or `string`. |

**Typical entries (by field_name):**

- **Paths and project:** `save_file_path`, `save_file` (default project path and name).
- **Video/export:** `video_codec`, `snapshot_vertical_resolution`, `snapshot_horizontal_resolution`, `movie_fps`.
- **Compute:** `use_gpu`, `gpu_num`, `parallel_vectors`, `parallel_processes`, `processes_per_core`.
- **UI:** `font_size`, `use_display`, `store_cdata`, `segmentation_tool_default_position`, `verbose_mode`, `use_waitbar`.
- **Profile and user:** `profile_name` (must match a subfolder name under `profile/`), `user_tag`.
- **Logging:** `use_log`, `zeffiro_log_file_name`, `max_n_log_files`.

The **profile name** in this file determines which profile subfolder is used for `zeffiro_init.ini`, `zeffiro_parameters.ini`, `zeffiro_forward_simulation.ini`, `zeffiro_plugins.ini`, and `zeffiro_segmentation.ini`.

---

## Profile-Specific Files (in Each Profile Subfolder)

The following five files must exist in every profile directory (e.g. `profile/multicompartment_head/`). They are read when the user applies or reloads profile settings and when initializing compartments, plugins, and forward simulation options.

### 1. `zeffiro_init.ini`

**Purpose:** Initialization and modality defaults for the selected profile (e.g. imaging modalities, default plot size, optional CEM electrode creation, compartment/sensor tags).

**Format:** CSV; each line: typically **Display name, value, field_name, type**. Some rows may contain MATLAB cell or struct expressions (e.g. modality lists, compartment tags).

**Typical fields:**

- `cam_va` — Default plot size (numeric).
- `imaging_method_cell` — Cell array of modality names (e.g. `{'EEG','MEG magnetometer', 'MEG gradiometers'}` or `{'Scalar field','Vector field', 'Vector field gradient'}`).
- `create_patch_sensor` — Optional; CEM electrode creation callback (e.g. `@zef_cem_electrode`).
- In **legacy** head profile: `compartment_tags`, `sensor_tags`, `s_imaging_method_name`, `imaging_method`, `s_on`, `s_names_visible`, `current_sensors`, `s_name_list`, `s_color_table`.

Loaded by: `zef_open_init_profile`, `zef_apply_init_profile`; applied when the user clicks “Apply” or “Update from profile” in the init profile dialog.

---

### 2. `zeffiro_parameters.ini`

**Purpose:** Defines **physical and numerical parameters** that can be assigned to compartments or used globally (e.g. electrical conductivity, mass density, electrode impedance). These appear in the parameter profile table and in segmentation/compartment dialogs.

**Format:** CSV; each line:  
`Display name, field_name, type, default_value, unit, visibility_flag_1, visibility_flag_2, category`

- **Display name** — Human-readable name (e.g. “Electrical conductivity”).
- **field_name** — Struct field used in the application (e.g. `sigma`, `rho`, `electrode_impedance`).
- **type** — Usually `Scalar`.
- **default_value** — Default numeric value.
- **unit** — Unit string (e.g. `S/m`, `kg/m3`, `Ohm`, `mm`, `Rel.`, `W/(Km)`).
- **visibility_flag_1, visibility_flag_2** — Control where the parameter is shown (e.g. On/Off in segmentation vs. sensors).
- **category** — Grouping: e.g. `Segmentation`, `Sensors`, `Free form`.

**Common parameters:**

- **Segmentation / physics:** `sigma` (electrical conductivity), `rho` (mass density), `epsilon` (dielectric permittivity), `mu` (magnetic permeability), `kappa` (thermal conductivity), `condition_number` (finite element condition number), `filtered_tetra` (filter labels).
- **Sensors:** `electrode_impedance`, `electrode_outer_radius`, `electrode_inner_radius`.
- **NSE profile only:** `mvd_length` (microvessel density), `nse_sigma` (NSE conductivity).
- **Radar profile:** `wireframe_permittivity_vec`, `wireframe_filling_vec`.

Loaded by: `zef_open_parameter_profile`, `zef_apply_parameter_profile`.

---

### 3. `zeffiro_forward_simulation.ini`

**Purpose:** Lists available **forward simulation types** (lead-field types) for the current profile. Each row corresponds to one option in the forward simulation / lead field selection UI.

**Format:** CSV; each line:  
`Display name, Short description, function_name`

- **Display name** — Label in the UI (e.g. “EEG lead field with isotropic electrical conductivity”).
- **Short description** — Tooltip or short explanation (e.g. “Electroencephalography lead field for electric potential field”).
- **function_name** — MATLAB function or script name (e.g. `zef_eeg_lead_field_isotropic;`). Trailing semicolon is conventional.

**Examples by profile:**

- **Neuro profiles:** EEG, MEG (magnetometers, gradiometers), EIT, tES; isotropic and anisotropic variants.
- **Asteroid gravity/radar:** Gravity and gravity-gradient lead fields (scalar and vector).

Loaded by: mesh tool and forward simulation UI (`zef_mesh_tool`, forward simulation table).

---

### 4. `zeffiro_plugins.ini`

**Purpose:** Registers **plugins** (tools) shown in the Zeffiro menu. Each row enables one menu item and links it to a startup script or function.

**Format:** CSV; each line:  
`Display name, menu_category, startup_function`

- **Display name** — Text shown in the menu (e.g. “Multi lead field tool”, “Beamformer”).
- **menu_category** — Group: `multi_tools`, `forward_tools`, `inverse_tools`, `settings`.
- **startup_function** — MATLAB function/script to run when the item is selected (e.g. `zef_lf_bank_tool`, `zef_beamformer_start`).

**Typical categories:**

- **multi_tools:** Lead field bank, reconstruction tool, data bank, wireframe creator, etc.
- **forward_tools:** Filter, topography, synthetic source, DTI conductivity, NSE tool (if enabled).
- **inverse_tools:** RAMUS, IAS, MNE, beamformer, dipole scan, Kalman, SESAME, etc.
- **settings:** e.g. GitHub pusher.

Loaded by: `zef_plugin`, `zef_open_plugin_settings`; saving from the plugin settings dialog writes back to this file.

---

### 5. `zeffiro_segmentation.ini`

**Purpose:** Default **compartment (tissue) definitions** for segmentation: identifiers, colors, activity flags, names, and default parameter values (e.g. conductivity or density). Used to populate the segmentation profile table and compartment lists.

**Format:** CSV; each line:  
`Property name, field_name, value_type, value1, value2, ...`

- **Property name** — Human-readable (e.g. “Compartment identifier”, “Compartment color”).
- **field_name** — Internal field (e.g. `compartment_tags`, `color`, `sources`, `name`, `sigma` or `rho`).
- **value_type** — `string` or `number`.
- **value1, value2, ...** — One value per compartment (order must match across rows).

**Rows typically present:**

- `compartment_tags` — Short identifiers (e.g. `sc`, `sk`, `c`, `g`, `w`, or `c1`, `c2`).
- `color` — RGB triplets per compartment (space-separated).
- `sources` — Activity/source flag per compartment (e.g. -1, 0, 1, 2, 3).
- `name` — Compartment names (e.g. Skin, Skull, Grey matter).
- **Parameter setting** — Default value for one physical parameter (e.g. `sigma` or `rho`) per compartment.

Profiles may leave compartment lists **empty** (user-defined mesh/compartments) or **prefilled** (e.g. legacy head with fixed sc, sk, c, g, w, d1–d22).

Loaded by: `zef_open_segmentation_profile`, `zef_init_compartments`.

---

## Profile Summaries

| Profile                     | Use case | Modalities / physics | Notes |
|----------------------------|----------|----------------------|--------|
| **asteroid_gravity**       | Gravity and gravity-gradient inversion (e.g. asteroid) | Scalar/vector field, gravity lead fields | Two compartments (Box, Asteroid); mass density (rho) as main parameter. |
| **asteroid_radar**         | Radar / EM with wireframe | Same gravity lead fields as asteroid_gravity; wireframe permittivity/filling | Same compartments as asteroid_gravity; dielectric/permittivity and wireframe parameters. |
| **multicompartment_head**  | General neuroimaging | EEG, MEG, EIT, tES (iso/aniso) | No predefined compartments; full plugin set (Kalman, NSE, DTI, etc.). |
| **multicompartment_head_legacy** | Legacy head model | Same as multicompartment_head | Fixed 30 compartments (sc, sk, c, g, w, d1–d22); predefined colors and sigma. |
| **multicompartment_head_nse** | Neuro + NSE (e.g. haemodynamics) | Same as multicompartment_head | Adds microvessel density and NSE conductivity parameters; NSE tool in plugins. |

---

## How the Application Uses These Files

1. **Startup:** `zeffiro_interface.ini` is read to set global options and `profile_name`. The profile subfolder `profile/<profile_name>/` is then used for init, parameters, forward simulation, plugins, and segmentation.
2. **Init profile:** Applying or loading the init profile reads `zeffiro_init.ini` and updates modalities, plot size, and (in legacy) compartment/sensor tags.
3. **Parameter profile:** Opening or applying the parameter profile reads/writes `zeffiro_parameters.ini` and updates the list of physical parameters available in the UI.
4. **Forward simulation:** The mesh/forward UI loads `zeffiro_forward_simulation.ini` to populate the list of lead-field types.
5. **Plugins:** The menu is built from `zeffiro_plugins.ini`; the plugin settings dialog can reload or save this file.
6. **Segmentation:** Compartment defaults come from `zeffiro_segmentation.ini`; they can be edited and saved back from the segmentation profile dialog.

For implementation details, see the functions referenced above (e.g. in `m/zef_open_init_profile.m`, `m/zef_apply_system_settings.m`, `m/zef_plugin.m`).

---

## Subfolder Documentation

Each profile subfolder has its own **README.md** describing that profile’s purpose and the role of each INI file in that folder:

- [asteroid_gravity/README.md](asteroid_gravity/README.md) — Gravity and gravity-gradient inversion (asteroid-style).
- [asteroid_radar/README.md](asteroid_radar/README.md) — Radar/EM with wireframe and dielectric parameters.
- [multicompartment_head/README.md](multicompartment_head/README.md) — Main neuroimaging profile (EEG/MEG/EIT/tES).
- [multicompartment_head_legacy/README.md](multicompartment_head_legacy/README.md) — Legacy 30-compartment head model.
- [multicompartment_head_nse/README.md](multicompartment_head_nse/README.md) — Neuroimaging with NSE (e.g. haemodynamics).

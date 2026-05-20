# menu_tool

The **+menu_tool** package holds callbacks for the Zeffiro Interface **Menu tool** submenu. Each function is tied to a specific menu action (e.g. Import electrodes) and updates the central application struct **zef** using data from user-selected files or dialogs.

Invocation is through the `core.gui.menu_tool` namespace, typically from the menu system rather than from user scripts.

## Functions

| Function | Menu action | Description |
|----------|-------------|-------------|
| **import_electrodes_callback** | *Menu tool > Import > Import electrodes* | Opens a file dialog for .dat or .csv files, imports electrode positions (and optional labels and CEM data), and writes them into **zef**. |

## import_electrodes_callback

- **Purpose:** Lets the user choose a .dat or .csv electrode file, parses it via **core.import.electrodes_from_dat** or **core.import.electrodes_from_csv**, and updates **zef** with sensor data.
- **Behavior:**
  - Shows a file dialog filtered to `*.dat` and `*.csv`.
  - On Cancel, returns immediately without changing **zef**.
  - On success: sets **zef.sensors**, **zef.(prefix)_points**, **zef.(prefix)_name_list**; if the file includes complete electrode model (CEM) data, **_(prefix)_points** also gets columns 4–6 (inner_radius, outer_radius, impedance). The prefix is **zef.current_sensors** if present, otherwise **"s"** (e.g. **s_points**, **s_name_list**).
  - On read or validation errors, displays an error dialog and returns without modifying **zef**.
  - Calls **zef_update(zef)** before returning so the UI reflects the new data.
- **Usage:** Normally not called directly; invoked by the menu when the user selects *Import electrodes*. For programmatic import, use **core.import.electrodes_from_dat** or **core.import.electrodes_from_csv** and then assign into **zef** and call **zef_update**.

## File formats

Supported formats are the same as in **core.import**: see [+import/README.md](../../+import/README.md) for .dat and .csv column layouts, optional labels, and CEM fields.

## See also

- [core.gui/README.md](../README.md) — GUI package overview.
- [core.import](../../+import/README.md) — Electrode import functions.
- [core/README.md](../../README.md) — Core package overview.

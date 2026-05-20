# import

The **+import** package provides functions to load external data into formats used by the Zeffiro Interface central struct. It is invoked with the `core.import` namespace from the Zeffiro root folder.

## Functions

| Function | Purpose |
|----------|---------|
| **electrodes_from_dat** | Import electrode positions and optional labels and CEM parameters from a whitespace-separated text (.dat) file. |
| **electrodes_from_csv** | Import electrode positions and optional labels and CEM parameters from a CSV file with named columns. |

Both return:

- **electrode_data** — `N×3` or `N×6` double array. Columns 1–3 are always `(x, y, z)`. Columns 4–6, when present, are complete electrode model (CEM) data: inner radius, outer radius, impedance.
- **electrode_labels** — `N×1` string array of electrode names. Missing labels are replaced by a configurable prefix plus row index (e.g. `"S1"`, `"S2"`).

## File formats

### .dat (electrodes_from_dat)

- One electrode per line; fields separated by whitespace; no spaces inside a field.
- **Required:** three numeric columns `x y z`.
- **Optional:** fourth column = label (string). If present, the line has 4 columns.
- **Optional CEM:** if CEM data is used, exactly three extra columns are required: `inner_radius outer_radius impedance`. So valid line lengths are:
  - 3 columns: `x y z`
  - 4 columns: `x y z label`
  - 6 columns: `x y z inner_radius outer_radius impedance`
  - 7 columns: `x y z label inner_radius outer_radius impedance`
- Constraints: inner_radius ≥ 0, outer_radius > inner_radius, impedance > 0.

### .csv (electrodes_from_csv)

- First row is the header. Column names are case-sensitive.
- **Required columns:** `x`, `y`, `z`.
- **Optional column:** `label`.
- **Optional CEM columns:** `inner_radius`, `outer_radius`, `impedance`. All three must be present together to be used; otherwise a warning is issued and CEM data is ignored.
- Same sign and ordering constraints as for .dat for CEM fields.

## Optional argument

Both functions accept:

- **MISSING_LABEL** (string, default `"S"`) — Prefix for auto-generated labels when a row has no label (e.g. `"S"` → `"S1"`, `"S2"`).

Example:

```matlab
[data, labels] = core.import.electrodes_from_dat("electrodes.dat");
[data, labels] = core.import.electrodes_from_csv("electrodes.csv", "MISSING_LABEL", "E");
```

## Integration with the GUI

The menu item *Menu tool > Import > Import electrodes* uses **core.gui.menu_tool.import_electrodes_callback**, which in turn calls `electrodes_from_dat` or `electrodes_from_csv` depending on the selected file extension and writes the results into the central Zeffiro struct (`sensors`, `<prefix>_points`, `<prefix>_name_list`, and CEM columns when available).

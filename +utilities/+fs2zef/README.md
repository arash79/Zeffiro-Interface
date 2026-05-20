# FreeSurfer to Zeffiro Pipeline (fs2zef)

Converts FreeSurfer segmentation data into Zeffiro Interface–compatible meshes and import files. Fully file-driven: you choose which `.mgz` files to process; the pipeline discovers labels, assigns parameters, and generates ready-to-use output.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Quick Start](#quick-start)
3. [Usage Guide](#usage-guide)
4. [API Reference](#api-reference)
5. [Output Structure](#output-structure)
6. [Importing into Zeffiro](#importing-into-zeffiro)
7. [Supported Segmentation Files](#supported-segmentation-files)
8. [Options Reference](#options-reference)
9. [Package Structure](#package-structure)
10. [Testing](#testing)
11. [Troubleshooting](#troubleshooting)

---

## Requirements

- **FreeSurfer** 7.0 or later (tested with 8.0)
- **MATLAB** R2020b or later
- FreeSurfer subject processed with `recon-all`

### Environment Variables

Before running, set:

```matlab
setenv('FREESURFER_HOME', '/path/to/freesurfer');   % e.g. /Applications/freesurfer/8.0.0
setenv('SUBJECTS_DIR', '/path/to/freesurfer/subjects');
```

---

## Quick Start

```matlab
% 1. Set environment
setenv('FREESURFER_HOME', '/Applications/freesurfer/8.0.0');
setenv('SUBJECTS_DIR', '/Users/you/freesurfer_subjects');

% 2. Run pipeline
utilities.fs2zef.run('subject01', "aseg.mgz", 'output');

% 3. Import into Zeffiro
zef = zef_import_segmentation([], 'import_segmentation.zef', 'output/mesh');
```

---

## Usage Guide

### Basic Workflow

1. **Set environment variables** (once per session).
2. **Choose segmentation files** in the subject’s `mri/` directory (e.g. `aseg.mgz`, `ThalamicNuclei.mgz`).
3. **Call `run`** with subject ID, segmentation files, and output directory.
4. **Import** the generated `.zef` file into Zeffiro Interface.

### Common Use Cases

**Standard brain (subcortical compartments):**
```matlab
utilities.fs2zef.run('subject01', "aseg.mgz", 'output');
```

**Brain with thalamic nuclei:**
```matlab
utilities.fs2zef.run('subject01', ...
    ["aseg.mgz", "ThalamicNuclei.v13.T1.FSvoxelSpace.mgz"], ...
    'output');
```

**White matter parcellation:**
```matlab
utilities.fs2zef.run('subject01', "wmparc.mgz", 'output');
```

**Multiple specialized segmentations:**
```matlab
utilities.fs2zef.run('subject01', ...
    ["aseg.mgz", "ThalamicNuclei.mgz", ...
     "lh.hippoSfLabels.mgz", "rh.hippoSfLabels.mgz"], ...
    'output');
```

---

## API Reference

### Main Function

```matlab
output = utilities.fs2zef.run(subject_id, segmentation_files, output_dir, options)
```

| Argument             | Type          | Required | Description                                          |
|----------------------|---------------|----------|------------------------------------------------------|
| `subject_id`         | string        | Yes      | FreeSurfer subject ID in `SUBJECTS_DIR`              |
| `segmentation_files` | string array  | Yes      | `.mgz` filenames (e.g. `["aseg.mgz", "ThalamicNuclei.mgz"]`) |
| `output_dir`         | string        | Yes      | Directory for output meshes and import files         |

### Return Value

Struct with:

- `subject_id` — Processed subject
- `segmentation_files` — Processed files
- `output_dir` — Output directory
- `meshes_created` — List of generated mesh files
- `zef_import_file` — Cell array of paths to import files (`ascii/` and `mesh/`)
- `warnings` — Any warnings
- `elapsed_time` — Time in seconds

---

## Output Structure

```
output_dir/
├── ascii/
│   ├── electrodes.dat
│   ├── import_segmentation.zef
│   ├── Left-Thalamus.asc
│   ├── Right-Thalamus.asc
│   └── ...
└── mesh/
    ├── electrodes.dat
    ├── import_segmentation.zef
    ├── Left-Thalamus.stl
    ├── Right-Thalamus.stl
    └── ...
```

- **`ascii/`** — FreeSurfer ASCII (`.asc`) meshes and import file.
- **`mesh/`** — STL meshes and import file.
- **`electrodes.dat`** — Copied into each subdirectory for use with the import files.
- **`import_segmentation.zef`** — Zeffiro import file for that format, with paths relative to the project root.

---

## Importing into Zeffiro

Use `zef_import_segmentation`, not `zef_import`:

```matlab
% Import mesh (STL) format
zef = zef_import_segmentation([], 'import_segmentation.zef', 'output_dir/mesh');

% Import ASCII format
zef = zef_import_segmentation([], 'import_segmentation.zef', 'output_dir/ascii');
```

Arguments: `(zef, filename, folder)`. Use the folder containing the `.zef` file.

---

## Supported Segmentation Files

Any `.mgz` in the subject’s `mri/` directory can be used. Common examples:

| File                         | Description                    |
|-----------------------------|--------------------------------|
| `aseg.mgz`                  | Standard subcortical (~40 labels) |
| `wmparc.mgz`                | White matter parcellation      |
| `ThalamicNuclei.mgz`        | Thalamic nuclei                |
| `lh.hippoSfLabels.mgz`      | Left hippocampal subfields     |
| `rh.hippoSfLabels.mgz`      | Right hippocampal subfields    |
| `brainstemSsLabels.mgz`     | Brainstem substructures        |

---

## Options Reference

| Option               | Type    | Default  | Description |
|----------------------|---------|----------|-------------|
| `output_format`      | string  | `'both'` | `'ascii'`, `'stl'`, or `'both'` |
| `compute_transforms` | logical | `true`   | Compute affine transforms for alignment |
| `reference_volume`   | string  | `'orig.mgz'` | Reference volume for transforms |
| `include_surfaces`   | logical | `true`   | Include cortical surfaces (pial, white) |
| `include_skull_skin` | logical | `true`   | Include skull and skin surfaces |
| `electrode_file`     | string  | built-in | Path to electrode file |
| `merge_left_right`   | logical | `true`   | See [Merge Option](#merge-option) |
| `verbose`            | logical | `true`   | Print progress |

### Merge Option (`merge_left_right`)

Controls how left/right compartments appear in the import file.

**`merge_left_right = true` (default):**
- Both entries use the base name (e.g. `CM`).
- `merge = 0` for left, `merge = 1` for right.
- Example: `name,CM,...,merge,0` and `name,CM,...,merge,1`.

**`merge_left_right = false`:**
- Name includes side: `Left CM`, `Right CM`.
- `merge = 0` for all compartments (left, right, and single).

```matlab
% Merged compartments (default)
utilities.fs2zef.run('subject01', "aseg.mgz", 'output', 'merge_left_right', true);

% Separate left/right
utilities.fs2zef.run('subject01', "aseg.mgz", 'output', 'merge_left_right', false);
```

### Sorting in Import Files

Segmentation rows are sorted by base compartment name (left/right ignored). Left/right pairs are adjacent, with left before right.

---

## Package Structure

```
+utilities/+fs2zef/
├── run.m                     # Main entry point
├── FREESURFER_ENV_VARS.m     # Environment variable definitions
├── example_usage.m           # Usage examples
├── test_unified_pipeline.m   # Foundation test suite
├── TEST_WITH_YOUR_DATA.m     # Test with real data
│
├── +config/
│   ├── default_config.m
│   ├── compartment_mappings.m
│   └── parcellation_schemes.m
│
├── +environment/
│   ├── setup_freesurfer_env.m
│   └── validate_environment.m
│
├── +generators/
│   ├── generate_zef_import.m   # Dynamic import file generation
│   ├── save_color_tables.m
│   └── save_dats.m
│
├── +readers/
│   ├── readFSLUT.m
│   ├── get_volume_centers.m
│   └── ...
│
├── +scripts/
│   └── makeParcellation.sh    # FreeSurfer extraction script
│
├── +transforms/
│   ├── compute_affine_transform.m
│   └── apply_affine_transform.m
│
└── data/
    ├── electrodes.dat
    └── import_segmentation_template.zef
```

---

## Testing

### Foundation Test

```matlab
utilities.fs2zef.test_unified_pipeline()
```

Checks environment, configuration, readers, transforms, and ZEF import generation.

### Test with Your Data

```matlab
run('+utilities/+fs2zef/TEST_WITH_YOUR_DATA.m')
```

Adapts to your `SUBJECTS_DIR` and subject IDs.

---

## Troubleshooting

### "FREESURFER_HOME is not set"

```matlab
setenv('FREESURFER_HOME', '/path/to/freesurfer');
```

### "SUBJECTS_DIR not set"

```matlab
setenv('SUBJECTS_DIR', '/path/to/freesurfer/subjects');
```

### "Environment validation failed" / binaries not found

The pipeline sets up the FreeSurfer environment before validation. If validation still fails:

1. Confirm `FREESURFER_HOME` points to a valid FreeSurfer install.
2. Run `source $FREESURFER_HOME/SetUpFreeSurfer.sh` in a terminal and verify `mris_convert` etc. are available.

### "Subject not found"

Ensure the subject exists under `SUBJECTS_DIR`:

```matlab
fullfile(getenv('SUBJECTS_DIR'), 'subject01')
```

### "Segmentation file not found"

Check that the `.mgz` file is in the subject’s `mri/` directory:

```matlab
fullfile(getenv('SUBJECTS_DIR'), 'subject01', 'mri', 'aseg.mgz')
```

### Import opens file dialog instead of loading

Use `zef_import_segmentation`, not `zef_import`:

```matlab
zef = zef_import_segmentation([], 'import_segmentation.zef', 'output_dir/mesh');
```

---

## How It Works

1. **Environment setup** — Adds FreeSurfer binaries to `PATH` and validates.
2. **For each segmentation file:**
   - Runs `mri_segstats` to discover labels.
   - Runs `mri_mc` to extract meshes per label.
   - Converts to ASCII and/or STL via `mris_convert`.
3. **Surfaces** — Converts pial, white, skull, and skin if requested.
4. **Electrodes** — Copies `electrodes.dat` into `ascii/` and `mesh/`.
5. **Import files** — Generates `import_segmentation.zef` for each subdirectory with:
   - Full relative paths (e.g. `./output/mesh/Left-Thalamus.stl`)
   - Colors from FreeSurferColorLUT.txt
   - Tissue parameters from `compartment_mappings`
   - Affine transforms when needed
   - Sorting by base compartment name, left before right

---

## License

[Specify license]

---

**Version:** 2.0  
**Status:** Production Ready

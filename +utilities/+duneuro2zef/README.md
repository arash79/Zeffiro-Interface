# Duneuro to Zeffiro Interface Converter

This utility package provides tools for importing externally generated finite element method (FEM) meshes from [Duneuro](https://www.duneuro.org/) into the Zeffiro Interface (ZI) environment. The package handles mesh conversion, sensor configuration, lead field processing, and measurement data import for both EEG and MEG modalities.

## Overview

The Duneuro2Zeffiro converter facilitates the integration of Duneuro-generated meshes and associated data into Zeffiro Interface workflows. It performs essential data transformations including:

- **Mesh Conversion**: Converts hexahedral (hex) meshes to tetrahedral (tet) format required by Zeffiro Interface
- **Source Space Processing**: Imports and processes source space definitions
- **Sensor Configuration**: Handles EEG electrode and MEG sensor configurations with coordinate transformations
- **Lead Field Processing**: Converts and filters lead field matrices for both modalities
- **Measurement Data**: Extracts and formats measurement data from FieldTrip structures

## Package Architecture

The package has been refactored into a modular, configurable architecture for better generalization and maintainability:

### Main Entry Point

- **`import_duneuro_project.m`**: **Main wrapper function** that orchestrates the entire import pipeline
  - Converts Duneuro files
  - Imports data into Zeffiro Interface
  - Configures settings and processes meshes
  - Recommended entry point for new projects

### Core Functions

- **`run.m`**: Main conversion function with programmatic interface and error handling
- **`get_default_config.m`**: Returns default configuration structure that can be customized
- **`validate_config.m`**: Validates configuration and ensures all required fields are present
- **`find_files.m`**: File discovery utility with pattern matching support

### Modular Processing Functions

- **`convert_mesh.m`**: Converts hexahedral to tetrahedral mesh format
- **`process_source_space.m`**: Processes source space grid positions
- **`process_resection_points.m`**: Handles resection point coordinates (optional)
- **`process_eeg_data.m`**: Processes EEG lead fields, measurements, and sensors
- **`process_meg_data.m`**: Processes MEG lead fields, measurements, and sensors
- **`process_sensors.m`**: Processes sensor configurations for EEG or MEG

### Pipeline Functions (Called from .zef file)

- **`Duneuro2Zeffiro_convert.m`**: Converts Duneuro files to Zeffiro format
  - Called from `.zef` file line 1
  - Can also be called programmatically
  - Wraps `run.m` for backward compatibility

- **`Duneuro2Zeffiro_settings.m`**: Configures Zeffiro Interface parameters after import
  - Called from `.zef` file line 19 (after all imports)
  - Can also be called programmatically
  - Sets source modes, processes meshes, performs interpolation

- **`Duneuro2Zeffiro_import.zef`**: Import configuration file for Zeffiro Interface import workflow
  - Defines the sequence of import operations
  - Parsed by `zef_import_segmentation()`
  - Contains conversion, import, and configuration steps

### Databank Helper Functions

- **`EEG_to_databank.m`**: Adds EEG data items to the Zeffiro Interface databank
- **`MEG_to_databank.m`**: Adds MEG data items to the Zeffiro Interface databank

## Import Pipeline and Workflow

The Duneuro to Zeffiro Interface import process consists of three main steps:

### Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Duneuro Import Pipeline                       │
└─────────────────────────────────────────────────────────────────┘

Step 1: CONVERSION
  Duneuro files → Zeffiro format files
  (Duneuro2Zeffiro_convert / run.m)
  
Step 2: IMPORT
  Zeffiro format files → Zeffiro Interface data structures
  (Handled by Duneuro2Zeffiro_import.zef)
  
Step 3: CONFIGURATION
  Configure ZI settings and process meshes
  (Duneuro2Zeffiro_settings)
```

### Two Usage Modes

#### Mode 1: Programmatic (Recommended for New Projects)

Use the main wrapper function `import_duneuro_project()` which orchestrates all three steps:

```matlab
% Full pipeline (convert + import + configure)
results = utilities.duneuro2zef.import_duneuro_project();

% Custom configuration
config = utilities.duneuro2zef.get_default_config();
config.input_folder = 'my_data/duneuro_export';
results = utilities.duneuro2zef.import_duneuro_project(config);
```

#### Mode 2: Via Zeffiro Interface Import System (Legacy/Manual)

Use the `.zef` import file through Zeffiro Interface's import menu:

1. **Convert files first** (can be done programmatically):
   ```matlab
   utilities.duneuro2zef.Duneuro2Zeffiro_convert();
   ```

2. **Import via Zeffiro Interface**:
   - Open Zeffiro Interface
   - Go to Import menu → "Import segmentation from folder"
   - Select `Duneuro2Zeffiro_import.zef`
   - The import system automatically executes all steps in the `.zef` file

### Understanding the .zef Import File

The `Duneuro2Zeffiro_import.zef` file is a configuration file that tells Zeffiro Interface's import system what to do. It contains a sequence of commands executed in order:

1. **Line 1**: Runs `Duneuro2Zeffiro_convert` to convert Duneuro files
2. **Lines 2-12**: Import converted data (sensors, meshes, lead fields, measurements)
3. **Lines 13-18**: Define segmentation compartments
4. **Line 19**: Runs `Duneuro2Zeffiro_settings` to configure ZI

The `.zef` file format is parsed by `zef_import_segmentation()`, which:
- Executes `type,script` entries by calling the specified function
- Imports `type,struct` entries as MATLAB structures
- Imports `type,sensors` entries as sensor configurations
- Defines `type,segmentation` entries as compartments

## Usage

### Quick Start: Full Pipeline (Recommended)

For complete import in one call:

```matlab
% Use default configuration - full pipeline
results = utilities.duneuro2zef.import_duneuro_project();

% Check results
if results.success
    fprintf('Import successful! Processed %d files.\n', length(results.processed_files));
else
    fprintf('Import completed with errors. Check results.errors\n');
end
```

### Quick Start: Conversion Only

For projects matching the default file structure and naming conventions:

```matlab
% Convert files only (no import)
results = utilities.duneuro2zef.run();

% Check results
if results.success
    fprintf('Conversion successful! Processed %d files.\n', length(results.processed_files));
else
    fprintf('Conversion completed with errors. Check results.errors\n');
end
```

### Custom Configuration

For projects with different file names, paths, or processing requirements:

```matlab
% Get default configuration
config = utilities.duneuro2zef.get_default_config();

% Customize paths
config.input_folder = 'my_data/duneuro_export';
config.output_folder = 'my_data/zeffiro_import';

% Customize file names
config.files.source_space = 'sp_vol_rgv_N85540.mat';  % Different source space
config.files.measurements_eeg = 'my_eeg_data.mat';

% Customize processing options
config.eeg.channel_indices = [1:64];  % Custom channel selection
config.meg.max_channels = 306;  % Use all MEG channels
config.domain_labels.brain = 3;  % Different brain domain label

% Run conversion
results = utilities.duneuro2zef.run(config);
```

### Configuration Options

The configuration structure supports the following customizable parameters:

#### File Paths
- `config.input_folder`: Directory containing Duneuro export files (default: `'data/exported'`)
- `config.output_folder`: Directory for converted files (default: `'data/converted'`)

#### Input File Names
- `config.files.mesh`: Mesh file name (default: `'mesh.mat'`)
- `config.files.source_space`: Source space file name or pattern (default: `'sp_vol_rgv_N*.mat'`)
- `config.files.resection_points`: Resection points file (default: `'resection_points.dat'`)
- `config.files.leadfield_eeg`: EEG lead field file (default: `'LF_EEG.mat'`)
- `config.files.leadfield_meg`: MEG lead field file (default: `'LF_MEG.mat'`)
- `config.files.measurements_eeg`: EEG measurements file (default: `'spikeAvgEEG.mat'`)
- `config.files.measurements_meg`: MEG measurements file (default: `'spikeAvgMEG.mat'`)
- `config.files.sensors`: Sensor configuration file (default: `'sensors.mat'`)

#### Processing Options
- `config.process_eeg`: Process EEG data (default: `true`)
- `config.process_meg`: Process MEG data (default: `true`)
- `config.process_resection_points`: Process resection points (default: `true`)
- `config.invert_domain_labels`: Invert domain labels (default: `true`)
- `config.verbose`: Print progress messages (default: `true`)
- `config.continue_on_error`: Continue processing if errors occur (default: `false`)

#### Domain Configuration
- `config.domain_labels.brain`: Domain label for brain compartment (default: `2`)

#### EEG Configuration
- `config.eeg.channel_indices`: Indices for EEG channels in full channel set (default: `[302:358, inf]`)
- `config.eeg.channel_path`: Path to channel list in FieldTrip structure (default: `{'cfg', 'previous', 'previous', 'channel'}`)
- `config.eeg.measurement_field`: Field name in measurement structure (default: `'avg'`)

#### MEG Configuration
- `config.meg.max_channels`: Maximum number of MEG channels (default: `274`)
- `config.meg.use_magnetometers`: Use magnetometers (default: `true`)
- `config.meg.measurement_field`: Field name in measurement structure (default: `'avg'`)

#### Source Space Configuration
- `config.source_space.priority`: Selection priority for multiple matches - `'smallest'`, `'largest'`, or `'first'` (default: `'smallest'`)

### Detailed Workflow Explanation

#### Step 1: Conversion (Duneuro → Zeffiro Format)

This step converts Duneuro export files into Zeffiro Interface-compatible format:

- **Functions**: `run.m` (orchestrator) → `convert_mesh()`, `process_source_space()`, `process_eeg_data()`, `process_meg_data()`
- **Entry Point**: `Duneuro2Zeffiro_convert.m` (called from .zef file) or `run.m` (called programmatically)
- **Input**: Duneuro export files in `config.input_folder` (default: `data/exported/`)
- **Output**: Converted files in `config.output_folder` (default: `data/converted/`)
- **What it does**:
  - Converts hexahedral mesh to tetrahedral (via `convert_mesh()`)
  - Processes source space positions (via `process_source_space()`)
  - Filters and processes lead fields (via `process_eeg_data()`, `process_meg_data()`)
  - Extracts measurement data
  - Configures sensor positions (via `process_sensors()`)
  - Processes optional resection points (via `process_resection_points()`)

**Idempotency**: `Duneuro2Zeffiro_convert()` checks if output files exist and skips conversion if they do, preventing duplicate work.

#### Step 2: Import (Files → Zeffiro Interface)

This step loads the converted files into Zeffiro Interface's data structures:

- **Mechanism**: Zeffiro Interface's import system (`zef_import_segmentation`)
- **Configuration**: `Duneuro2Zeffiro_import.zef` file
- **Execution**: Processes each line of `.zef` file sequentially
- **What it does**:
  - [Line 1] Runs conversion (if not already done)
  - [Lines 2-3] Imports sensor configurations (EEG, MEG)
  - [Lines 4-8] Imports data structures (mesh, source space, lead fields, measurements)
  - [Line 9] Adds MEG data to databank (via `MEG_to_databank()`)
  - [Lines 10-11] Imports EEG data structures
  - [Line 12] Adds EEG data to databank (via `EEG_to_databank()`)
  - [Lines 13-18] Defines segmentation compartments
  - [Line 19] Configures Zeffiro Interface (via `Duneuro2Zeffiro_settings()`)

**Path Resolution**: Relative paths in `.zef` file (e.g., `data/converted/`) are resolved relative to the current working directory (`pwd`).

#### Step 3: Configuration (ZI Settings & Mesh Processing)

This step configures Zeffiro Interface parameters and processes meshes:

- **Function**: `Duneuro2Zeffiro_settings.m`
- **When**: Called automatically by `.zef` file line 19 (after all imports)
- **What it does**:
  - Sets source direction modes
  - Configures frequency parameters
  - Sets compartment source constraints
  - Builds compartment table
  - Processes meshes (normals, adjacency)
  - Performs surface downsampling
  - Maps source positions to mesh elements (source interpolation)

**Note**: This step is automatically executed by the `.zef` file, so `import_duneuro_project()` does not call it separately.

### Manual Workflow (Using .zef File)

If you prefer to use Zeffiro Interface's import menu:

1. **Prepare Data Files**: Ensure all Duneuro-exported data files are in `data/exported/`:
   - `mesh.mat`: Hexahedral mesh with elements, nodes, and labels
   - `sp_vol_rgv_N*.mat`: Source space grid positions
   - `resection_points.dat`: Resection point coordinates (optional)
   - `LF_EEG.mat`, `LF_MEG.mat`: Lead field matrices
   - `spikeAvgEEG.mat`, `spikeAvgMEG.mat`: FieldTrip measurement structures
   - `sensors.mat`: Sensor configuration structure

2. **Option A - Let .zef file handle conversion**:
   - Open Zeffiro Interface
   - Import → "Import segmentation from folder"
   - Select `Duneuro2Zeffiro_import.zef`
   - The `.zef` file automatically runs conversion (line 1) before importing

3. **Option B - Convert first, then import**:
   ```matlab
   % Convert files first
   utilities.duneuro2zef.Duneuro2Zeffiro_convert();
   
   % Then import via ZI menu
   % Import → "Import segmentation from folder" → Duneuro2Zeffiro_import.zef
   ```

4. **Verify Import**:
   - Check that meshes, sensors, and data appear in the Zeffiro Interface databank
   - Verify source space and lead fields are correctly loaded

## How the .zef Import File Works

The `Duneuro2Zeffiro_import.zef` file is a configuration file that defines the import sequence. When you import it through Zeffiro Interface's import menu, the system (`zef_import_segmentation`) parses it line by line and executes each command in order.

### Execution Order in .zef File

```
Line 1:  Duneuro2Zeffiro_convert     → Converts Duneuro files to Zeffiro format
                                         (Checks if files exist, skips if already converted)
Lines 2-3:  Import sensors            → Loads EEG and MEG sensor configurations
Lines 4-8:  Import data structures    → Loads mesh, source space, lead fields, measurements
Line 9:     MEG_to_databank          → Adds MEG data to databank
Lines 10-12: Import EEG data         → Loads EEG lead fields and measurements
Line 12:    EEG_to_databank          → Adds EEG data to databank
Lines 13-18: Define compartments     → Creates segmentation compartments
Line 19:    Duneuro2Zeffiro_settings → Configures ZI and processes meshes
```

### Complete Execution Flow

#### When using `import_duneuro_project()`:

```
import_duneuro_project()
  │
  ├─> Step 1: Conversion
  │     └─> run(config)
  │           ├─> validate_config()
  │           ├─> convert_mesh() → find_files()
  │           ├─> process_source_space() → find_files()
  │           ├─> process_resection_points() [optional]
  │           ├─> process_eeg_data() → process_sensors('EEG')
  │           └─> process_meg_data() → process_sensors('MEG')
  │
  ├─> Step 2: Import (via .zef file)
  │     └─> zef_import_segmentation(Duneuro2Zeffiro_import.zef)
  │           ├─> [Line 1] Duneuro2Zeffiro_convert()
  │           │     └─> Detects files exist, skips conversion
  │           ├─> [Lines 2-3] Import sensors
  │           ├─> [Lines 4-8] Import data structures
  │           ├─> [Line 9] MEG_to_databank()
  │           ├─> [Lines 10-11] Import EEG data
  │           ├─> [Line 12] EEG_to_databank()
  │           ├─> [Lines 13-18] Define compartments
  │           └─> [Line 19] Duneuro2Zeffiro_settings()
  │
  └─> Step 3: Configuration (handled by .zef file line 19)
        └─> Duneuro2Zeffiro_settings()
              └─> Configures ZI, processes meshes, performs interpolation
```

#### When using .zef file directly:

```
User: Zeffiro Interface → Import → Duneuro2Zeffiro_import.zef

zef_import_segmentation() processes .zef file line by line:
  ├─> [Line 1] Duneuro2Zeffiro_convert()
  │     └─> run() → [All conversion functions]
  ├─> [Lines 2-18] Import all data
  └─> [Line 19] Duneuro2Zeffiro_settings()
```

### Important Notes

1. **Double Conversion Prevention**: `Duneuro2Zeffiro_convert()` automatically detects if conversion files already exist and skips re-conversion. This prevents duplicate work when `import_duneuro_project()` calls conversion first, then the `.zef` file tries to convert again.

2. **Path Resolution**: The `.zef` file uses relative paths (`data/converted/`) which are resolved relative to the **current working directory** (`pwd`). When using `import_duneuro_project()`, ensure you're in the project root directory where the `data/` folder exists.

3. **Configuration Timing**: `Duneuro2Zeffiro_settings()` is called automatically by the `.zef` file (line 19) after all imports are complete. `import_duneuro_project()` does NOT call it separately to avoid double configuration.

### Import Configuration File Format

The `Duneuro2Zeffiro_import.zef` file uses a comma-separated parameter format. Each line defines a single import item with the following structure:

```
type,<type_value>,parameter1,value1,parameter2,value2,...
```

### Parameter Types

- **`script`**: Executes a MATLAB function (e.g., `utilities.duneuro2zef.Duneuro2Zeffiro_convert`)
  - Functions are called using `evalc()` in the base workspace
  - Must be callable without arguments or handle missing arguments gracefully
  
- **`struct`**: Imports a MATLAB structure into the Zeffiro Interface data structure
  - Loads `.mat` files and merges them into `zef` structure
  
- **`segmentation`**: Defines a segmentation compartment
  - Creates a new compartment in the segmentation table
  
- **`sensors`**: Defines a sensor set (EEG electrodes or MEG sensors)
  - Loads sensor positions and configurations

### Common Parameters

| Parameter | Description | Example Values |
|-----------|-------------|----------------|
| `type` | Type of import item | `script`, `struct`, `segmentation`, `sensors` |
| `name` | Field name in Zeffiro Interface | `Scalp`, `Electrodes`, `EEG measurements` |
| `filename` | File to import | `tetra_mesh.mat`, `EEG_sensors.mat` |
| `foldername` | Directory containing the file | `data/converted/` |
| `filetype` | File format | `mat` (MATLAB structure) |
| `tag` | Compartment tag in database | If not given, tag equals name |
| `on` | Active status (logical) | `true`, `false`, `1`, `0` |
| `merge` | Merge with existing mesh (logical) | `true`, `false`, `1`, `0` |
| `invert` | Invert surface normals (logical) | `true`, `false`, `1`, `0` |
| `activity` | Compartment activity mode | `-1` (bounding box), `0` (inactive), `1` (constrained), `2` (unconstrained), `3` (surface projection) |
| `visible` | Visibility in segmentation (logical) | `true`, `false`, `1`, `0` |
| `affine transform` | 4×4 affine transformation matrix | `[R t; 0 0 0 1]` |

## Generalization Features

The refactored architecture provides several improvements for generalization:

### 1. **Configurable File Paths and Names**
   - No hard-coded paths or file names
   - Easy adaptation to different project structures
   - Supports wildcard patterns for file discovery

### 2. **Flexible Data Structure Handling**
   - Automatically detects variable names in MATLAB files
   - Handles different FieldTrip structure formats
   - Supports alternative data organization

### 3. **Robust Error Handling**
   - Validates file existence before processing
   - Checks data structure integrity
   - Provides detailed error messages
   - Optional error recovery mode

### 4. **Modular Design**
   - Each processing step is a separate function
   - Easy to test and maintain
   - Can process individual components independently

### 5. **Extensible Configuration**
   - Easy to add new configuration options
   - Supports project-specific customizations
   - Default values for common use cases

## Data Processing Details

### Mesh Conversion

The conversion transforms hexahedral meshes (8-node hexahedra) to tetrahedral meshes (4-node tetrahedra) by decomposing each hexahedron into 6 tetrahedra. Domain labels can be inverted to match Zeffiro Interface conventions (configurable via `config.invert_domain_labels`).

### Lead Field Processing

- **EEG**: Lead fields are filtered to match channels present in the measurement data. Channel selection is configurable via `config.eeg.channel_indices`.
- **MEG**: Lead fields are transformed using the sensor transformation matrix (`grad.tra`) and filtered to specified number of channels (configurable via `config.meg.max_channels`).

### Sensor Configuration

- **EEG**: Electrode positions are extracted and stored with affine transformation matrices for coordinate system conversion
- **MEG**: Sensor positions and orientations are extracted, with separate handling for magnetometers and gradiometers

## Settings Configuration

The `Duneuro2Zeffiro_settings.m` script configures Zeffiro Interface parameters after import:

- **Source Direction Mode**: Set to normal (constrained) sources
- **Sampling Frequency**: Default 2400 Hz
- **Frequency Filters**: Configured for inverse processing
- **Compartment Sources**: Different source constraints for different tissue types
- **Mesh Processing**: Surface downsampling and source interpolation

## Error Handling and Validation

The new architecture includes comprehensive error handling:

- **File Validation**: Checks file existence before processing
- **Data Structure Validation**: Verifies required fields in loaded data
- **Dimension Checking**: Validates matrix dimensions and compatibility
- **Error Recovery**: Optional mode to continue processing after errors
- **Detailed Reporting**: Results structure contains success status, errors, warnings, and processed files

Example error handling:

```matlab
results = utilities.duneuro2zef.run(config);

if ~results.success
    fprintf('Errors occurred:\n');
    for i = 1:length(results.errors)
        fprintf('  - %s\n', results.errors{i});
    end
end

if ~isempty(results.warnings)
    fprintf('Warnings:\n');
    for i = 1:length(results.warnings)
        fprintf('  - %s\n', results.warnings{i});
    end
end
```

## Pipeline Verification

### Complete Function Call Map

All 15 functions in the package are actively used in the pipeline:

#### Main Orchestration
- ✅ **`import_duneuro_project()`** → Main entry point (user calls this)
  - Calls: `run()`, `zef_import_segmentation()`

#### Conversion Pipeline
- ✅ **`run()`** → Conversion orchestrator
  - Called by: `import_duneuro_project()`, `Duneuro2Zeffiro_convert()`
  - Calls: `validate_config()`, `convert_mesh()`, `process_source_space()`, `process_resection_points()`, `process_eeg_data()`, `process_meg_data()`

- ✅ **`get_default_config()`** → Configuration defaults
  - Called by: `run()`, `Duneuro2Zeffiro_convert()`, `validate_config()`

- ✅ **`validate_config()`** → Configuration validation
  - Called by: `run()`

#### Processing Functions (All called by `run()`)
- ✅ **`convert_mesh()`** → Mesh conversion
  - Calls: `find_files()`

- ✅ **`process_source_space()`** → Source space processing
  - Calls: `find_files()`

- ✅ **`process_resection_points()`** → Resection points (optional)
  - Called conditionally if `config.process_resection_points == true`

- ✅ **`process_eeg_data()`** → EEG data processing
  - Calls: `process_sensors('EEG')`

- ✅ **`process_meg_data()`** → MEG data processing
  - Calls: `process_sensors('MEG')`

- ✅ **`process_sensors()`** → Sensor configuration
  - Called by: `process_eeg_data()`, `process_meg_data()`

- ✅ **`find_files()`** → File discovery utility
  - Called by: `convert_mesh()`, `process_source_space()`

#### Pipeline Functions (Called from `.zef` file)
- ✅ **`Duneuro2Zeffiro_convert()`** → Conversion entry point
  - Called from: `.zef` file line 1
  - Calls: `run()` (with idempotency check)

- ✅ **`MEG_to_databank()`** → MEG databank setup
  - Called from: `.zef` file line 9

- ✅ **`EEG_to_databank()`** → EEG databank setup
  - Called from: `.zef` file line 12

- ✅ **`Duneuro2Zeffiro_settings()`** → ZI configuration
  - Called from: `.zef` file line 19

**Verification Result**: ✅ All 15 functions are actively used. No unused code. Pipeline is complete and orchestrated.

## Troubleshooting

### Common Issues

1. **Missing Data Files**: 
   - Check that all required files exist in `config.input_folder`
   - Verify file names match `config.files.*` settings
   - Use `config.verbose = true` to see which files are being processed

2. **Path Issues**: 
   - **Critical**: The `.zef` file uses relative paths (`data/converted/`) resolved relative to `pwd`
   - When using `import_duneuro_project()`, ensure you're in the project root directory
   - The function validates that `config.output_folder` exists before import
   - Use absolute paths in `config` if working from a different directory

3. **Double Conversion**: 
   - `Duneuro2Zeffiro_convert()` automatically detects existing files and skips conversion
   - If you want to force re-conversion, delete files in `config.output_folder` first

4. **Channel Mismatch**: 
   - Verify `config.eeg.channel_indices` matches your data structure
   - Check FieldTrip structure path via `config.eeg.channel_path`
   - Use `config.verbose = true` to see channel processing details

5. **Domain Label Issues**: 
   - Verify `config.domain_labels.brain` matches your mesh labeling
   - Check if `config.invert_domain_labels` should be `true` or `false`

6. **Data Structure Variations**: 
   - The code automatically detects variable names, but if issues occur, check the FieldTrip structure format
   - Verify measurement structures contain `avg` or `data` fields

### File Format Requirements

- **Mesh files**: Must contain `elements`, `nodes`, and `labels` fields (or be in a `mesh` structure)
- **Lead field files**: Must contain a lead field matrix (variable names: `LF_EEG`, `LF_MEG`, `L`, or single variable)
- **Source space files**: Must contain N×3 matrix of source positions
- **Measurement files**: Must follow FieldTrip format with `avg` or `data` field
- **Sensor files**: Must contain sensor positions (`elec.chanpos` or `grad.chanpos`) and optionally transformations

## Function Roles in the Pipeline

### Main Orchestrator

- **`import_duneuro_project()`**: **Primary entry point** for complete import
  - Orchestrates all three pipeline steps
  - Handles errors and provides comprehensive results
  - Auto-detects Zeffiro Interface availability
  - Recommended for new projects

### Conversion Functions

- **`run()`**: Core conversion engine
  - Processes all data files
  - Modular, configurable, with error handling
  - Can be used independently for conversion-only workflows

- **`Duneuro2Zeffiro_convert()`**: Pipeline entry point for conversion step
  - Called from `.zef` file line 1
  - Wraps `run()` for backward compatibility
  - Can be called programmatically

### Import Functions (Called from .zef file)

- **`EEG_to_databank()`**: Adds EEG data to Zeffiro Interface databank
  - Called from `.zef` file line 12
  - Creates databank structure for EEG measurements and lead fields

- **`MEG_to_databank()`**: Adds MEG data to Zeffiro Interface databank
  - Called from `.zef` file line 9
  - Creates databank structure for MEG measurements and lead fields

### Configuration Function

- **`Duneuro2Zeffiro_settings()`**: Final configuration step
  - Called from `.zef` file line 19 (after all imports)
  - Configures source modes, processes meshes
  - Must run after data import is complete

## Examples

### Example 1: Complete Import (Recommended)

```matlab
% Full pipeline in one call
results = utilities.duneuro2zef.import_duneuro_project();

if results.success
    fprintf('Import completed successfully!\n');
    fprintf('Processed %d files\n', length(results.processed_files));
else
    fprintf('Import had errors:\n');
    for i = 1:length(results.errors)
        fprintf('  - %s\n', results.errors{i});
    end
end
```

### Example 2: Conversion Only

```matlab
% Simple conversion with default settings
results = utilities.duneuro2zef.run();

% Or use the wrapper function
utilities.duneuro2zef.Duneuro2Zeffiro_convert();
```

### Example 2: Custom File Locations

```matlab
config = utilities.duneuro2zef.get_default_config();
config.input_folder = '/path/to/duneuro/export';
config.output_folder = '/path/to/zeffiro/import';
results = utilities.duneuro2zef.run(config);
```

### Example 3: Different Source Space

```matlab
config = utilities.duneuro2zef.get_default_config();
config.files.source_space = 'sp_vol_rgv_N85540.mat';  % Higher resolution
results = utilities.duneuro2zef.run(config);
```

### Example 4: EEG Only (Skip MEG)

```matlab
config = utilities.duneuro2zef.get_default_config();
config.process_meg = false;
results = utilities.duneuro2zef.run(config);
```

### Example 5: Custom Channel Selection

```matlab
config = utilities.duneuro2zef.get_default_config();
config.eeg.channel_indices = [1:32, 65:96];  % Select specific channels
config.meg.max_channels = 102;  % Use fewer MEG channels
results = utilities.duneuro2zef.run(config);
```

## References

- [Duneuro Documentation](https://www.duneuro.org/)
- [Zeffiro Interface Documentation](https://github.com/sampsapursiainen/zeffiro_interface)
- [FieldTrip Toolbox](https://www.fieldtriptoolbox.org/)

## See Also

- `+utilities/+brainstorm2zef`: Brainstorm to Zeffiro Interface converter
- `+utilities/+fs2zef`: FreeSurfer to Zeffiro Interface converter
- `+utilities/+simnibsToZef`: SimNIBS to Zeffiro Interface converter

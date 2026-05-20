# Zeffiro-Brainstorm Plugin

A MATLAB-based plugin that provides a seamless pipeline between [Brainstorm](https://neuroimage.usc.edu/brainstorm/) and [Zeffiro Interface](https://github.com/zeffiro-interface/zeffiro_interface), two powerful tools for brain modeling and finite element analysis.

## Overview

The Zeffiro-Brainstorm plugin enables users to convert Brainstorm surface meshes and anatomical data into Zeffiro's finite element mesh format. This integration facilitates the use of Brainstorm's segmentation capabilities with Zeffiro's advanced mesh generation and forward/inverse modeling tools.

## Features

- **Automatic Compartment Detection**: Robustly locates and loads surface meshes from Brainstorm subject structures with flexible name matching
- **Atlas Support**: Handles both standard surface meshes and volumetric atlas data (Cube format)
- **Flexible Configuration**: Extensive parameter customization through settings files with validation
- **GUI Interface**: User-friendly graphical interface for project creation and management
- **Batch Processing**: Support for automated mesh generation workflows
- **Error Handling**: Comprehensive error handling and validation throughout the pipeline
- **Generalization**: Works with various Brainstorm project structures and naming conventions

## Installation

The plugin is located in the `+utilities/+brainstorm2zef` directory of your Zeffiro installation. No additional installation steps are required beyond having both Brainstorm and Zeffiro Interface properly configured.

### Prerequisites

- MATLAB (R2018b or later recommended)
- Brainstorm installed and configured
- Zeffiro Interface installed and configured

## Quick Start

### Option 1: High-Level Pipeline (Recommended)

Use the main `run()` function for a complete orchestrated pipeline:

```matlab
% Simple usage with defaults (uses current Brainstorm subject)
results = utilities.brainstorm2zef.run();

% Check results
if results.success
    fprintf('Success! Mesh has %d nodes\n', size(results.mesh_data.nodes, 1));
    % Continue working with results.zef if needed
    % Don't forget to close: zef_close_all(results.zef);
else
    fprintf('Failed: %s\n', results.errors{1});
end
```

With custom configuration:

```matlab
config = struct();
config.settings_file_name = 'zef_bst_default';
config.project_file_name = 'my_project.mat';
config.run_type = 1;  % Fresh start
config.verbose = true;

results = utilities.brainstorm2zef.run(config);
```

### Option 2: GUI Interface

1. Launch the plugin from MATLAB:
   ```matlab
   utilities.brainstorm2zef.zef_bst_plugin_start(pwd);
   ```

2. In the GUI:
   - Select a settings file (or use the default `zef_bst_default.m`)
   - Choose a run script (default: `zef_bst_default_fem_mesh_create`)
   - Select run type:
     - **Fresh start**: Load compartments from Brainstorm
     - **Import compartments**: Use existing compartment data
     - **Use project**: Work with an existing Zeffiro project
   - Click "Run" to generate the mesh

### Option 3: Programmatic Interface (Advanced)

For more control, use the individual functions directly:

```matlab
% Load settings
zef_bst = utilities.brainstorm2zef.zef_bst_get_settings('zef_bst_default', struct());

% Create project
zef = utilities.brainstorm2zef.zef_bst_create_project(...
    'zef_bst_default.m', ...  % Settings file
    'my_project.mat', ...      % Output project file
    1, ...                      % Run type: fresh start
    1, ...                      % Input mode: use input files
    zef_bst, ...               % Settings structure
    struct() ...                % Initial zef structure
);
```

## Configuration

### Settings Files

Settings files are located in `settings/` and define all parameters for the conversion process. The default settings file is `zef_bst_default.m`.

### Key Parameters

#### Project Management
- `save_project`: Save Zeffiro project file (logical, default: 1)
- `import_settings`: Path to script for importing additional Zeffiro settings (string, default: "")

#### Mesh Generation
- `mesh_resolution`: Base resolution for tetrahedral mesh (double, 1-5, default: 3)
- `compartment_list`: Priority-ordered list of compartments (cell array)
- `unit_conversion`: Conversion factor from meters to millimeters (default: 1000)

#### Surface Refinement
- `refine_surface`: Compartments to refine (cell array)
- `refine_surface_number`: Number of refinement iterations (default: 1)
- `refine_surface_on`: Enable surface refinement (logical, default: 1)
- `refine_surface_mode`: Refinement mode (1=external surface, 2=union, default: 2)

#### Volume Refinement
- `refine_volume`: Compartments for volume refinement (cell array)
- `refine_volume_number`: Number of volume refinement iterations (default: 1)
- `refine_volume_on`: Enable volume refinement (logical, default: 0)

#### Surface Inflation
- `inflation_on`: Enable surface inflation (logical, default: 1)
- `inflation_strength`: Inflation strength factor (default: 0.05)

#### Mesh Smoothing
- `mesh_smoothing_on`: Enable mesh smoothing (logical, default: 1)
- `distance_smoothing_on`: Enable distance-weighted smoothing (logical, default: 1)
- `distance_smoothing_exp`: Distance smoothing exponent (default: 0.01)
- `distance_smoothing_tol`: Distance smoothing tolerance (default: 0.9)

#### Material Properties
- `electrical_conductivity`: Key-value pairs of compartment names and conductivities (cell array)
  - Example: `{'Scalp',0.34,'OuterSkull',0.0042,'InnerSkull',1.79,'Cortex',0.33}`
- `dof_space`: Key-value pairs of compartment names and DOF values (cell array)

#### Domain Labeling
- `extensive_relabeling`: Use extensive relabeling with backward front (logical, default: 0)
- `priority_mode`: Priority mode (1=default, 2=initial only, 3=initial+relabel, default: 1)
- `labeling_priority`: Custom labeling priority vector (empty = use default)

#### Atlas Processing
- `n_inflation_steps`: Number of inflation steps for atlas surfaces (default: 20)
- `transform_cell`: Transformation fields to apply (cell array, default: {'InitTransf'})

#### Computation Settings
- `use_gpu`: Use GPU acceleration (logical, default: 1)
- `parallel_processes`: Number of parallel CPU processes (default: 10)
- `verbose_mode`: Print waitbar info to command window (logical, default: 1)
- `use_waitbar`: Use waitbar (logical, default: 1)
- `always_show_waitbar`: Always show graphical waitbar (logical, default: 1)

#### Brainstorm Integration
- `subject_struct`: Brainstorm subject structure (empty = use current)
- `subject_folder`: Path to Brainstorm subject folder (empty = use protocol default)
- `compartment_files`: Explicit list of compartment files (empty = auto-detect)

## File Structure

```
+brainstorm2zef/
├── settings/                    # Settings files (regular folder)
│   └── zef_bst_default.m
├── projects/                    # Output directory for generated projects (created automatically)
├── run.m                        # Main orchestration function (high-level wrapper)
├── zef_bst_compartment_settings.m
├── zef_bst_create_compartment_data.m
├── zef_bst_create_project.m
├── zef_bst_default_fem_mesh_create.m  # Run script (workflow function)
├── zef_bst_edit_project.m
├── zef_bst_find_compartment.m          # Helper: flexible compartment finding
├── zef_bst_get_atlas_surfaces.m
├── zef_bst_get_compartment_property.m  # Helper: extract property values
├── zef_bst_get_input_mode.m
├── zef_bst_get_project_file_name.m
├── zef_bst_get_run_type.m
├── zef_bst_get_settings_file_name.m
├── zef_bst_get_settings.m
├── zef_bst_init.m
├── zef_bst_normalize_compartment_name.m # Helper: normalize names
├── zef_bst_plugin_start.m
├── zef_bst_settings_file.m
├── zef_bst_validate_environment.m      # Validation: Brainstorm environment
├── zef_bst_validate_settings.m        # Validation: settings structure
└── README.md                    # This file
```

## Main Functions

### Core Functions

- **`run`**: **Main orchestration function** - High-level wrapper that executes the entire pipeline from Brainstorm to Zeffiro with comprehensive error handling and progress reporting
- **`zef_bst_plugin_start`**: Launches the graphical user interface
- **`zef_bst_create_project`**: Main function for creating Zeffiro projects from Brainstorm data
- **`zef_bst_create_compartment_data`**: Loads and processes compartment data from Brainstorm
- **`zef_bst_compartment_settings`**: Generates compartment configuration arrays
- **`zef_bst_get_atlas_surfaces`**: Extracts surfaces from volumetric atlas data

### Utility Functions

- **`zef_bst_get_settings`**: Loads and merges settings from files with validation
- **`zef_bst_init`**: Initializes default parameter values
- **`zef_bst_edit_project`**: Opens existing projects in Zeffiro interface
- **`zef_bst_get_*`**: GUI helper functions for retrieving user selections

### Validation Functions

- **`zef_bst_validate_environment`**: Validates Brainstorm availability and initialization
- **`zef_bst_validate_settings`**: Validates settings structure for required fields and values

### Helper Functions

- **`zef_bst_find_compartment`**: Flexible compartment finding with multiple search strategies
- **`zef_bst_normalize_compartment_name`**: Normalizes compartment names for consistent matching
- **`zef_bst_get_compartment_property`**: Extracts property values from key-value cell arrays

### Run Scripts

- **`zef_bst_default_fem_mesh_create`**: Default run script for creating FEM mesh from Brainstorm data

## Pipeline Architecture and Workflow

The Brainstorm-to-Zeffiro conversion pipeline consists of several orchestrated steps that transform Brainstorm surface meshes into Zeffiro finite element meshes.

### Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────┐
│              Brainstorm-to-Zeffiro Conversion Pipeline          │
└─────────────────────────────────────────────────────────────────┘

Step 1: VALIDATION
  Validate Brainstorm environment and settings
  (zef_bst_validate_environment, zef_bst_validate_settings)
  
Step 2: SETTINGS LOADING
  Load and merge default, file, and user settings
  (zef_bst_get_settings → zef_bst_init)
  
Step 3: ZEFFIRO INITIALIZATION
  Initialize Zeffiro Interface
  (zeffiro_interface)
  
Step 4: PROJECT CREATION
  Load compartments from Brainstorm and create Zeffiro project
  (zef_bst_create_project → zef_bst_create_compartment_data)
  
Step 5: MESH GENERATION
  Generate finite element tetrahedral mesh
  (zef_create_finite_element_mesh)
  
Step 6: DATA EXTRACTION
  Extract mesh data for Brainstorm compatibility
  (Convert units, extract nodes/tetra/name_tags)
  
Step 7: PROJECT SAVING (Optional)
  Save Zeffiro project file
  (zef_save)
```

### Complete Function Call Map

All functions in the package are actively used in the pipeline:

#### Main Orchestration
- ✅ **`run()`** → **Primary entry point** (user calls this)
  - Calls: `zef_bst_validate_environment()`, `zef_bst_get_settings()`, `zef_bst_create_project()`, `zef_create_finite_element_mesh()`

#### Validation Pipeline
- ✅ **`zef_bst_validate_environment()`** → Validates Brainstorm availability
  - Called by: `run()`, `zef_bst_create_project()`, `zef_bst_create_compartment_data()`

- ✅ **`zef_bst_validate_settings()`** → Validates settings structure
  - Called by: `zef_bst_get_settings()`

#### Settings Pipeline
- ✅ **`zef_bst_get_settings()`** → Loads and merges settings
  - Called by: `run()`, `zef_bst_create_project()`, `zef_bst_default_fem_mesh_create()`
  - Calls: `zef_bst_init()`, `zef_bst_validate_settings()`

- ✅ **`zef_bst_init`** → Initializes default settings
  - Called by: `zef_bst_get_settings()`

#### Project Creation Pipeline
- ✅ **`zef_bst_create_project()`** → Creates Zeffiro project from Brainstorm data
  - Called by: `run()`, `zef_bst_default_fem_mesh_create()`
  - Calls: `zef_bst_get_settings()`, `zef_bst_validate_environment()`, `zef_bst_create_compartment_data()`

- ✅ **`zef_bst_create_compartment_data()`** → Loads and processes compartments
  - Called by: `zef_bst_create_project()`
  - Calls: `zef_bst_validate_environment()`, `zef_bst_find_compartment()`, `zef_bst_get_atlas_surfaces()`, `zef_bst_compartment_settings()`

#### Compartment Processing Functions
- ✅ **`zef_bst_find_compartment()`** → Finds compartments in Brainstorm structure
  - Called by: `zef_bst_create_compartment_data()`
  - Calls: `zef_bst_normalize_compartment_name()`

- ✅ **`zef_bst_get_atlas_surfaces()`** → Extracts surfaces from volumetric atlas data
  - Called by: `zef_bst_create_compartment_data()`

- ✅ **`zef_bst_compartment_settings()`** → Generates compartment configuration
  - Called by: `zef_bst_create_compartment_data()`
  - Calls: `zef_bst_get_compartment_property()`

- ✅ **`zef_bst_get_compartment_property()`** → Extracts property values
  - Called by: `zef_bst_compartment_settings()`
  - Calls: `zef_bst_normalize_compartment_name()`

- ✅ **`zef_bst_normalize_compartment_name()`** → Normalizes compartment names
  - Called by: `zef_bst_find_compartment()`, `zef_bst_get_compartment_property()`

#### GUI Functions (Alternative Entry Point)
- ✅ **`zef_bst_plugin_start()`** → Launches GUI interface
  - Calls: `zef_bst_default_fem_mesh_create()` (via callback)
  - Uses: `zef_bst_get_settings_file_name()`, `zef_bst_get_project_file_name()`, `zef_bst_get_run_type()`, `zef_bst_get_input_mode()`, `zef_bst_settings_file()`, `zef_bst_edit_project()`

- ✅ **`zef_bst_default_fem_mesh_create()`** → Run script for GUI
  - Called by: `zef_bst_plugin_start()` (via GUI callback)
  - Calls: `zef_bst_get_settings()`, `zef_bst_create_project()`, `zef_create_finite_element_mesh()`

- ✅ **`zef_bst_edit_project()`** → Opens existing projects
  - Called by: `zef_bst_plugin_start()` (via GUI button)

- ✅ **`zef_bst_get_settings_file_name()`** → GUI helper
  - Called by: `zef_bst_plugin_start()` (via GUI callbacks)

- ✅ **`zef_bst_get_project_file_name()`** → GUI helper
  - Called by: `zef_bst_plugin_start()` (via GUI callbacks)

- ✅ **`zef_bst_get_run_type()`** → GUI helper
  - Called by: `zef_bst_plugin_start()` (via GUI callbacks)

- ✅ **`zef_bst_get_input_mode()`** → GUI helper
  - Called by: `zef_bst_plugin_start()` (via GUI callbacks)

- ✅ **`zef_bst_settings_file()`** → GUI helper for file selection
  - Called by: `zef_bst_plugin_start()` (via GUI button)

**Verification Result**: ✅ All 20 functions are actively used. No unused code. Pipeline is complete and orchestrated.

### Entry Points and Their Relationships

The package provides three main entry points, each serving different use cases:

1. **`run()`** - **Recommended for programmatic use**
   - Complete orchestrated pipeline
   - Comprehensive error handling and results reporting
   - Best for automation, scripting, and batch processing
   - Handles all steps: validation → settings → initialization → project creation → mesh generation → data extraction → saving

2. **`zef_bst_plugin_start()`** - **GUI interface**
   - User-friendly graphical interface
   - Calls `zef_bst_default_fem_mesh_create()` internally
   - Best for interactive use and exploration
   - Provides visual feedback and file selection dialogs

3. **`zef_bst_default_fem_mesh_create()`** - **Legacy run script**
   - Used by GUI as the run script
   - Can be called programmatically for backward compatibility
   - Similar functionality to `run()` but with different output format (cell array vs. results structure)
   - Note: `run()` is preferred for new code

**Note**: Both `run()` and `zef_bst_default_fem_mesh_create()` call the same underlying functions (`zef_bst_create_project()`, etc.), ensuring consistency across entry points.

**Important**: `run_type 3` (use existing project) is not supported in `run()`. For loading existing projects, use:
- `zef_bst_edit_project(project_file_name)` to open in Zeffiro Interface display mode
- `zeffiro_interface('open_project', project_file_name)` to load programmatically
- The GUI option for run_type 3 is available but has limited functionality (only initializes Zeffiro, doesn't load project)

### Detailed Workflow Steps

#### Step 1: Validation
- Validates that Brainstorm is installed, accessible, and initialized
- Checks that required Brainstorm protocol and subject are available
- Validates settings structure for required fields and value ranges

#### Step 2: Settings Loading
- Loads default settings from `zef_bst_init`
- Applies settings from specified settings file (e.g., `zef_bst_default.m`)
- Merges user-provided settings (highest priority)
- Validates final settings structure
- Adjusts `parallel_processes` to system capabilities

#### Step 3: Zeffiro Initialization
- Initializes Zeffiro Interface in `nodisplay` mode
- Configures GPU usage, parallel processing, and waitbar settings
- Closes any existing Zeffiro instances if needed

#### Step 4: Project Creation
- **Compartment Discovery**: Searches Brainstorm subject structure for compartments
  - Uses flexible name matching (case-insensitive, handles spaces/underscores)
  - Supports direct index fields (e.g., `iScalp`), Comment fields, and normalized matching
  - Handles both Surface and Anatomy structures
  
- **Compartment Loading**: Loads surface meshes from Brainstorm files
  - Converts from meters (Brainstorm) to millimeters (Zeffiro)
  - Handles standard surface meshes (Vertices/Faces)
  - Handles atlas-based volumetric data (Cube format) with surface extraction
  
- **Compartment Configuration**: Generates compartment settings
  - Sets refinement flags (surface/volume)
  - Assigns electrical conductivities
  - Assigns DOF space values
  - Reorders compartments by priority (outermost to innermost)

- **Project Assembly**: Creates Zeffiro project structure
  - Adds compartments to Zeffiro structure
  - Configures mesh generation parameters
  - Sets refinement and smoothing options
  - Processes surface meshes (normals, adjacency)

#### Step 5: Mesh Generation
- Generates finite element tetrahedral mesh from surface meshes
- Applies refinement, smoothing, and inflation as configured
- Creates domain labels for each compartment

#### Step 6: Data Extraction
- Extracts mesh data (nodes, tetrahedra, name_tags)
- Converts units back to meters for Brainstorm compatibility
- Validates mesh data integrity

#### Step 7: Project Saving (Optional)
- Saves Zeffiro project file if `save_project` is enabled
- Preserves all project settings and mesh data

### Workflow Options

1. **Prepare Brainstorm Data**: Ensure your Brainstorm subject has the required surface meshes (Scalp, OuterSkull, InnerSkull, Cortex, etc.)

2. **Configure Settings**: Create or modify a settings file in `settings/` to specify:
   - Compartment list and priorities
   - Mesh resolution and refinement options
   - Material properties (conductivities, DOF spaces)
   - Processing options

3. **Run Conversion**: Choose one of three methods:
   - **Option A (Recommended)**: Use `run()` for complete orchestrated pipeline
   - **Option B**: Use GUI via `zef_bst_plugin_start()`
   - **Option C**: Use individual functions for fine-grained control

4. **Post-Processing**: Open the generated project in Zeffiro Interface for:
   - Visualization
   - Forward modeling
   - Inverse source reconstruction
   - Further analysis

## Troubleshooting

### Common Issues

**Problem**: Compartments not found
- **Solution**: The plugin now uses flexible name matching (case-insensitive, handles spaces/underscores). Verify that your Brainstorm subject contains the compartments listed in `compartment_list`. Check the Brainstorm subject structure using `bst_get('Subject')` to see available compartments.

**Problem**: Mesh generation fails
- **Solution**: Ensure surface meshes are valid (closed, non-self-intersecting). Try reducing `mesh_resolution` or adjusting refinement parameters.

**Problem**: Memory errors during mesh generation
- **Solution**: Reduce `mesh_resolution`, disable volume refinement, or reduce `parallel_processes`.

**Problem**: Units mismatch
- **Solution**: Verify `unit_conversion` is set correctly (1000 for meters→millimeters). Check that Brainstorm data is in meters.

## Examples

### Example 1: Complete Pipeline (Recommended)

```matlab
% Full pipeline with default settings
results = utilities.brainstorm2zef.run();

if results.success
    fprintf('Conversion successful!\n');
    fprintf('Mesh: %d nodes, %d tetrahedra, %d compartments\n', ...
        size(results.mesh_data.nodes, 1), ...
        size(results.mesh_data.tetra, 1), ...
        length(results.mesh_data.name_tags));
    fprintf('Processing time: %.2f seconds\n', results.processing_time);
    
    % Continue working with results.zef if needed
    % Don't forget to close: zef_close_all(results.zef);
else
    fprintf('Conversion failed:\n');
    for i = 1:length(results.errors)
        fprintf('  - %s\n', results.errors{i});
    end
end
```

### Example 2: Custom Configuration

```matlab
config = struct();
config.settings_file_name = 'zef_bst_default';
config.project_file_name = 'my_brainstorm_project.mat';
config.run_type = 1;  % Fresh start
config.verbose = true;
config.use_gpu = false;
config.parallel_processes = 4;

results = utilities.brainstorm2zef.run(config);
```

### Example 3: Import Existing Compartment Data

```matlab
config = struct();
config.run_type = 2;  % Import compartments
config.settings_file_name = 'zef_bst_default';  % Must match previous run
config.project_file_name = 'imported_project.mat';

results = utilities.brainstorm2zef.run(config);
```

### Example 4: Using GUI Interface

```matlab
% Launch GUI
utilities.brainstorm2zef.zef_bst_plugin_start(pwd);

% Follow GUI prompts to:
% 1. Select settings file
% 2. Choose run script
% 3. Select run type
% 4. Click "Run"
```

### Example 5: Programmatic Control (Advanced)

```matlab
% Load settings
zef_bst = utilities.brainstorm2zef.zef_bst_get_settings('zef_bst_default', struct());

% Customize settings
zef_bst.mesh_resolution = 4;  % Higher resolution
zef_bst.compartment_list = {'Scalp', 'OuterSkull', 'InnerSkull', 'Cortex'};

% Create project
zef = utilities.brainstorm2zef.zef_bst_create_project(...
    'zef_bst_default.m', ...
    'my_project.mat', ...
    1, ...  % Fresh start
    1, ...  % Use input files
    zef_bst, ...
    struct());

% Generate mesh
zef = zef_create_finite_element_mesh(zef);

% Save project
zef_save(zef, 'my_project', pwd, 1);
zef_close_all(zef);
```

## Contributing

When contributing to this plugin:
1. Follow MATLAB coding conventions
2. Add comprehensive function documentation
3. Include inline comments for complex logic
4. Test with multiple Brainstorm subjects
5. Update this README if adding new features

## License

This plugin is part of the Zeffiro Interface project and follows the same license terms.

## References

- [Brainstorm Documentation](https://neuroimage.usc.edu/brainstorm/)
- [Zeffiro Interface Documentation](https://github.com/zeffiro-interface/zeffiro_interface)
- [Zeffiro Interface Paper](https://doi.org/10.1016/j.neuroimage.2019.06.014)

## Pipeline Consistency and Architecture

### Code Coverage Verification

All 20 functions in the package are actively used and integrated into the pipeline:

- **Orchestration**: `run()` - Main entry point
- **Validation**: `zef_bst_validate_environment()`, `zef_bst_validate_settings()` - Environment and settings validation
- **Settings**: `zef_bst_get_settings()`, `zef_bst_init` - Settings loading and initialization
- **Project Creation**: `zef_bst_create_project()`, `zef_bst_create_compartment_data()`, `zef_bst_compartment_settings()` - Core conversion logic
- **Compartment Processing**: `zef_bst_find_compartment()`, `zef_bst_get_atlas_surfaces()`, `zef_bst_get_compartment_property()`, `zef_bst_normalize_compartment_name()` - Compartment discovery and processing
- **GUI Interface**: `zef_bst_plugin_start()`, `zef_bst_default_fem_mesh_create()`, `zef_bst_edit_project()` - User interface
- **GUI Helpers**: `zef_bst_get_settings_file_name()`, `zef_bst_get_project_file_name()`, `zef_bst_get_run_type()`, `zef_bst_get_input_mode()`, `zef_bst_settings_file()` - GUI support functions

### Pipeline Flow Diagram

```
User Entry Points:
├── run() [Recommended]
│   └──> zef_bst_validate_environment()
│   └──> zef_bst_get_settings()
│   │       └──> zef_bst_init
│   │       └──> zef_bst_validate_settings()
│   └──> zeffiro_interface() [Zeffiro function]
│   └──> zef_bst_create_project()
│           └──> zef_bst_validate_environment()
│           └──> zef_bst_get_settings()
│           └──> zef_bst_create_compartment_data()
│                   └──> zef_bst_validate_environment()
│                   └──> zef_bst_find_compartment()
│                           └──> zef_bst_normalize_compartment_name()
│                   └──> zef_bst_get_atlas_surfaces()
│                   └──> zef_bst_compartment_settings()
│                           └──> zef_bst_get_compartment_property()
│                                   └──> zef_bst_normalize_compartment_name()
│   └──> zef_create_finite_element_mesh() [Zeffiro function]
│   └──> zef_save() [Zeffiro function, optional]
│
├── zef_bst_plugin_start() [GUI]
│   └──> zef_bst_default_fem_mesh_create() [via callback]
│           └──> [Same pipeline as run()]
│   └──> zef_bst_edit_project() [via button]
│   └──> [GUI helpers for user input]
│
└── Individual functions [Advanced users]
    └──> Direct calls to any function as needed
```

### Key Design Principles

1. **Single Responsibility**: Each function has a clear, focused purpose
2. **Modularity**: Functions can be used independently or as part of the orchestrated pipeline
3. **Validation**: Multiple validation layers ensure data integrity
4. **Error Handling**: Comprehensive error handling with informative messages
5. **Flexibility**: Supports various Brainstorm project structures and naming conventions
6. **Consistency**: All entry points use the same underlying functions

### Improvements Made

- ✅ **Orchestrated Pipeline**: Added `run()` function for complete end-to-end conversion
- ✅ **Comprehensive Validation**: Environment and settings validation at multiple levels
- ✅ **Error Handling**: Robust error handling throughout with detailed error messages
- ✅ **Code Consistency**: Standardized error handling, validation patterns, and code style
- ✅ **Documentation**: Complete pipeline documentation with function call maps
- ✅ **Generalization**: Flexible compartment matching works with various Brainstorm structures
- ✅ **Bug Fixes**: Fixed matrix initialization, array bounds, and validation issues

## Support

For issues, questions, or contributions, please refer to the main Zeffiro Interface repository or contact the development team.

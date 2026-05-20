%ZEF_BST_INIT Initializes default settings for Zeffiro-Brainstorm plugin.
%
% This script sets up default parameter values for the Brainstorm-to-Zeffiro
% conversion pipeline. These defaults are used unless overridden by settings
% files or user-provided parameters.
%
% See also: ZEF_BST_GET_SETTINGS

% Brainstorm subject configuration
zef_bst.subject_struct = struct;      % Brainstorm subject structure (empty = use current)
zef_bst.subject_folder = "";         % Path to Brainstorm subject folder (empty = use protocol default)

% Project saving
zef_bst.save_project = 1;            % Save Zeffiro project file (1) or not (0)
zef_bst.import_settings = "";        % Path to script for importing additional Zeffiro settings

% User interface
zef_bst.verbose_mode = 1;             % Print waitbar info to command window (1) or not (0)
zef_bst.use_waitbar = 1;             % Use waitbar (1) or not (0)
zef_bst.always_show_waitbar = 1;     % Always show graphical waitbar (1) or not (0)

% Surface mesh configuration
zef_bst.surface_names = cell(0);     % Custom names for surfaces (empty = use defaults)
zef_bst.surface_mesh_density = 0.5;  % Relative density of surface meshes (0-1)
zef_bst.compartment_files = cell(0); % Explicit list of compartment files (empty = auto-detect)

% Mesh generation parameters
zef_bst.mesh_resolution = 3;         % Base resolution for tetrahedral mesh (1-5, higher = finer)
zef_bst.compartment_list = {'Scalp','OuterSkull','InnerSkull','Cortex','Other','white','subcortical'};

% Surface refinement
zef_bst.refine_surface = {'Scalp','OuterSkull','InnerSkull','Cortex','Other','subcortical'};
zef_bst.refine_surface_number = 1;   % Number of surface refinement iterations
zef_bst.refine_surface_on = 1;       % Enable surface refinement (1) or not (0)
zef_bst.refine_surface_mode = 2;     % Refinement mode: 1=external surface, 2=union of surfaces

% Volume refinement
zef_bst.refine_volume = cell(0);     % Compartments for volume refinement
zef_bst.refine_volume_number = 1;    % Number of volume refinement iterations
zef_bst.refine_volume_on = 0;        % Enable volume refinement (1) or not (0)

% Surface inflation
zef_bst.inflation_on = 1;            % Enable surface inflation (1) or not (0)
zef_bst.inflation_strength = 0.05;    % Inflation strength factor

% Mesh smoothing
zef_bst.mesh_smoothing_on = 1;       % Enable mesh smoothing (1) or not (0)
zef_bst.distance_smoothing_on = 1;   % Enable distance-weighted smoothing (1) or not (0)
zef_bst.distance_smoothing_exp = 0.01; % Distance smoothing exponent
zef_bst.distance_smoothing_tol = 0.9;  % Distance smoothing tolerance

% Domain labeling
zef_bst.extensive_relabeling = 0;     % Use extensive relabeling with backward front (1) or not (0)
zef_bst.priority_mode = 1;            % Priority mode: 1=default, 2=initial only, 3=initial+relabel
zef_bst.labeling_priority = [];      % Custom labeling priority vector (empty = use default)

% Material properties (key-value pairs: compartment name, conductivity value)
zef_bst.electrical_conductivity = {'Scalp',0.34,'OuterSkull',0.0042,'InnerSkull',1.79,'Cortex',0.33,'white',0.14,'subcortical',0.33};

% Degree-of-freedom space (key-value pairs: compartment name, DOF value)
zef_bst.dof_space = {'Scalp',0,'OuterSkull',0,'InnerSkull',0,'Cortex',2,'white',3,'subcortical',1};

% Atlas processing
zef_bst.n_inflation_steps = 20;      % Number of inflation steps for atlas surfaces
zef_bst.transform_cell = {'InitTransf'}; % Transformation fields to apply

% Unit conversion
zef_bst.unit_conversion = 1000;      % Conversion factor: meters (Brainstorm) to millimeters (Zeffiro)

% Computation settings
zef_bst.use_gpu = 1;                 % Use GPU acceleration (1) or not (0)
zef_bst.parallel_processes = 10;     % Number of parallel CPU processes

% Compartment activation
zef_bst.compartment_on_vec = [];     % Vector specifying which compartments are active (empty = all)
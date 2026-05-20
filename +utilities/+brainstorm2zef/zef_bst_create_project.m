function zef = zef_bst_create_project(settings_file_name, project_file_name, run_type, input_mode, zef_bst, zef)
%ZEF_BST_CREATE_PROJECT Creates a Zeffiro project from Brainstorm data.
%
% This is the main function that orchestrates the conversion of Brainstorm
% surface meshes into a Zeffiro finite element mesh project. It handles
% compartment loading, mesh generation, and project saving.
%
% Inputs:
%   settings_file_name - Path to settings file containing configuration
%   project_file_name  - Path where project should be saved (empty = don't save)
%   run_type           - Execution mode:
%                        1 = Fresh start (load compartments from Brainstorm)
%                        2 = Import compartments (use existing compartment data)
%                        3 = Use existing project
%   input_mode         - Input handling mode:
%                        1 = Use input files
%                        2 = Ignore input files
%   zef_bst            - Structure containing Brainstorm-to-Zeffiro configuration
%   zef                 - Zeffiro project structure (optional)
%
% Outputs:
%   zef - Zeffiro project structure with loaded compartments and mesh settings
%
% See also: ZEF_BST_CREATE_COMPARTMENT_DATA, ZEF_BST_GET_SETTINGS

% Set default values for optional inputs
if nargin < 6
    zef = struct;
end

if nargin < 5
    zef_bst = struct;
end

if nargin < 4
    input_mode = 1;
end

if nargin < 3
    run_type = 1;
end

if nargin < 2
    project_file_name = '';
end

% Load and validate settings
try
    zef_bst = utilities.brainstorm2zef.zef_bst_get_settings(settings_file_name, zef_bst);
catch ME
    error('Failed to load settings: %s', ME.message);
end

% Validate Brainstorm environment
[is_valid, error_msg] = utilities.brainstorm2zef.zef_bst_validate_environment();
if ~is_valid
    error('Brainstorm environment validation failed: %s', error_msg);
end

% Initialize Zeffiro Interface (only if not already initialized)
if isempty(fieldnames(zef))
    try
        % Check if zef exists in base workspace and close it if needed
        if evalin("base","exist('zef', 'var');")
            zeffiro_path = fileparts(which('zeffiro_interface'));
            if ~isempty(zeffiro_path)
                run([zeffiro_path filesep 'src' filesep 'core' filesep 'zef_close_all.m']);
            end
        end
        
        zef = zeffiro_interface('start_mode','nodisplay','verbose_mode',zef_bst.verbose_mode,...
            'use_gpu',zef_bst.use_gpu,'parallel_processes',zef_bst.parallel_processes,...
            'always_show_waitbar',zef_bst.always_show_waitbar);
    catch ME
        error('Failed to initialize Zeffiro Interface: %s', ME.message);
    end
end

zef = zef_add_bounding_box(zef);
zef = zef_build_compartment_table(zef);

h_waitbar = zef_waitbar(0, 'Creating project.');

% Handle input mode: if ignoring input files, clear compartment_files
if isequal(input_mode,2)
    zef_bst.compartment_files = cell(0);
end

% Handle different run types
[aux_path, aux_file] = fileparts(settings_file_name);
if isempty(aux_path)
    % If no path provided, use current directory
    aux_path = pwd;
end

if isequal(run_type, 1)
    % Fresh start: load compartments from Brainstorm
    try
        [compartment_settings, surface_meshes, zef] = utilities.brainstorm2zef.zef_bst_create_compartment_data(settings_file_name, zef_bst, zef);
        
        % Save intermediate data for future use
        if ~isempty(aux_file)
            try
                writecell(compartment_settings, fullfile(aux_path, [aux_file '_compartment_settings.dat']));
                save(fullfile(aux_path, [aux_file '_surface_meshes.mat']), 'surface_meshes', '-v7.3');
            catch ME
                warning('Failed to save intermediate data: %s', ME.message);
            end
        end
    catch ME
        error('Failed to create compartment data: %s', ME.message);
    end
elseif isequal(run_type, 2)
    % Import compartments: use existing compartment data
    if isempty(aux_file)
        error('Settings file name required for importing compartment data');
    end
    try
        compartment_settings = readcell(fullfile(aux_path, [aux_file '_compartment_settings.dat']));
        load(fullfile(aux_path, [aux_file '_surface_meshes.mat']), 'surface_meshes');
    catch ME
        error('Failed to load compartment data from %s: %s', aux_path, ME.message);
    end
elseif isequal(run_type, 3)
    % Use existing project: this mode is not supported in zef_bst_create_project
    % For loading existing projects, use zef_bst_edit_project() or zeffiro_interface('open_project', ...)
    error('Run type 3 (use existing project) is not supported in zef_bst_create_project(). Use zef_bst_edit_project() or zeffiro_interface(''open_project'', project_file_name) instead.');
else
    error('Invalid run_type: %d. Must be 1 (fresh start) or 2 (import). For existing projects, use zef_bst_edit_project()', run_type);
end

n_surface_meshes = size(compartment_settings,1);
ind_vec_aux = zeros(n_surface_meshes,1);
for i = 1 : n_surface_meshes
    if size(surface_meshes(i).Points,1) >= 4
        ind_vec_aux(i) = 1;
    end
end
ind_vec_aux = find(ind_vec_aux);
surface_meshes = surface_meshes(ind_vec_aux);
compartment_settings = compartment_settings(ind_vec_aux,:);

n_surface_meshes = size(compartment_settings,1);

ref_vec_vol = flipud(cell2mat(compartment_settings(:,8)));
ref_vec_surf = flipud(cell2mat(compartment_settings(:,6)));

ind_vec_aux = zeros(n_surface_meshes,1);
h_waitbar = zef_waitbar(0, 'Creating project.');
for i = 1 : n_surface_meshes
    zef_waitbar(i/n_surface_meshes,h_waitbar,'Creating project.');
    surface_names_aux = {surface_meshes.Name};
    i_aux = find(ismember(surface_names_aux, compartment_settings{i,2}), 1);
    if ~isempty(i_aux)
        ind_vec_aux(i) = 1;
        zef = zef_add_compartment(zef);
        
        % Validate compartment tag exists
        if isempty(zef.compartment_tags) || length(zef.compartment_tags) < 1
            error('Failed to create compartment tag');
        end
        
        comp_tag = zef.compartment_tags{1};
        zef.([comp_tag '_name']) = [compartment_settings{i,4} ' : ' compartment_settings{i,2}];
        zef.([comp_tag '_points']) = surface_meshes(i_aux).Points;
        zef.([comp_tag '_triangles']) = surface_meshes(i_aux).Triangles(:,[1 3 2]);
        zef.([comp_tag '_submesh_ind']) = size(surface_meshes(i_aux).Triangles,1);
        zef.([comp_tag '_sigma']) = compartment_settings{i,10};
        zef.([comp_tag '_activity']) = compartment_settings{i,12};
        if ~isempty(surface_meshes(i_aux).Color)
            zef.([comp_tag '_color']) = surface_meshes(i_aux).Color;
        end
        zef = zef_build_compartment_table(zef);
    else
        warning('Surface mesh not found for compartment %s (row %d)', compartment_settings{i,2}, i);
    end
end

% Handle compartment activation vector
if isempty(zef_bst.compartment_on_vec) || length(zef_bst.compartment_on_vec) ~= n_surface_meshes
    % If not specified or wrong length, activate all compartments
    I_on = 1:n_surface_meshes;
else
I_on = find(zef_bst.compartment_on_vec);
    if isempty(I_on)
        warning('No compartments are active according to compartment_on_vec. Activating all compartments.');
        I_on = 1:n_surface_meshes;
    end
end

% Filter indices to only active compartments
ind_vec_aux = find(ind_vec_aux(I_on));
if isempty(ind_vec_aux)
    error('No valid compartments found after filtering by compartment_on_vec');
end

% Get refinement vectors for active compartments only
ref_vec_vol = find(ref_vec_vol(ind_vec_aux));
ref_vec_surf = find(ref_vec_surf(ind_vec_aux));

zef.refinement_on = 1;
zef.mesh_smoothing_on = zef_bst.mesh_smoothing_on;
zef.distance_smoothing_on = zef_bst.distance_smoothing_on;
zef.distance_smoothing_exp = zef_bst.distance_smoothing_exp;
zef.smoothing_steps_dist = zef_bst.distance_smoothing_tol;
zef.refinement_surface_on = zef_bst.refine_surface_on;
zef.refinement_volume_on = zef_bst.refine_volume_on;
zef.refinement_surface_number = zef_bst.refine_surface_number;
zef.refinement_volume_number = zef_bst.refine_volume_number;
zef.refinement_surface_mode = zef_bst.refine_surface_mode;
zef.refinement_surface_compartments = ref_vec_surf;
zef.refinement_volume_compartments = ref_vec_vol;
zef.mesh_resolution = zef_bst.mesh_resolution;
zef.use_fem_mesh_inflation = zef_bst.inflation_on;
zef.fem_mesh_inflation_strength = zef_bst.inflation_strength;

%if zef.([zef.temp_var_0 '_on'])
zef.max_surface_face_count = zef_bst.surface_mesh_density;
zef.priority_mode = zef_bst.priority_mode;
zef.extensive_relabeling = zef_bst.extensive_relabeling;

% Run import settings script if provided
if isfield(zef_bst, 'import_settings') && ~isempty(zef_bst.import_settings) && ...
   ischar(zef_bst.import_settings) && ~isequal(zef_bst.import_settings, "")
    try
        if exist(zef_bst.import_settings, 'file')
run(zef_bst.import_settings);
        else
            warning('Import settings file not found: %s', zef_bst.import_settings);
        end
    catch ME
        warning('Error running import settings script %s: %s', zef_bst.import_settings, ME.message);
    end
end

% Handle compartment activation vector
if isempty(zef_bst.compartment_on_vec) || length(zef_bst.compartment_on_vec) ~= n_surface_meshes
    % If not specified or wrong length, activate all compartments
    compartment_on_vec = [ones(1, n_surface_meshes) 1];  % All compartments + bounding box
else
    compartment_on_vec = [zef_bst.compartment_on_vec 1];  % User-specified + bounding box
end
zef = zef_turn_compartment_onoff(zef, compartment_on_vec);
zef = zef_process_meshes(zef);

if ~isempty(zef_bst.labeling_priority)
    try
        zef = zef_update_labeling_priority(zef, [], zef_bst.labeling_priority);
    catch ME
        warning('Failed to update labeling priority: %s', ME.message);
    end
end

if ~isempty(project_file_name) && ischar(project_file_name) && ~isequal(project_file_name, "")
    [file_path, file_name] = fileparts(project_file_name);
    if isempty(file_path)
        file_path = pwd;
    end
    zef.save_file = [file_name '.mat'];
    zef.save_file_path = file_path;
    try
        zef_save(zef, zef.save_file, zef.save_file_path, 1);
    catch ME
        error('Failed to save project file: %s', ME.message);
    end
    zef_close_all(zef);
end

end

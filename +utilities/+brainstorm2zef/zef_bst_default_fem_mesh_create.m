function out_cell = zef_bst_default_fem_mesh_create(run_type, input_mode, settings_file_name, project_file_name, zef_bst)
%ZEF_BST_DEFAULT_FEM_MESH_CREATE Default run script for creating FEM mesh from Brainstorm data.
%
% This is the default run script that creates a finite element mesh from
% Brainstorm surface meshes. It handles project creation, mesh generation,
% and optionally saves the project file.
%
% Inputs:
%   run_type          - Execution mode:
%                       1 = Fresh start (load compartments from Brainstorm)
%                       2 = Import compartments (use existing compartment data)
%                       3 = Use existing project
%                       0 = Return empty outputs (cancelled)
%   input_mode        - Input handling mode:
%                       1 = Use input files
%                       2 = Ignore input files
%   settings_file_name - Path to settings file
%   project_file_name  - Path where project should be saved
%   zef_bst           - Structure containing Brainstorm-to-Zeffiro configuration
%
% Outputs:
%   out_cell - Cell array containing:
%             {1} - Node coordinates (converted back to meters)
%             {2} - Tetrahedra with domain labels [tetra domain_labels]
%             {3} - Compartment name tags
%
% See also: ZEF_BST_CREATE_PROJECT, ZEF_CREATE_FINITE_ELEMENT_MESH

if nargin < 4
    zef_bst = struct;
end

% Handle cancellation case
if isequal(run_type,0)
    out_cell = cell(0);
    out_cell{1} = [];
    out_cell{2} = [];
    out_cell{3} = [];
    return;
end

% Load settings with validation
try
    zef_bst = utilities.brainstorm2zef.zef_bst_get_settings(settings_file_name, zef_bst);
catch ME
    error('Failed to load settings: %s', ME.message);
end

% Initialize Zeffiro and create/load project based on run type
try
    if ismember(run_type, [1 2])
    % Fresh start or import compartments: create new project
        zef = zeffiro_interface('start_mode','nodisplay','verbose_mode',zef_bst.verbose_mode,...
            'use_gpu',zef_bst.use_gpu,'parallel_processes',zef_bst.parallel_processes,...
            'always_show_waitbar',zef_bst.always_show_waitbar);
        zef = utilities.brainstorm2zef.zef_bst_create_project(settings_file_name, [], run_type, input_mode, zef_bst, zef);
    elseif isequal(run_type, 3)
    % Use existing project: just initialize Zeffiro
    % Note: Project loading is not handled here. User should load project separately
    % or use zef_bst_edit_project() for GUI-based project editing
        zef = zeffiro_interface('start_mode','nodisplay','verbose_mode',zef_bst.verbose_mode,...
            'use_gpu',zef_bst.use_gpu,'parallel_processes',zef_bst.parallel_processes,...
            'always_show_waitbar',zef_bst.always_show_waitbar);
        warning('Run type 3: Zeffiro initialized but project not loaded. Use zef_bst_edit_project() or zeffiro_interface(''open_project'', ...) to load project.');
    else
        error('Invalid run_type: %d. Must be 1, 2, or 3', run_type);
    end
catch ME
    error('Failed to create/load project: %s', ME.message);
end

% Generate finite element mesh
try
zef = zef_create_finite_element_mesh(zef);
catch ME
    zef_close_all(zef);
    error('Failed to generate finite element mesh: %s', ME.message);
end

% Save project if requested
if zef_bst.save_project && ~isempty(project_file_name)
    try
    [file_path, file_name] = fileparts(project_file_name);
        if isempty(file_path)
            file_path = pwd;
        end
    zef_save(zef, file_name, file_path, 1);
    catch ME
        warning('Failed to save project file: %s', ME.message);
    end
end

% Prepare output data (convert nodes back to meters for Brainstorm compatibility)
try
    if isfield(zef, 'nodes') && ~isempty(zef.nodes)
        out_cell{1} = zef.nodes / zef_bst.unit_conversion;
    else
        out_cell{1} = [];
    end
    
    if isfield(zef, 'tetra') && isfield(zef, 'domain_labels')
out_cell{2} = [zef.tetra zef.domain_labels];
    else
        out_cell{2} = [];
    end
    
    if isfield(zef, 'name_tags') && ~isempty(zef.name_tags)
out_cell{3} = zef.name_tags(1:end-1);
    else
        out_cell{3} = {};
    end
catch ME
    warning('Failed to prepare output data: %s', ME.message);
    out_cell{1} = [];
    out_cell{2} = [];
    out_cell{3} = {};
end

% Clean up
try
zef_close_all(zef);
catch
    % Ignore cleanup errors
end

end
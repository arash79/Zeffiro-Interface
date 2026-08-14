function out_cell = zef_bst_default_fem_mesh_create(run_type, input_mode, settings_file_name, project_file_name, zef_bst)
%ZEF_BST_DEFAULT_FEM_MESH_CREATE  Create project, mesh, return nodes in metres.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   out_cell = zef_bst_default_fem_mesh_create(run_type, input_mode, ...
%       settings_file_name, project_file_name)
%   out_cell = zef_bst_default_fem_mesh_create(..., zef_bst)
%
%   Plugin "Run" target (zef_bst_*_fem_mesh_create). run_type 0: empty
%   three-cell (cancel). 1 or 2: nodisplay zeffiro_interface then
%   zef_bst_create_project (project_file_name [] so no save there).
%   3: nodisplay session only (no open_project). Then
%   zef_create_finite_element_mesh. If zef_bst.save_project and
%   project_file_name non-empty, zef_save then zef_close_all.
%
%   out_cell{1} = zef.nodes / unit_conversion (metres);
%   out_cell{2} = [tetra domain_labels]; {3} = name_tags(1:end-1).
%
%   See also run, zef_bst_create_project, zef_bst_plugin_start.

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

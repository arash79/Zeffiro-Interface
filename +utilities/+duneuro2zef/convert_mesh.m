% convert_mesh.m
%
% Converts hexahedral mesh to tetrahedral format and processes domain labels.
%
% Input:
%   config - Configuration structure
%
% Output:
%   success - Logical indicating success
%   error_msg - Error message if failed (empty if successful)
%
% Usage:
%   [success, error_msg] = utilities.duneuro2zef.convert_mesh(config);
%
% See also: run.m, get_default_config.m

function [success, error_msg] = convert_mesh(config)
% --- Zeffiro documentation header ---
% utilities.duneuro2zef.convert_mesh — Convert mesh.
%
% Purpose:
%   Convert mesh.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   config
%
% Outputs:
%   success
%   error_msg
%
% Calls (project):
%   utilities.duneuro2zef.convert_mesh
%   utilities.duneuro2zef.find_files
%   zef_hexa_to_tetra
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[success, error_msg]] = utilities.duneuro2zef.convert_mesh(config)` with project root and `src` on the path.
% --- End Zeffiro documentation header


    success = false;
    error_msg = '';
    
    try
        % Find mesh file
        [mesh_path, mesh_file] = utilities.duneuro2zef.find_files(...
            config.files.mesh, config.input_folder, 'first');
        
        if isempty(mesh_path)
            error_msg = sprintf('Mesh file not found: %s', config.files.mesh);
            return;
        end
        
        if config.verbose
            fprintf('Loading mesh from: %s\n', mesh_path);
        end
        
        % Load mesh file
        mesh_data = load(mesh_path);
        
        % Extract mesh structure (handle different variable names)
        if isfield(mesh_data, 'mesh')
            mesh = mesh_data.mesh;
        elseif isfield(mesh_data, 'elements') && isfield(mesh_data, 'nodes')
            mesh = mesh_data;
        else
            % Try to find mesh-like structure
            fields = fieldnames(mesh_data);
            if length(fields) == 1
                mesh = mesh_data.(fields{1});
            else
                error_msg = 'Could not identify mesh structure in file';
                return;
            end
        end
        
        % Validate mesh structure
        if ~isfield(mesh, 'elements') || ~isfield(mesh, 'nodes')
            error_msg = 'Mesh file must contain elements and nodes fields';
            return;
        end
        
        % Validate mesh dimensions
        if size(mesh.elements, 2) ~= 8
            error_msg = sprintf('Hexahedral mesh elements must have 8 nodes per element, found %d', size(mesh.elements, 2));
            return;
        end
        if size(mesh.nodes, 2) ~= 3
            error_msg = sprintf('Mesh nodes must be 3D coordinates, found %d dimensions', size(mesh.nodes, 2));
            return;
        end
        
        % Process domain labels if present
        if isfield(mesh, 'labels')
            labels = mesh.labels;
            
            % Invert labels if configured
            if config.invert_domain_labels
                labels = max(labels) + 1 - labels;
            end
        else
            % Create default labels if missing
            labels = ones(size(mesh.elements, 1), 1);
            if config.verbose
                fprintf('Warning: No labels found in mesh, using default label 1\n');
            end
        end
        
        % Convert hexahedral to tetrahedral
        if config.verbose
            fprintf('Converting hexahedral mesh to tetrahedral...\n');
        end
        
        [tetra, domain_labels] = zef_hexa_to_tetra(mesh.elements, labels);
        nodes = mesh.nodes;
        
        % Identify brain compartment if configured
        if config.mesh.save_brain_ind && isfield(config.domain_labels, 'brain')
            brain_ind = find(domain_labels == config.domain_labels.brain);
        else
            brain_ind = [];
        end
        
        % Save converted mesh
        output_path = fullfile(config.output_folder, config.output.mesh);
        if config.verbose
            fprintf('Saving converted mesh to: %s\n', output_path);
        end
        
        if ~isempty(brain_ind)
            save(output_path, 'tetra', 'domain_labels', 'nodes', 'brain_ind', '-v7.3');
        else
            save(output_path, 'tetra', 'domain_labels', 'nodes', '-v7.3');
        end
        
        success = true;
        
    catch ME
        error_msg = sprintf('Error converting mesh: %s', ME.message);
        if config.verbose
            fprintf('Error: %s\n', error_msg);
            fprintf('Stack trace:\n');
            for i = 1:length(ME.stack)
                fprintf('  %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
            end
        end
    end

end

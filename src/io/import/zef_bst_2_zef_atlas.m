function [p_c_table, p_points] = zef_bst_2_zef_atlas(subject,surface_ind_aux,surface_struct,atlas_compartment,atlas_type,varargin)
%ZEF_BST_2_ZEF_ATLAS  Convert Brainstorm surface atlas scouts to Zeffiro parcellation tables.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finds an atlas on a Brainstorm surface by name, builds p_c_table label
%   and RGB rows from Scouts, and p_points with vertex coordinates scaled
%   by unit_scale (default 1000). Compartment references use
%   zef_find_compartment when atlas_compartment > 0.
%
%   [p_c_table, p_points] = zef_bst_2_zef_atlas(subject, surface_ind_aux, ...
%       surface_struct, atlas_compartment, atlas_type)
%   [p_c_table, p_points] = zef_bst_2_zef_atlas(..., atlas_tag, unit_scale)
%
%   Inputs
%     subject            - Brainstorm subject index.
%     surface_ind_aux    - surface index on the subject.
%     surface_struct     - preloaded struct with Atlas and Vertices, or [].
%     atlas_compartment  - compartment selector (>0 enables export).
%     atlas_type         - atlas Name to match (case insensitive).
%     atlas_tag          - optional table tag (defaults to atlas_type).
%     unit_scale         - coordinate scale factor (default 1000).
%
%   Outputs
%     p_c_table - Zeffiro parcellation colortable cell for one atlas.
%     p_points  - N-by-4 point table with scout indices in column 4.
%
%   See also zef_bst_2_zef_surface, zef_import_parcellation_colortable.

atlas_tag = '';
unit_scale = 1;

% Parse optional arguments
if ~isempty(varargin)
    atlas_tag = varargin{1};
    if length(varargin) > 1
        unit_scale = varargin{2};
    end
end

% Set defaults
if isempty(atlas_tag)
    atlas_tag = atlas_type;
end

% Load surface file if surface_struct not provided
if nargin < 3 || isempty(surface_struct)
    try
        if surface_ind_aux <= 0 || surface_ind_aux > length(bst_get('ProtocolSubjects').Subject(subject).Surface)
            error('Invalid surface index: %d', surface_ind_aux);
        end
        surface_file = fullfile(bst_get('ProtocolInfo').SUBJECTS, ...
            bst_get('ProtocolSubjects').Subject(subject).Surface(surface_ind_aux).FileName);
        if ~exist(surface_file, 'file')
            error('Surface file not found: %s', surface_file);
        end
        load_fields = {'Atlas', 'Vertices'};
        surface_struct = load(surface_file, load_fields{:});
    catch ME
        error('Failed to load surface file: %s', ME.message);
    end
end

% Validate surface_struct
if ~isfield(surface_struct, 'Atlas') || isempty(surface_struct.Atlas)
    error('Surface structure does not contain Atlas data');
end
if ~isfield(surface_struct, 'Vertices') || isempty(surface_struct.Vertices)
    error('Surface structure does not contain Vertices data');
end

p_c_table = cell(0);
p_points = cell(0);

if atlas_compartment > 0
    % Search for matching atlas
    atlas_found = false;
    for i = 1 : length(surface_struct.Atlas)
        if isequal(lower(atlas_type), lower(surface_struct.Atlas(i).Name))
            atlas_found = true;
            
            % Validate Atlas structure
            if ~isfield(surface_struct.Atlas(i), 'Scouts') || isempty(surface_struct.Atlas(i).Scouts)
                error('Atlas "%s" does not contain Scouts data', atlas_type);
            end
            
            p_c_table{1} = atlas_tag;
            p_c_table{2} = cell(0);
            p_c_table{3} = zeros(length(surface_struct.Atlas(i).Scouts), 5);
            
            % Count total nodes
            node_counter = 0;
            for j = 1 : length(surface_struct.Atlas(i).Scouts)
                if ~isfield(surface_struct.Atlas(i).Scouts(j), 'Vertices')
                    warning('Scout %d in atlas "%s" missing Vertices field. Skipping.', j, atlas_type);
                    continue;
                end
                p_c_table{2}{j, 1} = surface_struct.Atlas(i).Scouts(j).Label;
                if isfield(surface_struct.Atlas(i).Scouts(j), 'Color')
                    p_c_table{3}(j, 1:3) = round(255 * surface_struct.Atlas(i).Scouts(j).Color);
                else
                    p_c_table{3}(j, 1:3) = [128 128 128];  % Default gray
                end
                p_c_table{3}(j, 5) = j;
                node_counter = node_counter + size(surface_struct.Atlas(i).Scouts(j).Vertices, 1);
            end
            
            % Allocate point array
            n_nodes = node_counter;
            if n_nodes > 0
                p_points = zeros(n_nodes, 4);
                p_points(:, 1) = [0 : n_nodes-1]';
                p_c_table{4} = zeros(n_nodes, 1);
                
                % Extract point coordinates
                node_counter = 0;
                for j = 1 : length(surface_struct.Atlas(i).Scouts)
                    if ~isfield(surface_struct.Atlas(i).Scouts(j), 'Vertices')
                        continue;
                    end
                    
                    n_nodes_aux = size(surface_struct.Atlas(i).Scouts(j).Vertices, 1);
                    if n_nodes_aux > 0
                        try
                            % Validate vertex indices
                            max_vertex_idx = max(surface_struct.Atlas(i).Scouts(j).Vertices);
                            if max_vertex_idx > size(surface_struct.Vertices, 1)
                                error('Scout %d references vertex index %d, but only %d vertices exist', ...
                                    j, max_vertex_idx, size(surface_struct.Vertices, 1));
                            end
                            
                            p_points(node_counter + 1:node_counter + n_nodes_aux, 2:4) = ...
                                unit_scale * surface_struct.Vertices(surface_struct.Atlas(i).Scouts(j).Vertices, :);
                            p_c_table{4}(node_counter + 1:node_counter + n_nodes_aux) = j;
                            node_counter = node_counter + n_nodes_aux;
                        catch ME
                            error('Failed to extract points for Scout %d in atlas "%s": %s', ...
                                j, atlas_type, ME.message);
                        end
                    end
                end
            end
            
            % Set compartment references
            p_c_table{5} = cell(0);
            for p_ind = 1 : size(p_c_table{3}, 1)
                p_c_table{5}{p_ind, 1} = zef_find_compartment('name', atlas_compartment);
                p_c_table{5}{p_ind, 2} = 1;
            end
            p_c_table{6} = ones(size(p_c_table{3}, 1), 1);
            
            break;  % Found matching atlas, exit loop
        end
    end
    
    if ~atlas_found
        warning('Atlas type "%s" not found in surface structure', atlas_type);
    end
end

end

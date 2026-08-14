function atlas_surfaces = zef_bst_get_atlas_surfaces(zef, atlas_struct, n_inflation_steps, transform_cell, compartment_type, volume_extension_vec)
%ZEF_BST_GET_ATLAS_SURFACES  Voxel Cube → one inflated triangle mesh per label.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   atlas_surfaces = zef_bst_get_atlas_surfaces(zef, atlas_struct, n_infl)
%   atlas_surfaces = zef_bst_get_atlas_surfaces(..., transform_cell, type, vol_ext)
%
%   atlas_struct.Cube (required) and .Labels (N-by-up-to-3: id, name, RGB
%   0–255). Optional .Comment, .InitTransf, .SkipZefWaitbar.
%   Each voxel → 5 tets; zef_surface_mesh + zef_inflate_surface(n_infl).
%   volume_extension_vec(i)>0 dilates label i by that many tet rings
%   (default zeros). transform_cell containing 'InitTransf' applies
%   atlas_struct.InitTransf{2} (4×4) to nodes. Last entry is a dark
%   "domain fill" union of all labels. Faces reordered [1 3 2].
%
%   Fields: .Name .Type .Color (0–1) .Points .Triangles.
%
%   See also zef_bst_create_compartment_data, zef_surface_mesh.

if nargin < 4
    transform_cell = cell(0);
end
if nargin < 5
    compartment_type = '';
end
if nargin < 6
    if isfield(atlas_struct, 'Labels') && ~isempty(atlas_struct.Labels)
    volume_extension_vec = zeros(size(atlas_struct.Labels,1),1);
    else
        volume_extension_vec = [];
    end
end

% Validate inputs
if nargin < 2 || isempty(atlas_struct)
    error('Atlas structure is required');
end

atlas_surfaces = struct;

% Validate atlas structure
if ~isfield(atlas_struct, 'Cube') || isempty(atlas_struct.Cube)
    error('Atlas structure must contain a non-empty Cube field');
end
if ~isfield(atlas_struct, 'Labels') || isempty(atlas_struct.Labels)
    error('Atlas structure must contain a non-empty Labels field');
end
if ~isfield(atlas_struct, 'Comment')
    atlas_struct.Comment = 'Unknown';
end

% Create coordinate grid for volumetric data
% Note: meshgrid dimensions: X is (size_y x size_x x size_z), Y is (size_y x size_x x size_z), Z is (size_y x size_x x size_z)
cube_size = size(atlas_struct.Cube);
[X, Y, Z] = meshgrid([0:cube_size(1)], [0:cube_size(2)], [0:cube_size(3)]);
% Calculate number of cubes (voxels) in the volume
n_cubes = prod(cube_size);
size_xyz = size(X);
skip_wb = isfield(atlas_struct, 'SkipZefWaitbar') && logical(atlas_struct.SkipZefWaitbar);
if skip_wb
    h_waitbar = [];
else
    h_waitbar = zef_waitbar(0,['Atlas labels for ' atlas_struct.Comment '.']);
end

% Define tetrahedral decomposition patterns for each cube
% Pattern depends on cube position (even/odd indices) for consistent meshing
ind_mat_1{1}{2}{1} = [2 5 6 7; 7 5 4 2; 2 3 4 7; 1 2 4 5 ; 4 7 8 5];
ind_mat_1{1}{2}{2} = [6 2 1 3; 1 3 8 6; 8 7 6 3;  5 8 6 1; 3 8 4 1 ];
ind_mat_1{2}{2}{2} = [5 2 1 4; 4 2 7 5; 5 8 7 4;  5 7 6 2;  3 7 4 2];
ind_mat_1{2}{2}{1} = [1 5 6 8; 6 8 3 1; 3 4 1 8; 2 3 1 6 ; 3 7 8 6  ];
ind_mat_1{1}{1}{2} = [4 3 7 2; 2 7 4 5; 5 7 6 2; 1 5 2 4;  8 7 5 4 ];
ind_mat_1{2}{1}{2} = [3 6 8 1; 1 3 4 8; 5 8 6 1; 1 6 2 3 ; 8 7 6 3  ];
ind_mat_1{1}{1}{1} = [7 8 3 6; 8 1 3 6; 2 3 1 6;  1 5 6 8 ; 1 3 4 8   ];
ind_mat_1{2}{1}{1} = [7 8 4 5; 5 4 7 2; 2 4 1 5; 2 5 6 7 ;  2 3 4 7 ];

% Initialize arrays for tetrahedral mesh
tetra = zeros(5*n_cubes,4);
cube_labels = zeros(5*n_cubes,1);
nodes = [X(:) Y(:) Z(:)] + 0.5;  % Node coordinates (centered in voxels)

% Decompose each voxel into 5 tetrahedra
% Note: Cube indexing is (x, y, z) but meshgrid returns (y, x, z) dimensions
i = 1;
for i_x = 1 : cube_size(1)
    step_x = max(1, floor(cube_size(1) / 20));
    if mod(i_x, step_x) == 0 || i_x == 1 || i_x == cube_size(1)
        if skip_wb
            fprintf(1, 'Atlas surfaces: voxel tetra sweep %d / %d (dim 1)...\n', i_x, cube_size(1));
        elseif ~isempty(h_waitbar) && isvalid(h_waitbar)
            zef_waitbar(i_x/cube_size(1), h_waitbar, ['Atlas labels for ' atlas_struct.Comment '.']);
        end
    end
    for i_y = 1 : cube_size(2)
        for i_z = 1 : cube_size(3)
            % Define 8 vertices of the current cube
            % Note: meshgrid dimensions are swapped (y, x, z), so we adjust indexing
            x_ind = [i_x   i_x+1  i_x+1  i_x    i_x    i_x+1  i_x+1  i_x]';
            y_ind = [i_y   i_y    i_y+1  i_y+1  i_y    i_y    i_y+1  i_y+1]';
            z_ind = [i_z   i_z    i_z    i_z    i_z+1  i_z+1  i_z+1  i_z+1]';
            % sub2ind uses (row, col, page) which corresponds to (y, x, z) for meshgrid
            ind_mat_2 = sub2ind(size_xyz, y_ind, x_ind, z_ind);
            % Select decomposition pattern based on cube position
            tetra(i:i+4,:) = ind_mat_2(ind_mat_1{2-mod(i_x,2)}{2-mod(i_y,2)}{2-mod(i_z,2)});
            % Cube indexing: (x, y, z) = (i_x, i_y, i_z)
            cube_labels(i:i+4) = atlas_struct.Cube(i_x, i_y, i_z);
            i = i + 5;
        end
    end
end
if skip_wb
    fprintf(1, 'Atlas surfaces: voxel grid done; extracting meshes per tissue (inflation may dominate runtime)...\n');
end
% Extract surface meshes for each labeled region
surface_ind = 0;
label_ind_vec = [];
for i = 1 : size(atlas_struct.Labels,1)
    
    label_val = atlas_struct.Labels{i,1};
    if label_val > 0
        surface_ind = surface_ind + 1;
        % Find all tetrahedra belonging to this label
        I = find(cube_labels == label_val);
        
        % Apply volume extension if specified (dilates the region)
        if volume_extension_vec(i) > 0
            for j = 1 : volume_extension_vec(i)
                unique_nodes = unique(tetra(I,:));
                J = find(sum(ismember(tetra,unique_nodes),2)>=1);
                I = union(I,J);
            end
        end
        
        label_ind_vec = [label_ind_vec label_val];
        
        % Extract surface mesh from tetrahedral mesh
        if isempty(I)
            warning('No tetrahedra found for label %d, skipping', label_val);
            surface_ind = surface_ind - 1;  % Adjust counter
            continue;
        end
        
        try
        [triangles_aux, nodes_aux] = zef_surface_mesh(tetra(I,:),nodes);
            if isempty(triangles_aux) || isempty(nodes_aux)
                warning('Empty surface mesh for label %d, skipping', label_val);
                surface_ind = surface_ind - 1;  % Adjust counter
                continue;
            end
        % Apply surface inflation for smoothing
            [nodes_aux] = zef_inflate_surface(zef, nodes_aux, triangles_aux, n_inflation_steps);
        catch ME
            warning('Failed to extract surface mesh for label %d: %s. Skipping.', label_val, ME.message);
            surface_ind = surface_ind - 1;  % Adjust counter
            continue;
        end
        
        % Store surface information
        if size(atlas_struct.Labels, 2) >= 2 && ~isempty(atlas_struct.Labels{i,2})
        atlas_surfaces(surface_ind).Name = atlas_struct.Labels{i,2};
        else
            atlas_surfaces(surface_ind).Name = sprintf('Label_%d', label_val);
        end
        atlas_surfaces(surface_ind).Type = compartment_type;
        if size(atlas_struct.Labels, 2) >= 3 && ~isempty(atlas_struct.Labels{i,3})
        atlas_surfaces(surface_ind).Color = atlas_struct.Labels{i,3}/255;  % Convert from 0-255 to 0-1
        else
            atlas_surfaces(surface_ind).Color = [0.5 0.5 0.5];  % Default gray color
        end
        
        % Apply transformation if specified
        if ismember('InitTransf',transform_cell)
            if not(isempty(atlas_struct.InitTransf))
                A = atlas_struct.InitTransf{2};
                nodes_aux = (A*[nodes_aux' ; ones(1,size(nodes_aux,1))])';
            end
        end
        
        atlas_surfaces(surface_ind).Points = nodes_aux(:,1:3);
        atlas_surfaces(surface_ind).Triangles = triangles_aux(:,[1 3 2]);  % Reorder for Zeffiro convention
    end
end

% Create a combined surface for all labels (domain fill)
if not(isempty(label_ind_vec))
    surface_ind = surface_ind + 1;
    I = find(ismember(cube_labels, label_ind_vec));
    
    if isempty(I)
        warning('No tetrahedra found for domain fill, skipping');
    else
        try
    [triangles_aux, nodes_aux] = zef_surface_mesh(tetra(I,:),nodes);
            if ~isempty(triangles_aux) && ~isempty(nodes_aux)
                [nodes_aux] = zef_inflate_surface(zef, nodes_aux, triangles_aux, n_inflation_steps);
    
    atlas_surfaces(surface_ind).Name = [atlas_struct.Comment ' domain fill'];
    atlas_surfaces(surface_ind).Type = compartment_type;
    atlas_surfaces(surface_ind).Color = [0.05 0.05 0.05];
    
    if ismember('InitTransf',transform_cell)
                    if isfield(atlas_struct, 'InitTransf') && ~isempty(atlas_struct.InitTransf) && ...
                       length(atlas_struct.InitTransf) >= 2
            A = atlas_struct.InitTransf{2};
            nodes_aux = (A*[nodes_aux' ; ones(1,size(nodes_aux,1))])';
        end
    end
    
    atlas_surfaces(surface_ind).Points = nodes_aux(:,1:3);
    atlas_surfaces(surface_ind).Triangles = triangles_aux(:,[1 3 2]);
            else
                warning('Empty surface mesh for domain fill, skipping');
            end
        catch ME
            warning('Failed to extract domain fill surface: %s', ME.message);
        end
    end
end

% Properly delete waitbar by clearing DeleteFcn first
if ~isempty(h_waitbar) && isvalid(h_waitbar)
    set(h_waitbar, 'DeleteFcn', '');
    delete(h_waitbar);
end

end

function atlas_surfaces = extract_SimNIBS_surfaces( ...
    zef, atlas_struct, n_inflation_steps, transform_cell, compartment_type)
%EXTRACT_SIMNIBS_SURFACES  Closed surfaces from a labelled volume (atlas_struct.Cube).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   atlas_struct.Cube (labelled volume) and .Labels required. Optional
%   n_inflation_steps, transform_cell (default {}), compartment_type ('').
%   Each label becomes a closed triangulated surface (marching / inflation
%   path in the body). Used by volume pipelines inside sn2zef; the public
%   public run uses export_segmentation_meshes → zef_bst_get_atlas_surfaces
%   instead. Keep this function for callers that already have an atlas_struct.
%
%   atlas_surfaces = extract_SimNIBS_surfaces(zef, atlas_struct, ...
%       n_inflation_steps, transform_cell, compartment_type)
%

    if nargin < 4
        transform_cell = {};
    end

    if nargin < 5
        compartment_type = '';
    end

    % Validate atlas structure has required fields
    if ~isfield(atlas_struct, 'Cube') || isempty(atlas_struct.Cube)
        error('Atlas structure must contain a non-empty Cube field');
    end
    if ~isfield(atlas_struct, 'Labels') || isempty(atlas_struct.Labels)
        error('Atlas structure must contain a non-empty Labels field');
    end
    if ~isfield(atlas_struct, 'Comment')
        atlas_struct.Comment = 'Unknown';
    end

    % Convert volume data to uint16 for consistent processing
    data = atlas_struct.Cube;

    if ~isinteger(data)
        data = round(data);  % Round to nearest integer
        data = uint16(data);
    else
        data = uint16(data);
    end

    vol = data;  % Working volume array
    sz  = size(vol);  % Volume dimensions [x, y, z]

    % Initialize progress waitbar
    h_waitbar = zef_waitbar(0, ['Atlas labels for ' atlas_struct.Comment '.']);

    % Check if initial transformation should be applied
    % Transformation is used if explicitly requested and available in atlas_struct
    use_init_transf = ...
        ~isempty(transform_cell) && ...
        any(strcmp(transform_cell, 'InitTransf')) && ...
        isfield(atlas_struct, 'InitTransf') && ...
        ~isempty(atlas_struct.InitTransf);

    if use_init_transf
        A = atlas_struct.InitTransf{2};  % Extract transformation matrix
    else
        A = [];
    end

    % Check if Image Processing Toolbox is available for morphological operations
    have_im = license('test', 'image_toolbox');

    % Performance thresholds to prevent excessive computation
    max_morph_voxels        = 5e6;  % Skip morphological ops for large labels
    max_vertices_for_infl   = 5e5;  % Skip inflation for very large surfaces
    bbox_padding_voxels     = 1;    % Padding around bounding box for surface extraction

    n_labels = size(atlas_struct.Labels, 1);

    % Preallocate output structure array
    atlas_surfaces(1, n_labels) = struct( ...
        'Name',      [], ...
        'Type',      [], ...
        'Color',     [], ...
        'Points',    [], ...
        'Triangles', []);

    surface_ind = 0;  % Counter for successfully extracted surfaces

    % Process each label in the atlas
    for i_label = 1:n_labels

        % Update progress bar periodically (every 5 labels, first, and last)
        if mod(i_label, 5) == 0 || i_label == 1 || i_label == n_labels
            zef_waitbar(i_label / max(1, n_labels + 1), h_waitbar, ...
                ['Atlas labels for ' atlas_struct.Comment '.']);
        end

        % Safely access Labels array with validation
        if i_label > size(atlas_struct.Labels, 1)
            warning('Label index %d exceeds Labels array size. Skipping.', i_label);
            continue;
        end
        
        if size(atlas_struct.Labels, 2) < 2
            warning('Labels array has insufficient columns. Skipping label %d.', i_label);
            continue;
        end

        % Extract label value and name from Labels array
        label_val  = atlas_struct.Labels{i_label, 1};
        label_name = atlas_struct.Labels{i_label, 2};

        % Validate label values (must be positive integer)
        if isempty(label_val) || ~isnumeric(label_val) || label_val <= 0
            continue;
        end
        
        % Use default name if label name is empty
        if isempty(label_name)
            label_name = sprintf('Label_%d', label_val);
        end

        % Create binary mask for current label value
        mask = (vol == uint16(label_val));

        % Skip if label doesn't appear in volume
        if ~any(mask(:))
            continue;
        end

        % Compute bounding box to reduce computation volume
        % Find extent of label in each dimension
        any_x = squeeze(any(any(mask, 2), 3));
        xmin  = find(any_x, 1, 'first');
        xmax  = find(any_x, 1, 'last');

        any_y = squeeze(any(any(mask, 1), 3));
        ymin  = find(any_y, 1, 'first');
        ymax  = find(any_y, 1, 'last');

        any_z = squeeze(any(any(mask, 1), 2));
        zmin  = find(any_z, 1, 'first');
        zmax  = find(any_z, 1, 'last');

        % Add padding and clamp to volume boundaries
        xmin = max(1, xmin - bbox_padding_voxels);
        xmax = min(sz(1), xmax + bbox_padding_voxels);
        ymin = max(1, ymin - bbox_padding_voxels);
        ymax = min(sz(2), ymax + bbox_padding_voxels);
        zmin = max(1, zmin - bbox_padding_voxels);
        zmax = min(sz(3), zmax + bbox_padding_voxels);

        % Extract subvolume containing the label
        mask_sub = mask(xmin:xmax, ymin:ymax, zmin:zmax);

        % Apply morphological operations if Image Processing Toolbox is available
        % These operations close small gaps and fill holes in the mask
        if have_im
            vox_count = nnz(mask_sub);

            % Only apply morphological operations for reasonably sized labels
            if vox_count <= max_morph_voxels
                se = strel('sphere', 2);  % Spherical structuring element
                mask_sub = imclose(mask_sub, se);  % Morphological closing
                mask_sub = imfill(mask_sub, 'holes');  % Fill interior holes
            end
        end

        % Skip if mask becomes empty after processing
        if ~any(mask_sub(:))
            continue;
        end

        % Create coordinate grids for the subvolume
        [X_sub, Y_sub, Z_sub] = ndgrid(xmin:xmax, ymin:ymax, zmin:zmax);

        % Extract isosurface using marching cubes algorithm
        % Threshold of 0.5 extracts surface at the boundary between label and background
        fv = isosurface(X_sub, Y_sub, Z_sub, mask_sub, 0.5);

        % Skip if no surface was extracted
        if isempty(fv.vertices)
            continue;
        end

        nodes_aux     = fv.vertices;  % Vertex coordinates
        triangles_aux = fv.faces;     % Triangle vertex indices

        n_vertices = size(nodes_aux, 1);

        % Apply surface inflation for smoothing (if requested and feasible)
        if n_inflation_steps > 0
            if n_vertices <= max_vertices_for_infl
                nodes_aux = zef_inflate_surface( ...
                    zef, nodes_aux, triangles_aux, n_inflation_steps);
            end
        end

        % Apply initial transformation if specified
        if use_init_transf
            % Convert to homogeneous coordinates and apply transformation
            nodes_hom = (A * [nodes_aux.'; ones(1, n_vertices)]);
            nodes_aux = nodes_hom(1:3, :).';  % Extract xyz coordinates
        end

        % Store extracted surface in output structure
        surface_ind = surface_ind + 1;

        atlas_surfaces(surface_ind).Name      = label_name;
        atlas_surfaces(surface_ind).Type      = compartment_type;
        
        % Safely access color from Labels array
        % Colors are stored as RGB values [0-255], normalize to [0-1]
        if size(atlas_struct.Labels, 2) >= 3 && ~isempty(atlas_struct.Labels{i_label, 3})
            atlas_surfaces(surface_ind).Color = double(atlas_struct.Labels{i_label, 3}) / 255;
        else
            atlas_surfaces(surface_ind).Color = [0.5 0.5 0.5];  % Default gray color
        end
        
        atlas_surfaces(surface_ind).Points    = nodes_aux(:, 1:3);
        % Flip triangle vertex order for correct surface orientation
        atlas_surfaces(surface_ind).Triangles = triangles_aux(:, [1 3 2]);

    end

    atlas_surfaces = atlas_surfaces(1:surface_ind);

    if ishghandle(h_waitbar)
        % Properly delete waitbar by clearing DeleteFcn first
        if isvalid(h_waitbar)
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        end
    end

end % function

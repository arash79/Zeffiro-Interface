%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_VISUALIZE_DTI_STREAMLINES
%
%Visualizes DTI streamlines using FreeSurfer dt_recon outputs.
%This function:
%1. Uses FreeSurfer v1.nii.gz (principal eigenvector) and fa.nii.gz (FA)
%2. Gets seed point (from mesh center or user-specified)
%3. Transforms seed point from mesh space to FA voxel space using register.dat
%4. Generates streamlines in FA space using zef_dti_streamlines
%5. Transforms streamlines back to mesh space for visualization
%6. Plots streamlines in the current axes
%
%WHY THIS IS NEEDED:
%DTI streamlines show white matter fiber tracts, which is important for
%understanding brain connectivity. The streamlines must be properly
%transformed between FA voxel space and mesh physical space using
%FreeSurfer's register.dat transformation.
%
%Inputs:
%   zef - Zeffiro struct (optional, reads from base workspace if not provided)
%   seed_point - [1×3] Seed point in mesh space (optional, uses mesh center if not provided)
%
%Outputs:
%   h_streamlines - Handle to streamline plot objects

function h_streamlines = zef_visualize_dti_streamlines(zef, seed_point)

% Initialize waitbar
h_waitbar = [];
try
    h_waitbar = zef_waitbar(0, 1, 'Initializing FreeSurfer DTI streamline visualization...');
    if ~isempty(h_waitbar)
        try
            figure(h_waitbar);
            drawnow;
            pause(0.05);
        catch
            drawnow;
        end
    end
catch
    h_waitbar = [];
end

if nargin == 0
    zef = evalin('base','zef');
end

% ========================================================================
% STEP 1: VALIDATION - Ensure prerequisites are met
% ========================================================================

if ~isempty(h_waitbar)
    try
        zef_waitbar(0.02, 1, h_waitbar, 'Validating inputs...');
        drawnow;
    catch
    end
end

% Check for FreeSurfer FA data
if ~isfield(zef,'freesurfer_fa_data') || isempty(zef.freesurfer_fa_data)
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        catch
        end
    end
    error(['FreeSurfer FA data not loaded. Please import FA data first using:' newline ...
           '  [zef.freesurfer_fa_data, zef.freesurfer_fa_info] = zef_freesurfer_load_fa(fa_file);']);
end

% Check for v1 (principal eigenvector) - required for streamlines
if ~isfield(zef,'freesurfer_v1_data') || isempty(zef.freesurfer_v1_data)
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        catch
        end
    end
    error(['FreeSurfer v1 data not loaded. Please import v1.nii.gz first using:' newline ...
           '  [zef.freesurfer_v1_data, zef.freesurfer_v1_info] = zef_freesurfer_load_v1(v1_file);']);
end

% Check for register.dat
if ~isfield(zef,'freesurfer_register_transform') || isempty(zef.freesurfer_register_transform)
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        catch
        end
    end
    error(['FreeSurfer register.dat not loaded. Please load register.dat:' newline ...
           '  zef.freesurfer_register_transform = zef_freesurfer_read_register_dat(register_dat_file);']);
end

if ~isfield(zef,'nodes') || isempty(zef.nodes)
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        catch
        end
    end
    error('Mesh nodes not available. Please create or load mesh first.');
end

% Validate transformation matrices are available (from auto-extraction, GUI handles, or auto-computable from file data)
has_dwi_tkr = (isfield(zef,'dti_dwi_vox2ras_tkr') && ~isempty(zef.dti_dwi_vox2ras_tkr) && ~isequal(zef.dti_dwi_vox2ras_tkr, eye(4))) || ...
              (isfield(zef,'h_dti_dwi_vox2ras_tkr') && ~isempty(zef.h_dti_dwi_vox2ras_tkr)) || ...
              (isfield(zef,'freesurfer_fa_info') && ~isempty(zef.freesurfer_fa_info));
has_ref_vox2ras = (isfield(zef,'dti_ref_vox2ras') && ~isempty(zef.dti_ref_vox2ras) && ~isequal(zef.dti_ref_vox2ras, eye(4))) || ...
                  (isfield(zef,'h_dti_ref_vox2ras') && ~isempty(zef.h_dti_ref_vox2ras)) || ...
                  (isfield(zef,'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry));
has_ref_tkr = (isfield(zef,'dti_ref_vox2ras_tkr') && ~isempty(zef.dti_ref_vox2ras_tkr) && ~isequal(zef.dti_ref_vox2ras_tkr, eye(4))) || ...
              (isfield(zef,'h_dti_ref_vox2ras_tkr') && ~isempty(zef.h_dti_ref_vox2ras_tkr)) || ...
              (isfield(zef,'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry));
has_ref_center = (isfield(zef,'dti_ref_center') && ~isempty(zef.dti_ref_center) && any(zef.dti_ref_center(:) ~= 0)) || ...
                 (isfield(zef,'h_dti_ref_center') && ~isempty(zef.h_dti_ref_center)) || ...
                 (isfield(zef,'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry));

if ~has_dwi_tkr
    if ~isempty(h_waitbar) && isvalid(h_waitbar), try set(h_waitbar,'DeleteFcn',''); delete(h_waitbar); catch, end, end
    error(['DWI vox2ras-tkr not available. Load fa.nii.gz in the DTI Conductivity Tool ' ...
           '(auto-extracted on load), or ensure freesurfer_fa_info is populated.']);
end
if ~has_ref_vox2ras
    if ~isempty(h_waitbar) && isvalid(h_waitbar), try set(h_waitbar,'DeleteFcn',''); delete(h_waitbar); catch, end, end
    error('Reference vox2ras not available. Load a Reference MRI file (e.g. orig.mgz) in the DTI Conductivity Tool.');
end
if ~has_ref_tkr
    if ~isempty(h_waitbar) && isvalid(h_waitbar), try set(h_waitbar,'DeleteFcn',''); delete(h_waitbar); catch, end, end
    error('Reference vox2ras-tkr not available. Load a Reference MRI file (e.g. orig.mgz) in the DTI Conductivity Tool.');
end
if ~has_ref_center
    if ~isempty(h_waitbar) && isvalid(h_waitbar), try set(h_waitbar,'DeleteFcn',''); delete(h_waitbar); catch, end, end
    error('Reference center not available. Load a Reference MRI file (e.g. orig.mgz) in the DTI Conductivity Tool.');
end

% Get FA dimensions
[nx, ny, nz] = size(zef.freesurfer_fa_data);

% Verify v1 dimensions match FA
v1_dims = size(zef.freesurfer_v1_data);
if length(v1_dims) == 4 && v1_dims(4) == 3
    if ~isequal(v1_dims(1:3), [nx, ny, nz])
        error('v1 dimensions [%s] do not match FA dimensions [%s]', mat2str(v1_dims(1:3)), mat2str([nx, ny, nz]));
    end
else
    error('v1 data has unexpected format. Expected [nx, ny, nz, 3], got [%s]', mat2str(v1_dims));
end

% ========================================================================
% STEP 2: GET SEED POINT
% ========================================================================

if ~isempty(h_waitbar)
    try
        zef_waitbar(0.04, 1, h_waitbar, 'Computing seed point...');
        drawnow;
    catch
    end
end

if nargin < 2 || isempty(seed_point)
    % Use mesh center as seed point
    nodes = zef.nodes;
    seed_point = [mean(nodes(:,1)), mean(nodes(:,2)), mean(nodes(:,3))];
else
    % Validate seed point format
    if ~isequal(size(seed_point), [1, 3]) && ~isequal(size(seed_point), [3, 1])
        if ~isempty(h_waitbar) && isvalid(h_waitbar)
            try
                set(h_waitbar, 'DeleteFcn', '');
                delete(h_waitbar);
            catch
            end
        end
        error('Seed point must be [1×3] or [3×1] vector');
    end
    seed_point = seed_point(:)';  % Ensure row vector
end

% ========================================================================
% STEP 3: PREPARE DTI DIRECTIONS AND ANISOTROPY FROM FREE SURFER
% ========================================================================

if ~isempty(h_waitbar)
    try
        zef_waitbar(0.06, 1, h_waitbar, 'Preparing FreeSurfer DTI data...');
        drawnow;
    catch
    end
end

% v1 is already in [nx, ny, nz, 3] format (principal eigenvector)
% FA is in [nx, ny, nz] format
dti_directions = zef.freesurfer_v1_data;  % Already normalized in load function
dti_anisotropy = zef.freesurfer_fa_data;   % FA values

% ========================================================================
% STEP 4: TRANSFORM SEED POINT FROM MESH SPACE TO FA VOXEL SPACE
% ========================================================================

if ~isempty(h_waitbar)
    try
        zef_waitbar(0.25, 1, h_waitbar, 'Transforming seed point to FA space...');
        drawnow;
    catch
    end
end

try
    % Get the full mesh→voxel transformation (same chain as conductivity pipeline)
    % This correctly accounts for ref_center, ref_vox2ras, ref_vox2ras_tkr,
    % register.dat, and FA vox2ras-tkr.
    T_mesh2voxel = zef_dti_get_mesh2voxel(zef);
    
    % Transform seed point from mesh display space to FA voxel space
    % T_mesh2voxel uses 0-based voxel convention (matches mri_info / FreeSurfer)
    seed_point_homogeneous = [seed_point, 1];
    seed_point_fa_voxel_homogeneous = (T_mesh2voxel * seed_point_homogeneous')';
    seed_point_fa_voxel_original_0based = seed_point_fa_voxel_homogeneous(1:3);
    
    % Validate seed point is within FA volume bounds (0-based: valid range 0..dim-1)
    is_outside_bounds = any(seed_point_fa_voxel_original_0based < -0.5) || ...
                        seed_point_fa_voxel_original_0based(1) > nx-0.5 || ...
                        seed_point_fa_voxel_original_0based(2) > ny-0.5 || ...
                        seed_point_fa_voxel_original_0based(3) > nz-0.5;
    
    if is_outside_bounds
        % Use FA volume center as seed point instead (0-based center)
        seed_point_fa_voxel_0based = [(nx-1)/2, (ny-1)/2, (nz-1)/2];
        
        if nargin < 2 || isempty(seed_point)
            % Only warn if we used mesh center (not user-provided)
            warning(['Mesh center transformed outside FA volume bounds. Using FA volume center as seed point instead.' newline ...
                     'Mesh center (mesh space): (%.2f, %.2f, %.2f)' newline ...
                     'Transformed to FA voxel (0-based): (%.2f, %.2f, %.2f) [OUT OF BOUNDS]' newline ...
                     'Using FA center (0-based voxel): (%.2f, %.2f, %.2f)'], ...
                seed_point(1), seed_point(2), seed_point(3), ...
                seed_point_fa_voxel_original_0based(1), seed_point_fa_voxel_original_0based(2), seed_point_fa_voxel_original_0based(3), ...
                seed_point_fa_voxel_0based(1), seed_point_fa_voxel_0based(2), seed_point_fa_voxel_0based(3));
        else
            % User provided seed point - still use FA center but warn
            warning(['User-provided seed point transformed outside FA volume bounds. Using FA volume center as seed point instead.' newline ...
                     'User seed (mesh space): (%.2f, %.2f, %.2f)' newline ...
                     'Transformed to FA voxel (0-based): (%.2f, %.2f, %.2f) [OUT OF BOUNDS]' newline ...
                     'Using FA center (0-based voxel): (%.2f, %.2f, %.2f)'], ...
                seed_point(1), seed_point(2), seed_point(3), ...
                seed_point_fa_voxel_original_0based(1), seed_point_fa_voxel_original_0based(2), seed_point_fa_voxel_original_0based(3), ...
                seed_point_fa_voxel_0based(1), seed_point_fa_voxel_0based(2), seed_point_fa_voxel_0based(3));
        end
    else
        seed_point_fa_voxel_0based = seed_point_fa_voxel_original_0based;
    end
    
    % Clamp to valid 0-based range [0, dim-1]
    seed_point_fa_voxel_0based = [
        max(0, min(nx-1, seed_point_fa_voxel_0based(1))), ...
        max(0, min(ny-1, seed_point_fa_voxel_0based(2))), ...
        max(0, min(nz-1, seed_point_fa_voxel_0based(3)))
    ];
    % zef_dti_streamlines expects 1-based voxel coordinates
    seed_point_fa_voxel = seed_point_fa_voxel_0based + 1;
    
    % Get FA threshold (needed for validation check below)
    fa_thresh = 0.15;  % Default threshold
    if isfield(zef,'dti_streamline_fa_thresh')
        fa_thresh = zef.dti_streamline_fa_thresh;
        warning('FA threshold set to %f', fa_thresh);
    end
    
    % Check if seed point is in a region with valid FA values
    % Convert to integer indices for array access (1-based)
    seed_idx = round(seed_point_fa_voxel);
    seed_idx(1) = max(1, min(nx, seed_idx(1)));
    seed_idx(2) = max(1, min(ny, seed_idx(2)));
    seed_idx(3) = max(1, min(nz, seed_idx(3)));
    
    fa_at_seed = zef.freesurfer_fa_data(seed_idx(1), seed_idx(2), seed_idx(3));
    if fa_at_seed < fa_thresh
        % Try to find a nearby point with valid FA
        % Search in a small sphere around the seed point
        search_radius = min(10, min([nx, ny, nz])/4);
        found_valid = false;
        
        for r = 1:search_radius
            [x_search, y_search, z_search] = meshgrid(...
                max(1, seed_idx(1)-r):min(nx, seed_idx(1)+r), ...
                max(1, seed_idx(2)-r):min(ny, seed_idx(2)+r), ...
                max(1, seed_idx(3)-r):min(nz, seed_idx(3)+r));
            
            for i = 1:numel(x_search)
                x = x_search(i);
                y = y_search(i);
                z = z_search(i);
                if zef.freesurfer_fa_data(x, y, z) >= fa_thresh
                    seed_point_fa_voxel = [x, y, z];
                    found_valid = true;
                    break;
                end
            end
            if found_valid
                break;
            end
        end
        
        if ~found_valid
            warning(['Seed point is in a region with low FA (%.4f < threshold %.4f). ' ...
                     'Streamlines may not generate properly. Consider adjusting seed point or FA threshold.'], ...
                fa_at_seed, fa_thresh);
        end
    end
    
catch ME
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        catch
        end
    end
    error('Coordinate transformation failed: %s', ME.message);
end

% ========================================================================
% STEP 5: GET STREAMLINE PARAMETERS
% ========================================================================

% Default parameters
roi_radius = 15;
if isfield(zef,'dti_streamline_roi_radius')
    roi_radius = zef.dti_streamline_roi_radius;
    warning('ROI radius set to %f', roi_radius);
end

n_dir = 1000;
if isfield(zef,'dti_streamline_n_dir')
    n_dir = zef.dti_streamline_n_dir;
    warning('Number of directions set to %d', n_dir);
end

step_size = 1.0;
if isfield(zef,'dti_streamline_step_size')
    step_size = zef.dti_streamline_step_size;
    warning('Step size set to %f', step_size);
end

max_steps = 1000;
if isfield(zef,'dti_streamline_max_steps')
    max_steps = zef.dti_streamline_max_steps;
    warning('Max steps set to %d', max_steps);
end

fa_thresh = 0.15;
if isfield(zef,'dti_streamline_fa_thresh')
    fa_thresh = zef.dti_streamline_fa_thresh;
    warning('FA threshold set to %f', fa_thresh);
end

% ========================================================================
% STEP 6: GENERATE STREAMLINES IN FA SPACE
% ========================================================================

if ~isempty(h_waitbar)
    try
        zef_waitbar(0.35, 1, h_waitbar, sprintf('Generating %d streamlines...', n_dir));
        drawnow;
    catch
    end
end

try
    dti_streamlines = zef_dti_streamlines(...
        dti_directions, ...
        dti_anisotropy, ...
        seed_point_fa_voxel, ...
        roi_radius, ...
        n_dir, ...
        step_size, ...
        max_steps, ...
        fa_thresh);
catch ME
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        catch
        end
    end
    error('Streamline generation failed: %s', ME.message);
end

% ========================================================================
% STEP 7: TRANSFORM STREAMLINES FROM FA SPACE TO MESH SPACE
% ========================================================================

if ~isempty(h_waitbar)
    try
        zef_waitbar(0.55, 1, h_waitbar, 'Transforming streamlines to mesh space...');
        drawnow;
    catch
    end
end

% Get transformation matrices once (more efficient than per-streamline extraction)
% Extract matrices (prefer auto-extracted direct fields, fall back to GUI handles)
T_dwi_vox2ras_tkr = extract_vis_matrix(zef, 'dti_dwi_vox2ras_tkr', 'h_dti_dwi_vox2ras_tkr', eye(4));
T_ref_vox2ras = extract_vis_matrix(zef, 'dti_ref_vox2ras', 'h_dti_ref_vox2ras', eye(4));
T_ref_vox2ras_tkr = extract_vis_matrix(zef, 'dti_ref_vox2ras_tkr', 'h_dti_ref_vox2ras_tkr', eye(4));
ref_center = extract_vis_vector(zef, 'dti_ref_center', 'h_dti_ref_center', [0; 0; 0]);

% Transform each streamline from FA voxel space to mesh display space
% Transformation chain (forward, FA_voxel → mesh_display):
% 1. FA_voxel → DWI_tkRAS:     T_dwi_vox2ras_tkr * voxel
% 2. DWI_tkRAS → T1_tkRAS:     inv(T_register) * DWI_tkRAS
% 3. T1_tkRAS → scanner_RAS:   T_ref_vox2ras * inv(T_ref_vox2ras_tkr) * T1_tkRAS
% 4. scanner_RAS → mesh_display: scanner - ref_center
streamlines_mesh_space = cell(size(dti_streamlines));
n_valid = 0;
n_total = length(dti_streamlines);

for k = 1:n_total
    if ~isempty(h_waitbar) && mod(k, max(1, floor(n_total/20))) == 0
        try
            progress = 0.55 + 0.15 * (k / n_total);
            zef_waitbar(progress, 1, h_waitbar, ...
                sprintf('Transforming streamlines to mesh space... (%d/%d)', k, n_total));
            drawnow;
        catch
        end
    end
    
    stream_fa_voxel = dti_streamlines{k};
    if ~isempty(stream_fa_voxel) && size(stream_fa_voxel, 1) > 1
        try
            % Transform each point in the streamline from FA voxel → mesh space
            % T_dwi_vox2ras_tkr uses 0-based voxel (mri_info convention); streamlines are 1-based
            N_points = size(stream_fa_voxel, 1);
            stream_fa_voxel_0based = [stream_fa_voxel(:,1)-1, stream_fa_voxel(:,2)-1, stream_fa_voxel(:,3)-1];
            stream_fa_voxel_homogeneous_0based = [stream_fa_voxel_0based, ones(N_points, 1)];

            % Step 1 and 2: Transform FA_voxel (0-based) → mesh_tkRAS using register_transform
            P = stream_fa_voxel_homogeneous_0based';
            P_t1_tkr = inv(zef.freesurfer_register_transform) * (T_dwi_vox2ras_tkr * P);              % 4xN

            % stream_mesh_homogeneous = (inv(t1_vox2ras) * (zef.freesurfer_register_transform) * stream_fa_tkras_homogeneous')';
            % Step 3: Transform mesh_tkRAS → scanner_space using ref_vox2ras
            P_t1_scanner = T_ref_vox2ras * inv(T_ref_vox2ras_tkr) * P_t1_tkr;
            stream_t1_scanner = (P_t1_scanner)';
            stream_mesh = stream_t1_scanner(:, 1:3);

            % Step 4: Transform scanner_space → mesh_space using ref_center
            stream_mesh = stream_mesh - ref_center.';
            streamlines_mesh_space{k} = stream_mesh;
            n_valid = n_valid + 1;
        catch ME
            streamlines_mesh_space{k} = [];
            warning('Failed to transform streamline %d: %s', k, ME.message);
        end
    else
        streamlines_mesh_space{k} = [];
    end
end

if n_valid == 0
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        catch
        end
    end
    warning('No valid streamlines generated. Check seed point and FreeSurfer data.');
    h_streamlines = [];
    return;
end

% ========================================================================
% STEP 8: PLOT STREAMLINES
% ========================================================================

if ~isempty(h_waitbar)
    try
        zef_waitbar(0.75, 1, h_waitbar, 'Plotting streamlines...');
        drawnow;
    catch
    end
end

% Get current axes
if isfield(zef,'h_axes1') && isvalid(zef.h_axes1)
    h_axes = zef.h_axes1;
else
    h_axes = gca;
end

% Clear existing DTI streamlines if any
h_existing = findobj(h_axes, 'Tag', 'dti_streamlines');
if ~isempty(h_existing)
    delete(h_existing);
end

% Plot parameters
line_width = 1.5;
if isfield(zef,'dti_streamline_linewidth')
    line_width = zef.dti_streamline_linewidth;
end

% Enable direction-based RGB coloring (standard DTI visualization convention)
use_direction_coloring = true;
if isfield(zef,'dti_streamline_direction_coloring')
    use_direction_coloring = zef.dti_streamline_direction_coloring;
end

% Fallback single color (if direction coloring disabled)
line_color = [0.2 0.6 1.0];  % Light blue
if isfield(zef,'dti_streamline_color')
    line_color = zef.dti_streamline_color;
end

line_alpha = 0.8;
if isfield(zef,'dti_streamline_alpha')
    line_alpha = zef.dti_streamline_alpha;
end

% Plot each streamline with direction-based RGB coloring
if ~isempty(h_waitbar)
    try
        zef_waitbar(0.70, 1, h_waitbar, 'Preparing streamline visualization...');
        drawnow;
    catch
    end
end

hold(h_axes, 'on');
h_streamlines = [];
idx = 0;
n_streamlines_total = length(streamlines_mesh_space);

for k = 1:n_streamlines_total
    stream = streamlines_mesh_space{k};
    if ~isempty(stream) && size(stream, 1) > 1
        idx = idx + 1;
        
        % Update progress during plotting
        if ~isempty(h_waitbar) && mod(k, max(1, floor(n_streamlines_total/50))) == 0
            try
                progress = 0.70 + 0.25 * (k / n_streamlines_total);
                zef_waitbar(progress, 1, h_waitbar, ...
                    sprintf('Plotting streamlines with RGB coloring... (%d/%d)', k, n_streamlines_total));
                drawnow limitrate;
            catch
            end
        end
        
        if use_direction_coloring && size(stream, 1) > 1
            % Direction-based RGB coloring: standard DTI visualization convention
            % Red = X direction (left-right), Green = Y direction (anterior-posterior),
            % Blue = Z direction (superior-inferior)
            
            % Compute direction vectors for each segment
            segments = size(stream, 1) - 1;
            
            for seg = 1:segments
                % Direction vector for this segment
                dir_vec = stream(seg+1, :) - stream(seg, :);
                dir_length = norm(dir_vec);
                
                if dir_length > 0
                    % Normalize direction vector to unit length
                    dir_normalized = dir_vec / dir_length;
                    
                    % Map direction to RGB using standard DTI convention
                    rgb = abs(dir_normalized);
                    
                    % Normalize RGB to ensure colors are visible
                    max_component = max(rgb);
                    if max_component > 0
                        rgb = rgb / max_component;
                    else
                        rgb = [0.2 0.6 1.0];
                    end
                    
                    % Ensure RGB values are in valid range [0,1]
                    rgb = max(0, min(1, rgb));
                else
                    % Degenerate segment: use neutral gray
                    rgb = [0.5 0.5 0.5];
                end
                
                % Plot this segment with its direction-based color
                h_seg = plot3(h_axes, ...
                    stream(seg:seg+1, 1), ...
                    stream(seg:seg+1, 2), ...
                    stream(seg:seg+1, 3), ...
                    'LineWidth', line_width, ...
                    'Color', rgb, ...
                    'Tag', 'dti_streamlines');
                
                h_streamlines = [h_streamlines; h_seg];
            end
        else
            % Single color mode
            h_line = plot3(h_axes, ...
                stream(:,1), stream(:,2), stream(:,3), ...
                'LineWidth', line_width, ...
                'Color', line_color, ...
                'Tag', 'dti_streamlines');
            
            % Set transparency if supported
            try
                set(h_line, 'Color', [line_color, line_alpha]);
            catch
            end
            
            h_streamlines = [h_streamlines; h_line];
        end
    end
end

hold(h_axes, 'off');

% Update axes limits if needed
if isfield(zef,'auto_axes_limits') && zef.auto_axes_limits
    axis(h_axes, 'equal');
    axis(h_axes, 'tight');
end

if ~isempty(h_waitbar)
    try
        zef_waitbar(1, 1, h_waitbar, sprintf('Completed! Plotted %d streamlines.', idx));
        drawnow;
        pause(0.5);
        % Properly delete waitbar by clearing DeleteFcn first
        if isvalid(h_waitbar)
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        end
    catch
    end
end

% Store in zef for reference
if nargout == 0
    assignin('base','zef',zef);
end

end

%% -----------------------------------------------------------------------
%  Local helpers for matrix extraction (direct field or GUI handle)
%  -----------------------------------------------------------------------

function T = extract_vis_matrix(zef, direct_field, handle_field, default_val)
%EXTRACT_VIS_MATRIX Extracts a 4×4 matrix from zef, preferring direct fields.
    T = default_val;
    % Priority 1: Direct numeric field (auto-extracted)
    if isfield(zef, direct_field) && ~isempty(zef.(direct_field))
        d = zef.(direct_field);
        if isnumeric(d) && isequal(size(d), [4 4]) && ~isequal(d, eye(4))
            T = double(d);
            return;
        end
    end
    % Priority 2: GUI handle with .Data property (legacy)
    if isfield(zef, handle_field) && ~isempty(zef.(handle_field))
        try
            d = zef.(handle_field).Data;
            if isnumeric(d) && isequal(size(d), [4 4])
                T = double(d);
                return;
            end
        catch
        end
    end
    % Priority 3: Auto-compute from file data
    if strcmp(direct_field, 'dti_dwi_vox2ras_tkr') && isfield(zef, 'freesurfer_fa_info') && ~isempty(zef.freesurfer_fa_info)
        try
            % Prefer file path over niftiinfo struct for mri_info-based extraction
            if isfield(zef, 'freesurfer_fa_file') && ~isempty(zef.freesurfer_fa_file) && isfile(zef.freesurfer_fa_file)
                fa_geom = zef_freesurfer_read_volume_geometry(zef.freesurfer_fa_file);
            else
                fa_geom = zef_freesurfer_read_volume_geometry(zef.freesurfer_fa_info);
            end
            T = fa_geom.vox2ras_tkr;
            return;
        catch
        end
    end
    if isfield(zef, 'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry)
        if strcmp(direct_field, 'dti_ref_vox2ras') && ~isempty(zef.dti_ref_geometry.vox2ras)
            T = zef.dti_ref_geometry.vox2ras;
        elseif strcmp(direct_field, 'dti_ref_vox2ras_tkr') && ~isempty(zef.dti_ref_geometry.vox2ras_tkr)
            T = zef.dti_ref_geometry.vox2ras_tkr;
        end
    end
end

function v = extract_vis_vector(zef, direct_field, handle_field, default_val)
%EXTRACT_VIS_VECTOR Extracts a 3×1 vector from zef, preferring direct fields.
    v = default_val;
    if isfield(zef, direct_field) && ~isempty(zef.(direct_field))
        d = zef.(direct_field);
        if isnumeric(d) && numel(d) == 3 && any(d(:) ~= 0)
            v = double(d(:));
            return;
        end
    end
    if isfield(zef, handle_field) && ~isempty(zef.(handle_field))
        try
            d = zef.(handle_field).Data;
            if isnumeric(d) && numel(d) == 3
                v = double(d(:));
                return;
            end
        catch
        end
    end
    if isfield(zef, 'dti_ref_geometry') && ~isempty(zef.dti_ref_geometry) && strcmp(direct_field, 'dti_ref_center')
        if ~isempty(zef.dti_ref_geometry.center_ras)
            v = double(zef.dti_ref_geometry.center_ras(:));
        end
    end
end

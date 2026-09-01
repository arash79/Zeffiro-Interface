function Q_tract = zef_dti_tractography_covariance(zef, source_positions, varargin)
%ZEF_DTI_TRACTOGRAPHY_COVARIANCE  Source covariance from deterministic v1 streamlines.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Q_tract = zef_dti_tractography_covariance(zef, source_positions)
%   Q_tract = zef_dti_tractography_covariance(..., Name, Value, ...)
%
%   Called from zef_dti_structural_Q(..., 'tractography') on the legacy
%   Kalman plugin path only (not inverse.KalmanInverter). Maps sources with
%   zef_dti_get_mesh2voxel, traces bidirectional v1 streamlines from seeds
%   with FA above threshold, and sets C(i,j) from co-traversal counts.
%   Name-values: fa_threshold (0.15), step_size (0.5 voxels), max_steps
%   (500), proximity_radius (3 voxels), normalize (true).
%
%   See also zef_dti_fa_covariance, zef_dti_interpolate_to_sources,
%   zef_dti_streamlines, zef_dti_get_mesh2voxel.

p = inputParser;
addRequired(p, 'zef');
addRequired(p, 'source_positions', @(x) isnumeric(x) && size(x,2)==3);
addParameter(p, 'fa_threshold', 0.15, @(x) isscalar(x) && x >= 0);
addParameter(p, 'step_size', 0.5, @(x) isscalar(x) && x > 0);
addParameter(p, 'max_steps', 500, @(x) isscalar(x) && x >= 1);
addParameter(p, 'proximity_radius', 3.0, @(x) isscalar(x) && x > 0);
addParameter(p, 'normalize', true, @(x) islogical(x) || isscalar(x));
parse(p, zef, source_positions, varargin{:});

fa_thresh = p.Results.fa_threshold;
step_size = p.Results.step_size;
max_steps = round(p.Results.max_steps);
prox_radius = p.Results.proximity_radius;
do_normalize = logical(p.Results.normalize);

% ========================================================================
% VALIDATE DTI DATA
% ========================================================================

if ~isfield(zef, 'freesurfer_fa_data') || isempty(zef.freesurfer_fa_data)
    error('zef_dti_tractography_covariance:noFA', ...
        'FreeSurfer FA data not loaded.');
end
if ~isfield(zef, 'freesurfer_v1_data') || isempty(zef.freesurfer_v1_data)
    error('zef_dti_tractography_covariance:noV1', ...
        'FreeSurfer v1 (principal eigenvector) data required for tractography.');
end

fa_data = double(zef.freesurfer_fa_data);
v1_data = double(zef.freesurfer_v1_data);
[nx, ny, nz] = size(fa_data);
N = size(source_positions, 1);

% ========================================================================
% TRANSFORM SOURCE POSITIONS TO FA VOXEL SPACE (1-based)
% ========================================================================

T_mesh2voxel = zef_dti_get_mesh2voxel(zef);
pts_mesh = [source_positions, ones(N, 1)];
pts_vox_0 = (T_mesh2voxel * pts_mesh')';
pts_vox = pts_vox_0(:, 1:3) + 1;  % 0-based → 1-based MATLAB indexing

% ========================================================================
% BUILD KD-TREE OF SOURCES IN VOXEL SPACE
% ========================================================================

KDT_sources = KDTreeSearcher(pts_vox);

% ========================================================================
% GET FA AT EACH SOURCE POSITION
% ========================================================================

gx = double(1:nx); gy = double(1:ny); gz = double(1:nz);
F_fa = griddedInterpolant({gx, gy, gz}, fa_data, 'linear', 'nearest');
fa_at_sources = F_fa(pts_vox(:,1), pts_vox(:,2), pts_vox(:,3));

% ========================================================================
% PHASE 1: TRACE ALL STREAMLINES — store points with origin labels
% ========================================================================

seed_mask = fa_at_sources >= fa_thresh;
seed_indices = find(seed_mask);
n_seeds = length(seed_indices);

fprintf('  Tractography covariance: %d/%d sources above FA=%.2f threshold\n', ...
    n_seeds, N, fa_thresh);

if n_seeds == 0
    warning('zef_dti_tractography_covariance:noSeeds', ...
        'No sources above FA threshold. Returning identity matrix.');
    Q_tract = speye(N);
    return;
end

% Preallocate storage for all streamline points
% Generous estimate: n_seeds × 2 directions × max_steps points
est_total_points = n_seeds * 2 * max_steps;
all_points = zeros(est_total_points, 3);   % Voxel coordinates
all_stream_id = zeros(est_total_points, 1); % Which streamline
pt_count = 0;

h_wb = [];
try h_wb = zef_waitbar(0, 1, 'Tractography covariance: tracing streamlines...'); catch, end

for si = 1:n_seeds
    src_idx = seed_indices(si);
    seed = pts_vox(src_idx, :);

    % Trace bidirectional streamline (forward = +1, backward = -1)
    for direction = [1, -1]
        pos = seed;
        prev_dir = [0, 0, 0];

        for step = 1:max_steps
            ix = round(pos(1));
            iy = round(pos(2));
            iz = round(pos(3));

            % Bounds check (1-based)
            if ix < 1 || ix > nx || iy < 1 || iy > ny || iz < 1 || iz > nz
                break;
            end

            % FA threshold check
            if fa_data(ix, iy, iz) < fa_thresh
                break;
            end

            % Get principal direction at this voxel
            v = squeeze(v1_data(ix, iy, iz, :))';
            v_norm = norm(v);
            if v_norm < 1e-10
                break;
            end
            v = v / v_norm;

            % Direction consistency
            if step == 1 && all(prev_dir == 0)
                v = direction * v;
            elseif dot(v, prev_dir) < 0
                v = -v;
            end
            prev_dir = v;

            % Store this point
            pt_count = pt_count + 1;
            if pt_count > size(all_points, 1)
                % Grow arrays if needed
                all_points = [all_points; zeros(est_total_points, 3)]; %#ok<AGROW>
                all_stream_id = [all_stream_id; zeros(est_total_points, 1)]; %#ok<AGROW>
            end
            all_points(pt_count, :) = pos;
            all_stream_id(pt_count) = si;  % Streamline ID = seed index

            % Step forward
            pos = pos + step_size * v;
        end
    end

    % Update progress
    if ~isempty(h_wb) && isvalid(h_wb) && mod(si, max(1, floor(n_seeds/50))) == 0
        try zef_waitbar(0.5*si/n_seeds, 1, h_wb, ...
            sprintf('Tracing streamlines... %d/%d seeds', si, n_seeds)); catch, end
    end
end

% Trim to actual size
all_points = all_points(1:pt_count, :);
all_stream_id = all_stream_id(1:pt_count);

fprintf('  Traced %d total streamline points from %d seeds\n', pt_count, n_seeds);

% ========================================================================
% PHASE 2: BATCH KNN — find nearest source for each streamline point
% ========================================================================

if ~isempty(h_wb) && isvalid(h_wb)
    try zef_waitbar(0.55, 1, h_wb, 'Finding nearest sources...'); catch, end
end

[nearest_src, nearest_dist] = knnsearch(KDT_sources, all_points, 'K', 1);

% Filter: only keep points close enough to a source
close_mask = nearest_dist <= prox_radius;
stream_ids_close = all_stream_id(close_mask);
source_ids_close = nearest_src(close_mask);

fprintf('  %d/%d points within proximity radius (%.1f voxels)\n', ...
    sum(close_mask), pt_count, prox_radius);

% ========================================================================
% PHASE 3: BUILD CONNECTIVITY MATRIX from streamline co-traversal
% ========================================================================

if ~isempty(h_wb) && isvalid(h_wb)
    try zef_waitbar(0.70, 1, h_wb, 'Building connectivity matrix...'); catch, end
end

% Group visited sources by streamline ID
unique_streams = unique(stream_ids_close);
n_unique = length(unique_streams);

% Preallocate connectivity triplets
C_rows = [];
C_cols = [];
C_vals = [];

for us = 1:n_unique
    stream_id = unique_streams(us);
    visited = unique(source_ids_close(stream_ids_close == stream_id));
    n_vis = length(visited);

    if n_vis > 1
        % All pairs of visited sources are structurally connected
        % Generate all pairs using meshgrid
        [ii, jj] = meshgrid(visited, visited);
        mask = ii(:) ~= jj(:);  % Exclude self-connections (added separately)

        C_rows = [C_rows; ii(mask)]; %#ok<AGROW>
        C_cols = [C_cols; jj(mask)]; %#ok<AGROW>
        C_vals = [C_vals; ones(sum(mask), 1)]; %#ok<AGROW>
    end

    % Progress
    if ~isempty(h_wb) && isvalid(h_wb) && mod(us, max(1, floor(n_unique/20))) == 0
        try zef_waitbar(0.70 + 0.20*us/n_unique, 1, h_wb, ...
            sprintf('Building connectivity... %d/%d streamlines', us, n_unique)); catch, end
    end
end

% Assemble sparse matrix (accumulates duplicate entries automatically)
if ~isempty(C_rows)
    C = sparse(C_rows, C_cols, C_vals, N, N);
else
    C = sparse(N, N);
end

% Add identity (self-connections)
C = C + speye(N);

n_connections = nnz(C) - N;  % Exclude diagonal
fprintf('  Connectivity matrix: %d non-zero off-diagonal entries (%.2f%% density)\n', ...
    n_connections, 100*n_connections/(N*(N-1)));

% ========================================================================
% PHASE 4: NORMALIZE
% ========================================================================

if ~isempty(h_wb) && isvalid(h_wb)
    try zef_waitbar(0.95, 1, h_wb, 'Normalizing...'); catch, end
end

if do_normalize
    % Normalize to correlation-like matrix (unit diagonal)
    d_sqrt = sqrt(full(diag(C)));
    d_sqrt(d_sqrt == 0) = 1;
    D_inv = spdiags(1./d_sqrt, 0, N, N);
    Q_tract = D_inv * C * D_inv;
else
    Q_tract = C;
end

if ~isempty(h_wb) && isvalid(h_wb)
    try
        zef_waitbar(1, 1, h_wb, 'Tractography covariance complete.');
        pause(0.3);
        zef_close_waitbar(h_wb);
    catch, end
end

end

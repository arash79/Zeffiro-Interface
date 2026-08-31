function Q_fa = zef_dti_fa_covariance(source_positions, fa_sources, v1_sources, varargin)
%ZEF_DTI_FA_COVARIANCE  Sparse FA-weighted spatial covariance on source positions.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Q_fa = zef_dti_fa_covariance(source_positions, fa_sources, v1_sources)
%   Q_fa = zef_dti_fa_covariance(..., Name, Value, ...)
%
%   Called from zef_dti_structural_Q(..., 'fa') on the legacy Kalman
%   plugin path only (not inverse.KalmanInverter).
%     C(i,j) = FA_i FA_j exp(-d_ij^2 / (2 sigma^2)) * dir_weight(i,j)
%   with optional v1 directional weight
%     |v1_i·r̂_ij| |v1_j·r̂_ij| |v1_i·v1_j|
%   and k-NN sparsity. Name-values: length_scale (mm, 10), k_neighbors (50),
%   use_direction (default true if v1 given), normalize (true).
%
%   See also zef_dti_interpolate_to_sources, zef_dti_tractography_covariance,
%   zef_dti_structural_Q.

p = inputParser;
addRequired(p, 'source_positions', @(x) isnumeric(x) && size(x,2)==3);
addRequired(p, 'fa_sources', @(x) isnumeric(x) && isvector(x));
addRequired(p, 'v1_sources');
addParameter(p, 'length_scale', 10, @(x) isscalar(x) && x > 0);
addParameter(p, 'k_neighbors', 50, @(x) isscalar(x) && x >= 1);
addParameter(p, 'use_direction', [], @(x) isempty(x) || islogical(x) || isscalar(x));
addParameter(p, 'normalize', true, @(x) islogical(x) || isscalar(x));
parse(p, source_positions, fa_sources, v1_sources, varargin{:});

length_scale = p.Results.length_scale;
do_normalize = logical(p.Results.normalize);
use_dir = p.Results.use_direction;

N = size(source_positions, 1);
K = min(p.Results.k_neighbors, N);
fa_sources = fa_sources(:);

% Default: use directional weighting if v1 is available
if isempty(use_dir)
    use_dir = ~isempty(v1_sources) && size(v1_sources, 1) == N;
end

% ========================================================================
% BUILD K-NEAREST NEIGHBOR GRAPH
% ========================================================================

MdlKDT = KDTreeSearcher(source_positions);
[IDX, D] = knnsearch(MdlKDT, source_positions, 'K', K);

% ========================================================================
% COMPUTE COVARIANCE ENTRIES
% ========================================================================

% Preallocate sparse matrix triplets
rows = repmat((1:N)', 1, K);   % [N×K]
cols = IDX;                      % [N×K]
vals = zeros(N, K);

for kk = 1:K
    d_ij = D(:, kk);  % Euclidean distances to k-th neighbor

    % Spatial Gaussian kernel
    spatial_weight = exp(-d_ij.^2 / (2 * length_scale^2));

    % FA weighting: product of FA at both endpoints
    % High-FA source pairs get stronger coupling
    fa_weight = fa_sources .* fa_sources(IDX(:, kk));

    % Directional weighting (optional)
    if use_dir && ~isempty(v1_sources) && size(v1_sources, 1) == N
        % Unit direction from source i to neighbor j
        r_ij = source_positions(IDX(:, kk), :) - source_positions;
        r_norm = sqrt(sum(r_ij.^2, 2));
        r_norm(r_norm < 1e-12) = 1;
        r_ij = r_ij ./ r_norm;

        % |cos(angle between v1_i and separation direction)|
        % High when source i's fiber points toward neighbor j
        cos_v1i_rij = abs(sum(v1_sources .* r_ij, 2));

        % |cos(angle between v1_j and separation direction)|
        % High when neighbor j's fiber points toward source i
        cos_v1j_rij = abs(sum(v1_sources(IDX(:, kk), :) .* r_ij, 2));

        % |cos(angle between v1_i and v1_j)| — fiber parallelism
        % High when both sources have aligned fiber directions
        cos_v1i_v1j = abs(sum(v1_sources .* v1_sources(IDX(:, kk), :), 2));

        dir_weight = cos_v1i_rij .* cos_v1j_rij .* cos_v1i_v1j;

        % Self-connections (distance ≈ 0): directional weight = 1
        self_mask = d_ij < 1e-10;
        dir_weight(self_mask) = 1;
    else
        dir_weight = ones(N, 1);
    end

    vals(:, kk) = fa_weight .* spatial_weight .* dir_weight;
end

% ========================================================================
% ASSEMBLE SPARSE MATRIX
% ========================================================================

Q_fa = sparse(rows(:), cols(:), vals(:), N, N);

% Symmetrize: k-NN graph is generally not symmetric
% (i may be a neighbor of j but j may not be a neighbor of i)
Q_fa = (Q_fa + Q_fa') / 2;

% Ensure positive diagonal (needed for PSD and normalization)
d_diag = full(diag(Q_fa));
d_diag(d_diag < 1e-12) = 1e-12;
Q_fa = Q_fa - spdiags(diag(Q_fa), 0, N, N) + spdiags(d_diag, 0, N, N);

% ========================================================================
% NORMALIZE TO CORRELATION MATRIX (unit diagonal)
% ========================================================================

if do_normalize
    d_sqrt = sqrt(full(diag(Q_fa)));
    d_sqrt(d_sqrt == 0) = 1;
    D_inv = spdiags(1./d_sqrt, 0, N, N);
    Q_fa = D_inv * Q_fa * D_inv;
end

end

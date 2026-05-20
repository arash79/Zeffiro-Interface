function metrics = compute_metrics(z, source_positions, source_indices, diff_type, dispersion_radius, opts)
%COMPUTE_METRICS Position / direction / magnitude / dispersion metrics.
%
%   metrics = compute_metrics(z, source_positions, source_indices, ...
%                             diff_type, dispersion_radius)
%   metrics = compute_metrics(z, source_positions, source_indices, ...
%                             diff_type, dispersion_radius, ...
%                             "SourceDirectionMode", mode, ...
%                             "SourceDirections",    Q, ...
%                             "ProbesPerSource",     p)
%
% Strict re-implementation of the per-(i, j) metric loop and per-element
% rangesearch in +examples/+studies/+santtus_peeling_article/zef_rec_diff.m,
% with two structural changes that do not alter the formulas:
%   1. The dispersion stage builds the KD-tree once and resolves all queries
%      with a single multi-query rangesearch instead of one rangesearch per
%      reconstruction (which rebuilt the tree every call in the legacy code).
%   2. Per-cell reshape, max, and normalisation are kept in a tight loop;
%      the BLAS calls inside dominate per-iteration cost and the loop
%      overhead is small relative to the inverse stage.
%
% When source_indices = 1:size(source_positions, 1) and SourceDirectionMode
% is 1 or 2 (the only mode the legacy zef_rec_diff supported), the output
% vectors match the legacy ones element-for-element. For mode 3 the layout
% degenerates to one probe per source along the source's intrinsic
% direction, and the metrics are computed accordingly.
%
% Inputs:
%   z                  Cell array of length probes_per_source * numel(source_indices).
%                      probes_per_source is 3 for modes 1/2 and 1 for mode 3.
%                      Cell k holds the reconstructed dipole-vector for one
%                      synthetic probe; cells may be shorter than 3 * n_full
%                      (the class-based inverter only writes into active
%                      source positions) and are zero-padded.
%   source_positions   n_full x 3 matrix of every mesh source position.
%                      The reconstruction can land on any of these, so this
%                      is also the search pool for dispersion.
%   source_indices     Column vector of 1-based indices into source_positions
%                      that were probed. Defaults to (1:n_full)'.
%   diff_type          "L2" or "minabs". Position-difference metric.
%   dispersion_radius  Radius (mm) for the dispersion ROI.
%   opts.SourceDirectionMode 1 | 2 | 3 (default 1).
%   opts.SourceDirections    n_full x 3, required when mode == 3 (intrinsic
%                            direction per mesh source).
%
% Output (struct):
%   dist_vec       (n_rec x 1) Position error per reconstruction.
%   angle_vec      (n_rec x 1) Direction error in degrees.
%   mag_vec        (n_rec x 1) Reconstructed peak magnitude / sqrt(3).
%   dispersion_vec (n_rec x 1) Weighted spatial spread.
%   max_ind_vec    (n_rec x 1) Peak source-position index per
%                  reconstruction (into source_positions, range 1:n_full).

arguments
    z (1,:) cell
    source_positions (:,3) double
    source_indices (:,1) double {mustBeInteger, mustBePositive} = ...
        (1 : size(source_positions, 1)).'
    diff_type (1,1) string {mustBeMember(diff_type, ["L2", "minabs"])} = "L2"
    dispersion_radius (1,1) double {mustBePositive} = 30
    opts.SourceDirectionMode (1,1) double {mustBeMember(opts.SourceDirectionMode,[1,2,3])} = 1
    opts.SourceDirections double = []
end

n_full = size(source_positions, 1);
if any(source_indices > n_full)
    error("utilities.sensitivity:compute_metrics:IndexOutOfRange", ...
        "source_indices contains values exceeding size(source_positions, 1) = %d.", n_full);
end

mode = opts.SourceDirectionMode;
if mode == 3
    if isempty(opts.SourceDirections)
        error("utilities.sensitivity:compute_metrics:MissingSourceDirections", ...
            "source_direction_mode = 3 requires opts.SourceDirections (n_full x 3) so per-probe directions can be evaluated.");
    end
    if size(opts.SourceDirections, 1) ~= n_full || size(opts.SourceDirections, 2) ~= 3
        error("utilities.sensitivity:compute_metrics:DirectionsShapeMismatch", ...
            "opts.SourceDirections must be %d x 3 to match source_positions.", n_full);
    end
    probes_per_source = 1;
else
    probes_per_source = 3;
end

n_used = numel(source_indices);
n_rec = probes_per_source * n_used;
n_full_cols = 3 * n_full;

if numel(z) ~= n_rec
    error("utilities.sensitivity:compute_metrics:LengthMismatch", ...
        "Expected numel(z) = %d (probes_per_source * numel(source_indices)) but got %d.", ...
        n_rec, numel(z));
end

dist_vec       = zeros(n_rec, 1);
angle_vec      = zeros(n_rec, 1);
mag_vec        = zeros(n_rec, 1);
dispersion_vec = zeros(n_rec, 1);
max_ind_vec    = zeros(n_rec, 1);

inv_sqrt3 = 1 / sqrt(3);
dir_mat = eye(3);

for k = 1:n_rec
    if probes_per_source == 3
        dir_k = mod(k - 1, 3) + 1;
        src_k = (k - dir_k) / 3 + 1;
        probe_dir = dir_mat(:, dir_k);
    else
        src_k = k;
        probe_dir = opts.SourceDirections(source_indices(src_k), :).';
        probe_dir = probe_dir / max(norm(probe_dir, 2), eps);
    end
    src_pos_idx = source_indices(src_k);

    z_k = z{k};
    if isempty(z_k)
        z_k = zeros(n_full_cols, 1);
    elseif numel(z_k) < n_full_cols
        z_pad = zeros(n_full_cols, 1);
        z_pad(1:numel(z_k)) = z_k(:);
        z_k = z_pad;
    else
        z_k = z_k(:);
    end

    W_k = reshape(z_k(1:n_full_cols), 3, n_full);
    z_norm = sqrt(sum(W_k.^2, 1));
    [mag_val, I] = max(z_norm);

    max_ind_vec(k) = I;
    mag_vec(k)     = inv_sqrt3 * mag_val;

    dir_vec_rec = W_k(:, I);
    rec_norm = norm(dir_vec_rec, 2);
    if rec_norm > 0
        dir_vec_rec = dir_vec_rec / rec_norm;
    end

    pos_diffs = source_positions(src_pos_idx, :) - source_positions(I, :);
    if diff_type == "L2"
        dist_vec(k) = inv_sqrt3 * sqrt(sum(pos_diffs.^2, 2));
    else
        dist_vec(k) = inv_sqrt3 * min(abs(pos_diffs), [], 2);
    end

    angle_vec(k) = acosd(max(min(dot(dir_vec_rec, probe_dir), 1), -1));
end

% --- Dispersion (single KD-tree build, single multi-query rangesearch). ---
%
% Match the legacy semantics (zef_rec_diff): the search pool is every probed
% source position repeated probes_per_source times so that within_roi_inds
% can be used to look up mag_vec entries directly. With source_indices ==
% 1:n_full and probes_per_source = 3 this reproduces the legacy pool
% exactly. With a strict subset or with mode 3, the pool is restricted to
% the probed positions so the within-ROI lookups stay well-defined for the
% n_rec-long mag_vec.

probed_positions   = source_positions(source_indices, :);
repeated_positions = repelem(probed_positions, probes_per_source, 1);
query_positions    = source_positions(max_ind_vec, :);
within_inds_cells  = rangesearch(repeated_positions, query_positions, dispersion_radius);

mag_sqr = mag_vec.^2;

for k = 1:n_rec
    inds = within_inds_cells{k};
    if isempty(inds)
        dispersion_vec(k) = 0;
        continue;
    end
    inds = inds(:);
    diffs   = repeated_positions(inds, :) - query_positions(k, :);
    sq_dist = sum(diffs.^2, 2);
    sq_mag  = mag_sqr(inds);
    dispersion_vec(k) = sqrt(sum(sq_dist .* sq_mag) / max(sum(sq_mag), eps));
end

metrics = struct( ...
    "dist_vec",       dist_vec, ...
    "angle_vec",      angle_vec, ...
    "mag_vec",        mag_vec, ...
    "dispersion_vec", dispersion_vec, ...
    "max_ind_vec",    max_ind_vec);

end

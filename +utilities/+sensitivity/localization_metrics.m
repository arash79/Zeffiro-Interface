function m = localization_metrics(z, source_positions, true_source, opts)
%LOCALIZATION_METRICS  Source-localization accuracy of one reconstruction.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Scores a reconstruction against a known (synthetic) source. This is
%   the single-run counterpart of compute_metrics (which scores per-probe
%   Monte Carlo batches): the reconstruction peak defines the estimated
%   position and orientation, and three optional accuracy metrics are
%   reported:
%
%     distance_mm   - Euclidean distance between the reconstruction peak
%                     position and the true source position (mm). Unlike
%                     the legacy probe metrics in compute_metrics, no
%                     1/sqrt(3) scale factor is applied; this is the plain
%                     geometric distance.
%     angular_deviation_deg
%                  - Angle in [0, 180] between the unit peak dipole vector
%                    and the unit true dipole orientation (same definition
%                    as the legacy zef_rec_diff / compute_metrics angle).
%                    NaN when no true orientation is available or the
%                    peak vector is degenerate.
%     angular_deviation_symmetrized_deg
%                  - min(theta, 180 - theta) in [0, 90]. Under dipole sign
%                    equivalence p == -p a globally flipped reconstruction
%                    is not an orientation error; use this variant then.
%     dispersion_mm - Magnitude-squared weighted RMS distance of the
%                     reconstruction from its own peak, over source nodes
%                     within opts.DispersionRadius of the peak position
%                     (same dispersion definition as compute_metrics).
%
%   With several true sources the peak is scored against the nearest one;
%   the matched row index is reported as true_index. Matching one peak to
%   a joint multi-source ground truth is out of scope.
%
%   m = localization_metrics(z, source_positions, true_source)
%   m = localization_metrics(z, source_positions, true_source, Name, Value)
%
%   Inputs
%     z                - Reconstruction. Numeric 3n-by-1 (interleaved x,y,z
%                        per source, any source_direction_mode after
%                        zef_postProcessInverseClassObj) or a cell array of
%                        such vectors, one per time frame.
%     source_positions - n-by-3 source node coordinates in mm, the same
%                        rows zef.source_positions has.
%     true_source      - Ground truth. N-by-(>=6) matrix whose columns are
%                        [x y z nx ny nz ...] (the zef.inv_synth_source
%                        layout; columns beyond 6 are ignored) or a struct
%                        with fields position (N-by-3) and optional
%                        direction (N-by-3).
%
%   Name-value options
%     DispersionRadius - Positive radius in mm. Default 30.
%
%   Output
%     m - Struct with:
%         per_frame     Struct array, one entry per frame (single entry
%                       when z is numeric). Each entry has valid (logical),
%                       distance_mm, angular_deviation_deg,
%                       angular_deviation_symmetrized_deg, dispersion_mm,
%                       peak_index, peak_position, peak_magnitude,
%                       true_index, message ('' when valid).
%         summary       Struct with n_frames, mean_distance_mm,
%                       max_distance_mm, mean_dispersion_mm, best_frame
%                       (frame with the smallest distance), and
%                       all_valid (logical).
%
%   Failure
%     Errors with identifier utilities:sensitivity:localization_metrics:*
%     when the shapes are inconsistent or the ground truth is empty.
%     Degenerate frames (all-zero reconstruction) are NOT errors: the
%     entry is returned with valid=false, NaN metrics, and a message.
%
%   See also compute_metrics, zef_inverse_run, zef_postProcessInverseClassObj.

arguments
    z
    source_positions (:, 3) double {mustBeReal}
    true_source
    opts.DispersionRadius (1, 1) double {mustBePositive} = 30
end

[true_pos, true_dir] = local_parse_true_source(true_source);
[n_sources, ~] = size(source_positions);
n_cols = 3 * n_sources;

frames = {};
if iscell(z)
    frames = z(:);
elseif isnumeric(z)
    frames = {z(:)};
else
    error("utilities:sensitivity:localization_metrics:BadZ", ...
        "z must be a numeric 3n-by-1 vector or a cell array of them.");
end
n_frames = numel(frames);
if n_frames < 1
    error("utilities:sensitivity:localization_metrics:EmptyZ", ...
        "z contains no frames.");
end

per_frame = repmat(local_empty_frame(), n_frames, 1);
for f = 1:n_frames
    per_frame(f) = local_score_frame(frames{f}, n_cols, ...
        source_positions, true_pos, true_dir, opts.DispersionRadius);
end

dist = [per_frame.distance_mm];
disp_ = [per_frame.dispersion_mm];
valid = [per_frame.valid];

m = struct();
m.per_frame = per_frame;
m.summary = struct( ...
    "n_frames", n_frames, ...
    "mean_distance_mm", mean(dist), ...
    "max_distance_mm", max(dist), ...
    "mean_dispersion_mm", mean(disp_), ...
    "all_valid", all(valid), ...
    "best_frame", local_best_frame(dist, valid) ...
);

end

function f = local_empty_frame()

f = struct( ...
    "valid", false, ...
    "distance_mm", NaN, ...
    "angular_deviation_deg", NaN, ...
    "angular_deviation_symmetrized_deg", NaN, ...
    "dispersion_mm", NaN, ...
    "peak_index", NaN, ...
    "peak_position", [NaN NaN NaN], ...
    "peak_magnitude", NaN, ...
    "true_index", NaN, ...
    "message", "" ...
);

end

function idx = local_best_frame(dist, valid)

idx = NaN;
if any(valid)
    dist(~valid) = Inf;
    [~, idx] = min(dist);
end

end

function [pos, dir_] = local_parse_true_source(true_source)

if isstruct(true_source)
    if ~isfield(true_source, 'position') || isempty(true_source.position)
        error("utilities:sensitivity:localization_metrics:MissingTrueSource", ...
            "true_source struct needs a nonempty position (N-by-3, mm).");
    end
    pos = double(true_source.position);
    if isfield(true_source, 'direction') && ~isempty(true_source.direction)
        dir_ = double(true_source.direction);
    else
        dir_ = zeros(0, 3);
    end
else
    ts = double(true_source);
    if isempty(ts)
        error("utilities:sensitivity:localization_metrics:MissingTrueSource", ...
            "true_source is empty; localization metrics need ground truth.");
    end
    if size(ts, 2) < 6
        error("utilities:sensitivity:localization_metrics:BadTrueSource", ...
            "true_source must have at least 6 columns [x y z nx ny nz].");
    end
    pos = ts(:, 1:3);
    dir_ = ts(:, 4:6);
end
if size(pos, 1) < 1 || size(pos, 2) ~= 3
    error("utilities:sensitivity:localization_metrics:BadTrueSource", ...
        "true_source position must be N-by-3.");
end
n_true = size(pos, 1);
if isempty(dir_)
    dir_ = zeros(n_true, 3);
else
    if size(dir_, 1) < n_true
        pad = zeros(n_true - size(dir_, 1), size(dir_, 2));
        dir_ = [dir_; pad];
    end
    dir_ = dir_(1:n_true, :);
end

end

function f = local_score_frame(z_vec, n_cols, source_positions, ...
    true_pos, true_dir, radius)

f = local_empty_frame();

if isempty(z_vec)
    f.message = "Reconstruction frame is empty.";
    return
end
z_vec = double(z_vec(:));
if numel(z_vec) < n_cols
    padded = zeros(n_cols, 1);
    padded(1:numel(z_vec)) = z_vec;
    z_vec = padded;
elseif numel(z_vec) > n_cols
    error("utilities:sensitivity:localization_metrics:SizeMismatch", ...
        "Reconstruction has %d entries but 3 * size(source_positions,1) is %d.", ...
        numel(z_vec), n_cols);
end

W = reshape(z_vec, 3, []);
n_nodes = size(W, 2);
if n_nodes ~= size(source_positions, 1)
    error("utilities:sensitivity:localization_metrics:SizeMismatch", ...
        "Reconstruction has %d source nodes but source_positions has %d rows.", ...
        n_nodes, size(source_positions, 1));
end

magnitudes = sqrt(sum(W.^2, 1));
[peak_magnitude, peak_index] = max(magnitudes);
f.peak_magnitude = peak_magnitude;
f.peak_index = peak_index;
f.peak_position = source_positions(peak_index, :);

if ~isfinite(peak_magnitude) || peak_magnitude <= 0
    f.message = "Reconstruction is degenerate (no positive peak).";
    return
end

% Nearest true source to the peak position.
d_true = sqrt(sum((true_pos - f.peak_position).^2, 2));
[~, true_index] = min(d_true);
f.true_index = true_index;
f.distance_mm = d_true(true_index);

% Orientation error against the matched true source orientation.
v = W(:, peak_index);
v = v / max(norm(v), eps);
d_hat = true_dir(true_index, :).';
n_d = norm(d_hat);
if n_d > 0
    d_hat = d_hat / n_d;
    cosang = max(min(dot(v, d_hat), 1), -1);
    theta = acosd(cosang);
    f.angular_deviation_deg = theta;
    f.angular_deviation_symmetrized_deg = min(theta, 180 - theta);
end

% Dispersion: magnitude^2 weighted RMS distance around the peak, over
% nodes within radius of the peak position (compute_metrics definition).
rel = source_positions - f.peak_position;
node_dist2 = sum(rel.^2, 2);
within = node_dist2 <= radius^2;
w = magnitudes(:).^2;
den = sum(w(within));
if den > 0
    f.dispersion_mm = sqrt(sum(node_dist2(within) .* w(within)) / den);
else
    f.dispersion_mm = 0;
end

f.valid = true;

end

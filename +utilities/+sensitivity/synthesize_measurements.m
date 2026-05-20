function F = synthesize_measurements(L, source_indices, amp, noise_db, opts)
%SYNTHESIZE_MEASUREMENTS Build sensitivity-study synthetic measurements.
%
%   F = synthesize_measurements(L, source_indices, amp, noise_db)
%   F = synthesize_measurements(L, source_indices, amp, noise_db, ...
%                               "SourceDirectionMode", mode, ...
%                               "SourceDirections",    Q)
%
% Replacement for the per-position / per-direction loop in
% +examples/+studies/+santtus_peeling_article/zef_rec_diff.m, which calls
% zef_find_source_legacy(zef) once per (source, direction) pair. With a
% unit Cartesian direction the per-call work collapses to scaling a single
% column of the lead field by 1e-3 * amp, so the entire stage becomes a
% single column-indexing expression for modes 1 and 2 and a single
% direction-weighted sum of three columns per source for mode 3.
%
% Input L is always the raw zef.L: an n_ch x (3 * n_sources_total) matrix
% laid out as (x_1, y_1, z_1, x_2, y_2, z_2, ...). The inverter receives a
% downstream copy that may be reordered or collapsed to one column per
% source for mode 3; this function reproduces that collapse internally so
% the synthetic source matches what the inverter expects to recover.
%
% Inputs:
%   L                Lead field. n_ch x (3 * n_sources_total).
%   source_indices   Optional column vector of 1-based source indices.
%                    Defaults to every source in L.
%   amp              Source amplitude (matches zef.inv_synth_source(7);
%                    zef_rec_diff hard-codes 10).
%   noise_db         Additive Gaussian noise level (dB, <= 0). When 0 the
%                    output is noise-free.
%   opts.SourceDirectionMode  1 | 2 | 3 (default 1).
%   opts.SourceDirections     Required when SourceDirectionMode == 3:
%                             n_sources_total x 3 matrix giving the unit
%                             direction of every source. Each output column
%                             collapses the 3 lead-field columns of one
%                             source via this direction so probes match
%                             what the mode-3 inverter operates on.
%
% Output:
%   F                Measurement matrix.
%                    - modes 1 and 2: n_ch x (3 * numel(source_indices));
%                      column 3*(k-1)+j (j = 1..3) holds the EEG of a unit
%                      Cartesian dipole along axis j placed at
%                      source_indices(k).
%                    - mode 3:        n_ch x numel(source_indices);
%                      column k holds the EEG of a unit dipole along the
%                      intrinsic direction of source_indices(k).
%                    Compute_metrics adapts to either layout.

arguments
    L (:,:) {mustBeA(L, ["double", "gpuArray"])}
    source_indices (:,1) double {mustBeInteger, mustBePositive} = double.empty(0, 1)
    amp (1,1) double = 10
    noise_db (1,1) double {mustBeNonpositive} = 0
    opts.SourceDirectionMode (1,1) double {mustBeMember(opts.SourceDirectionMode,[1,2,3])} = 1
    opts.SourceDirections double = []
end

n_cols = size(L, 2);
if mod(n_cols, 3) ~= 0
    error("utilities.sensitivity:synthesize_measurements:BadLeadFieldShape", ...
        "Lead field has %d columns; expected a multiple of 3 (3 columns per source in zef.L layout).", n_cols);
end
n_sources_total = n_cols / 3;

if isempty(source_indices)
    source_indices = (1 : n_sources_total).';
end

if any(source_indices > n_sources_total)
    error("utilities.sensitivity:synthesize_measurements:IndexOutOfRange", ...
        "source_indices contains values exceeding the number of available sources (%d).", n_sources_total);
end

mode = opts.SourceDirectionMode;
if mode == 3
    if isempty(opts.SourceDirections)
        error("utilities.sensitivity:synthesize_measurements:MissingSourceDirections", ...
            "source_direction_mode = 3 requires opts.SourceDirections (n_sources_total x 3) so probes can be built along intrinsic directions.");
    end
    if size(opts.SourceDirections, 1) ~= n_sources_total || size(opts.SourceDirections, 2) ~= 3
        error("utilities.sensitivity:synthesize_measurements:DirectionsShapeMismatch", ...
            "opts.SourceDirections must be %d x 3 to match the %d sources implied by L.", ...
            n_sources_total, n_sources_total);
    end
end

source_indices = source_indices(:);
n_used = numel(source_indices);
scale = 1e-3 * amp;

if mode == 1 || mode == 2
    col_inds = reshape([ ...
        3 * source_indices.' - 2; ...
        3 * source_indices.' - 1; ...
        3 * source_indices.' ...
        ], 3 * n_used, 1);
    F = scale * L(:, col_inds);
else
    % Mode 3: collapse the three lead-field columns of each probed source
    % along the source's intrinsic direction, matching how the mode-3
    % inverter receives a 1-column-per-source L from zef_processLeadfields.
    Lx = L(:, 3 * source_indices - 2);
    Ly = L(:, 3 * source_indices - 1);
    Lz = L(:, 3 * source_indices);
    Q = opts.SourceDirections(source_indices, :);
    F = scale * (Lx .* Q(:,1).' + Ly .* Q(:,2).' + Lz .* Q(:,3).');
end

if noise_db ~= 0
    sigma = 10^(noise_db / 20);
    F = F + sigma * randn(size(F), 'like', F);
end

end

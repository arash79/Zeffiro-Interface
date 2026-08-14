function F = synthesize_measurements(L, source_indices, amp, noise_db, opts)
%SYNTHESIZE_MEASUREMENTS  Forward-model dipole probes with optional AWGN.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   F = synthesize_measurements(L, source_indices, amp, noise_db, opts)
%
%   L must have 3 columns per source (x,y,z). Builds unit or fixed-orientation
%   probes per opts.SourceDirectionMode (1=3 dirs, 2=normal, 3=intrinsic from
%   opts.SourceDirections), scales by amp, adds noise at noise_db dB SNR.

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

function zef = createSyntheticUKFNMMZef(opts)
%CREATESYNTHETICUKFNMMZEF  Synthetic zef with xyz sources and bump activity.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = createSyntheticUKFNMMZef()
%   zef = createSyntheticUKFNMMZef(Name=Value)
%
%   Larger than tests.createSyntheticInverseZef so UKFNMM clustering
%   (kmeans with number_of_corrclusters+1) and Jansen-Rit fitting have
%   enough sources and frames. Mode 1, inv_data_mode 'raw', CPU.
%
%   Name-value: n_sensors (8), n_sources (6), n_frames (12),
%   sampling_frequency (100), noise_level (0.02).

    arguments
        opts.n_sensors (1,1) double {mustBeInteger, mustBePositive} = 8
        opts.n_sources (1,1) double {mustBeInteger, mustBePositive} = 6
        opts.n_frames (1,1) double {mustBeInteger, mustBePositive} = 12
        opts.sampling_frequency (1,1) double {mustBePositive} = 100
        opts.noise_level (1,1) double {mustBeNonnegative} = 0.02
    end

    n_sensors = opts.n_sensors;
    n_sources = opts.n_sources;
    n_frames = opts.n_frames;
    fs = opts.sampling_frequency;

    zef = tests.createSyntheticInverseZef();
    zef.source_direction_mode = 1;
    zef.source_interpolation_ind = {(1:n_sources)', [], []};
    zef.source_positions = [(0:n_sources-1)', zeros(n_sources, 2)];
    zef.source_directions = repmat([1 0 0], n_sources, 1);

    rng(1, "twister");
    L = randn(n_sensors, 3 * n_sources);
    t = (0:n_frames-1) / fs;
    x = zeros(3 * n_sources, n_frames);
    t_span = max(t(end), eps);
    x(1, :) = exp(-((t - 0.30 * t_span) / (0.08 * t_span + eps)).^2);
    if n_sources >= 3
        x(7, :) = 0.85 * exp(-((t - 0.70 * t_span) / (0.08 * t_span + eps)).^2);
    end
    if n_sources >= 5
        x(13, :) = 0.4 * exp(-((t - 0.50 * t_span) / (0.10 * t_span + eps)).^2);
    end
    zef.L = L;
    zef.measurements = L * x + opts.noise_level * randn(n_sensors, n_frames);

    zef.number_of_frames = n_frames;
    zef.inv_sampling_frequency = fs;
    zef.inv_time_1 = 0;
    zef.inv_time_2 = 0;
    zef.inv_time_3 = 1 / fs;
    zef.inv_low_cut_frequency = 0;
    zef.inv_high_cut_frequency = 0;
    zef.inv_data_mode = 'raw';
    zef.use_gpu = false;
    zef.gpu_count = 0;
end

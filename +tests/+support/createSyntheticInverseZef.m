function zef = createSyntheticInverseZef()
%CREATESYNTHETICINVERSEZEF  Minimal zef struct for inverse unit tests.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   zef = createSyntheticInverseZef()
%
%   Not a test. 4 sensors, 2 sources, L randn(4,6), 3 measurement frames,
%   zef.source_interpolation_ind{1} is a column so
%   zef_postProcessInverseClassObj can expand xyz indices.
%
n_sensors = 4;
n_interp = 2;
n_frames = 3;

zef = struct;
zef.source_direction_mode = 1;
zef.source_interpolation_ind = {(1:n_interp)', [], []};
zef.source_positions = [0 0 0; 1 0 0];
zef.source_directions = [1 0 0; 0 1 0];

% Mode 1 expects 3 components per source.
zef.L = randn(n_sensors, 3*n_interp);
zef.measurements = randn(n_sensors, n_frames);

zef.inv_data_mode = 'raw';
zef.inv_low_cut_frequency = 7;
zef.inv_high_cut_frequency = 9;
zef.inv_sampling_frequency = 1025;
zef.inv_time_1 = 0;
zef.inv_time_2 = 0;
zef.inv_time_3 = 1/zef.inv_sampling_frequency;
zef.number_of_frames = n_frames;
zef.inv_snr = 30;
zef.normalize_data = 1;
zef.use_gpu = false;
zef.gpu_count = 0;
zef.inv_time_interval_averaging = false;

% Common method fields used by legacy paths.
zef.csm_type = 1;
zef.inv_prior_over_measurement_db = 20;
zef.inv_amplitude_db = 0;
zef.mne_type = 1;
zef.mne_prior = 1;
zef.mne_sampling_frequency = zef.inv_sampling_frequency;
zef.mne_low_cut_frequency = zef.inv_low_cut_frequency;
zef.mne_high_cut_frequency = zef.inv_high_cut_frequency;
zef.mne_number_of_frames = zef.number_of_frames;
zef.mne_time_1 = zef.inv_time_1;
zef.mne_time_2 = zef.inv_time_2;
zef.mne_time_3 = zef.inv_time_3;
zef.mne_normalize_data = zef.normalize_data;
zef.filter_type = 1;
zef.kf_smoothing = 1;
zef.kf_burn_in = 0;
zef.standardization_exponent = 1;
zef.inv_evolution_prior = 0;
zef.kf_structural_Q_type = 0;

end

%KALMAN_PRIMER  Lab script: two-dipole synthetic measurements on live zef.L.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Needs workspace zef with .L and source_positions. Hard-coded
%   cortical/thalamic MNI-ish positions, 2500 Hz, 0–0.01 s Blackman–Harris
%   pulses, noise_dB=25. Nearest brain sources via zef_processLeadfields
%   (temporarily sets source_direction_mode 2 then 1). Writes
%   zef.measurements. The zef_KF / visualize block at the bottom is
%   commented out. Does not save. Pair with kalman_custom_q_driver.m.
%

noise_dB = 25;  % Measurement noise level (dB, higher = less noise)
sampling_frequency = 2500;  % Sampling frequency (Hz) for synthetic data

% Cortical source (P20 component):
pos(1,:)
 = [-33,-37,80];  % Position (mm) in MNI or head coordinates
ori(1,:) = [0.2,1,0];     % Orientation vector
amp(1) = 10;              % Amplitude (nAm)

% Thalamic source (N20 component):
pos(2,:) = [-12,-32,50];  % Position (mm)
ori(2,:) = [0.2,0.196,-0.98058];  % Orientation vector
amp(2) = 10;              % Amplitude (nAm)

ori = ori ./ sqrt(sum(ori.^2, 2));  % Normalize orientations to unit vectors

% Time course: Blackman-Harris window models Gaussian-like pulse.
t = 0:(1/sampling_frequency):0.01;   % Time vector (seconds)
sz = find(t > 0.008, 1);             % Pulse width (8 ms)
time_series = [zeros(1, length(t)-sz), blackmanharris(sz)'];
% Cortical source (1) peaks at ~6 ms; thalamic source (2) at ~4 ms;
% 2 ms delay models thalamo-cortical propagation.
time_series(2,:) = flip(time_series);
noise = randn(size(zef.L, 1), length(t));  % Gaussian measurement noise
% Find source indices for Cartesian (non-normal) lead field within brain,
% excluding outer compartments (skin, skull, etc.).
zef.source_direction_mode = 2;
[~,n_interp,procFile] = zef_processLeadfields(zef);
zef.source_direction_mode = 1;

mesh_points = zef.source_positions(procFile.s_ind_0, :);  % Brain source points
source_ind = nan(2, 1);
% Find nearest mesh nodes to target positions by Euclidean distance.
for i = 1:2
    [~,source_ind(i)] = min(sum((mesh_points-pos(i,:)).^2,2));
end
source_ind = [source_ind; source_ind+n_interp; source_ind+2*n_interp];  % 3D lead field indices
L = 1e-6 * zef.L(:, procFile.s_ind_1(source_ind));  % Lead field (µV/nAm)

zef.measurements = (L .* ori(:)') * repmat((amp' .* time_series), 3, 1);  % Noiseless signal
% Add noise according to specified SNR.
zef.measurements = zef.measurements + (10^(-noise_dB/20)*sqrt(sum(zef.measurements.^2,2)./sum(noise.^2,2))).*noise;



% zef.inv_snr = 25;
% zef.inv_sampling_frequency = 2500;
% zef.inv_low_cut_frequency = 0;
% zef.inv_high_cut_frequency = 0;
% zef.number_of_frames = 26;
% zef.inv_time_1 = 0;
% zef.inv_time_2 = 0;
% zef.inv_time_3 = 0.0004;
% zef.normalize_data = 1;
% zef.inv_evolution_prior = -34;
% % Filter type: 1 = Kalman, 2 = EnKF, 3 = Kalman SL, 4 = Kalman spatial SL
% zef.filter_type = 1;
% % Smoothing: 1 = none, 2 = Rauch-Tung-Striebel (RTS) smoother
% zef.kf_smoothing = 1;
% 
% % Execute the inverse reconstruction.
% [zef] = zef_KF(zef);
% 
% zef.h_zeffiro.Visible = 1;
% zef.use_display = 1;
% zef.visualization_type = 3;
% zef_visualize_surfaces;
% 
% zef_figure_tool
% zef.h_zeffiro.Visible = 1;
% zef.use_display = 1;
% zef.visualization_type = 3;
% zef.cp2_on = 0;
% zef.cp_on = 0;
% zef.cp3_on = 0;
% zef_visualize_surfaces;


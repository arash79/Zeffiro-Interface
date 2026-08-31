function [zef] = zef_KF(zef, q_value)
%ZEF_KF  Kalman-filter source reconstruction with optional DTI structural Q.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Legacy GUI plugin path (not inverse.KalmanInverter). Processes lead
%   fields, band-pass filters measurements, then runs a discrete-time KF
%   with A = I, P0 = theta0 I, and process-noise Q either diagonal or
%   DTI-informed. Filter type is zef.filter_type: 1 no standardization,
%   2 EnKF, 3 spatiotemporal sLORETA, 4 spatial standardization, 5–9
%   double/triple block Kalman. Optional RTS when zef.kf_smoothing > 1.
%
%   zef = zef_KF(zef)
%   zef = zef_KF(zef, q_value)
%
%   Inputs
%     zef      - session with zef.L, measurements, inv_snr (dB),
%                inv_prior_over_measurement_db, inv_evolution_prior,
%                filter_type, kf_smoothing, optional kf_structural_Q_type
%                (0 diagonal, 1 FA, 2 tractography). Frames:
%                number_of_frames, inv_time_*. SNR → R = (10^(-inv_snr/20))^2 I.
%     q_value  - optional scalar process-noise scale. If omitted, computed
%                from inv_evolution_prior via find_evolution_prior.
%
%   Output
%     zef  - reconstruction and reconstruction_information filled.
%            If nargout is 0, assigned into the base workspace.
%
%   See also inverse.KalmanInverter, zef_processLeadfields, zef_dti_structural_Q.

snr_val = zef.inv_snr;
pm_val = zef.inv_prior_over_measurement_db;
amplitude_db = zef.inv_amplitude_db;
pm_val = pm_val - amplitude_db;
std_lhood = 10^(-snr_val/20);
sampling_freq = zef.inv_sampling_frequency;
high_pass = zef.inv_low_cut_frequency;
low_pass = zef.inv_high_cut_frequency;
number_of_frames = zef.number_of_frames;
source_direction_mode = zef.source_direction_mode;
source_directions = zef.source_directions;
source_positions = zef.source_positions;
if isfield(zef, 'standardization_exponent')
    standardization_exponent = zef.standardization_exponent;
else
    standardization_exponent = 1;  % sLORETA exponent; default matches zef_kf_open_window
end
time_step = zef.inv_time_3;
if isfield(zef, 'kf_burn_in')
    burn_in = zef.kf_burn_in;
else
    burn_in = 4;  % burn-in frames for block filters; default matches zef_kf_open_window
end

%% Reconstruction identifiers
reconstruction_information.tag = 'Kalman';
reconstruction_information.inv_time_1 = zef.inv_time_1;
reconstruction_information.inv_time_2 = zef.inv_time_2;
reconstruction_information.inv_time_3 = zef.inv_time_3;
reconstruction_information.normalize_data = zef.normalize_data;
reconstruction_information.sampling_freq = zef.inv_sampling_frequency;
reconstruction_information.low_pass = zef.inv_high_cut_frequency;
reconstruction_information.high_pass = zef.inv_low_cut_frequency;
reconstruction_information.number_of_frames = zef.number_of_frames;
reconstruction_information.source_direction_mode = zef.source_direction_mode;
reconstruction_information.source_directions = zef.source_directions;
reconstruction_information.snr_val = zef.inv_snr;
reconstruction_information.pm_val = zef.inv_prior_over_measurement_db;

%%
[L,n_interp, procFile] = zef_processLeadfields(zef);

%get ellipse filteres full measurement data. f_data: "sensors" x "time points"
[f_data] = zef_getFilteredData(zef);
timeSteps = arrayfun(@(x) zef_getTimeStep(f_data, x, zef), 1:number_of_frames, 'UniformOutput', false);

z_inverse_results = cell(0);
%% CALCULATION STARTS HERE
% m_0 = prior mean
m = zeros(size(L,2), 1);

[theta0] = zef_find_gaussian_prior(snr_val-pm_val,L,size(L,2),zef.normalize_data,0);

% Transition matrix is Identity matrix (sparse: kf_predict's isdiag path
% is O(n) rather than O(n^2); P+Q then touches only the diagonal of Q).
P = eye(size(L,2)) * theta0;

A = speye(size(L,2));

% If q_value given in the function call
if nargin > 1
    q_scalar = q_value;
else
    zef_init_gaussian_prior_options;
    evolution_prior_db = zef.inv_evolution_prior;
    q_scalar = find_evolution_prior(L, theta0, number_of_frames, evolution_prior_db, pm_val, snr_val);
end

% Build Q matrix: structural (DTI-informed) or standard (diagonal)
% zef.kf_structural_Q_type:
%   0 or absent = standard diagonal Q (default)
%   1 = FA-based structural Q (requires DTI FA data)
%   2 = Tractography-based structural Q (requires DTI FA + v1 data)
structural_Q_type = 0;
if isfield(zef, 'kf_structural_Q_type')
    structural_Q_type = zef.kf_structural_Q_type;
end

if structural_Q_type == 1
    % FA-based structural covariance from DTI
    Q = zef_dti_structural_Q(zef, q_scalar, 'fa', ...
        'source_direction_mode', source_direction_mode);
elseif structural_Q_type == 2
    % Tractography-based structural covariance from DTI
    Q = zef_dti_structural_Q(zef, q_scalar, 'tractography', ...
        'source_direction_mode', source_direction_mode);
else
    % Standard diagonal Q (original behavior). Sparse identity matches the
    % dense q*I algebra while avoiding an extra dense n_state^2 matrix.
    Q = q_scalar * speye(size(L,2));
end
reconstruction_information.Q = q_scalar;
reconstruction_information.structural_Q_type = structural_Q_type;

% std_lhood
R = std_lhood^2 * eye(size(L,1));

%% KALMAN FILTER
% filter_type 1–9 from zef.KF.filter_type (legacy plugin only; DTI Q
% above is this path, not inverse.KalmanInverter).
sL=0;
filter_type = zef.filter_type;
smoothing = zef.kf_smoothing;
D_store = {};
pending_W = [];
% filter_type ItemsData 1–9 from zef_kf_open_window. Each branch may
% cap kf_smoothing (EnKF has no RTS; double/triple allow 2- or 3-block).
% sL is the sLORETA block depth passed into double/triple and ext_sL.
if filter_type == 1
    % No standardization: plain KF (A = I).
    smoothing=min(smoothing,2);
    sL=5;
    [P_store, z_inverse] = kalman_filter(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing);
elseif filter_type == 2
    % Ensemble Kalman (EnKF). Ensemble count from the app widget.
    smoothing=min(smoothing,1);
    n_ensembles = str2double(zef.KF.number_of_ensembles.Value);
    z_inverse = EnKF(m,A,P,Q,L,R,timeSteps,number_of_frames, n_ensembles);
elseif filter_type == 3
    % Spatiotemporal sLORETA inside the KF update (kalman_filter_sLORETA).
    smoothing=min(smoothing,2);
    sL=1;
    [P_store, z_inverse, D_store] = kalman_filter_sLORETA(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing,standardization_exponent);
elseif filter_type == 4
    % Spatial standardization after a plain KF: diagonal sLORETA weights W.
    sL=1;
    smoothing=min(smoothing,2);
    [P_store, z_inverse] = kalman_filter(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing);
    P_old = eye(size(L,2)) * theta0;
    H = L * sqrtm(P_old);
    pending_W = inv((diag(diag(H'*inv(H*H' + R)*H))).^standardization_exponent);
elseif filter_type == 5
    % Double-block Kalman, sLORETA depth 1.
    sL=1;
    smoothing=min(smoothing,3);
    [P_store, z_inverse] = double_kf_sL(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing,sL,standardization_exponent,burn_in);
elseif filter_type == 6
    % Double-block Kalman, sLORETA depth 2.
    sL=2;
    smoothing=min(smoothing,3);
    [P_store, z_inverse] = double_kf_sL(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing,sL,standardization_exponent,burn_in);
elseif filter_type == 7
    % Triple-block Kalman, sLORETA depth 1.
    sL=1;
    [P_store, z_inverse] = triple_kf_sL(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing,sL,standardization_exponent,burn_in);
elseif filter_type == 8
    sL=2;
    [P_store, z_inverse] = triple_kf_sL(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing,sL,standardization_exponent,burn_in);
elseif filter_type == 9
    sL=3;
    [P_store, z_inverse] = triple_kf_sL(m,P,A,Q,L,R,timeSteps, number_of_frames, smoothing,sL,standardization_exponent,burn_in);
end


%% RTS SMOOTHING
% kf_smoothing ItemsData: 1 none (skip), 2 RTS, 3 2-block RTS, 4 3-block RTS.
% EnKF already capped smoothing at 1 so this block is skipped for type 2.
if (smoothing == 2)
    [P_s_store, m_s_store, ~] = RTS_smoother(P_store, z_inverse, A, Q, number_of_frames);
    z_inverse = m_s_store;
elseif (smoothing == 3)
    [P_s_store, m_s_store, ~] = Block_RTS_smoother(P_store, z_inverse, A, Q, number_of_frames,2,sL);
    z_inverse = m_s_store;
elseif (smoothing == 4)
    [P_s_store, m_s_store, ~] = Block_RTS_smoother(P_store, z_inverse, A, Q, number_of_frames,3,sL);
    z_inverse = m_s_store;
end

if ~isempty(D_store)
    for k = 1:numel(z_inverse)
        z_inverse{k} = D_store{k} * z_inverse{k};
    end
end
if ~isempty(pending_W)
    z_inverse = cellfun(@(x) pending_W*x, z_inverse, 'UniformOutput', false);
end

if sL<smoothing-1
    % Extra sLORETA pass when the chosen smoother is deeper than the
    % filter's own sL (e.g. triple-block with sL=1 plus 3-block RTS).
    [z_inverse] = ext_sL(z_inverse,P_s_store,L,R, number_of_frames, smoothing, sL,standardization_exponent);
end
%% POSTPROCESSING
[z] = zef_postProcessInverse(z_inverse, procFile);
%normalize the reconstruction so that the highest value is equal to 1
[z] = zef_normalizeInverseReconstruction(z);
%% CALCULATION ENDS HERE
zef.reconstruction_information = reconstruction_information;
zef.reconstruction = z;

end

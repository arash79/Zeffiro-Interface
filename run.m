%RUN  Lab Kalman driver: Q .mat files on disk, project name relative to cwd.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Hard-coded q_dir =
%   /home/rdnzl/Documents/MATLAB/zeffiro_may_2026/data/dti and
%   project_file = 'Sub01FG_Anisotropic_Interpolated.mat' (opened from
%   cwd, not this repo). Each Q file must contain variable Q matching
%   size(L,2). filter_type 1/3/4 (plain / sLORETA / W). Writes
%   inversion_data_kalman_connectivity_*.mat and run_log_*.txt in cwd,
%   then zef_close_all. kalman_primer is commented out; measurements are
%   whatever the opened project already has. One-off lab batch.
%

%% Standalone Kalman inversion driver — bypasses zef_KF so that custom,
%  precomputed Q matrices on disk are *actually* used. Everything zef_KF
%  would have done is replicated inline below so we can swap Q.

%% ----------------------------------------------------------------------
%% 1. Tunable parameters
%% ----------------------------------------------------------------------
smoothing                = 2;
standardization_exponent = 0.5;
filter_type              = 3;        % 1 = KF, 3 = KF sLORETA, 4 = KF + W
noise_level              = 25;       % matches kalman_primer noise_dB
sample_size              = 10;
pm_snr                   = 0;
inv_evolution_prior      = 50;       % kept for reconstruction_information only
epsilon_db               = 80;       % naming only

sampling_frequency       = 2500;     % from kalman_primer.m
number_of_frames_val     = 26;       % length(0:1/2500:0.01)

q_dir = '/home/rdnzl/Documents/MATLAB/zeffiro_may_2026/data/dti';
q_files = { ...
    'Anisotropic_Normal_Q_Matrix.mat',            'AnisoNormal'; ...
    'Anisotropic_FA_Based_Q_Matrix.mat',          'AnisoFA';     ...
    'Anisotropic_Tractography_Based_Q_Matrix.mat','AnisoTract';  ...
    % 'Isotropic_Normal_Q_Matrix.mat',            'IsoNormal';   ...
    % 'Isotropic_FA_Based_Q_Matrix.mat',          'IsoFA';       ...
    % 'Isotropic_Tractography_Based_Q_Matrix.mat','IsoTract'     ...
};

project_file = 'Sub01FG_Anisotropic_Interpolated.mat';
parcellation_selected_list = [5 11 19 70];

%% ----------------------------------------------------------------------
%% 2. Logging
%% ----------------------------------------------------------------------
diary(sprintf('run_log_%s.txt', datestr(now,'yyyymmdd_HHMMSS')
));
diary on
cleanupDiary = onCleanup(@() diary('off'));

%% ----------------------------------------------------------------------
%% 3. Boot Zeffiro and open the project
%% ----------------------------------------------------------------------
zef = zeffiro_interface('start_mode','nodisplay','open_project',project_file);
zef.parcellation_selected = parcellation_selected_list;

zef = zef_kf_start(zef);

zef_init_parcellation;
zef.parcellation_time_series_mode = 1;   % 1 = numeric matrix, 2 = cell

rng(now);

%% ----------------------------------------------------------------------
%% 4. Push user parameters into zef
%% ----------------------------------------------------------------------
zef.filter_type                    = filter_type;
zef.kf_smoothing                   = smoothing;
zef.standardization_exponent       = standardization_exponent;
zef.inv_evolution_prior            = inv_evolution_prior;
zef.inv_prior_over_measurement_db  = pm_snr;
zef.inv_snr                        = noise_level;
zef.ias_snr                        = noise_level;
zef.fss_bg_noise                   = -noise_level;
zef.inv_sampling_frequency         = sampling_frequency;
zef.inv_time_1                     = 0;
zef.inv_time_2                     = 0;
zef.inv_time_3                     = 1/sampling_frequency;
zef.number_of_frames               = number_of_frames_val;
zef.source_direction_mode          = 1;     % Cartesian (3 dirs per source)

if ~isfield(zef,'kf_burn_in') || isempty(zef.kf_burn_in)
    zef.kf_burn_in = 0;
end

% Metadata saved alongside each results file.
inv_time_1              = zef.inv_time_1;
inv_time_2              = zef.inv_time_2;
inv_time_3              = zef.inv_time_3;
number_of_frames        = zef.number_of_frames;
parcellation_colortable = zef.parcellation_colortable;
parcellation_selected   = zef.parcellation_selected;

%% ----------------------------------------------------------------------
%% 5. Pre-compute everything that does NOT change between samples
%% ----------------------------------------------------------------------
fprintf('\n[setup] Processing leadfield...\n');
[L_kf, n_interp_kf, procFile_kf] = zef_processLeadfields(zef);

n_state    = size(L_kf, 2);
n_sensors  = size(L_kf, 1);
snr_val    = zef.inv_snr;
pm_val     = zef.inv_prior_over_measurement_db - 0;    % no inv_amplitude_db adjustment by default
if isfield(zef,'inv_amplitude_db') && ~isempty(zef.inv_amplitude_db)
    pm_val = zef.inv_prior_over_measurement_db - zef.inv_amplitude_db;
end
std_lhood  = 10^(-snr_val/20);

A_kf       = eye(n_state);
m_kf       = zeros(n_state, 1);
fprintf('[setup] Computing theta0 (Gaussian prior)...\n');
theta0_kf  = zef_find_gaussian_prior(snr_val - pm_val, L_kf, n_state, zef.normalize_data, 0);
P_init_kf  = eye(n_state) * theta0_kf;
R_kf       = std_lhood^2 * eye(n_sensors);

fprintf('[setup] L is [%d x %d], expecting Q of size [%d x %d]\n', ...
        n_sensors, n_state, n_state, n_state);

%% ----------------------------------------------------------------------
%% 6. Pre-validate every Q file BEFORE doing any expensive work
%% ----------------------------------------------------------------------
fprintf('\n[setup] Pre-checking Q matrix dimensions...\n');
for q_idx = 1 : size(q_files,1)
    q_path = fullfile(q_dir, q_files{q_idx,1});
    info   = whos('-file', q_path, 'Q');
    if isempty(info)
        error('Q variable not found in %s', q_path);
    end
    if numel(info.size) ~= 2 || any(info.size ~= [n_state n_state])
        error(['Q in %s has size [%s] but the leadfield needs [%d %d]. ' ...
               'Regenerate the Q matrices against the current project.'], ...
              q_path, num2str(info.size), n_state, n_state);
    end
    fprintf('  ok  %-50s  [%d x %d]\n', q_files{q_idx,1}, info.size(1), info.size(2));
end
fprintf('[setup] All %d Q matrices match the leadfield.\n', size(q_files,1));

%% ----------------------------------------------------------------------
%% 7. Sanity guard for filter_type (this script supports 1, 3, 4)
%% ----------------------------------------------------------------------
if ~ismember(filter_type, [1 3 4])
    error(['This standalone script supports filter_type 1, 3, or 4 only ' ...
           '(got %d). Other filters depend on GUI handles or extras.'], ...
          filter_type);
end

%% ----------------------------------------------------------------------
%% 8. Main loop over Q matrices
%% ----------------------------------------------------------------------
for q_idx = 1 : size(q_files,1)

    q_path  = fullfile(q_dir, q_files{q_idx,1});
    q_label = q_files{q_idx,2};

    fprintf('\n=== Q matrix %d/%d: %s ===\n', q_idx, size(q_files,1), q_label);

    S    = load(q_path, 'Q');
    Q_kf = S.Q;
    clear S;

    inversion_data = struct;

    out_name = sprintf('inversion_data_kalman_connectivity_%d_%d_%d_%d_%s.mat', ...
                       noise_level, inv_evolution_prior, pm_snr, epsilon_db, q_label);

    for i = 1 : sample_size
        sample_tic = tic;
        fprintf('  sample %d/%d ... ', i, sample_size);

        rec_out  = [];
        meas_out = [];
        ts_out   = [];

        try
            %% (a) Fresh synthetic measurements (kalman_primer overwrites
            %%     locals named L, time_series, n_interp, procFile, etc., so we
            %%     keep our own copies under the *_kf suffix and never touch
            %%     them inside this try-block.)
            % kalman_primer;
            meas_out = zef.measurements;

            %% (b) Filtered data + time-step structure (depend on measurements)
            f_data           = zef_getFilteredData(zef);
            timeSteps_cell   = arrayfun(@(x) zef_getTimeStep(f_data, x, zef), ...
                                        1:number_of_frames_val, ...
                                        'UniformOutput', false);

            %% (c) Kalman filter (Q from disk, NOT the diagonal q*I that
            %%     zef_KF would have built)
            switch filter_type
                case 1   % plain Kalman filter
                    sm_kf = min(smoothing,2);
                    sL    = 5;
                    [P_store, z_inverse] = kalman_filter( ...
                        m_kf, P_init_kf, A_kf, Q_kf, L_kf, R_kf, ...
                        timeSteps_cell, number_of_frames_val, sm_kf);

                case 3   % Kalman filter sLORETA
                    sm_kf = min(smoothing,2);
                    sL    = 1;
                    [P_store, z_inverse] = kalman_filter_sLORETA( ...
                        m_kf, P_init_kf, A_kf, Q_kf, L_kf, R_kf, ...
                        timeSteps_cell, number_of_frames_val, sm_kf, ...
                        standardization_exponent);

                case 4   % Kalman filter + W post-transform
                    sm_kf = min(smoothing,2);
                    sL    = 1;
                    [P_store, z_inverse] = kalman_filter( ...
                        m_kf, P_init_kf, A_kf, Q_kf, L_kf, R_kf, ...
                        timeSteps_cell, number_of_frames_val, sm_kf);
                    H = L_kf * sqrtm(P_init_kf);
                    W = inv((diag(diag(H'*inv(H*H' + R_kf)*H))).^standardization_exponent);
                    z_inverse = cellfun(@(x) W*x, z_inverse, 'UniformOutput', false);
            end

            %% (d) RTS smoother
            if sm_kf == 2
                [P_s_store, m_s_store, ~] = RTS_smoother( ...
                    P_store, z_inverse, A_kf, Q_kf, number_of_frames_val);
                z_inverse = m_s_store;
            end
            if sL < sm_kf - 1
                z_inverse = ext_sL(z_inverse, P_s_store, L_kf, R_kf, ...
                                   number_of_frames_val, sm_kf, sL, ...
                                   standardization_exponent);
            end

            %% (e) Post-process + normalize, exactly as zef_KF does
            z_out = zef_postProcessInverse(z_inverse, procFile_kf);
            z_out = zef_normalizeInverseReconstruction(z_out);

            zef.reconstruction = z_out;
            rec_out = z_out;

            %% (f) Parcellation in its own try so a failure here only drops
            %%     time_series and never wipes the reconstruction/measurements
            try
                ts_out = zef_parcellation_time_series(zef);
            catch ME_ts
                warning('  parcellation failed (%s)', ME_ts.message);
                ts_out = [];
            end

        catch ME
            warning('  KF/measurements failed: %s', ME.message);
        end

        inversion_data(i).reconstruction = rec_out;
        inversion_data(i).time_series    = ts_out;
        inversion_data(i).measurements   = meas_out;

        % Incremental save so a later crash never wipes earlier samples.
        save(out_name, ...
             'inversion_data','inv_time_1','inv_time_2','inv_time_3', ...
             'number_of_frames','parcellation_colortable','parcellation_selected', ...
             '-v7.3');

        fprintf('done (%.1fs, rec=%s, ts=%s)\n', toc(sample_tic), ...
                tern(isempty(rec_out),'EMPTY','ok'), ...
                tern(isempty(ts_out), 'EMPTY','ok'));
    end

    fprintf('=== finished %s -> %s ===\n', q_label, out_name);
end

zef_close_all
diary off

%% ----------------------------------------------------------------------
%% local helper
%% ----------------------------------------------------------------------
function s = tern(cond,a,b)
    if cond, s = a; else, s = b; end
end

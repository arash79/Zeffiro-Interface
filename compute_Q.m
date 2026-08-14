%COMPUTE_Q  Lab script: process-noise Q from a live zef (DTI or diagonal).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Needs workspace zef with L, measurements, and
%   inv_prior_over_measurement_db / inv_amplitude_db / normalize_data /
%   source_direction_mode. Overwrites zef.inv_snr=25, number_of_frames=26.
%   zef_processLeadfields + zef_getFilteredData (unused except to build
%   timeSteps). theta0 from zef_find_gaussian_prior; q_scalar from
%   find_evolution_prior. Then zef.kf_structural_Q_type (default 2 if the
%   field is absent): 1 FA Q, 2 tractography Q via zef_dti_structural_Q,
%   else q_scalar*eye. Leaves Q and reconstruction_information in the
%   workspace; does not invert or save. One-off Kalman/DTI lab helper.
%

zef.inv_snr = 25;
zef.number_of_frames = 26;


snr_val = zef.inv_snr;
pm_val = zef.inv_prior_over_measurement_db;
amplitude_db = zef.inv_amplitude_db;
pm_val = pm_val - amplitude_db;
number_of_frames = zef.number_of_frames;
source_direction_mode = zef.source_direction_mode;


[L,n_interp, procFile] = zef_processLeadfields(zef);

[f_data] = zef_getFilteredData(zef);
timeSteps = arrayfun(@(x) zef_getTimeStep(f_data, x, zef), 1:number_of_frames, 'UniformOutput', false);


[theta0] = zef_find_gaussian_prior(snr_val-pm_val,L,size(L,2),zef.normalize_data,0);

zef_init_gaussian_prior_options;
evolution_prior_db = zef.inv_evolution_prior;
q_scalar = find_evolution_prior(L, theta0, number_of_frames, evolution_prior_db, pm_val, snr_val);


% Build Q matrix: structural (DTI-informed) or standard (diagonal)
% zef.kf_structural_Q_type:
%   0 or absent = standard diagonal Q (default)
%   1 = FA-based structural Q (requires DTI FA data)
%   2 = Tractography-based structural Q (requires DTI FA + v1 data)
structural_Q_type = 2;
if isfield(zef, 'kf_structural_Q_type')
    structural_Q_type = zef.kf_structural_Q_type;
end
% 
if structural_Q_type == 1
    % FA-based structural covariance from DTI
    Q = zef_dti_structural_Q(zef, q_scalar, 'fa', ...
        'source_direction_mode', source_direction_mode);
elseif structural_Q_type == 2
    % Tractography-based structural covariance from DTI
    Q = zef_dti_structural_Q(zef, q_scalar, 'tractography', ...
        'source_direction_mode', source_direction_mode);
else
    % Standard diagonal Q (original behavior)
    Q = q_scalar * eye(size(L,2));
end
reconstruction_information.Q = q_scalar;
reconstruction_information.structural_Q_type = structural_Q_type;

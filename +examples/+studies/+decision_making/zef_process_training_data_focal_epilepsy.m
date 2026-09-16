%ZEF_PROCESS_TRAINING_DATA_FOCAL_EPILEPSY  Score methods on saved training_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. zef_parameters_focal_epilepsy then load(training_data_file_name)
%   (expects variable training_data). Opens project_file_name if zef missing.
%   For each trial: zef_dataBank_set_reconstructions, then package helper
%   zef_cluster_reconstructions_focal_epilepsy (needs supervised clustering
%   off or an existing credibility .mat — first pass typically uses
%   cred_val_points). Increments credibility_data_aux(J_aux,snr_ind).
%   save(credibility_data_file_name,'credibility_data','-v7.3') as fractions.
%
%   See also zef_create_training_data_focal_epilepsy,
%   zef_cluster_reconstructions_focal_epilepsy.

examples.studies.decision_making.zef_parameters_focal_epilepsy;

load(training_data_file_name)
;

if not(exist('zef', 'var'))
    zef = zeffiro_interface('start_mode','nodisplay','open_project',project_file_name);
end
zef_start_dataBank;

waitbar_counter = 0;
% credibility_data_aux accumulates selection counts; J_aux set by clustering.
h_waitbar = zef_waitbar(waitbar_counter,(training_data_size*length(snr_vec)),'Creating training dataset.');

n_data = size(training_data.z_inverse_results,2);
n_snr = size(training_data.z_inverse_results{1},2);
n_rec = size(training_data.z_inverse_results{1}{1},2);

credibility_data_aux = zeros(2*n_rec,n_snr);

for data_ind = 1 : n_data
    for snr_ind = 1 : n_snr

        waitbar_counter = waitbar_counter + 1;
        zef_waitbar(waitbar_counter,(training_data_size*length(snr_vec)),h_waitbar,'Creating training dataset.');

        z_inverse_results = training_data.z_inverse_results{data_ind}{snr_ind};
        zef.resection_points = training_data.dipole_positions{data_ind}{snr_ind};

        zef = zef_dataBank_set_reconstructions(zef,z_inverse_results,frame_number);
        examples.studies.decision_making.helpers.zef_cluster_reconstructions_focal_epilepsy;

        credibility_data_aux(J_aux,snr_ind) = credibility_data_aux(J_aux,snr_ind) + 1;

        credibility_data_aux/((data_ind-1)*n_snr + snr_ind)

    end
end

credibility_data = credibility_data_aux./(n_data*n_snr);

save(credibility_data_file_name,'credibility_data','-v7.3');
zef_close_waitbar(h_waitbar);

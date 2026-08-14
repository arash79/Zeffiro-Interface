%ZEF_PARAMETERS_FOCAL_EPILEPSY  Workspace names for the focal-epilepsy study scripts.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Assigns then prefixes paths with
%   fileparts(mfilename('fullpath'))/data/:
%     training_data_file_name      starts '' → that folder with a trailing
%                                  filesep (save() would treat it as a dir)
%     credibility_data_file_name   'credibility_dataset_p0857_10dB' (no .mat)
%     project_file_name            set to a ~/Dropbox/... string THEN
%                                  concatenated under data/ — that default
%                                  does not resolve; edit after folder_name
%   Also: snr_vec=[10], training_data_size=50, frame_number=1,
%   supervised_clustering='on', cred_val_rec/points, max_n_clusters=100,
%   n_dynamic_levels, tol_val_*, reg_param_*, max_iter.
%   Other scripts in this package run this first.
%
%   See also zef_create_training_data_focal_epilepsy.

training_data_file_name = '';
credibility_data_file_name = 'credibility_dataset_p0857_10dB';
project_file_name = '~/Dropbox/ResearchData/PerEpi_material/Patients/p0803.mat';

supervised_clustering = 'on';
frame_number = 1;
max_iter = 10000;
training_data_size = 50;
snr_vec = [10];
frame_number = 1;
cred_val_rec = 0.95;
cred_val_points = 0.98;
max_n_clusters = 100;
n_dynamic_levels = 4;
tol_val_rec = 1e-3;
tol_val_points = 1e-6;
reg_param_rec = 1E-1;
reg_param_points = 1e-3;

% Resolve paths relative to this script's directory.
folder_name = [fileparts(mfilename('fullpath')) filesep 'data'];

credibility_data_file_name = [folder_name filesep credibility_data_file_name];
training_data_file_name = [folder_name filesep training_data_file_name];
project_file_name = [folder_name filesep project_file_name];

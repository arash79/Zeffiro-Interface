% ZEF_PARAMETERS_FOCAL_EPILEPSY - Configuration script for focal epilepsy workflow
%
% Sets global parameters used by the decision_making study scripts. Must be
% run (or sourced) before other scripts in this module. Updates paths to
% point to the local 'data' subfolder.
%
% Key parameters:
%   training_data_file_name   Output file for synthetic training data
%   credibility_data_file_name  Output file for credibility dataset
%   project_file_name         Path to patient project (.mat)
%   supervised_clustering     'on' = use credibility data; 'off' = uniform
%   frame_number              Frame index for reconstruction
%   training_data_size        Number of synthetic trials
%   snr_vec                   SNR levels (dB) for training
%   cred_val_rec, cred_val_points  Credibility thresholds for clustering
%   max_n_clusters, n_dynamic_levels  GMM clustering parameters
%   tol_val_rec, tol_val_points      Convergence tolerances
%   reg_param_rec, reg_param_points  Regularization parameters
%
% See also: zef_create_training_data_focal_epilepsy, zef_decision_script_focal_epilepsy

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

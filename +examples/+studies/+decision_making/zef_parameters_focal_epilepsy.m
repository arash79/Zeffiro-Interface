% --- Zeffiro documentation header ---
% examples.studies.decision_making.training_data_file_name = ''; — Example or study script demonstrating training_data_file_name = '';.
%
% Purpose:
%   Example or study script demonstrating training_data_file_name = '';.
%   Folder: Runnable examples and study scripts that exercise meshing, forward lead fields, inverse solvers, importing, and published workflows.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `examples.studies.decision_making.training_data_file_name = '';` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

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

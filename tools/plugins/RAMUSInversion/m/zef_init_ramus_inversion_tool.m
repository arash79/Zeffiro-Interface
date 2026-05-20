%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isfield(zef,'ramus_multires_dec')); — If not(isfield(zef,'ramus multires dec'));.
%
% Purpose:
%   If not(isfield(zef,'ramus multires dec'));.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_ramus_high_cut_frequency (read)
%   zef.h_ramus_hyperprior (read)
%   zef.h_ramus_init_guess_mode (read)
%   zef.h_ramus_low_cut_frequency (read)
%   zef.h_ramus_multires_n_decompositions (read)
%   zef.h_ramus_multires_n_iter (read)
%   zef.h_ramus_multires_n_levels (read)
%   zef.h_ramus_multires_sparsity (read)
%   zef.h_ramus_normalize_data (read)
%   zef.h_ramus_number_of_frames (read)
%   zef.h_ramus_sampling_frequency (read)
%   zef.h_ramus_snr (read)
%   zef.h_ramus_time_1 (read)
%   zef.h_ramus_time_2 (read)
%   zef.h_ramus_time_3 (read)
%   … (30 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'ramus_multires_dec'));` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



if not(isfield(zef,'ramus_multires_dec'));
    zef.ramus_multires_dec = [];
end;
if not(isfield(zef,'ramus_multires_n_decompositions'));
    zef.ramus_multires_n_decompositions = [20];
end;
if not(isfield(zef,'ramus_initial_guess_mode'));
    zef.ramus_initial_guess_mode = [1];
end;
if not(isfield(zef,'ramus_multires_ind'));
    zef.ramus_multires_ind= [];
end;
if not(isfield(zef,'ramus_multires_count'));
    zef.ramus_multires_count= [];
end;
if not(isfield(zef,'ramus_multires_n_levels'));
    zef.ramus_multires_n_levels= [3];
end;
if not(isfield(zef,'ramus_multires_sparsity'));
    zef.ramus_multires_sparsity = [10];
end;
if not(isfield(zef,'ramus_multires_n_iter'));
    zef.ramus_multires_n_iter = [10];
end;
if not(isfield(zef,'ramus_hyperprior'));
    zef.ramus_hyperprior = 2;
end;
if not(isfield(zef,'ramus_n_map_iterations'));
    zef.ramus_n_map_iterations = 25;
end;
if not(isfield(zef,'ramus_pcg_tol'));
    zef.ramus_pcg_tol = 1e-8;
end;
if not(isfield(zef,'ramus_data_segment'));
    zef.ramus_data_segment = 1;
end;

zef.ramus_sampling_frequency = zef.inv_sampling_frequency;
zef.ramus_low_cut_frequency = zef.inv_low_cut_frequency;
zef.ramus_high_cut_frequency = zef.inv_high_cut_frequency;

if not(isfield(zef,'ramus_normalize_data'));
    zef.ramus_normalize_data = 1;
end;
if not(isfield(zef,'ramus_init_guess_mode'));
    zef.ramus_init_guess_mode = 1;
end;
if not(isfield(zef,'ramus_hyperprior'));
    zef.ramus_hyperprior = 1;
end;

zef.ramus_time_1 = zef.inv_time_1;
zef.ramus_time_2 = zef.inv_time_2;
zef.ramus_time_3 = zef.inv_time_3;
zef.ramus_number_of_frames = zef.number_of_frames;

zef.ramus_snr = zef.inv_snr;

set(zef.h_ramus_multires_n_levels ,'string',num2str(zef.ramus_multires_n_levels));
set(zef.h_ramus_multires_n_decompositions ,'string',num2str(zef.ramus_multires_n_decompositions));
set(zef.h_ramus_multires_sparsity,'string',num2str(zef.ramus_multires_sparsity));
set(zef.h_ramus_snr,'string',num2str(zef.ramus_snr));
set(zef.h_ramus_multires_n_iter,'string',num2str(zef.ramus_multires_n_iter));
set(zef.h_ramus_sampling_frequency,'string',num2str(zef.ramus_sampling_frequency));
set(zef.h_ramus_low_cut_frequency,'string',num2str(zef.ramus_low_cut_frequency));
set(zef.h_ramus_high_cut_frequency ,'string',num2str(zef.ramus_high_cut_frequency));
set(zef.h_ramus_normalize_data ,'value',zef.ramus_normalize_data);
set(zef.h_ramus_init_guess_mode ,'value',zef.ramus_init_guess_mode);
set(zef.h_ramus_hyperprior ,'value',zef.ramus_hyperprior);
set(zef.h_ramus_time_1 ,'string',num2str(zef.ramus_time_1));
set(zef.h_ramus_time_2 ,'string',num2str(zef.ramus_time_2));
set(zef.h_ramus_time_3 ,'string',num2str(zef.ramus_time_3));
set(zef.h_ramus_number_of_frames,'string',num2str(zef.ramus_number_of_frames));

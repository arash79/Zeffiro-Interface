%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.exp_em_q = get(zef — Zef.exp em q = get(zef.
%
% Purpose:
%   Zef.exp em q = get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.exp_em_beta (read, write)
%   zef.exp_em_hyper_type (read, write)
%   zef.exp_em_theta0 (read, write)
%   zef.h_exp_em_beta (read)
%   zef.h_exp_em_data_segment (read)
%   zef.h_exp_em_high_cut_frequency (read)
%   zef.h_exp_em_hyper_type (read)
%   zef.h_exp_em_low_cut_frequency (read)
%   zef.h_exp_em_n_L1_iterations (read)
%   zef.h_exp_em_n_map_iterations (read)
%   zef.h_exp_em_normalize_data (read)
%   zef.h_exp_em_number_of_frames (read)
%   zef.h_exp_em_pcg_tol (read)
%   zef.h_exp_em_sampling_frequency (read)
%   zef.h_exp_em_snr (read)
%   … (17 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.exp_em_q = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.exp_em_q = get(zef.h_exp_em_q,'value');
zef.exp_em_hyper_type = get(zef.h_exp_em_hyper_type,'value');
zef.exp_em_beta = str2num(get(zef.h_exp_em_beta,'string'));
zef.exp_em_theta0 = str2num(get(zef.h_exp_em_theta0,'string'));
zef.inv_snr = str2num(get(zef.h_exp_em_snr,'string'));
zef.inv_n_map_iterations = str2num(get(zef.h_exp_em_n_map_iterations,'string'));
zef.inv_n_L1_iterations = str2num(get(zef.h_exp_em_n_L1_iterations,'string'));
%zef.inv_pcg_tol = str2num(get(zef.h_exp_em_pcg_tol,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_exp_em_sampling_frequency,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_exp_em_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_exp_em_high_cut_frequency,'string'));
zef.inv_data_segment = str2num(get(zef.h_exp_em_data_segment,'string'));
zef.inv_time_1 = str2num(get(zef.h_exp_em_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_exp_em_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_exp_em_time_3,'string'));
zef.number_of_frames = str2num(get(zef.h_exp_em_number_of_frames,'string'));
zef.normalize_data = get(zef.h_exp_em_normalize_data ,'value');

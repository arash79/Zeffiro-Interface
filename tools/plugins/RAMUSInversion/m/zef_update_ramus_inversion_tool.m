%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.ramus_multires_n_levels = str2num(get(zef — Zef.ramus multires n levels = str2num(get(zef.
%
% Purpose:
%   Zef.ramus multires n levels = str2num(get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_ramus_high_cut_frequency (read)
%   zef.h_ramus_hyperprior (read)
%   zef.h_ramus_init_guess_mode (read)
%   zef.h_ramus_low_cut_frequency (read)
%   zef.h_ramus_multires_n_decompositions (read)
%   zef.h_ramus_multires_n_iter (read)
%   zef.h_ramus_multires_sparsity (read)
%   zef.h_ramus_normalize_data (read)
%   zef.h_ramus_number_of_frames (read)
%   zef.h_ramus_sampling_frequency (read)
%   zef.h_ramus_snr (read)
%   zef.h_ramus_time_1 (read)
%   zef.h_ramus_time_2 (read)
%   zef.h_ramus_time_3 (read)
%   zef.inv_high_cut_frequency (read, write)
%   … (22 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.ramus_multires_n_levels = str2num(get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.ramus_multires_n_levels = str2num(get(zef.h_ramus_multires_n_levels,'string'));
zef.ramus_multires_sparsity = str2num(get(zef.h_ramus_multires_sparsity,'string'));
zef.ramus_multires_n_decompositions = str2num(get(zef.h_ramus_multires_n_decompositions,'string'));
zef.ramus_snr = str2num(get(zef.h_ramus_snr,'string'));
zef.ramus_multires_n_iter = str2num(get(zef.h_ramus_multires_n_iter,'string'));
zef.ramus_sampling_frequency = str2num(get(zef.h_ramus_sampling_frequency,'string'));
zef.ramus_low_cut_frequency = str2num(get(zef.h_ramus_low_cut_frequency,'string'));
zef.ramus_high_cut_frequency = str2num(get(zef.h_ramus_high_cut_frequency,'string'));
zef.ramus_time_1 = str2num(get(zef.h_ramus_time_1,'string'));
zef.ramus_time_2 = str2num(get(zef.h_ramus_time_2,'string'));
zef.ramus_time_3 = str2num(get(zef.h_ramus_time_3,'string'));
zef.ramus_number_of_frames = str2num(get(zef.h_ramus_number_of_frames,'string'));
zef.ramus_normalize_data = get(zef.h_ramus_normalize_data ,'value');
zef.ramus_init_guess_mode = get(zef.h_ramus_init_guess_mode ,'value');
zef.ramus_initial_guess_mode = get(zef.h_ramus_normalize_data ,'value');
zef.ramus_hyperprior = get(zef.h_ramus_hyperprior ,'value');
zef.inv_time_1 = str2num(get(zef.h_ramus_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_ramus_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_ramus_time_3,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_ramus_sampling_frequency,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_ramus_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_ramus_high_cut_frequency,'string'));
zef.number_of_frames = str2num(get(zef.h_ramus_number_of_frames,'string'));
zef.inv_snr = zef.ramus_snr;

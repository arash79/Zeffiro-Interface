%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.ias_hyperprior = get(zef — Zef.ias hyperprior = get(zef.
%
% Purpose:
%   Zef.ias hyperprior = get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_ias_high_cut_frequency (read)
%   zef.h_ias_low_cut_frequency (read)
%   zef.h_ias_n_map_iterations (read)
%   zef.h_ias_normalize_data (read)
%   zef.h_ias_number_of_frames (read)
%   zef.h_ias_sampling_frequency (read)
%   zef.h_ias_snr (read)
%   zef.h_ias_time_1 (read)
%   zef.h_ias_time_2 (read)
%   zef.h_ias_time_3 (read)
%   zef.h_ias_type (read)
%   zef.ias_high_cut_frequency (read, write)
%   zef.ias_low_cut_frequency (read, write)
%   zef.ias_n_map_iterations (read, write)
%   zef.ias_normalize_data (read, write)
%   … (15 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.ias_hyperprior = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.ias_hyperprior = get(zef.h_ias_hyperprior ,'value');
zef.ias_snr = str2num(get(zef.h_ias_snr,'string'));
zef.ias_type = get(zef.h_ias_type,'value');
zef.ias_n_map_iterations = str2num(get(zef.h_ias_n_map_iterations,'string'));
zef.ias_sampling_frequency = str2num(get(zef.h_ias_sampling_frequency,'string'));
zef.ias_low_cut_frequency = str2num(get(zef.h_ias_low_cut_frequency,'string'));
zef.ias_high_cut_frequency = str2num(get(zef.h_ias_high_cut_frequency,'string'));
zef.ias_time_1 = str2num(get(zef.h_ias_time_1,'string'));
zef.ias_time_2 = str2num(get(zef.h_ias_time_2,'string'));
zef.ias_time_3 = str2num(get(zef.h_ias_time_3,'string'));
zef.ias_number_of_frames = str2num(get(zef.h_ias_number_of_frames,'string'));
zef.ias_normalize_data = get(zef.h_ias_normalize_data ,'value');
zef.inv_time_1 = str2num(get(zef.h_ias_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_ias_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_ias_time_3,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_ias_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_ias_high_cut_frequency,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_ias_sampling_frequency,'string'));
zef.number_of_frames = str2num(get(zef.h_ias_number_of_frames,'string'));
zef.inv_snr = zef.ias_snr;

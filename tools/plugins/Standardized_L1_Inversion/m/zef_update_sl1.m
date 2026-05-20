%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.sl1_hyperprior = get(zef — Zef.sl1 hyperprior = get(zef.
%
% Purpose:
%   Zef.sl1 hyperprior = get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_sl1_high_cut_frequency (read)
%   zef.h_sl1_low_cut_frequency (read)
%   zef.h_sl1_n_map_iterations (read)
%   zef.h_sl1_normalize_data (read)
%   zef.h_sl1_number_of_frames (read)
%   zef.h_sl1_sampling_frequency (read)
%   zef.h_sl1_snr (read)
%   zef.h_sl1_time_1 (read)
%   zef.h_sl1_time_2 (read)
%   zef.h_sl1_time_3 (read)
%   zef.h_sl1_type (read)
%   zef.inv_high_cut_frequency (read, write)
%   zef.inv_low_cut_frequency (read, write)
%   zef.inv_sampling_frequency (read, write)
%   zef.inv_snr (read, write)
%   … (15 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.sl1_hyperprior = get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.sl1_hyperprior = get(zef.h_sl1_hyperprior ,'value');
zef.sl1_snr = str2num(get(zef.h_sl1_snr,'string'));
zef.sl1_type = get(zef.h_sl1_type,'value');
zef.sl1_n_map_iterations = str2num(get(zef.h_sl1_n_map_iterations,'string'));
zef.sl1_sampling_frequency = str2num(get(zef.h_sl1_sampling_frequency,'string'));
zef.sl1_low_cut_frequency = str2num(get(zef.h_sl1_low_cut_frequency,'string'));
zef.sl1_high_cut_frequency = str2num(get(zef.h_sl1_high_cut_frequency,'string'));
zef.sl1_time_1 = str2num(get(zef.h_sl1_time_1,'string'));
zef.sl1_time_2 = str2num(get(zef.h_sl1_time_2,'string'));
zef.sl1_time_3 = str2num(get(zef.h_sl1_time_3,'string'));
zef.sl1_number_of_frames = str2num(get(zef.h_sl1_number_of_frames,'string'));
zef.sl1_normalize_data = get(zef.h_sl1_normalize_data ,'value');
zef.inv_time_1 = str2num(get(zef.h_sl1_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_sl1_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_sl1_time_3,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_sl1_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_sl1_high_cut_frequency,'string'));
zef.inv_sampling_frequency = str2num(get(zef.h_sl1_sampling_frequency,'string'));
zef.number_of_frames = str2num(get(zef.h_sl1_number_of_frames,'string'));
zef.inv_snr = zef.sl1_snr;

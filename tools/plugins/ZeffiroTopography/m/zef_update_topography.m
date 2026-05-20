%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.top_regularization_parameter = str2num(get(zef — Zef.top regularization parameter = str2num(get(zef.
%
% Purpose:
%   Zef.top regularization parameter = str2num(get(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_top_data_segment (read)
%   zef.h_top_high_cut_frequency (read)
%   zef.h_top_low_cut_frequency (read)
%   zef.h_top_normalize_data (read)
%   zef.h_top_number_of_frames (read)
%   zef.h_top_sampling_frequency (read)
%   zef.h_top_time_1 (read)
%   zef.h_top_time_2 (read)
%   zef.h_top_time_3 (read)
%   zef.inv_data_segment (read, write)
%   zef.inv_high_cut_frequency (read, write)
%   zef.inv_low_cut_frequency (read, write)
%   zef.inv_sampling_frequency (read, write)
%   zef.inv_time_1 (read, write)
%   zef.inv_time_2 (read, write)
%   … (12 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.top_regularization_parameter = str2num(get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.top_regularization_parameter = str2num(get(zef.h_top_regularization_parameter,'string'));
zef.top_sampling_frequency = str2num(get(zef.h_top_sampling_frequency,'string'));
zef.top_low_cut_frequency = str2num(get(zef.h_top_low_cut_frequency,'string'));
zef.top_high_cut_frequency = str2num(get(zef.h_top_high_cut_frequency,'string'));
zef.top_data_segment = str2num(get(zef.h_top_data_segment,'string'));
zef.top_time_1 = str2num(get(zef.h_top_time_1,'string'));
zef.top_time_2 = str2num(get(zef.h_top_time_2,'string'));
zef.top_time_3 = str2num(get(zef.h_top_time_3,'string'));
zef.top_number_of_frames = str2num(get(zef.h_top_number_of_frames,'string'));
zef.top_normalize_data = get(zef.h_top_normalize_data ,'value');

zef.inv_sampling_frequency = str2num(get(zef.h_top_sampling_frequency,'string'));
zef.inv_low_cut_frequency = str2num(get(zef.h_top_low_cut_frequency,'string'));
zef.inv_high_cut_frequency = str2num(get(zef.h_top_high_cut_frequency,'string'));
zef.inv_data_segment = str2num(get(zef.h_top_data_segment,'string'));
zef.inv_time_1 = str2num(get(zef.h_top_time_1,'string'));
zef.inv_time_2 = str2num(get(zef.h_top_time_2,'string'));
zef.inv_time_3 = str2num(get(zef.h_top_time_3,'string'));
zef.number_of_frames = str2num(get(zef.h_top_number_of_frames,'string'));
zef.normalize_data = get(zef.h_top_normalize_data ,'value');

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef.bf_sampling_frequency = str2num(get(zef — Zef.bf sampling frequency = str2num(get(zef.
%
% Purpose:
%   Zef.bf sampling frequency = str2num(get(zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.bf_data_segment (read, write)
%   zef.bf_high_cut_frequency (read, write)
%   zef.bf_low_cut_frequency (read, write)
%   zef.bf_normalize_data (read, write)
%   zef.bf_time_1 (read, write)
%   zef.bf_time_2 (read, write)
%   zef.h_bf_data_segment (read)
%   zef.h_bf_high_cut_frequency (read)
%   zef.h_bf_low_cut_frequency (read)
%   zef.h_bf_normalize_data (read)
%   zef.h_bf_time_1 (read)
%   zef.h_bf_time_2 (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef.bf_sampling_frequency = str2num(get(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.bf_sampling_frequency = str2num(get(zef.h_bf_sampling_frequency,'string'));
zef.bf_low_cut_frequency = str2num(get(zef.h_bf_low_cut_frequency,'string'));
zef.bf_high_cut_frequency = str2num(get(zef.h_bf_high_cut_frequency,'string'));
zef.bf_data_segment = str2num(get(zef.h_bf_data_segment,'string'));
zef.bf_time_1 = str2num(get(zef.h_bf_time_1,'string'));
zef.bf_time_2 = str2num(get(zef.h_bf_time_2,'string'));
zef.bf_normalize_data = get(zef.h_bf_normalize_data ,'value');

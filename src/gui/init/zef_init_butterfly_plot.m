%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isfield(zef,'bf_sampling_frequency')) — If not(isfield(zef,'bf sampling frequency')).
%
% Purpose:
%   If not(isfield(zef,'bf sampling frequency')).
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.bf_data_segment (read, write)
%   zef.bf_high_cut_frequency (read, write)
%   zef.bf_low_cut_frequency (read, write)
%   zef.bf_normalize_data (read, write)
%   zef.bf_sampling_frequency (read, write)
%   zef.bf_time_1 (read, write)
%   zef.bf_time_2 (read, write)
%   zef.h_bf_data_segment (read)
%   zef.h_bf_high_cut_frequency (read)
%   zef.h_bf_low_cut_frequency (read)
%   zef.h_bf_normalize_data (read)
%   zef.h_bf_sampling_frequency (read)
%   zef.h_bf_time_1 (read)
%   zef.h_bf_time_2 (read)
%   zef.inv_data_segment (read)
%   … (6 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'bf_sampling_frequency'))` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




if not(isfield(zef,'bf_sampling_frequency'))
    zef.bf_sampling_frequency = zef.inv_sampling_frequency;
end

if not(isfield(zef,'bf_low_cut_frequency'))
    zef.bf_low_cut_frequency = zef.inv_low_cut_frequency;
end

if not(isfield(zef,'bf_high_cut_frequency'))
    zef.bf_high_cut_frequency = zef.inv_high_cut_frequency;
end

if not(isfield(zef,'bf_time_1'))
    zef.bf_time_1 = zef.inv_time_1;
end

if not(isfield(zef,'bf_time_2'))
    zef.bf_time_2 = zef.inv_time_2;
end

if not(isfield(zef,'bf_data_segment'))
    zef.bf_data_segment =  zef.inv_data_segment;
end;
if not(isfield(zef,'bf_normalize_data'))
    zef.bf_normalize_data = zef.normalize_data;
end;

set(zef.h_bf_sampling_frequency ,'string',num2str(zef.bf_sampling_frequency));
set(zef.h_bf_low_cut_frequency ,'string',num2str(zef.bf_low_cut_frequency));
set(zef.h_bf_high_cut_frequency ,'string',num2str(zef.bf_high_cut_frequency));
set(zef.h_bf_data_segment ,'string',num2str(zef.bf_data_segment));
set(zef.h_bf_normalize_data ,'value',zef.bf_normalize_data);
set(zef.h_bf_time_1 ,'string',num2str(zef.bf_time_1));
set(zef.h_bf_time_2 ,'string',num2str(zef.bf_time_2));

function [processed_data] = zef_simple_downsampling_filter(f, downsampled_frequency, sampling_frequency)
% --- Zeffiro documentation header ---
% zef_simple_downsampling_filter — Zef simple downsampling filter.
%
% Purpose:
%   Zef simple downsampling filter.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   f
%   downsampled_frequency
%   sampling_frequency
%
% Outputs:
%   processed_data
%
% Calls (project):
%   zef_simple_downsampling_filter
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[processed_data] = zef_simple_downsampling_filter(f, downsampled_frequency, sampling_frequency)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function processes the N-by-M data array f for N channels and M time
%steps. The other arguments can be controlled via the ZI user interface.
%The desctiption and argument definitions shown in ZI are listed below.
%Description: Simple downsampling filter
%Input: 1 Downsampled frequency (Hz) [Default: filter_sampling_rate],
%2 Original sampling frequency (Hz) [Default: filter_sampling_rate]
%Output: Data limited to the given time interval.

%Conversion between string and numeric data types.
if isstr(downsampled_frequency)
    downsampled_frequency = str2num(downsampled_frequency);
end
if isstr(sampling_frequency)
    sampling_frequency = str2num(sampling_frequency);
end
%End of conversion.

skip_param = floor(sampling_frequency/downsampled_frequency);

processed_data = f(:,1:skip_param:end);

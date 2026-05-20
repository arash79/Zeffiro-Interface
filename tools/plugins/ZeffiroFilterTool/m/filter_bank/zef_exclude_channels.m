function [processed_data] = zef_exclude_channels(f, exclude_channels)
% --- Zeffiro documentation header ---
% zef_exclude_channels — Zef exclude channels.
%
% Purpose:
%   Zef exclude channels.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   f
%   exclude_channels
%
% Outputs:
%   processed_data
%
% Calls (project):
%   zef_exclude_channels
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[processed_data] = zef_exclude_channels(f, exclude_channels)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function processes the N-by-M data array f for N channels and M time
%steps. The other arguments can be controlled via the ZI user interface.
%The desctiption and argument definitions shown in ZI are listed below.
%Description: Exclude channels
%Input: 1 Exclude channels [Default: ]
%Output: Data without the excluded channels.

%Conversion between string and numeric data types.
if isstr(exclude_channels)
    exclude_channels = str2num(exclude_channels);
end
%End of conversion.

selected_channels = find(not(ismember([1:length(f)],exclude_channels)));

processed_data = f(selected_channels,:);

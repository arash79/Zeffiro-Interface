function [processed_data] = zef_select_channels(f, select_channels)
% --- Zeffiro documentation header ---
% zef_select_channels — Zef select channels.
%
% Purpose:
%   Zef select channels.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   f
%   select_channels
%
% Outputs:
%   processed_data
%
% Calls (project):
%   zef_select_channels
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[processed_data] = zef_select_channels(f, select_channels)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function processes the N-by-M data array f for N channels and M time
%steps. The other arguments can be controlled via the ZI user interface.
%The desctiption and argument definitions shown in ZI are listed below.
%Description: Select channels
%Input: 1 Selected channels [Default: '']
%Output: Data for selected channels.

%Conversion between string and numeric data types.

if isstr(select_channels)
    select_channels = str2num(select_channels);
end
%End of conversion.

processed_data = f(select_channels,:);

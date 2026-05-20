function [y_vals, plot_mode] = zef_dtw_mean_scaling(time_series)
% --- Zeffiro documentation header ---
% zef_dtw_mean_scaling — Zef dtw mean scaling.
%
% Purpose:
%   Zef dtw mean scaling.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   time_series
%
% Outputs:
%   y_vals
%   plot_mode
%
% Calls (project):
%   zef_dtw_mean_scaling
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[y_vals, plot_mode]] = zef_dtw_mean_scaling(time_series)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function processes the N-by-M data array f for N channels and M time
%steps. The other arguments can be controlled via the ZI user interface.
%The desctiption and argument definitions shown in ZI are listed below.
%Description: Dynamic time warping (DTW), mean scaling

time_series = time_series./max(time_series);
y_vals = zeros(size(time_series,1), size(time_series,1));
for i = 1 : size(time_series,1)
    for j = 1 : size(time_series,1)
        y_vals(i,j) = dtw(time_series(i,:),time_series(j,:));
    end
end

plot_mode = 2;

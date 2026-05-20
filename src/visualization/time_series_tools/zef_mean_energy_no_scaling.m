function [y_vals, plot_mode] = zef_mean_energy_no_scaling(time_series)
% --- Zeffiro documentation header ---
% zef_mean_energy_no_scaling — Zef mean energy no scaling.
%
% Purpose:
%   Zef mean energy no scaling.
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
%   zef_mean_energy_no_scaling
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[y_vals, plot_mode]] = zef_mean_energy_no_scaling(time_series)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function processes the N-by-M data array f for N channels and M time
%steps. The other arguments can be controlled via the ZI user interface.
%The desctiption and argument definitions shown in ZI are listed below.
%Description: Mean energy, no scaling

time_series = time_series./mean(time_series);
y_vals = std(time_series');

plot_mode = 1;

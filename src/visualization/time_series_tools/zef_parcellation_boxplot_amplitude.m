function [y_vals, plot_mode] = zef_parcellation_boxplot_amplitude(time_series)
% --- Zeffiro documentation header ---
% zef_parcellation_boxplot_amplitude — Zef parcellation boxplot amplitude.
%
% Purpose:
%   Zef parcellation boxplot amplitude.
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
%   zef_parcellation_boxplot_amplitude
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[y_vals, plot_mode]] = zef_parcellation_boxplot_amplitude(time_series)` with project root and `src` on the path.
% --- End Zeffiro documentation header

plot_mode = 4; % custom mode for boxplot rendering

if ~iscell(time_series)
    error('Time series must be a cell array for boxplot mode.');
end

[num_rois, num_frames] = size(time_series);
y_vals = cell(num_rois, 1);

for i = 1:num_rois
    % Collect all frame samples for the i-th ROI
    all_samples = [];
    for j = 1:num_frames
        if ~isempty(time_series{i, j})
            all_samples = [all_samples; abs(time_series{i, j}(:))];
        end
    end
    y_vals{i} = all_samples;
end

end

function [reconstruction, sample_rate, time_step, column_title_vec] = reconstruction_from_edf_fn(path_to_file)
% --- Zeffiro documentation header ---
% utilities.io.reconstruction_from_edf_fn — Reconstruction from edf fn.
%
% Purpose:
%   Reconstruction from edf fn.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   path_to_file
%
% Outputs:
%   reconstruction
%   sample_rate
%   time_step
%   column_title_vec
%
% Calls (project):
%   utilities.io.reconstruction_from_edf_fn
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[reconstruction, sample_rate, time_step]] = utilities.io.reconstruction_from_edf_fn(path_to_file)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments

    path_to_file (1,1) string { mustBeFile }

end

% Load EDF into a timetable (requires Signal Processing Toolbox or compatible).
timetable = edfread(path_to_file);

% Infer dimensions from the first cell (assumes constant samples per channel).
[n_of_rows, n_of_cols] = size(timetable);

upper_left_corner_cell = timetable{1,1};

upper_left_corner_series = upper_left_corner_cell{1,1};

cell_size = numel(upper_left_corner_series);

% Preallocate: one row per channel (timetable column), columns = time points.
reconstruction = zeros(n_of_cols, n_of_rows * cell_size);

% Fill each channel row by concatenating the timetable cells for that column.
for col = 1 : n_of_cols

    col_of_cells = timetable{:,col};

    col_as_matrix = [col_of_cells{:}];

    matrix_as_vector = col_as_matrix(:);

    reconstruction(col,:) = matrix_as_vector;

end % for

% Derive sampling metadata and channel names from the timetable.
time_step = seconds(timetable.Properties.TimeStep);

sample_rate = cell_size / time_step;

column_title_cells = timetable.Properties.VariableNames';

column_title_vec = string(column_title_cells);

end % function

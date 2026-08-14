function [reconstruction, sample_rate, time_step, column_title_vec] = reconstruction_from_edf_fn(path_to_file)
%RECONSTRUCTION_FROM_EDF_FN  Load multichannel EDF into a reconstruction matrix.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [reconstruction, sample_rate, time_step, column_title_vec] = ...
%       reconstruction_from_edf_fn(path_to_file)
%
%   Uses edfread (Signal Processing Toolbox). Each timetable column is one
%   channel; cells are concatenated horizontally into reconstruction rows.
%   sample_rate = samples_per_cell / time_step; column_title_vec holds
%   VariableNames from the timetable.

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

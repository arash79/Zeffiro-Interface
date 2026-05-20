function save_dats(out_dir)
% --- Zeffiro documentation header ---
% utilities.fs2zef.generators.save_dats — Save dats.
%
% Purpose:
%   Save dats.
%   Folder: Reusable utilities: cluster dispatch, Brainstorm/FreeSurfer/Duneuro/SN converters, plotting helpers, inverse frame loop, sensitivity Monte Carlo.
%
% Inputs:
%   out_dir
%
% Outputs:
%   See function signature and code below.
%
% Calls (project):
%   utilities.fs2zef.generators.save_dats
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `utilities.fs2zef.generators.save_dats(out_dir)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%
% save_dats
%
% Converts FreeSurfer ASCII label files (.asc) to DAT format for Zeffiro
% Interface. Extracts point coordinates from merged label files and saves them
% in a format compatible with Zeffiro's import system.
%
% The function processes both left and right hemisphere labels for two
% parcellation schemes:
%   - 76 labels: Destrieux parcellation (aparc.a2009s)
%   - 36 labels: Desikan-Killiany parcellation (aparc)
%
% Inputs:
%
% - out_dir (1,1) string { mustBeFolder }
%
%   The output directory containing the merged label files (lh_labels_76.asc,
%   rh_labels_76.asc, lh_labels_36.asc, rh_labels_36.asc) and where the
%   corresponding DAT files will be saved.
%
% Outputs:
%
%   None. The function saves four DAT files:
%   - lh_points_76.dat, rh_points_76.dat (76-label parcellation)
%   - lh_points_36.dat, rh_points_36.dat (36-label parcellation)
%

    arguments

        out_dir (1,1) string { mustBeFolder }

    end

    % Normalize the output directory path
    dir_name = fullfile(out_dir);

    % Process left hemisphere 76-label parcellation
    % Read merged label file (skip first 2 header lines, start from row 3)
    a = dlmread(fullfile(dir_name, 'lh_labels_76.asc'), ' ', 2, 0);
    % Extract columns: x-coord, y-coord, z-coord, and label (columns 1, 3, 5, 7)
    a = a(:, [1, 3, 5, 7]);
    save(fullfile(dir_name, 'lh_points_76.dat'), '-ascii', 'a');

    % Process right hemisphere 76-label parcellation
    a = dlmread(fullfile(dir_name, 'rh_labels_76.asc'), ' ', 2, 0);
    a = a(:, [1, 3, 5, 7]);
    save(fullfile(dir_name, 'rh_points_76.dat'), '-ascii', 'a');

    % Process left hemisphere 36-label parcellation
    a = dlmread(fullfile(dir_name, 'lh_labels_36.asc'), ' ', 2, 0);
    a = a(:, [1, 3, 5, 7]);
    save(fullfile(dir_name, 'lh_points_36.dat'), '-ascii', 'a');

    % Process right hemisphere 36-label parcellation
    a = dlmread(fullfile(dir_name, 'rh_labels_36.asc'), ' ', 2, 0);
    a = a(:, [1, 3, 5, 7]);
    save(fullfile(dir_name, 'rh_points_36.dat'), '-ascii', 'a');

end % function

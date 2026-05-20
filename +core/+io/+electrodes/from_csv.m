function [electrode_data, electrode_labels] = from_csv(file, kwargs)
% --- Zeffiro documentation header ---
% core.io.electrodes.from_csv — Parses electrode file format and returns positions, optional CEM columns, and labels.
%
% Purpose:
%   Parses electrode file format and returns positions, optional CEM columns, and labels.
%   Folder: Parses electrode positions (and optional CEM columns) from `.csv` and `.dat` files; returns numeric data and label strings.
%
% Inputs:
%   file
%   kwargs
%
% Outputs:
%   electrode_data
%   electrode_labels
%
% Calls (project):
%   core.io.electrodes.from_csv
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[electrode_data, electrode_labels]] = core.io.electrodes.from_csv(file, kwargs)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments

        file (1,1) string { mustBeFile }

        kwargs.MISSING_LABEL (1,1) string = "S"

    end

    % Load CSV as table and infer column layout from variable names.
    electrode_table = readtable ( file ) ;
    column_titles = string ( electrode_table.Properties.VariableNames ) ;
    [ n_of_rows, ~ ] = size ( electrode_table ) ;

    % Preallocate: up to 6 numeric columns; default labels use MISSING_LABEL + index.

    electrode_data = zeros ( n_of_rows, 6 ) ;

    electrode_labels = repmat ( kwargs.MISSING_LABEL, n_of_rows, 1 ) + ( 1 : n_of_rows )' ;

    % Fill position columns (x, y, z) and optional label column.

    if ismember ( "x", column_titles )

        electrode_data(:,1) = electrode_table.x ;

    else

        error("Electrodes should have an x-column, but the file " + file + " does not contain one. Aborting...")

    end

    if ismember ( "y", column_titles )

        electrode_data(:,2) = electrode_table.y ;

    else

        error("Electrodes should have a y-column, but the file " + file + " does not contain one. Aborting...")

    end

    if ismember ( "z", column_titles )

        electrode_data(:,3) = electrode_table.z ;

    else

        error("Electrodes should have a z-column, but the file " + file + " does not contain one. Aborting...")

    end

    if ismember ( "label", column_titles )

        electrode_labels = string ( electrode_table.label ) ;

    end

    % Optional CEM columns: all three must be present to be used.
    cem_data_set = false ;

    if ismember ( "inner_radius", column_titles ) ...
    && ismember ( "outer_radius", column_titles) ...
    && ismember ( "impedance", column_titles )

        inner_radii = double ( electrode_table.inner_radius ) ;

        outer_radii = double ( electrode_table.outer_radius ) ;

        impedances = double ( electrode_table.impedance ) ;

        assert ( ( numel ( inner_radii ) == numel ( outer_radii ) ) && ( numel ( outer_radii ) == numel ( impedances ) ), "Each column in file " + file + " must contain the same number of rows. Aborting..." ) ;

        for ii = 1 : numel( inner_radii )

            if isnan ( inner_radii (ii) )

                error ( "The inner radius at row " + ii + " of file " + file + " could not be converted to double. Aborting..." ) ;

            end

            if isnan ( outer_radii (ii) )

                error ( "The outer radius at row " + ii + " of file " + file + " could not be converted to double. Aborting..." ) ;

            end

            if isnan ( impedances (ii) )

                error ( "The impedance at row " + ii + " of file " + file + " could not be converted to double. Aborting..." ) ;

            end

            if inner_radii (ii) < 0

                error ( "The inner radius at row " + ii + " of file " + file + " was less than 0. Aborting..." ) ;

            end

            if impedances (ii) < 0

                error ( "The impedance at row " + ii + " of file " + file + " was less than 0. Aborting..." ) ;

            end

            if inner_radii (ii) >= outer_radii (ii)

                error ( "The inner radius at row " + ii + " of file " + file + " was greater than or equal to the corresponding outer radius. Aborting..." ) ;

            end

        end % for

        electrode_data(:,4) = inner_radii ;

        electrode_data(:,5) = outer_radii ;

        electrode_data(:,6) = impedances ;

        cem_data_set = true ;

    else

        if ismember ( "inner_radius", column_titles ) ...
        || ismember ( "outer_radius", column_titles) ...
        || ismember ( "impedance", column_titles )

            warning ( "At least one but not all of inner_radius, outer_radius or impedance columns were found in file " + file + ", but all are required for complete electrode model data to be recorded. Ignoring..." );

        end % if

    end % if

    % Return only (x,y,z) if no CEM data was present.

    if not ( cem_data_set )

        electrode_data(:, 4 : 6) = [] ;

    end

end % function

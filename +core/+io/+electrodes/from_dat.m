function [ electrode_data, electrode_labels ] = from_dat(file, kwargs)
%FROM_DAT  Read electrode positions from a whitespace-separated .dat file.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Parser used by Import → Import electrodes when the chosen file has
%   extension .dat. Bundled examples such as ProneFreeSurfer/ascii/electrodes.dat
%   and data/electrodes use this layout. Same numeric contract as
%   core.io.electrodes.from_csv: N-by-3 point electrodes or N-by-6 CEM.
%
%   Each non-empty line must have 3, 4, 6, or 7 whitespace-separated fields:
%     x y z
%     x y z label
%     x y z inner_radius outer_radius impedance
%     x y z label inner_radius outer_radius impedance
%   There is no header row. Empty lines are skipped. Coordinates and
%   radii are not converted (typically millimetres). Impedance is ohms.
%
%   Mixed files: if any row has CEM columns, the output is N-by-6 and
%   point-only rows keep zeros in columns 4–6. If every CEM column is
%   zero after parsing, those three columns are dropped so the result
%   is N-by-3. Unlike from_csv, a 6-column line cannot carry a label
%   (use 7 columns for label + CEM). Impedance must be strictly positive
%   on CEM rows (from_csv allows 0).
%
%   [data, labels] = core.io.electrodes.from_dat(file)
%   [data, labels] = core.io.electrodes.from_dat(file, "MISSING_LABEL", "S")
%
%   Inputs
%     file           - existing file path (mustBeFile).
%     MISSING_LABEL  - prefix for default labels S1, S2, … Default "S".
%
%   Outputs
%     electrode_data    - N-by-3 or N-by-6 double.
%     electrode_labels  - N-by-1 string. Column 4 of a 4- or 7-column
%                         line, otherwise MISSING_LABEL + row index.
%
%   See also core.io.electrodes.from_csv, core.gui.menu_tool.import_electrodes_callback.

    arguments

        file (1,1) string { mustBeFile }

        kwargs.MISSING_LABEL (1,1) string = "S"

    end

    % Read all non-empty lines and preallocate outputs (max 6 numeric columns).
    text_lines = readlines ( file, "EmptyLineRule", "skip"  ) ;
    n_of_rows = numel ( text_lines ) ;
    electrode_data = zeros ( n_of_rows, 6 ) ;
    electrode_labels = repmat ( kwargs.MISSING_LABEL, n_of_rows, 1 ) + ( 1 : n_of_rows )' ;

    for li = 1 : numel ( text_lines )

        line_cols = split ( text_lines ( li ) ) ;

        n_of_cols = numel ( line_cols ) ;

        if not ( n_of_cols == 3 || n_of_cols == 4 || n_of_cols == 6 || n_of_cols == 7 )
            error ( "Line " + li + " of the given electrode file does not contain 3, 4, 6 or 7 columns. The format of each line should be ""x y z [label inner_radius outer_radius impedance]"". Aborting..." ) ;
        end

        % Parse (x, y, z) and validate numeric conversion.

        position = double ( line_cols ( 1 : 3 ) ) ;

        for posi = 1 : numel ( position )

            if isnan ( position ( posi ) )

                error ( "Could not convert coordinate " + posi + " of electrode position on line " + li + "to a double. Aborting..." ) ;

            end % if

        end % for

        electrode_data ( li, 1 : 3 ) = position ;

        % Label: use column 4 if present (4- or 7-column format), else default.

        if n_of_cols == 4 || n_of_cols == 7

            label = line_cols ( 4 ) ;

            if strlength ( label ) == 0

                label = electrode_labels ( li ) ;

            end % if

        else

            label = electrode_labels ( li ) ;

        end % if

        electrode_labels ( li ) = label ;

        % CEM columns: 4–6 for 6-column lines (x,y,z,ir,or,imp); 5–7 for 7-column (with label).
        if n_of_cols == 6
            iri = 4 ; ori = 5 ; ii = 6 ;
        elseif n_of_cols == 7
            iri = 5 ; ori = 6 ; ii = 7 ;
        end

        % Parse and validate complete electrode model (inner/outer radius, impedance).

        if n_of_cols == 6 || n_of_cols == 7

            inner_radius = double ( line_cols ( iri ) ) ;

            if isnan ( inner_radius )

                error ( "Could not convert electrode inner radius (column " + iri + ") on line " + li + " of file " + file + " into a double. Aborting..." ) ;

            end % if

            if inner_radius < 0

                error ( "The radius of an electrode inner radius (column " + iri + ") cannot be less than 0 on line " + li + " of file " + file + ". Aborting..." )

            end % if

            outer_radius = double ( line_cols ( ori) ) ;

            if isnan ( outer_radius )

                error ( "Could not convert electrode outer radius (column " + ori + ") on line " + li + " of file " + file + " into a double. Aborting..." ) ;

            end % if

            if inner_radius >= outer_radius

                error ( "The inner radius (column " + iri + ") of a given electrode was the same or greater than its outer radius (column " + ori + ") on line " + li + " of " + file + ". Aborting..." ) ;

            end % if

            impedance = double ( line_cols ( ii ) ) ;

            if isnan ( impedance )

                error ( "Could not convert electrode impedance (column " + ii + ") on line " + li + " of file " + file + " into a double. Aborting..." ) ;

            end % if

            if impedance <= 0

                error ( "The impedance (column " + ii + ") of a complete electrode on line " + li + " of file " + file + " cannot be 0 or negative. Aborting..." ) ;

            end % if

            electrode_data (li, 4) = inner_radius;

            electrode_data (li, 5) = outer_radius;

            electrode_data (li, 6) = impedance;

        end % if

    end % for

    % If no row had CEM data, return only the 3 position columns.
    cem_cols = 4 : 6 ;

    last_3_cols = electrode_data ( : , cem_cols ) ;

    last_3_cols = last_3_cols(:);

    if all ( last_3_cols == 0 )

        electrode_data(:, cem_cols ) = [] ;

    end

end % function

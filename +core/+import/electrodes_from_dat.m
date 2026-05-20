function [ electrode_data, electrode_labels ] = electrodes_from_dat(file, kwargs)
% electrodes_from_dat — Import electrode positions and labels from a .dat text file.
%
% Reads a whitespace-separated text file where each line defines one electrode.
% Supports optional labels and optional complete electrode model (CEM) parameters
% (inner radius, outer radius, impedance). Throws an error if the file is
% missing, unreadable, or if any line has an invalid format.
%
% Line format (whitespace-separated, no spaces within fields):
%
%   x y z [label] [inner_radius outer_radius impedance]
%
% - Columns 1–3 (x, y, z): required; electrode position in arbitrary units.
% - Column 4 (label): optional. If present, CEM columns 5–7 must also be present.
% - Columns 5–7: optional CEM data; if any is present, all three are required.
%   inner_radius and outer_radius must be non-negative; inner_radius < outer_radius;
%   impedance must be positive.
%
% Inputs:
%
%   file (1,1) string { mustBeFile }
%       Path to the text file. Each line must have 3, 4, 6, or 7 columns.
%
%   kwargs.MISSING_LABEL (1,1) string = "S"
%       Prefix for auto-generated labels when a line has no label (e.g. "S" → "S1", "S2").
%
% Outputs:
%
%   electrode_data (:,:) double
%       N-by-3 or N-by-6 array: (x,y,z) for each electrode; if CEM data was
%       present, columns 4–6 are inner_radius, outer_radius, impedance.
%
%   electrode_labels (N,1) string
%       Electrode names. Rows without a label in the file get MISSING_LABEL
%       plus row index (e.g. "S1", "S2"); empty labels in file are replaced
%       the same way.
%
% See also: core.import.electrodes_from_csv, readlines, split.
%
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

function zef = import_electrodes_callback(zef)
% import_electrodes_callback — Menu callback: Import electrodes from .dat or .csv.
%
% Invoked from Menu tool > Import > Import electrodes. Opens a file dialog
% restricted to .dat and .csv files; reads electrode positions (and optional
% labels and CEM data) and writes them into the central Zeffiro struct zef.
% Overwrites existing sensor data if present. On read or validation errors,
% shows an error dialog and returns without modifying zef.
%
% Input:
%   zef (1,1) struct — Central Zeffiro application struct.
%
% Output:
%   zef (1,1) struct — Same struct with sensor data updated:
%       zef.sensors, zef.<prefix>_points, zef.<prefix>_name_list. Prefix
%       comes from zef.current_sensors if set, otherwise "s" (e.g. s_points,
%       s_name_list). If the file contained CEM data, _points includes
%       columns 4–6 (inner_radius, outer_radius, impedance). zef_update is
%       called before return.
%
% See also: core.import.electrodes_from_dat, core.import.electrodes_from_csv,
%           uigetfile, zef_update.

    arguments
        zef (1,1) struct
    end

    filter = { '*.dat', 'DAT files' ; '*.csv', 'CSV files' } ;
    [ name, path ] = uigetfile ( filter, "Import electrodes from .dat or .csv" ) ;

    name = string ( name ) ;
    path = string ( path ) ;

    if name == "0" || path == "0"
        return
    end

    abspath = fullfile ( path, name ) ;
    [ ~, ~, extension ] = fileparts ( abspath ) ;

    if extension == ".dat"
        try
            [ electrode_data, electrode_labels ] = core.import.electrodes_from_dat ( abspath ) ;
        catch err
            fig = errordlg ( err.message, "Could not read DAT file." ) ;
            uiwait ( fig ) ;
            return
        end
    elseif extension == ".csv"
        try
            [ electrode_data, electrode_labels ] = core.import.electrodes_from_csv ( abspath ) ;
        catch err
            fig = errordlg ( err.message, "Could not read CSV file." ) ;
            uiwait ( fig ) ;
            return
        end
    else
        fig = errordlg ( "The chosen file was not a .dat or .csv file.", "Wrong file type" ) ;
        uiwait ( fig ) ;
        return
    end

    % Sensor field prefix: use current_sensors if set (e.g. "s2"), else "s".
    if isfield ( zef, "current_sensors" )
        name_field_prefix = zef.current_sensors ;
    else
        name_field_prefix = "s" ;
    end

    name_field_name   = name_field_prefix + "_name_list" ;
    points_field_name = name_field_prefix + "_points" ;

    zef.sensors = electrode_data ;
    zef.(points_field_name) = electrode_data ( :, 1 : 3 ) ;
    zef.(name_field_name)   = electrode_labels ;

    % Append CEM columns to _points when present (inner_radius, outer_radius, impedance).
    if size ( electrode_data, 2 ) == 6
        zef.(points_field_name) = [ ...
            zef.(points_field_name), ...
            electrode_data( :, 4 ), ...
            electrode_data( :, 5 ), ...
            electrode_data( :, 6 ) ...
        ] ;
    end

    zef = zef_update ( zef ) ;

end % function

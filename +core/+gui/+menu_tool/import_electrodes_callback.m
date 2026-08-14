function zef = import_electrodes_callback(zef)
%IMPORT_ELECTRODES_CALLBACK  Menu Import → Import electrodes.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from src/gui/tools/zef_menu_tool.m onto ImportelectrodesMenu
%   (parent menu text is "Import", item text is "Import electrodes").
%   Opens uigetfile for *.dat / *.csv, parses with from_dat or from_csv,
%   then writes:
%     zef.sensors              - full N-by-3 or N-by-6 matrix
%     zef.<prefix>_points      - same; CEM columns appended when present
%     zef.<prefix>_name_list   - string labels
%   Prefix is zef.current_sensors when that field exists (e.g. "s" or
%   "s2" for a second sensor set), otherwise "s". Then zef_update so the
%   segmentation/mesh tools show the new sensors.
%
%   Cancel (uigetfile returns 0) leaves zef unchanged. Parse errors are
%   shown with errordlg and also leave zef unchanged.
%
%   zef = core.gui.menu_tool.import_electrodes_callback(zef)
%
%   See also core.io.electrodes.from_csv, core.io.electrodes.from_dat, zef_update.

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
            [ electrode_data, electrode_labels ] = core.io.electrodes.from_dat ( abspath ) ;
        catch err
            fig = errordlg ( err.message, "Could not read DAT file." ) ;
            uiwait ( fig ) ;
            return
        end
    elseif extension == ".csv"
        try
            [ electrode_data, electrode_labels ] = core.io.electrodes.from_csv ( abspath ) ;
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

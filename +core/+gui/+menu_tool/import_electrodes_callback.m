function zef = import_electrodes_callback(zef)
% --- Zeffiro documentation header ---
% core.gui.menu_tool.import_electrodes_callback — GUI callback for import_electrodes actions.
%
% Purpose:
%   GUI callback for import_electrodes actions.
%   Folder: Menu callbacks wired from `src/gui/tools/zef_menu_tool.m` into refactored package code.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.current_sensors (read)
%   zef.sensors (read, write)
%
% Calls (project):
%   core.gui.menu_tool.import_electrodes_callback
%   core.io.electrodes.from_csv
%   core.io.electrodes.from_dat
%   zef_update
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Edit → Import electrodes (wired in `zef_menu_tool.m`).
%   Programmatic: `[zef] = core.gui.menu_tool.import_electrodes_callback(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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

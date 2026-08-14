classdef zef_segmentation_tool_app_exported < matlab.apps.AppBase
%ZEF_SEGMENTATION_TOOL_APP_EXPORTED  App Designer export: segmentation tool UIFigure.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Generated from the matching .mlapp; layout only—wire callbacks in src/gui/tools.
%   Tool scripts copy h_* properties into zef and attach MenuSelectedFcn/ButtonPushedFcn.
properties (Access = public)
        h_zeffiro_window_main           matlab.ui.Figure
        h_set_position                  matlab.ui.control.Button
        h_segmentation_tool_toggle      matlab.ui.control.Button
        h_profile_name                  matlab.ui.control.DropDown
        ProfileDropDownLabel            matlab.ui.control.Label
        h_project_tag                   matlab.ui.control.EditField
        ProjecttagEditFieldLabel        matlab.ui.control.Label
        h_project_notes                 matlab.ui.control.TextArea
        ProjectnotesTextAreaLabel       matlab.ui.control.Label
        ParametersLabel                 matlab.ui.control.Label
        SensorsLabel_2                  matlab.ui.control.Label
        h_sensors_name_table            matlab.ui.control.Table
        h_parameters_table              matlab.ui.control.Table
        TransformLabel                  matlab.ui.control.Label
        SensorsetsLabel                 matlab.ui.control.Label
        ProjectinformationLabel         matlab.ui.control.Label
        CompartmentsLabel               matlab.ui.control.Label
        h_project_information           matlab.ui.control.ListBox
        h_transform_table               matlab.ui.control.Table
        h_sensors_table                 matlab.ui.control.Table
        h_compartment_table             matlab.ui.control.Table
        h_axes2                         matlab.ui.control.Image
        h_menu_compartment_table        matlab.ui.container.ContextMenu
        h_menu_lock_on                  matlab.ui.container.Menu
        h_menu_add_compartment          matlab.ui.container.Menu
        h_menu_delete_compartment       matlab.ui.container.Menu
        h_menu_compartment_surface_mesh  matlab.ui.container.Menu
        h_menu_stl                      matlab.ui.container.Menu
        h_menu_dat_points               matlab.ui.container.Menu
        h_menu_dat_triangles            matlab.ui.container.Menu
        h_menu_compartments_visibility  matlab.ui.container.Menu
        h_menu_compartments_on          matlab.ui.container.Menu
        h_menu_sensors_table            matlab.ui.container.ContextMenu
        h_menu_lock_sensor_sets_on      matlab.ui.container.Menu
        h_menu_add_sensor_sets          matlab.ui.container.Menu
        h_menu_delete_sensor_sets       matlab.ui.container.Menu
        ImportsensorsMenu               matlab.ui.container.Menu
        h_menu_sensor_dat_points        matlab.ui.container.Menu
        h_menu_sensor_dat_directions    matlab.ui.container.Menu
        h_menu_transform_table          matlab.ui.container.ContextMenu
        h_menu_lock_transforms_on       matlab.ui.container.Menu
        h_menu_add_transform            matlab.ui.container.Menu
        h_menu_delete_transform         matlab.ui.container.Menu
        h_menu_sensors_name_table       matlab.ui.container.ContextMenu
        h_menu_lock_sensor_names_on     matlab.ui.container.Menu
        h_menu_add_sensors              matlab.ui.container.Menu
        h_menu_delete_sensors           matlab.ui.container.Menu
        h_menu_import_sensor_names      matlab.ui.container.Menu
        h_menu_sensors_visibility       matlab.ui.container.Menu
    end


    % -------------------------------------------------------------------------
    % Private helper: legacy CreateFcn support for App Designer callbacks
    % -------------------------------------------------------------------------
    methods (Access = private)
        function local_CreateFcn(app, hObject, eventdata, createfcn, appdata)
            % Store application data on the graphics object for use in callbacks.
            if ~isempty(appdata)
               names = fieldnames(appdata);
               for i = 1:length(names)
                   name = char(names(i));
                   setappdata(hObject, name, getfield(appdata, name));
               end
            end
            % Run the create function (handle or string) if provided.
            if ~isempty(createfcn)
               if isa(createfcn, 'function_handle')
                   createfcn(hObject, eventdata);
               else
                   eval(createfcn);
               end
            end
        end
    end

    % -------------------------------------------------------------------------
    % Component initialization: build segmentation tool figure and all controls
    % -------------------------------------------------------------------------
    methods (Access = private)

        % Create the segmentation tool figure and all UI components (compartment
        % table, sensor sets, transforms, parameters, project info, sensor names).
        function createComponents(app)

            % Create main figure; keep hidden until all components are created.
            app.h_zeffiro_window_main = uifigure('Visible', 'off');
            colormap(app.h_zeffiro_window_main, 'parula');
            app.h_zeffiro_window_main.Position = [42 157 1151 545];
            app.h_zeffiro_window_main.Name = 'ZEFFIRO Interface: Segmentation tool';
            app.h_zeffiro_window_main.Scrollable = 'on';

            % Create h_axes2
            app.h_axes2 = uiimage(app.h_zeffiro_window_main);
            app.h_axes2.HorizontalAlignment = 'right';
            app.h_axes2.Position = [478 508 95 31];
            app.h_axes2.ImageSource = 'zeffiro_logo_compass.png';

            % --- Compartment table: ID, Name, On, Visible, Merge, Invert normal, Activity, Conductivity ---
            % Create h_compartment_table
            app.h_compartment_table = uitable(app.h_zeffiro_window_main);
            app.h_compartment_table.ColumnName = {'ID'; 'Name'; 'On'; 'Visible'; 'Merge'; 'Invert normal'; 'Activity'; 'Conductivity'};
            app.h_compartment_table.ColumnWidth = {'fit', 'auto', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};
            app.h_compartment_table.RowName = {};
            app.h_compartment_table.ColumnEditable = true;
            app.h_compartment_table.FontSize = 8;
            app.h_compartment_table.Position = [10 159 563 343];

            % --- Sensor sets table: ID, Name, Modality, On, Visible, Tags, Points, Directions ---
            % Create h_sensors_table
            app.h_sensors_table = uitable(app.h_zeffiro_window_main);
            app.h_sensors_table.ColumnName = {'ID'; 'Name'; 'Modality'; 'On'; 'Visible'; 'Tags'; 'Points'; 'Directions'};
            app.h_sensors_table.ColumnWidth = {'fit', 'auto', 'fit', 'fit', 'fit', 'fit', 'fit', 'fit'};
            app.h_sensors_table.RowName = {};
            app.h_sensors_table.ColumnEditable = [true true true true true true false false];
            app.h_sensors_table.Position = [593 370 321 132];

            % --- Transform table: coordinate transforms (ID, Name) ---
            % Create h_transform_table
            app.h_transform_table = uitable(app.h_zeffiro_window_main);
            app.h_transform_table.ColumnName = {'ID'; 'Name'};
            app.h_transform_table.ColumnWidth = {'fit', 'auto'};
            app.h_transform_table.RowName = {};
            app.h_transform_table.ColumnEditable = true;
            app.h_transform_table.Position = [593 159 150 177];

            % Create h_project_information
            app.h_project_information = uilistbox(app.h_zeffiro_window_main);
            app.h_project_information.Position = [12 15 561 112];

            % Create CompartmentsLabel
            app.CompartmentsLabel = uilabel(app.h_zeffiro_window_main);
            app.CompartmentsLabel.Position = [11 512 89 22];
            app.CompartmentsLabel.Text = 'Compartments:';

            % Create ProjectinformationLabel
            app.ProjectinformationLabel = uilabel(app.h_zeffiro_window_main);
            app.ProjectinformationLabel.Position = [12 131 110 22];
            app.ProjectinformationLabel.Text = 'Project information:';

            % Create SensorsetsLabel
            app.SensorsetsLabel = uilabel(app.h_zeffiro_window_main);
            app.SensorsetsLabel.Position = [593 512 72 22];
            app.SensorsetsLabel.Text = 'Sensor sets:';

            % Create TransformLabel
            app.TransformLabel = uilabel(app.h_zeffiro_window_main);
            app.TransformLabel.Position = [593 339 82 22];
            app.TransformLabel.Text = 'Transform:';

            % Create h_parameters_table
            app.h_parameters_table = uitable(app.h_zeffiro_window_main);
            app.h_parameters_table.ColumnName = {'Parameter'; 'Value'};
            app.h_parameters_table.ColumnWidth = {'fit', 'auto'};
            app.h_parameters_table.RowName = {};
            app.h_parameters_table.ColumnEditable = [false true];
            app.h_parameters_table.Position = [757 159 157 177];

            % Create h_sensors_name_table
            app.h_sensors_name_table = uitable(app.h_zeffiro_window_main);
            app.h_sensors_name_table.ColumnName = {'ID'; 'Tag'; 'Visible'};
            app.h_sensors_name_table.ColumnWidth = {'fit', 'auto', 'fit'};
            app.h_sensors_name_table.RowName = {};
            app.h_sensors_name_table.ColumnEditable = true;
            app.h_sensors_name_table.Position = [930 15 212 487];

            % Create SensorsLabel_2
            app.SensorsLabel_2 = uilabel(app.h_zeffiro_window_main);
            app.SensorsLabel_2.Position = [930 512 53 22];
            app.SensorsLabel_2.Text = 'Sensors:';

            % Create ParametersLabel
            app.ParametersLabel = uilabel(app.h_zeffiro_window_main);
            app.ParametersLabel.Position = [758 339 85 22];
            app.ParametersLabel.Text = 'Parameters:';

            % Create ProjectnotesTextAreaLabel
            app.ProjectnotesTextAreaLabel = uilabel(app.h_zeffiro_window_main);
            app.ProjectnotesTextAreaLabel.Position = [595 131 80 22];
            app.ProjectnotesTextAreaLabel.Text = 'Project notes:';

            % Create h_project_notes
            app.h_project_notes = uitextarea(app.h_zeffiro_window_main);
            app.h_project_notes.Position = [594 15 321 112];

            % Create ProjecttagEditFieldLabel
            app.ProjecttagEditFieldLabel = uilabel(app.h_zeffiro_window_main);
            app.ProjecttagEditFieldLabel.Position = [296 513 65 22];
            app.ProjecttagEditFieldLabel.Text = 'Project tag:';

            % Create h_project_tag
            app.h_project_tag = uieditfield(app.h_zeffiro_window_main, 'text');
            app.h_project_tag.Position = [367 513 95 22];

            % Create ProfileDropDownLabel
            app.ProfileDropDownLabel = uilabel(app.h_zeffiro_window_main);
            app.ProfileDropDownLabel.Position = [205 133 43 22];
            app.ProfileDropDownLabel.Text = 'Profile:';

            % Create h_profile_name
            app.h_profile_name = uidropdown(app.h_zeffiro_window_main);
            app.h_profile_name.Position = [254 133 95 22];

            % Create h_segmentation_tool_toggle
            app.h_segmentation_tool_toggle = uibutton(app.h_zeffiro_window_main, 'push');
            app.h_segmentation_tool_toggle.Position = [478 133 95 22];
            app.h_segmentation_tool_toggle.Text = 'Toggle controls';

            % Create h_set_position
            app.h_set_position = uibutton(app.h_zeffiro_window_main, 'push');
            app.h_set_position.Position = [366 133 95 22];
            app.h_set_position.Text = 'Set position';

            % Create h_menu_compartment_table
            app.h_menu_compartment_table = uicontextmenu(app.h_zeffiro_window_main);

            % Create h_menu_lock_on
            app.h_menu_lock_on = uimenu(app.h_menu_compartment_table);
            app.h_menu_lock_on.Text = 'Lock on';

            % Create h_menu_add_compartment
            app.h_menu_add_compartment = uimenu(app.h_menu_compartment_table);
            app.h_menu_add_compartment.Text = 'Add compartment';

            % Create h_menu_delete_compartment
            app.h_menu_delete_compartment = uimenu(app.h_menu_compartment_table);
            app.h_menu_delete_compartment.Text = 'Delete compartment(s)';

            % Create h_menu_compartment_surface_mesh
            app.h_menu_compartment_surface_mesh = uimenu(app.h_menu_compartment_table);
            app.h_menu_compartment_surface_mesh.Text = 'Import surface mesh';

            % Create h_menu_stl
            app.h_menu_stl = uimenu(app.h_menu_compartment_surface_mesh);
            app.h_menu_stl.Text = 'Full mesh (STL file)';

            % Create h_menu_dat_points
            app.h_menu_dat_points = uimenu(app.h_menu_compartment_surface_mesh);
            app.h_menu_dat_points.Text = 'Points (DAT file)';

            % Create h_menu_dat_triangles
            app.h_menu_dat_triangles = uimenu(app.h_menu_compartment_surface_mesh);
            app.h_menu_dat_triangles.Text = 'Triangles (DAT file)';

            % Create h_menu_compartments_visibility
            app.h_menu_compartments_visibility = uimenu(app.h_menu_compartment_table);
            app.h_menu_compartments_visibility.Text = 'Toggle visible';

            % Create h_menu_compartments_on
            app.h_menu_compartments_on = uimenu(app.h_menu_compartment_table);
            app.h_menu_compartments_on.Text = 'Toggle on';
            
            % Assign app.h_menu_compartment_table
            app.h_compartment_table.ContextMenu = app.h_menu_compartment_table;

            % Create h_menu_sensors_table
            app.h_menu_sensors_table = uicontextmenu(app.h_zeffiro_window_main);

            % Create h_menu_lock_sensor_sets_on
            app.h_menu_lock_sensor_sets_on = uimenu(app.h_menu_sensors_table);
            app.h_menu_lock_sensor_sets_on.Text = 'Lock on';

            % Create h_menu_add_sensor_sets
            app.h_menu_add_sensor_sets = uimenu(app.h_menu_sensors_table);
            app.h_menu_add_sensor_sets.Text = 'Add sensor set';

            % Create h_menu_delete_sensor_sets
            app.h_menu_delete_sensor_sets = uimenu(app.h_menu_sensors_table);
            app.h_menu_delete_sensor_sets.Text = 'Delete sensor set(s)';

            % Create ImportsensorsMenu
            app.ImportsensorsMenu = uimenu(app.h_menu_sensors_table);
            app.ImportsensorsMenu.Text = 'Import sensors';

            % Create h_menu_sensor_dat_points
            app.h_menu_sensor_dat_points = uimenu(app.ImportsensorsMenu);
            app.h_menu_sensor_dat_points.Text = 'Points (DAT file)';

            % Create h_menu_sensor_dat_directions
            app.h_menu_sensor_dat_directions = uimenu(app.ImportsensorsMenu);
            app.h_menu_sensor_dat_directions.Text = 'Directions (DAT file)';
            
            % Assign app.h_menu_sensors_table
            app.h_sensors_table.ContextMenu = app.h_menu_sensors_table;

            % Create h_menu_transform_table
            app.h_menu_transform_table = uicontextmenu(app.h_zeffiro_window_main);

            % Create h_menu_lock_transforms_on
            app.h_menu_lock_transforms_on = uimenu(app.h_menu_transform_table);
            app.h_menu_lock_transforms_on.Text = 'Lock on';

            % Create h_menu_add_transform
            app.h_menu_add_transform = uimenu(app.h_menu_transform_table);
            app.h_menu_add_transform.Text = 'Add transform';

            % Create h_menu_delete_transform
            app.h_menu_delete_transform = uimenu(app.h_menu_transform_table);
            app.h_menu_delete_transform.Text = 'Delete transform(s)';
            
            % Assign app.h_menu_transform_table
            app.h_transform_table.ContextMenu = app.h_menu_transform_table;

            % Create h_menu_sensors_name_table
            app.h_menu_sensors_name_table = uicontextmenu(app.h_zeffiro_window_main);

            % Create h_menu_lock_sensor_names_on
            app.h_menu_lock_sensor_names_on = uimenu(app.h_menu_sensors_name_table);
            app.h_menu_lock_sensor_names_on.Text = 'Lock on';

            % Create h_menu_add_sensors
            app.h_menu_add_sensors = uimenu(app.h_menu_sensors_name_table);
            app.h_menu_add_sensors.Text = 'Add sensor';

            % Create h_menu_delete_sensors
            app.h_menu_delete_sensors = uimenu(app.h_menu_sensors_name_table);
            app.h_menu_delete_sensors.Text = 'Delete sensor(s)';

            % Create h_menu_import_sensor_names
            app.h_menu_import_sensor_names = uimenu(app.h_menu_sensors_name_table);
            app.h_menu_import_sensor_names.Text = 'Import sensor names (DAT file)';

            % Create h_menu_sensors_visibility
            app.h_menu_sensors_visibility = uimenu(app.h_menu_sensors_name_table);
            app.h_menu_sensors_visibility.Text = 'Toggle visible';
            
            app.h_sensors_name_table.ContextMenu = app.h_menu_sensors_name_table;

            % Figure remains hidden here; visibility is typically set by the caller.
            app.h_zeffiro_window_main.Visible = 'off';
        end
    end

    % -------------------------------------------------------------------------
    % App lifecycle: construction (singleton) and deletion
    % -------------------------------------------------------------------------
    methods (Access = public)

        % Constructor: create or reuse the single running instance.
        function app = zef_segmentation_tool_app_exported

            runningApp = getRunningApp(app);

            if isempty(runningApp)
                createComponents(app);
                registerApp(app, app.h_zeffiro_window_main);
            else
                figure(runningApp.h_zeffiro_window_main);
                app = runningApp;
            end

            if nargout == 0
                clear app
            end
        end

        % Destructor: remove the segmentation tool figure when the app is destroyed.
        function delete(app)
            delete(app.h_zeffiro_window_main);
        end
    end
end

function zef = zef_load(zef,file_name,path_name)
%ZEF_LOAD  Load a saved Zeffiro project from a MAT-file into the session.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Opens a *.mat project (uigetfile when file_name and path_name are
%   omitted), loads fields in batches with a waitbar (small fields first,
%   then fields larger than 100 MB), merges them into zef, applies system
%   settings and profile initialization, recreates sensor and compartment
%   defaults, and starts the main GUI tools. Legacy single-variable MAT
%   files (one scalar struct) are expanded in memory; the MAT file is not rewritten.
%
%   zef = zef_load(zef)
%   zef = zef_load(zef, file_name, path_name)
%
%   Inputs
%     zef        - current session struct (read from base workspace when
%                  called with no output and no inputs).
%     file_name  - MAT file name; uigetfile when omitted with path_name.
%     path_name  - folder containing file_name.
%
%   Output
%     zef - session populated from the project file, with save_file and
%           save_file_path updated.
%
%   See also zef_save, zef_start_new_project, zef_apply_system_settings,
%            zef_create_sensors, zef_create_compartment.
%
if nargin == 0
    zef = evalin('base','zef');
end

zef_data = struct;

if nargin < 3
    if not(isempty(zef.save_file_path)) && not(isequal(zef.save_file_path,0))
        [file_name, path_name] = uigetfile('*.mat','Open project',zef.save_file_path);
    else
        [file_name, path_name] = uigetfile('*.mat','Open project');
    end
end
if not(isequal(file_name,0))
    % Do not restart the application. A full zef_start_new_project would
    % destroy the unified shell and, after load, zef_menu_tool would raise
    % the legacy menu-bar window. Merge into the live session instead.

    zef_data.save_file = file_name;
    zef_data.save_file_path = path_name;
    try
        if isfield(zef, 'h_zeffiro') && isvalid(zef.h_zeffiro)
            zef_ui_shell('dismiss', zef.h_zeffiro);
        end
    catch
    end

    h_waitbar = [];
    if zef.use_display
        h_waitbar = zef_waitbar(0, 1, 'Opening project.');
        try
            zef_window_manager('raise', h_waitbar);
            drawnow;
        catch
        end
    end

    project_path = fullfile(path_name, file_name);
    matfile_whos = whos('-file', project_path);
    matfile_fieldnames = {matfile_whos.name}';
    I_mf = 1:length(matfile_fieldnames);
    loaded_from_legacy_struct = false;

    % Old projects sometimes store one struct (often named zef). Upstream
    % load+save('-struct','zef_data') overwrote that file with whatever
    % zef_data was in this workspace (usually only save_file / path).
    % Convert in memory and leave the user's MAT file untouched.
    if isequal(length(matfile_fieldnames), 1)
        raw = load(project_path);
        payload = raw.(matfile_fieldnames{1});
        if ~(isstruct(payload) && isscalar(payload))
            error("zef_load:UnsupportedLegacyMat", ...
                "Single-variable MAT file '%s' must contain a scalar struct.", file_name);
        end
        zef_data = payload;
        zef_data.save_file = file_name;
        zef_data.save_file_path = path_name;
        loaded_from_legacy_struct = true;
        matfile_fieldnames = fieldnames(zef_data);
        I_mf = 1:numel(matfile_fieldnames);
    end

    if ismember('zeffiro_variable_data', matfile_fieldnames)
        if loaded_from_legacy_struct
            zeffiro_variable_data = [];
            if isfield(zef_data, 'zeffiro_variable_data')
                zeffiro_variable_data = zef_data.zeffiro_variable_data;
            end
        else
            aux_struct = load(project_path, 'zeffiro_variable_data');
            zeffiro_variable_data = aux_struct.('zeffiro_variable_data');
        end
        if not(isempty(zeffiro_variable_data))
            [matfile_fieldnames, I_mf] = setdiff(matfile_fieldnames, zeffiro_variable_data(:,2));
        end
    end

    if isempty(h_waitbar) || ~isvalid(h_waitbar)
        h_waitbar = zef_waitbar(0,1,'Loading fields.');
    else
        h_waitbar = zef_waitbar(0,1,h_waitbar,'Loading fields.');
    end
    if zef.use_display && ~isempty(h_waitbar) && isvalid(h_waitbar)
        try
            h_waitbar.Visible = 'on';
            zef_window_manager('raise', h_waitbar);
            drawnow;
        catch
        end
    end

    if ~loaded_from_legacy_struct
        field_sizes = cell2mat({matfile_whos(I_mf).bytes});
        I_fs = find(field_sizes <= 1e8);
        matfile_fieldnames_aux = matfile_fieldnames(I_fs);
        matfile_fieldnames = setdiff(matfile_fieldnames, matfile_fieldnames_aux);
        n_fields_2 = length(I_fs);
        if isempty(matfile_fieldnames_aux)
            zef_data_aux = struct();
        else
            zef_data_aux = load(project_path, matfile_fieldnames_aux{:});
        end
        fieldnames_zef_data_aux = fieldnames(zef_data_aux);
        for i = 1 : n_fields_2
            zef_data.(fieldnames_zef_data_aux{i}) = zef_data_aux.(fieldnames_zef_data_aux{i});
            if n_fields_2 > 0 && isequal(mod(i,ceil(n_fields_2/100)),0)
                zef_waitbar(i,n_fields_2,h_waitbar,['Loading <=100 MB fields: ' num2str(i) ' / ' num2str(n_fields_2) '.']);
            end
        end

        n_fields_1 = length(matfile_fieldnames);
        for i = 1 : n_fields_1
            aux_struct = load(project_path, matfile_fieldnames{i});
            zef_data.(matfile_fieldnames{i}) = aux_struct.(matfile_fieldnames{i});
            if n_fields_1 > 0 && isequal(mod(i,ceil(n_fields_1/100)),0)
                zef_waitbar(i,n_fields_1,h_waitbar,['Loading >100 MB fields: ' num2str(i) ' / ' num2str(n_fields_1) '.']);
            end
        end
    end
    zef_waitbar(1, 1, h_waitbar, 'Applying project data.');
    zef_data = zef_remove_system_fields(zef, zef_data);
    zef_data.project_matfile = [path_name filesep file_name];

    zef.matlab_release = version('-release');
    zef.matlab_release = str2num(zef.matlab_release(1:4)) + double(zef.matlab_release(5))/128;
    zef_data.matlab_release = zef.matlab_release;
    zef_data.code_path = zef.code_path;
    zef_data.program_path = zef.program_path;

    zef = zef_merge_project_data(zef, zef_data);
    if ~isfield(zef, 'current_version') || isempty(zef.current_version)
        zef.current_version = 2.2;
    end

    zef = zef_apply_system_settings(zef);
    if isfield(zef, 'source_model')
        zef.source_model = core.types.ZefSourceModel.from(zef.source_model);
    end
    
    % Keep Save / project info on the file that was actually opened.
    zef.save_file = file_name;
    if isempty(path_name)
        zef.save_file_path = '';
    elseif path_name(end) ~= filesep && path_name(end) ~= '/'
        zef.save_file_path = [path_name filesep];
    else
        zef.save_file_path = path_name;
    end
    zef.project_matfile = fullfile(path_name, file_name);
    if isfield(zef_data,'profile_name')
        zef.profile_name = zef_data.profile_name;
    end

    zef_replace_project_fields;

    % CRITICAL: Ensure sensor_tags and compartment_tags exist before calling
    % initialization functions that access them (zef_init_parameter_profile accesses them)
    if not(isfield(zef,'sensor_tags')) || not(iscell(zef.sensor_tags))
        zef.sensor_tags = {};
    end
    if not(isfield(zef,'compartment_tags')) || not(iscell(zef.compartment_tags))
        zef.compartment_tags = {};
    end

    zef_init_init_profile;
    zef_init_parameter_profile;

    if ismember(zef.start_mode,{'nodisplay'})
        zef.use_display = 0;

    end

    clear zef_data;

    try
        if ~isempty(h_waitbar) && isvalid(h_waitbar)
            zef_waitbar(1, 1, h_waitbar, 'Initializing sensors and compartments.');
        end
    catch
    end

    for zef_i = 1 : length(zef.sensor_tags)
        if zef_i <= length(zef.sensor_tags)
            zef = zef_create_sensors(zef, zef.sensor_tags{zef_i});
        end
    end

    for zef_i = 1 : length(zef.compartment_tags)
        if zef_i <= length(zef.compartment_tags)
            zef = zef_create_compartment(zef, zef.compartment_tags{zef_i});
        end
    end

    try
        zef = zef_set_figure_tool_sliders(zef);
    catch
    end

    have_shell = zef.use_display && isfield(zef, 'h_zeffiro') && isvalid(zef.h_zeffiro);
    have_menu = isfield(zef, 'h_zeffiro_menu') && isvalid(zef.h_zeffiro_menu);
    have_segmentation = isfield(zef, 'h_zeffiro_window_main') && isvalid(zef.h_zeffiro_window_main);
    if have_shell
        if ~have_menu
            zef_plugin;
            zef_menu_tool;
        end
        if ~have_segmentation && zef.use_display
            zef_segmentation_tool;
            zef_mesh_tool;
            zef_mesh_visualization_tool;
        elseif have_segmentation
            try
                zef = zef_build_compartment_table(zef);
            catch
            end
        end
        try
            zef_ui_shell('hide_companions', zef);
        catch
        end
    else
        if ~have_menu
            zef_plugin;
            zef_menu_tool;
        end
        if ~have_segmentation && zef.use_display
            zef_segmentation_tool;
            zef_mesh_tool;
            zef_mesh_visualization_tool;
        elseif have_segmentation
            try
                zef = zef_build_compartment_table(zef);
            catch
            end
            try
                zef.h_zeffiro_window_main.Visible = 'off';
            catch
            end
        end
    end
    try
        zef_ui_shell('hide_menu', zef);
    catch
    end

    if isfield(zef,'sensor_tags') && iscell(zef.sensor_tags) && not(isempty(zef.sensor_tags))
        if not(isfield(zef,'current_sensors')) || isempty(zef.current_sensors)
            zef.current_sensors = zef.sensor_tags{1};
        end
    end

    if zef.use_display && isfield(zef,'h_sensors_table') && isvalid(zef.h_sensors_table)
        if isfield(zef,'sensor_tags') && iscell(zef.sensor_tags) && not(isempty(zef.sensor_tags))
            try
                zef.aux_field_1 = cell(0);
                for zef_i = 1 : length(zef.sensor_tags)
                    zef.aux_field_1{zef_i,1} = zef_i;
                    zef.aux_field_1{zef_i,2} = eval(['zef.' zef.sensor_tags{zef_i} '_name']);
                    zef.aux_field_1{zef_i,3} = eval(['zef.' zef.sensor_tags{zef_i} '_imaging_method_name']);
                    zef.aux_field_1{zef_i,4} = eval(['zef.' zef.sensor_tags{zef_i} '_on']);
                    zef.aux_field_1{zef_i,5} = eval(['zef.' zef.sensor_tags{zef_i} '_visible']);
                    zef.aux_field_1{zef_i,6} = eval(['zef.' zef.sensor_tags{zef_i} '_names_visible']);
                    zef.aux_field_1{zef_i,7} = eval(['not(isempty(zef.' zef.sensor_tags{zef_i} '_points))']);
                    zef.aux_field_1{zef_i,8} = eval(['not(isempty(zef.' zef.sensor_tags{zef_i} '_directions))']);
                end
                original_callback = zef.h_sensors_table.CellEditCallback;
                zef.h_sensors_table.CellEditCallback = '';
                zef.h_sensors_table.Data = zef.aux_field_1;
                zef.h_sensors_table.CellEditCallback = original_callback;
                zef = rmfield(zef,'aux_field_1');
            catch
            end
        end
    end

    try
        if ~isempty(h_waitbar) && isvalid(h_waitbar)
            zef_waitbar(1, 1, h_waitbar, 'Updating interface.');
            set(h_waitbar, 'DeleteFcn', '');
            delete(h_waitbar);
        end
    catch
    end

    if have_shell
        try
            if isfield(zef, 'current_sensors') && ~isempty(zef.current_sensors)
                zef = zef_init_sensors_name_table(zef);
            end
        catch
        end
        try
            zef = zef_update(zef);
        catch
        end
        try
            zef = zef_update_fig_details(zef);
        catch
        end
        try
            zef_figure_tool_layout(zef.h_zeffiro);
        catch
        end
        try
            figure(zef.h_zeffiro);
        catch
        end
        try
            zef_ui_shell('dismiss', zef.h_zeffiro);
        catch
        end
        try
            if isfield(zef, 'h_project_information') && isvalid(zef.h_project_information)
                wsz = 0;
                try
                    wsz = getfield(whos('zef'), 'bytes');
                catch
                end
                zef.h_project_information.Items = { ...
                    ['App folder: ' zef.program_path], ...
                    ['Current path: ' pwd], ...
                    ['Project file: ' zef.save_file], ...
                    ['Project folder: ' zef.save_file_path], ...
                    ['Project size (MB): ' num2str(round(wsz / 1e6))]};
            end
        catch
        end
        drawnow;
    end

end

if nargout == 0
    assignin('base','zef',zef);
end

end

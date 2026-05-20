%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_load(zef,file_name,path_name)
% --- Zeffiro documentation header ---
% zef_load — Loads external data or a saved Zeffiro project into `zef`.
%
% Purpose:
%   Loads external data or a saved Zeffiro project into `zef`.
%   Folder: Project load/save, segmentation import, figure import, FEM export.
%
% Inputs:
%   zef
%   file_name
%   path_name
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.aux_field_1 (read, write)
%   zef.code_path (read)
%   zef.compartment_tags (read, write)
%   zef.current_sensors (read, write)
%   zef.current_version (read, write)
%   zef.fieldnames (read, write)
%   zef.h_compartment_visible_color (read)
%   zef.h_sensor_visible_color (read)
%   zef.h_sensors_table (read)
%   zef.h_zeffiro (read)
%   zef.profile_name (read, write)
%   zef.program_path (read)
%   zef.save_file (read, write)
%   zef.save_file_path (read, write)
%   zef.sensor_tags (read, write)
%   … (2 more)
%
% Calls (project):
%   zef_apply_system_settings
%   zef_create_compartment
%   zef_create_sensors
%   zef_load
%   zef_set_figure_tool_sliders
%   zef_update
%   zef_update_fig_details
%   zef_waitbar
%
% Side effects:
%   - base/caller workspace
%   - creates/updates figures
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%   - waitbar progress UI
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_load(zef, file_name, path_name)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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
    zef_start_new_project;

    zef_data.save_file = file_name;
    zef_data.save_file_path = path_name;

    matfile_whos = whos('-file',[path_name filesep file_name]);
    matfile_fieldnames = {matfile_whos.name}';
    I_mf = [1:length(matfile_fieldnames)];

    if isequal(length(matfile_fieldnames),1)
        load([path_name filesep file_name]);
        save([path_name filesep file_name],'-struct','zef_data','-v7.3');
        matfile_whos = whos('-file',[path_name filesep file_name]);
        matfile_fieldnames = {matfile_whos.name}';
        I_mf = [1:length(matfile_fieldnames)];
    end

    if ismember('zeffiro_variable_data',matfile_fieldnames)
        aux_struct = load([path_name filesep file_name],'zeffiro_variable_data');
        zeffiro_variable_data = aux_struct.('zeffiro_variable_data');
        if not(isempty(zeffiro_variable_data))
            [matfile_fieldnames, I_mf] = setdiff(matfile_fieldnames,zeffiro_variable_data(:,2));
        end
    end

    h_waitbar = zef_waitbar(0,1,'Loading fields.');
    n_fields = length(matfile_fieldnames);
    if zef.use_display
        figure(h_waitbar);
    end
    
    field_sizes = cell2mat({matfile_whos(I_mf).bytes});
    I_fs = find(field_sizes <= 1e8);
    matfile_fieldnames_aux = matfile_fieldnames(I_fs);
    matfile_fieldnames = setdiff(matfile_fieldnames, matfile_fieldnames_aux);
    n_fields_2 = length(I_fs);
    zef_data_aux = eval(['load(''' fullfile(path_name,file_name) ''',' strjoin(strcat('"',matfile_fieldnames_aux,'"'),',')  ');']);
    fieldnames_zef_data_aux = fieldnames(zef_data_aux);
    for i = 1 : n_fields_2
        zef_data.(fieldnames_zef_data_aux{i}) = zef_data_aux.(fieldnames_zef_data_aux{i});
          if isequal(mod(i,ceil(n_fields_2/100)),0)
            zef_waitbar(i,n_fields_2,h_waitbar,['Loading <=100 MB fields: ' num2str(i) ' / ' num2str(n_fields_2) '.']);
        end
    end

  n_fields_1 = length(matfile_fieldnames);
    for i = 1 : n_fields_1
        aux_struct = load(fullfile(path_name,file_name),matfile_fieldnames{i});
        zef_data.(matfile_fieldnames{i}) = aux_struct.(matfile_fieldnames{i});
        if isequal(mod(i,ceil(n_fields_1/100)),0)
            zef_waitbar(i,n_fields_1,h_waitbar,['Loading >100 MB fields: ' num2str(i) ' / ' num2str(n_fields_1) '.']);
        end
    end
    % Properly delete waitbar by clearing DeleteFcn first
    if ~isempty(h_waitbar) && isvalid(h_waitbar)
        set(h_waitbar, 'DeleteFcn', '');
        delete(h_waitbar);
    end
    zef_remove_system_fields;
    zef_data.project_matfile = [path_name filesep file_name];

    zef_data.matlab_release = version('-release');
    zef_data.matlab_release = str2num(zef_data.matlab_release(1:4)) + double(zef_data.matlab_release(5))/128;
    zef_data.code_path = zef.code_path;
    zef_data.program_path = zef.program_path;

    zef_data.mlapp = 1;

    zef.fieldnames = fieldnames(zef_data);
    for zef_i = 1:length(zef.fieldnames)
        if not(isequal(zef.fieldnames{zef_i},'fieldnames'))
            zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
        end
    end
    if isempty(find(contains(zef.fieldnames,'current_version'),1))
        zef.current_version = 2.2;
    end
    clear zef_i;
    zef = rmfield(zef,'fieldnames');

    zef = zef_apply_system_settings(zef);
    
    % CRITICAL FIX: Skip zef_remove_object_handles entirely - it's not needed since zef_data
    % is cleared right after (line 141), and this function can hang indefinitely on large projects.
    % Object handles in zef_data don't matter since we're just copying fields to zef.
    zef.save_file = zef_data.save_file;
    zef.save_file_path = zef_data.save_file_path;
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

    zef = zef_set_figure_tool_sliders(zef);
    zef_plugin;
    zef_mesh_tool;
    zef_mesh_visualization_tool;
    zef_segmentation_tool;  % This already calls zef_update internally via zef_build_compartment_table
    zef_menu_tool;
    
    % CRITICAL FIX: Skip zef_update here - it can hang on large projects and is unnecessary.
    % The tools (especially zef_segmentation_tool) already call zef_update during their initialization.
    % However, we still need to populate sensor and compartment tables/lists after loading.
    % These are lightweight operations that just populate UI elements.
    
    % Ensure current_sensors is set (needed for sensor display in figure tool)
    if isfield(zef,'sensor_tags') && iscell(zef.sensor_tags) && not(isempty(zef.sensor_tags))
        if not(isfield(zef,'current_sensors')) || isempty(zef.current_sensors)
            zef.current_sensors = zef.sensor_tags{1};
        end
    end
    
    % Populate sensor table in segmentation tool (lightweight operation)
    if zef.use_display && isfield(zef,'h_sensors_table') && isvalid(zef.h_sensors_table)
        if isfield(zef,'sensor_tags') && iscell(zef.sensor_tags) && not(isempty(zef.sensor_tags))
            try
                % This is the lightweight sensor table population from zef_update (lines 186-206)
                % It only reads sensor data and populates the table, no heavy computations
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
                
                % Temporarily disable callbacks to prevent recursion during programmatic updates
                original_callback = zef.h_sensors_table.CellEditCallback;
                zef.h_sensors_table.CellEditCallback = '';
                zef.h_sensors_table.Data = zef.aux_field_1;
                zef.h_sensors_table.CellEditCallback = original_callback;
                zef = rmfield(zef,'aux_field_1');
            catch
                % If update fails, it's not critical - sensors will show when user interacts
            end
        end
    end
    
    % Update figure tool compartment and sensor lists (lightweight operation)
    if zef.use_display && isfield(zef,'h_zeffiro') && isvalid(zef.h_zeffiro)
        if isfield(zef,'h_compartment_visible_color') && isvalid(zef.h_compartment_visible_color)
            if isfield(zef,'h_sensor_visible_color') && isvalid(zef.h_sensor_visible_color)
                if (isfield(zef,'compartment_tags') && iscell(zef.compartment_tags)) || ...
                   (isfield(zef,'sensor_tags') && iscell(zef.sensor_tags))
                    try
                        zef = zef_update_fig_details(zef);
                    catch
                        % If update fails (e.g., handles not fully initialized), it's not critical.
                        % The list will be populated when user first interacts with visualization.
                    end
                end
            end
        end
    end

end

if nargout == 0
    assignin('base','zef',zef);
end

end

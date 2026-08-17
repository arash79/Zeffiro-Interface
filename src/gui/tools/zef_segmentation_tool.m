%ZEF_SEGMENTATION_TOOL  Open the Segmentation tool and wire its tables.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script (not a function). Called first from zef_start. Instantiates
%   zef_segmentation_tool_app_exported onto h_zeffiro_window_main.
%   Window title is "ZEFFIRO Interface: Segmentation tool".
%
%   CellEditCallback: compartment/sensors -> zef_update; transform ->
%   zef_update_transform; name table -> zef_update_sensors_name_table;
%   parameters -> zef_update_parameters. Buttons Toggle controls /
%   Set position -> zef_segmentation_tool_toggle / zef_set_position.
%   Profile dropdown lists profile/ subfolders. DeleteFcn closes all
%   Zeffiro windows and rmpaths when not deployed.
%
%   See also zef_update, zef_build_compartment_table.
if isfield(zef,'h_zeffiro_window_main')
    if isvalid(zef.h_zeffiro_window_main)
        delete(zef.h_zeffiro_window_main)
    end
end

set(groot,'defaultFigureVisible','off')
zef_data = zef_segmentation_tool_app_exported;
%zef_data.h_zeffiro_window_main.Visible = zef.use_display;

set(groot,'defaultFigureVisible','on')
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end

set(zef.h_transform_table,'columnformat',{'numeric','char'});
set(zef.h_transform_table,'columnformat',{'numeric','char'});
set(zef.h_sensors_name_table,'columnformat',{'numeric','char','logical'});
set(zef.h_sensors_table,'columnformat',{'numeric','char',zef.imaging_method_cell,'logical','logical','logical','logical','logical'});
set(zef.h_parameters_table,'columnformat',{'char','numeric'});
set(zef.h_zeffiro_window_main,'DeleteFcn','if not(isdeployed); zef.h_zeffiro = []; zef_arrange_windows(''close'',''windows'',''all''); rmpath([zef.program_path zef.code_path]); rmpath([zef.program_path ''/assets/fig'']); end; clear zef;');
set(zef.h_project_tag,'ValueChangedFcn','zef = zef_update(zef);');
set(zef.h_compartment_table,'CellEditCallback','zef = zef_update(zef);');
set(zef.h_sensors_table,'CellEditCallback','zef = zef_update(zef);');
set(zef.h_transform_table,'CellEditCallback','zef = zef_update_transform(zef);');
set(zef.h_sensors_name_table,'CellEditCallback','zef_update_sensors_name_table;');
set(zef.h_parameters_table,'CellEditCallback','zef_update_parameters;');
set(zef.h_compartment_table,'CellSelectionCallback',@zef_compartment_table_selection);
set(zef.h_transform_table,'CellSelectionCallback',@zef_transform_table_selection);
set(zef.h_sensors_table,'CellSelectionCallback',@zef_sensors_table_selection);
set(zef.h_sensors_name_table,'CellSelectionCallback',@zef_sensors_name_table_selection);

zef.h_project_notes.ValueChangedFcn = 'zef = zef_update(zef);';

zef.mlapp = 1;

clear zef_data;

zef.aux_dir = dir([zef.program_path filesep 'profile']);
zef.aux_cell = cell(0);
zef_j = 0;
for zef_i = 3 : length(zef.aux_dir)
    if zef.aux_dir(zef_i).isdir
        zef_j = zef_j + 1;
        zef.aux_cell{zef_j} = zef.aux_dir(zef_i).name;
    end
end
zef.h_profile_name.Items = zef.aux_cell;
zef = rmfield(zef,{'aux_dir','aux_cell'});
zef.h_profile_name.Value = zef.profile_name;
zef.h_profile_name.ValueChangedFcn = 'zef.profile_name = zef.h_profile_name.Value;';

zef.h_project_tag.Value = zef.project_tag;

zef = zef_ui_tag_handles(zef);
zef.h_zeffiro_window_main.AutoResizeChildren = 'on';
zef.h_windows_open = findall(groot, 'Type','figure','-regexp','Name','ZEFFIRO Interface:*','-not','Name','ZEFFIRO Interface: Segmentation tool');

%set(zef.h_zeffiro_window_main,'DeleteFcn','zef_closereq;');

if isempty(zef.h_segmentation_tool_toggle.UserData)
    zef.h_segmentation_tool_toggle.ButtonPushedFcn = 'zef_segmentation_tool_toggle(zef,zef.h_segmentation_tool_toggle);';
    zef.h_set_position.ButtonPushedFcn = 'zef_set_position(zef);';

    zef.h_segmentation_tool_toggle.UserData = 1;
    %eval(zef.h_segmentation_tool_toggle.ButtonPushedFcn);
    %zef.h_zeffiro_window_main.Position = zef.segmentation_tool_default_position;

end

zef = zef_build_compartment_table(zef);

% CRITICAL FIX: Skip zef_update here during initial load - it can hang on large projects.
% The table data is already set in zef_build_compartment_table, and zef_update will be
% called when user interacts with the UI. During load, this call can cause infinite loops.
% zef = zef_update(zef);  % Commented out to prevent hangs during project load

zef.h_zeffiro_window_main.CloseRequestFcn = 'zef.h_zeffiro_window_main.Visible=''off'';';
zef.h_zeffiro_window_main.DeleteFcn = 'zef.h_zeffiro_window_main.Visible=''off'';';

if not(ismember('ZefTool',properties(zef.h_zeffiro_window_main)))
    addprop(zef.h_zeffiro_window_main,'ZefTool');
end
zef.h_zeffiro_window_main.ZefTool = mfilename;

ref = zef.segmentation_tool_default_position;
zef.h_zeffiro_window_main.Position = [ref(1), ref(2), 1280, 620];
zef_window_manager('standalone', zef.h_zeffiro_window_main);
zef_ui_apply_size(zef.h_zeffiro_window_main, 1280, 620, 1020, 500);
zef_ui_ready(zef.h_zeffiro_window_main);

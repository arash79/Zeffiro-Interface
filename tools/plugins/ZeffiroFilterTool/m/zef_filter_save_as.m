%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isempty(zef.save_file_path)) & not(zef — If not(isempty(zef.save file path)) & not(zef.
%
% Purpose:
%   If not(isempty(zef.save file path)) & not(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.file (read)
%   zef.file_path (read)
%   zef.filter_data_segment (read)
%   zef.filter_epoch_points (read)
%   zef.filter_list_selected (read)
%   zef.filter_name_list (read)
%   zef.filter_parameter_list (read)
%   zef.filter_pipeline (read)
%   zef.filter_pipeline_list (read)
%   zef.filter_pipeline_selected (read)
%   zef.filter_sampling_rate (read)
%   zef.filter_save_file (read, write)
%   zef.filter_save_file_path (read, write)
%   zef.filter_tag (read)
%   zef.filter_zoom (read)
%   … (1 more)
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `if not(isempty(zef.save_file_path)) & not(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




if not(isempty(zef.save_file_path)) & not(zef.save_file_path==0)
    [zef.file zef.file_path] = uiputfile('*.mat','Save as...',[zef.filter_save_file_path zef.filter_save_file]);
else
    [zef.file zef.file_path] = uiputfile('*.mat','Save as...');
end
if not(isequal(zef.file,0));

    zef.filter_save_file_path = zef.file_path;
    zef.filter_save_file = zef.file;
    zef_data.filter_zoom = zef.filter_zoom;
    zef_data.raw_data = zef.raw_data;
    zef_data.filter_epoch_points =  zef.filter_epoch_points;
    zef_data.filter_name_list = zef.filter_name_list;
    zef_data.filter_file_list = zef.filter_name_list;
    zef_data.filter_parameter_list = zef.filter_parameter_list;
    zef_data.filter_list_selected = zef.filter_list_selected;
    zef_data.filter_sampling_rate = zef.filter_sampling_rate ;
    zef_data.filter_tag = zef.filter_tag ;
    zef_data.filter_data_segment = zef.filter_data_segment;
    zef_data.filter_pipeline = zef.filter_pipeline;
    zef_data.filter_pipeline_list = zef.filter_pipeline_list;
    zef_data.filter_pipeline_selected = zef.filter_pipeline_selected;

    save([zef.file_path zef.file],'zef_data','-v7.3');
    clear zef_data;

end

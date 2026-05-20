% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.filter_data_segment (read, write)
%   zef.filter_file_list (read, write)
%   zef.filter_list_selected (read, write)
%   zef.filter_name_list (read, write)
%   zef.filter_parameter_list (read, write)
%   zef.filter_pipeline (read, write)
%   zef.filter_pipeline_list (read, write)
%   zef.filter_pipeline_selected (read, write)
%   zef.filter_sampling_rate (read, write)
%   zef.filter_save_file (read, write)
%   zef.filter_save_file_path (read, write)
%   zef.filter_tag (read, write)
%   zef.inv_sampling_frequency (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.filter_epoch_points = [];
zef.filter_save_file_path = './data';
zef.filter_save_file = '';
zef.filter_name_list = cell(0);
zef.filter_file_list = cell(0);
zef.filter_parameter_list = cell(0);
zef.filter_list_selected = '';
zef.filter_sampling_rate = zef.inv_sampling_frequency;
zef.filter_tag = 'Default tag';
zef.filter_data_segment = '0';
zef.filter_pipeline = cell(0);
zef.filter_pipeline_list = cell(0);
zef.filter_pipeline_selected = [];

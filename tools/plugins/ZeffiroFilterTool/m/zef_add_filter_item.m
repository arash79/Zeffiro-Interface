%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef_i = length(zef — Zef i = length(zef.
%
% Purpose:
%   Zef i = length(zef.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.filter_file_list (read)
%   zef.filter_list_selected (read)
%   zef.filter_name_list (read)
%   zef.filter_parameter_list (read, write)
%   zef.filter_pipeline (read)
%   zef.filter_pipeline_selected (read, write)
%   zef.filter_tag (read)
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_i = length(zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




zef_i = length(zef.filter_pipeline_list)+1;
zef.filter_pipeline{zef_i}.name = zef.filter_name_list{zef.filter_list_selected};
zef.filter_pipeline{zef_i}.file = zef.filter_file_list{zef.filter_list_selected};
zef.filter_pipeline{zef_i}.filter_tag = zef.filter_tag;

zef.aux_field = help(zef.filter_file_list{zef.filter_list_selected});
zef.aux_field = zef.aux_field(strfind(zef.aux_field,'Input:')+6:strfind(zef.aux_field,'Output:')-1);
zef.aux_field = textscan(zef.aux_field,'%s','Delimiter',',');
zef.aux_field = zef.aux_field{:};
zef.filter_parameter_list = cell(size(zef.aux_field,1),2);
for zef_j = 1 : size(zef.aux_field,1)
    zef.filter_parameter_list{zef_j,1} = strtrim(zef.aux_field{zef_j}(1:strfind(zef.aux_field{zef_j},'[Default:')-1));
    zef.filter_parameter_list{zef_j,2} = strtrim(zef.aux_field{zef_j}(strfind(zef.aux_field{zef_j},'[Default:')+9:strfind(zef.aux_field{zef_j},']')-1));
    if isfield(zef,zef.filter_parameter_list{zef_j,2})
        zef.filter_parameter_list{zef_j,2} = evalin('base',['zef.' zef.filter_parameter_list{zef_j,2}]);
        if isnumeric(zef.filter_parameter_list{zef_j,2})
            zef.filter_parameter_list{zef_j,2} = num2str(zef.filter_parameter_list{zef_j,2});
        end
    end
end

zef.filter_pipeline{zef_i}.parameters = zef.filter_parameter_list;

zef.filter_pipeline_selected = [];

clear zef_i zef_j;

zef_update_filter_tool;

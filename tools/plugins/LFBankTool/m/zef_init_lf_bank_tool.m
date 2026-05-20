%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isfield(zef,'lf_bank_scaling_factor')); — If not(isfield(zef,'lf bank scaling factor'));.
%
% Purpose:
%   If not(isfield(zef,'lf bank scaling factor'));.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.h_lf_bank_scaling_factor (read)
%   zef.h_lf_bank_tool (read)
%   zef.h_lf_normalization (read)
%   zef.h_lf_tag (read)
%   zef.lf_bank_scaling_factor (read, write)
%   zef.lf_bank_storage (read, write)
%   zef.lf_item_list (read, write)
%   zef.lf_item_selected (read, write)
%   zef.lf_item_type (read, write)
%   zef.lf_normalization (read, write)
%   zef.lf_normalization_functions_dir (read, write)
%   zef.lf_normalization_functions_file_list (read, write)
%   zef.lf_normalization_functions_name_list (read, write)
%   zef.lf_tag (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'lf_bank_scaling_factor'));` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




if not(isfield(zef,'lf_bank_scaling_factor'));
    zef.lf_bank_scaling_factor = 1;
end;

if not(isfield(zef,'lf_item_type'));
    zef.lf_item_type = '';
end;

if not(isfield(zef,'lf_tag'));
    zef.lf_tag = 'EEG';
end;

if not(isfield(zef,'lf_normalization'));
    zef.lf_normalization = 1;
end;

if not(isfield(zef,'lf_bank_storage'));
    zef.lf_bank_storage = cell(0);
end;

if not(isfield(zef,'lf_bank_storage'));
    zef.lf_item_list = cell(0);
end;

if not(isfield(zef,'lf_item_selected'));
    zef.lf_item_selected = [];
end;

zef.lf_normalization_functions_dir = which('zef_init_lf_bank_tool.m');
zef.lf_normalization_functions_dir = [fileparts(zef.lf_normalization_functions_dir) '/' 'lead_field_normalization_functions/*.m'];

zef.lf_normalization_functions_name_list = cell(0);
zef.lf_normalization_functions_file_list = cell(0);

zef.aux_field = dir(zef.lf_normalization_functions_dir);
for zef_i = 1 : length(zef.aux_field)
    [~, zef.lf_normalization_functions_file_list{zef_i}] = fileparts(zef.aux_field(zef_i).name);
end
for zef_i = 1 : length(zef.lf_normalization_functions_file_list)
    zef.aux_field = help(zef.lf_normalization_functions_file_list{zef_i});
    zef.aux_field = zef.aux_field(strfind(zef.aux_field,'Description:'):end);
    zef.lf_normalization_functions_name_list{zef_i} = strtrim(zef.aux_field(13:end-1));
end
[zef.lf_normalization_functions_name_list zef.aux_field] = sort(zef.lf_normalization_functions_name_list);
zef.lf_normalization_functions_file_list = zef.lf_normalization_functions_file_list(zef.aux_field);

if not(isempty(zef.lf_normalization_functions_name_list))
    set(zef.h_lf_normalization,'items',zef.lf_normalization_functions_name_list);
end

if isfield(zef,'h_lf_bank_tool')
    if isvalid(zef.h_lf_bank_tool)
        set(zef.h_lf_tag,'Value',zef.lf_tag);
        set(zef.h_lf_bank_scaling_factor,'Value',num2str(zef.lf_bank_scaling_factor));
        zef.aux_field = get(zef.h_lf_normalization,'items');
        set(zef.h_lf_normalization,'Value',zef.aux_field(zef.lf_normalization));
    end
end

zef_update_lf_bank_tool;

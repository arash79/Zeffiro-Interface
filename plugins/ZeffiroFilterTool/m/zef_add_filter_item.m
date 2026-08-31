%ZEF_ADD_FILTER_ITEM  Add button: append selected filter_bank stage; parse help() Input: defaults.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_add_filter (wired in zef_filter_tool).
%   Index is length(filter_pipeline_list)+1. Copies name/file from
%   filter_name_list / filter_file_list at filter_list_selected, and
%   filter_tag. help(file) slice from 'Input:' to 'Output:' is split on
%   commas; each token's label is before '[Default:' and the default is
%   inside the brackets. If that default string is a field of zef (e.g.
%   filter_sampling_rate), evalin('base','zef.<name>') replaces it.
%   Writes filter_pipeline{i}.parameters as an N-by-2 cell, clears
%   filter_pipeline_selected, then zef_update_filter_tool.
%
%   See also zef_init_filter_tool, zef_filter_raw_data.

zef_i = length(zef.filter_pipeline_list)+1;
zef.filter_pipeline{zef_i}.name = zef.filter_name_list{zef.filter_list_selected};
zef.filter_pipeline{zef_i}.file = zef.filter_file_list{zef.filter_list_selected};
zef.filter_pipeline{zef_i}.filter_tag = zef.filter_tag;

zef.aux_field = help(zef.filter_file_list{zef.filter_list_selected});
zef.aux_idx_1 = strfind(zef.aux_field, 'Input:');
zef.aux_idx_2 = strfind(zef.aux_field, 'Output:');
if ~isempty(zef.aux_idx_1) && ~isempty(zef.aux_idx_2) ...
        && zef.aux_idx_2(1) > zef.aux_idx_1(1)
    zef.aux_field = zef.aux_field(zef.aux_idx_1(1)+6:zef.aux_idx_2(1)-1);
else
    zef.aux_field = '';
end
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

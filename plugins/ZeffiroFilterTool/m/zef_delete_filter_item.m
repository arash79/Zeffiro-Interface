%ZEF_DELETE_FILTER_ITEM  Delete selected pipeline stages (after the confirm dialog).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_del_filter (confirm dialog is in
%   zef_filter_tool). Re-reads Value from h_filter_pipeline_list, keeps
%   stages whose index is not in that selection, truncates both
%   filter_pipeline and filter_pipeline_list, clears selection, then
%   zef_update_filter_tool. Does not touch raw_data / processed_data.
%
%   See also zef_add_filter_item, zef_update_filter_tool.

zef.filter_pipeline_selected = get(zef.h_filter_pipeline_list,'value');

zef_j = 0;
for zef_i = 1 : length(zef.filter_pipeline_list)
    if not(ismember(zef_i,zef.filter_pipeline_selected))
        zef_j = zef_j + 1;
        zef.filter_pipeline{zef_j} =  zef.filter_pipeline{zef_i};
        zef.filter_pipeline_list{zef_j} = zef.filter_pipeline_list{zef_i};
    end
end

zef.filter_pipeline = zef.filter_pipeline(1:zef_j);
zef.filter_pipeline_list = zef.filter_pipeline_list(1:zef_j);

zef.filter_pipeline_selected = [];

clear zef_i zef_j;

zef_update_filter_tool;

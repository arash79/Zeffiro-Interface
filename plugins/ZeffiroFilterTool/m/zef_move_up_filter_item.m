%ZEF_MOVE_UP_FILTER_ITEM  Move selected pipeline items to the front of the list.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. ButtonPushedFcn of h_move_up_filter. Reorders
%   filter_pipeline as [selected, setdiff(1:N, selected)] then
%   zef_update_filter_tool. Does not change processed_data.
%
%   See also zef_move_down_filter_item, zef_update_filter_tool.

zef.filter_pipeline =  zef.filter_pipeline([zef.filter_pipeline_selected setdiff([1:length(zef.filter_pipeline)],zef.filter_pipeline_selected)]);
zef_update_filter_tool;

%ZEF_FILTER_RAW_DATA  Run zef.filter_pipeline on zef.raw_data.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. zef_update_filter_tool first, then processed_data = raw_data.
%   Loops j = 1:length(filter_pipeline_list) (every stage, not the
%   current selection). Each stage is str2func(entry.file) called as
%   processed_data = f(processed_data, parameters{:,2}{:}). A string
%   filter_pipeline_selected is wrapped in a cell but that value is not
%   used as a subset. Plot and the three Substitute-processed buttons
%   call this first.
%
%   See also zef_add_filter_item, zef_filter_plot_data.

zef_update_filter_tool;
zef.processed_data = zef.raw_data;
if isstr(zef.filter_pipeline_selected)
    zef.filter_pipeline_selected = {zef.filter_pipeline_selected};
end
for zef_j = 1 : length(zef.filter_pipeline_list)
    zef.aux_field = str2func(zef.filter_pipeline{zef_j}.file);
    zef.filter_parameters = zef.filter_pipeline{zef_j}.parameters(:,2);
    zef.processed_data = zef.aux_field(zef.processed_data, zef.filter_parameters{:});
end

clear zef_i zef_j

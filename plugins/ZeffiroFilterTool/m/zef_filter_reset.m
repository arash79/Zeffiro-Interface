%ZEF_FILTER_RESET  Clear pipeline, epoch points, and filter_* lists (Reset button, after confirm).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Confirm dialog is in zef_filter_tool (then this, then
%   zef_init_filter_tool / zef_update_filter_tool). Also called from
%   zef_filter_load and zef_load_epoch_points. Clears epoch points,
%   save path/file, name/file/parameter lists, tag ('Default tag'),
%   data_segment '0', pipeline cells, and sets filter_sampling_rate
%   from inv_sampling_frequency. Does not clear raw_data, processed_data,
%   measurements, or filter_zoom.
%
%   See also zef_init_filter_tool, zef_filter_load.

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

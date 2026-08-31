%ZEF_FILTER_TOOL  Open Forward tools → Filter tool.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Menu callback from profile/multicompartment_head/zeffiro_plugins.ini
%   (label "Filter tool", parent forward_tools). Script: opens the App
%   Designer window, wires ButtonPushedFcn, then zef_init_filter_tool.
%   Pipeline stages are m/filter_bank; runner is zef_filter_raw_data.
%   Writes zef.processed_data; substitute buttons copy to measurements,
%   raw_data, or noise_data.
%
%   See also zef_filter_raw_data, zef_import_raw_data.
%

zef_data= zeffiro_interface_filter_tool;
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end
set(zef.h_zef_filter_tool,'Name','ZEFFIRO Interface: Filter tool')
set(findobj(zef.h_zef_filter_tool.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_zef_filter_tool.Children,'-property','FontSize'),'FontSize',zef.font_size);
clear zef_i zef_data;

zef.h_filter_load_epoch_points.ButtonPushedFcn = 'zef_load_epoch_points;';
zef.h_filter_reset.ButtonPushedFcn = '[zef.yesno] = zef_ui_confirm(''Reset filter tool?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef_filter_reset; zef_init_filter_tool; zef_update_filter_tool; end;';
zef.h_zef_filter_tool.DeleteFcn = 'if isfield(zef,''h_scroll_bar''); delete(zef.h_scroll_bar);end;';
zef.h_filter_get_epoch_points.ButtonPushedFcn = 'zef.aux_field = getpts(zef.h_axes1); zef.filter_epoch_points = [zef.filter_epoch_points(:) ; zef.aux_field]'';';
zef.h_filter_reset_epoch_points.ButtonPushedFcn = '[zef.yesno] = zef_ui_confirm(''Reset epoch points?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef.filter_epoch_points = []; end;';
zef.h_filter_save_as.ButtonPushedFcn = 'zef_filter_save_as;';
zef.h_filter_save_processed_data.ButtonPushedFcn = 'zef_filter_save_processed_data_as;';
zef.h_filter_load.ButtonPushedFcn = 'zef_filter_load;';
zef.h_filter_import_data.ButtonPushedFcn = 'zef_import_raw_data;';
zef.h_filter_substitute_raw_data_with_measurement_data.ButtonPushedFcn = 'zef_filter_substitute_raw_data_with_measurement_data;';
zef.h_filter_plot_data.ButtonPushedFcn = 'zef_filter_schroll_bar; zef_update_filter_tool; zef_filter_raw_data; zef_filter_plot_data;';
zef.h_filter_substitute_measurement_data.ButtonPushedFcn = 'zef_filter_substitute_raw_data;';
zef.h_filter_substitute_raw_data.ButtonPushedFcn = 'zef_filter_substitute_measurement_data;';
zef.h_filter_substitute_noise_data.ButtonPushedFcn = 'zef_filter_substitute_noise_data;';
zef.h_add_filter.ButtonPushedFcn = 'zef_add_filter_item;';
zef.h_del_filter.ButtonPushedFcn = '[zef.yesno] = zef_ui_confirm(''Delete selected filters?'',''Yes'',''No''); if isequal(zef.yesno,''Yes''); zef_delete_filter_item; end;';
zef.h_move_up_filter.ButtonPushedFcn = 'zef_move_up_filter_item;';
zef.h_move_down_filter.ButtonPushedFcn = 'zef_move_down_filter_item;';
zef.h_filter_tag.ValueChangedFcn = 'zef.filter_tag = get(zef.h_filter_tag,''value'');';
zef.h_filter_sampling_rate.ValueChangedFcn = 'zef.filter_sampling_rate = str2num(get(zef.h_filter_sampling_rate,''value''));';
zef.h_filter_pipeline_list.ValueChangedFcn = 'zef.filter_pipeline_selected = get(zef.h_filter_pipeline_list,''value'');zef_update_filter_tool;';
zef.h_filter_parameter_list.DisplayDataChangedFcn = 'zef.filter_pipeline{zef.filter_pipeline_selected(1)}.parameters = zef.h_filter_parameter_list.Data;';
zef.h_filter_list.ValueChangedFcn = 'zef.filter_list_selected = get(zef.h_filter_list,''value'');';
zef.h_filter_list.ItemsData=1;

zef_init_filter_tool;

try
    zef_ui_ready(zef.h_zef_filter_tool);
catch
end
try
    zef.h_zef_filter_tool.SizeChangedFcn = '';
    if isappdata(zef.h_zef_filter_tool, 'ZefSizeChangedInner')
        rmappdata(zef.h_zef_filter_tool, 'ZefSizeChangedInner');
    end
catch
end
try
    zef_ui_bind_min_size(zef.h_zef_filter_tool, 640, 640);
catch
end
zef.zef_filter_tool_current_size = get(zef.h_zef_filter_tool,'Position');

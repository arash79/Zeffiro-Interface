%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_dpq_window(zef)
% --- Zeffiro documentation header ---
% zef_dpq_window — Zef dpq window.
%
% Purpose:
%   Zef dpq window.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.aux_field (read, write)
%   zef.dpq_dir (read, write)
%   zef.dpq_selected (read)
%   zef.dynamica_plot_queue_description (read, write)
%   zef.dynamical_plot_queue_current_size (read, write)
%   zef.dynamical_plot_queue_description (read)
%   zef.dynamical_plot_queue_list (read, write)
%   zef.dynamical_plot_queue_table (read, write)
%   zef.fieldnames (read, write)
%   zef.font_size (read)
%   zef.h_dynamical_plot_queue (read)
%   zef.h_dynamical_plot_queue_description (read)
%   zef.h_dynamical_plot_queue_list (read)
%   zef.h_dynamical_plot_queue_menu_add (read)
%   zef.h_dynamical_plot_queue_menu_delete (read)
%   … (3 more)
%
% Calls (project):
%   zef_change_size_function
%   zef_dpq_window
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_dpq_window(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef_data=zeffiro_interface_dynamical_plot_queue_app;
zef.fieldnames = fieldnames(zef_data);
for zef_i = 1:length(zef.fieldnames)
    zef.(zef.fieldnames{zef_i}) = zef_data.(zef.fieldnames{zef_i});
end
set(zef.h_dynamical_plot_queue,'Name','ZEFFIRO Interface: Dynamical plot queue');
set(findobj(zef.h_dynamical_plot_queue.Children,'-property','FontUnits'),'FontUnits','pixels')
set(findobj(zef.h_dynamical_plot_queue.Children,'-property','FontSize'),'FontSize',zef.font_size);
clear zef_i zef_data;

zef.h_dynamical_plot_queue_table.Data = zef.dynamical_plot_queue_table;

zef.dpq_dir = which('zeffiro_interface_dynamical_plot_queue.m');
zef.dpq_dir = [fileparts(zef.dpq_dir) '/' 'dynamical_plot_queue_bank/*.m'];

zef.dynamical_plot_queue_list =  cell(0);
zef.aux_field = dir(zef.dpq_dir);
for zef_i = 1 : length(zef.aux_field)
    [~, zef.dynamical_plot_queue_list{zef_i}] = fileparts(zef.aux_field(zef_i).name);
end
zef.dynamica_plot_queue_description = cell(0);
for zef_i = 1 : length(zef.dynamical_plot_queue_list)
    zef.dynamical_plot_queue_description{zef_i} = erase(help(zef.dynamical_plot_queue_list{zef_i}),char(10));
end

zef = rmfield(zef,'aux_field');

set(zef.h_dynamical_plot_queue_list,'Items',zef.dynamical_plot_queue_list);
set(zef.h_dynamical_plot_queue_list,'ItemsData',[1:length(zef.dynamical_plot_queue_list)]');
zef.h_dynamical_plot_queue_list.Value = 1;
zef.h_dynamical_plot_queue_description.Value = zef.dynamical_plot_queue_description{1};

set(zef.h_dynamical_plot_queue_table,'columnformat',{'char','logical',{'static', 'dynamical'},'char'});
set(zef.h_dynamical_plot_queue_table,'CellEditCallback','zef.dynamical_plot_queue_table = zef.h_dynamical_plot_queue_table.Data;');
set(zef.h_dynamical_plot_queue_table,'CellSelectionCallback',@zef_dpq_selection);

set(zef.h_dynamical_plot_queue_menu_add,'MenuSelectedFcn','zef.h_dynamical_plot_queue_table.Data = zef_dpq_add;');
set(zef.h_dynamical_plot_queue_menu_list,'MenuSelectedFcn',['zef.h_dynamical_plot_queue_table.Data(end+1,:) = {zef.dynamical_plot_queue_list{zef.h_dynamical_plot_queue_list.Value}, ''true'', ''static'', zef.dynamical_plot_queue_description{zef.h_dynamical_plot_queue_list.Value}}; zef.dynamical_plot_queue_table = zef.h_dynamical_plot_queue_table.Data;']);
set(zef.h_dynamical_plot_queue_menu_delete,'MenuSelectedFcn','zef.h_dynamical_plot_queue_table.Data = zef_dpq_delete;zef.dynamical_plot_queue_table = zef.h_dynamical_plot_queue_table.Data;');
set(zef.h_dynamical_plot_queue_list,'ValueChangedFcn','zef.h_dynamical_plot_queue_description.Value = zef.dynamical_plot_queue_description{zef.h_dynamical_plot_queue_list.Value};');
set(zef.h_dynamical_plot_queue_description,'ValueChangedFcn','zef.h_dynamical_plot_queue_table.Data{zef.dpq_selected(1),4} = [zef.h_dynamical_plot_queue_description.Value{:}];')
set(zef.h_dynamical_plot_queue_script,'ValueChangedFcn','zef.h_dynamical_plot_queue_table.Data{zef.dpq_selected(1),1} = [zef.h_dynamical_plot_queue_script.Value{:}];')

set(zef.h_dynamical_plot_queue,'AutoResizeChildren','off');
zef.dynamical_plot_queue_current_size = get(zef.h_dynamical_plot_queue,'Position');
set(zef.h_dynamical_plot_queue,'SizeChangedFcn','zef.dynamical_plot_queue_current_size = zef_change_size_function(zef.h_dynamical_plot_queue,zef.dynamical_plot_queue_current_size);');

end

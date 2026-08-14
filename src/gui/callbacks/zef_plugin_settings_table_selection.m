function zef_plugin_settings_table_selection(hObject,eventdata,handles)
%ZEF_PLUGIN_SETTINGS_TABLE_SELECTION  CellSelectionCallback for the plugin-settings table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_open_plugin_settings (Settings → **Plugin settings**).
%   Unique selected rows → zef.plugin_settings_selected for that table's
%   Add/Delete menus. Apply on that window is zef_save_plugin_settings;
%   zef_plugin (not a callback in this folder).
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_open_plugin_settings.

plugin_settings_selected = eventdata.Indices(:,1);
plugin_settings_selected = unique(plugin_settings_selected);
plugin_settings_selected = plugin_settings_selected(:)';
evalin('base',['zef.plugin_settings_selected =[' num2str(plugin_settings_selected) '];']);

end

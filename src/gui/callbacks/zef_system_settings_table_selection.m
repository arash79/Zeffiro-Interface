function zef_system_settings_table_selection(hObject,eventdata,handles)
%ZEF_SYSTEM_SETTINGS_TABLE_SELECTION  CellSelectionCallback for the system-settings INI table.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Wired from zef_open_system_settings (Settings → **System settings
%   (zeffiro_interface.ini)**). Unique selected rows →
%   zef.system_settings_selected so the table Add/Delete menus insert or
%   remove at that row. Does not apply the INI; that is
%   zef_apply_system_settings.
%
%   Inputs (MATLAB UITable CellSelectionCallback)
%     hObject, handles  - unused.
%     eventdata.Indices - N-by-2 [row, column] of the selection.
%
%   See also zef_apply_system_settings, zef_open_system_settings.

system_settings_selected = eventdata.Indices(:,1);
system_settings_selected = unique(system_settings_selected);
system_settings_selected = system_settings_selected(:)';
evalin('base',['zef.system_settings_selected =[' num2str(system_settings_selected) '];']);

end

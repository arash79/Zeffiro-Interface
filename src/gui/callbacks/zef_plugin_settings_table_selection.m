function zef_plugin_settings_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_plugin_settings_table_selection — Zef plugin settings table selection.
%
% Purpose:
%   Zef plugin settings table selection.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   hObject
%   eventdata
%   handles
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.plugin_settings_selected (read, write)
%
% Calls (project):
%   zef_plugin_settings_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_plugin_settings_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


plugin_settings_selected = eventdata.Indices(:,1);
plugin_settings_selected = unique(plugin_settings_selected);
plugin_settings_selected = plugin_settings_selected(:)';
evalin('base',['zef.plugin_settings_selected =[' num2str(plugin_settings_selected) '];']);

end

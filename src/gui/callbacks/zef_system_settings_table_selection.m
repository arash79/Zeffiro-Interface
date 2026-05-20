function zef_system_settings_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_system_settings_table_selection — Zef system settings table selection.
%
% Purpose:
%   Zef system settings table selection.
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
%   zef.system_settings_selected (read, write)
%
% Calls (project):
%   zef_system_settings_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_system_settings_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


system_settings_selected = eventdata.Indices(:,1);
system_settings_selected = unique(system_settings_selected);
system_settings_selected = system_settings_selected(:)';
evalin('base',['zef.system_settings_selected =[' num2str(system_settings_selected) '];']);

end

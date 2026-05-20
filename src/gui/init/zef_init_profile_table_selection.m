function zef_init_profile_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_init_profile_table_selection — Initializes GUI widgets and default `zef` fields for profile_table_selection.
%
% Purpose:
%   Initializes GUI widgets and default `zef` fields for profile_table_selection.
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
%   zef.init_profile_selected (read, write)
%
% Calls (project):
%   zef_init_profile_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_init_profile_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


init_profile_selected = eventdata.Indices(:,1);
init_profile_selected = unique(init_profile_selected);
init_profile_selected = init_profile_selected(:)';
evalin('base',['zef.init_profile_selected =[' num2str(init_profile_selected) '];']);
end

function zef_parameter_profile_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_parameter_profile_table_selection — Zef parameter profile table selection.
%
% Purpose:
%   Zef parameter profile table selection.
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
%   zef.parameter_profile_selected (read, write)
%
% Calls (project):
%   zef_parameter_profile_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_parameter_profile_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


parameter_profile_selected = eventdata.Indices(:,1);
parameter_profile_selected = unique(parameter_profile_selected);
parameter_profile_selected = parameter_profile_selected(:)';
evalin('base',['zef.parameter_profile_selected =[' num2str(parameter_profile_selected) '];']);

end

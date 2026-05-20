function zef_forward_simulation_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_forward_simulation_table_selection — Zef forward simulation table selection.
%
% Purpose:
%   Zef forward simulation table selection.
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
%   zef.forward_simulation_column_selected (read, write)
%   zef.forward_simulation_selected (read, write)
%   zef.h_forward_simulation_script (read)
%   zef.h_forward_simulation_table (read)
%
% Calls (project):
%   zef_forward_simulation_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_forward_simulation_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


forward_simulation_selected = eventdata.Indices(:,1);
forward_simulation_column_selected = eventdata.Indices(1,2);
forward_simulation_selected = unique(forward_simulation_selected);
forward_simulation_selected = forward_simulation_selected(:)';
evalin('base',['zef.forward_simulation_selected =[' num2str(forward_simulation_selected) '];']);
evalin('base',['zef.forward_simulation_column_selected =[' num2str(forward_simulation_column_selected) '];']);
aux_char = char(evalin('base',['zef.h_forward_simulation_table.Data{' num2str(forward_simulation_selected(1)) ',' num2str(forward_simulation_column_selected) '}']));
evalin('base',['zef.h_forward_simulation_script.Value = ''' aux_char ''';']);

end

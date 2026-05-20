function zef_transform_table_selection(hObject,eventdata,handles)
% --- Zeffiro documentation header ---
% zef_transform_table_selection — Zef transform table selection.
%
% Purpose:
%   Zef transform table selection.
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
%   zef.current_transform (read, write)
%   zef.transforms_selected (read, write)
%
% Calls (project):
%   zef_transform_table_selection
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `zef_transform_table_selection(hObject, eventdata, handles)` with project root and `src` on the path.
% --- End Zeffiro documentation header


transform_selected = eventdata.Indices(1);

evalin('base', ['zef.current_transform = ' num2str(transform_selected) ';']);
evalin('base','run(''zef_init_transform_parameters'')');

transforms_selected = eventdata.Indices(:,1);
transforms_selected = unique(transforms_selected);
transforms_selected = transforms_selected(:)';
evalin('base',['zef.transforms_selected =[' num2str(transforms_selected) '];']);

end

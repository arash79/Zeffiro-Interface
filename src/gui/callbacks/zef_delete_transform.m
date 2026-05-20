% --- Zeffiro documentation header ---
% function zef_delete_transform — Function zef delete transform.
%
% Purpose:
%   Function zef delete transform.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.h_transform_table (read)
%   zef.lock_transforms_on (read)
%   zef.transforms_selected (read)
%
% Calls (project):
%   zef_delete_transform
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_delete_transform` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_delete_transform


if not(evalin('base','zef.lock_transforms_on'))

    table_data = evalin('base','zef.h_transform_table.Data');
    transforms_selected = evalin('base','zef.transforms_selected');

    for i = 1 : length(transforms_selected)

        evalin('base',['zef.h_transform_table.Data{' num2str(table_data{transforms_selected(i),1}) '} = NaN;'])

    end

    evalin('base','run(''zef_update_transform'')');

end

end

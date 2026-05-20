function [relative_size] = zef_get_relative_size(object_handle)
% --- Zeffiro documentation header ---
% zef_get_relative_size — Zef get relative size.
%
% Purpose:
%   Zef get relative size.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   object_handle
%
% Outputs:
%   relative_size
%
% Calls (project):
%   zef_get_relative_size
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[relative_size] = zef_get_relative_size(object_handle)` with project root and `src` on the path.
% --- End Zeffiro documentation header


set(object_handle,'units','pixels')
object_size = get(object_handle,'position');
object_children = findall(object_handle,'-property','Position');
object_children = setdiff(object_children,object_handle);
relative_size_aux = get(object_children,'Position');

if and(iscell(relative_size_aux),not(isempty(relative_size_aux)))
    for i = 1 : length(relative_size_aux)
        if size(relative_size_aux{i},2) == 4
            relative_size_aux{i} = relative_size_aux{i}./object_size([3 4 3 4]);
        end
    end
else
    relative_size_aux = relative_size_aux./object_size([3 4 3 4]);
end

if iscell(relative_size_aux)
    relative_size = relative_size_aux(:);
else
    relative_size = {relative_size_aux};
end


end

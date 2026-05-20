% --- Zeffiro documentation header ---
% function zef_toggle_edges — Function zef toggle edges.
%
% Purpose:
%   Function zef toggle edges.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Calls (project):
%   zef_toggle_edges
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_toggle_edges` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_toggle_edges


h = get(gcf,'Children');
h = findobj(h,'Tag','axes1');
h = get(h,'Children');
for i = 1 : length(h);
    if find(ismember(properties(h(i)),'EdgeColor'));
        if isequal(h(i).EdgeColor,[1 1 1])
            set(h(i),'edgecolor','none');
        else
            set(h(i),'edgecolor',[1 1 1]);
        end
    end

end

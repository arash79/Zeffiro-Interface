function fig_num = zef_fig_num
% --- Zeffiro documentation header ---
% fig_num — Fig num.
%
% Purpose:
%   Fig num.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Calls (project):
%   zef_fig_num
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `fig_num` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header


h_fig_aux = findobj(groot, '-property','ZefFig');

max_tag = 0;
for i = 1 : length(h_fig_aux)
    tag_val = get(h_fig_aux(i),'ZefFig');
    if not(isempty(tag_val))
        max_tag = max(max_tag,tag_val);
    end
end

fig_num = max_tag + 1;

end

function zef_update_contour(zef)
% --- Zeffiro documentation header ---
% zef_update_contour — Syncs GUI control values into `zef` for contour.
%
% Purpose:
%   Syncs GUI control values into `zef` for contour.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Inputs:
%   zef
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.contour_set (read)
%   zef.show_contour (read)
%
% Calls (project):
%   zef_plot_contour
%   zef_update_contour
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_update_contour(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if eval('zef.show_contour')
    h_fig = gcf;
    h_axes = findobj(h_fig.Children,'Tag','axes1');
    h_contour_old = findobj(h_axes.Children,'Tag','contour');
    delete(h_contour_old);
    h_contour_text_old = findobj(h_axes.Children,'Tag','contour_text');
    delete(h_contour_text_old);
    h_reconstruction = findobj(h_axes.Children,'Tag','reconstruction');
    for i = 1 : length(h_reconstruction)
        zef_plot_contour(zef,eval('zef.contour_set'),h_reconstruction(i).FaceVertexCData,h_reconstruction(i).Faces,h_reconstruction(i).Vertices);
    end
end

end

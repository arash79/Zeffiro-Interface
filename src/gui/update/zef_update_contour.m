function zef_update_contour(zef)
%ZEF_UPDATE_CONTOUR  Redraw contour overlays on Tag='reconstruction' patches.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Function. No-op unless zef.show_contour is true (Mesh visualization
%   tool contour toggle, copied by zef_update_mesh_visualization_tool).
%   Deletes existing Tag='contour' and Tag='contour_text' on gcf axes1,
%   then calls zef_plot_contour(zef, zef.contour_set, FaceVertexCData,
%   Faces, Vertices) for each reconstruction patch.
%
%   Also run from zef_update_colorscale_min / _max after CLim changes.
%   Does not write zef fields.
%
%   zef_update_contour(zef)
%
%   See also zef_plot_contour, zef_update_mesh_visualization_tool.
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

function zef_dpq_wireframe_plot
%ZEF_DPQ_WIREFRAME_PLOT  Queue renderer: zef.wireframe_triangles as a grey surface.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Reads zef.wireframe_triangles and zef.wireframe_nodes from base
%   (WireframeTool). trimesh on base zef.h_axes1, FaceColor 0.5 grey,
%   two opposing lights, phong, axis equal, then hides the axes.
%   Tag: 'additional'.
%
%   zef_dpq_wireframe_plot
%
%   See also zef_dpq_plot_resection, zef_plot_dpq.

w_t = evalin('base','zef.wireframe_triangles');
w_n = evalin('base','zef.wireframe_nodes');

h_a = evalin('base','zef.h_axes1');
hold on;

h_t = trimesh(w_t,w_n(:,1),w_n(:,2),w_n(:,3));
h_t.EdgeColor = 'none';
h_t.FaceColor  = 0.5*[1 1 1];
h_l = light;
h_l.Position = [1 0 0];
h_l = light;
h_l.Position = [-1 0 0];
lighting phong;
axis equal;
h_t.Tag = 'additional';

h_a.Visible = 'off';
hold off;

end

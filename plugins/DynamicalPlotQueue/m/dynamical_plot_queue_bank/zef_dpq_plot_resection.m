function zef_dpq_plot_resection(varargin)
%ZEF_DPQ_PLOT_RESECTION  Queue renderer: free-boundary mesh of resection points.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Delaunay tetrahedralization of the point cloud, then trimesh of
%   freeBoundary. Default points are base zef.resection_points. Draws on
%   caller h_axes_image. Default color 'g'. If alpha is 0 (default), Tag
%   is 'additional' and facealpha is left unset; otherwise facealpha is
%   set and the tag is not.
%
%   zef_dpq_plot_resection
%   zef_dpq_plot_resection(points)
%   zef_dpq_plot_resection(points, color)
%   zef_dpq_plot_resection(points, color, alpha)
%
%   Tetra volumes and centroids are computed and unused.
%
%   See also zef_dpq_wireframe_plot, zef_plot_dpq.

alpha_value = 0;
resection_color = 'g';
if not(isempty(varargin))
    resection_points = varargin{1};
    if length(varargin) > 1
        resection_color = varargin{2};
    end
    if length(varargin) > 2
        alpha_value = varargin{3};
    end
else
    resection_points = evalin('base','zef.resection_points');
end

D = delaunayTriangulation(resection_points(:,1),resection_points(:,2),resection_points(:,3));
nodes = D.Points;
tetrahedra = D.ConnectivityList;

tilavuus = zef_tetra_volume(nodes, tetrahedra, true);

c_points = 0.25*(nodes(tetrahedra(:,1),:)+ nodes(tetrahedra(:,2),:)+nodes(tetrahedra(:,3),:)+nodes(tetrahedra(:,4),:));

FB = freeBoundary(D);

h = evalin('caller','h_axes_image');
h_f = gcf;
h_f.CurrentAxes = h;
h_resection = trimesh(FB,nodes(:,1),nodes(:,2),nodes(:,3));
set(h_resection,'facecolor',resection_color)
set(h_resection,'edgecolor','none');
if alpha_value == 0
    set(h_resection,'tag','additional');
else
    set(h_resection,'facealpha',alpha_value);
end
set(h_resection,'facelighting','phong');

end

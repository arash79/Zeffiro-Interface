function zef_dpq_plot_resection(varargin)
% --- Zeffiro documentation header ---
% zef_dpq_plot_resection — Zef dpq plot resection.
%
% Purpose:
%   Zef dpq plot resection.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   varargin
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.resection_points (read)
%
% Calls (project):
%   zef_dpq_plot_resection
%   zef_tetra_volume
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_dpq_plot_resection(varargin)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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
%axes(h);
h_resection = trimesh(FB,nodes(:,1),nodes(:,2),nodes(:,3));
set(h_resection,'facecolor',resection_color);
set(h_resection,'edgecolor','none');
if alpha_value == 0
    set(h_resection,'tag','additional');
else
    set(h_resection,'facealpha',alpha_value);
end
set(h_resection,'facelighting','phong');

end

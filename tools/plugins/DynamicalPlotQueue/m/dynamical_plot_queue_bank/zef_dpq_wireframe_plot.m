% --- Zeffiro documentation header ---
% function zef_dpq_wireframe_plot — Function zef dpq wireframe plot.
%
% Purpose:
%   Function zef dpq wireframe plot.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.wireframe_nodes (read)
%   zef.wireframe_triangles (read)
%
% Calls (project):
%   zef_dpq_wireframe_plot
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `function zef_dpq_wireframe_plot` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header
function zef_dpq_wireframe_plot


w_t = evalin('base','zef.wireframe_triangles');
w_n = evalin('base','zef.wireframe_nodes');

h_a = evalin('base','zef.h_axes1');
hold on;
%axes(h_a);

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

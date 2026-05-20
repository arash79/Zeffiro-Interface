function zef_wireframe_plot(w_t,w_n)
% --- Zeffiro documentation header ---
% zef_wireframe_plot — Zef wireframe plot.
%
% Purpose:
%   Zef wireframe plot.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   w_t
%   w_n
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%
% Calls (project):
%   zef_wireframe_plot
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_wireframe_plot(w_t, w_n)` with project root and `src` on the path.
% --- End Zeffiro documentation header


h_a = evalin('base','zef.h_axes1');
axes(h_a);

h_t = trimesh(w_t,w_n(:,1),w_n(:,2),w_n(:,3));
h_t.EdgeColor = 'none';
h_t.FaceColor  = 0.5*[1 1 1];
h_l = light;
h_l.Position = [1 0 0];
h_l = light;
h_l.Position = [-1 0 0];
lighting phong;
axis equal;
h_t.Tag = 'surface';

h_a.Visible = 'off';

end

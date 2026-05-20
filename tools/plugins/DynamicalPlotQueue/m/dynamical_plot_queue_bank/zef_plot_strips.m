function zef_plot_strips(strip_struct)
% --- Zeffiro documentation header ---
% zef_plot_strips — Renders or updates a plot_strips figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_strips figure from current `zef` state.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   strip_struct
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.strip_struct (read)
%
% Calls (project):
%   zef_plot_strips
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_plot_strips(strip_struct)` with project root and `src` on the path.
% --- End Zeffiro documentation header


hold on
if nargin == 0;
    strip_struct = evalin('caller','zef.strip_struct');
end
haxes = evalin('caller','zef.h_axes1');
axes(haxes);
hold on
for i=1:strip_struct.probe_num
    
    tri1 = strip_struct.faces{i};
    
    x1 = strip_struct.vertices{i}(:,1);
    y1 = strip_struct.vertices{i}(:,2);
    z1 = strip_struct.vertices{i}(:,3);
    
    
    h_t1 = trisurf(tri1,x1,y1,z1);
    h_t1.EdgeColor = 'none';
    h_t1.Tag = 'additional: electrode strip';
    h_t1.FaceColor = [0.6 0.6 0.6];

end

hold off

end

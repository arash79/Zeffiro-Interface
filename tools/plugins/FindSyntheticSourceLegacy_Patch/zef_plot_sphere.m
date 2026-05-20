function h_surf = zef_plot_sphere(position,radius,color)
% --- Zeffiro documentation header ---
% zef_plot_sphere — Renders or updates a plot_sphere figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_sphere figure from current `zef` state.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   position
%   radius
%   color
%
% Outputs:
%   h_surf
%
% Calls (project):
%   zef_plot_sphere
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[h_surf] = zef_plot_sphere(position, radius, color)` with project root and `src` on the path.
% --- End Zeffiro documentation header




h_axes = gca;
hold_state = ishold(h_axes);

if not(hold_state)
    hold on;
end

[X,Y,Z] = sphere;
X = X*radius;
Y = Y*radius;
Z = Z*radius;
h_surf = surf(h_axes,X+position(1),Y+position(2),Z+position(3));
set(h_surf,'edgecolor','none','facecolor',color,'facealpha','0.5');

if not(hold_state)
    hold off;
end

end

function h_surf = zef_plot_ellipsoid(position,a,b,c,z,color)
% --- Zeffiro documentation header ---
% zef_plot_ellipsoid — Renders or updates a plot_ellipsoid figure from current `zef` state.
%
% Purpose:
%   Renders or updates a plot_ellipsoid figure from current `zef` state.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   position
%   a
%   b
%   c
%   z
%   color
%
% Outputs:
%   h_surf
%
% Calls (project):
%   zef_plot_ellipsoid
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[h_surf] = zef_plot_ellipsoid(position, a, b, c, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header




h_axes = gca;
hold_state = ishold(h_axes);

if not(hold_state)
    hold on;
end

z = z'/norm(z);
x = 1/sqrt(z(1)^2+z(2)^2)* [z(2) -z(1) 0]';
y = cross(z,x);



T_ellipsoid_to_lab = [x y z];
ellipsoid = T_ellipsoid_to_lab*[[a 0 0];[0 b 0];[0 0 c]]';


[X_0,Y_0,Z_0] = sphere(50);

Aux_arr = ellipsoid*[X_0(:) Y_0(:) Z_0(:)]';
X = reshape(Aux_arr(1,:),size(X_0));
Y = reshape(Aux_arr(2,:),size(Y_0));
Z = reshape(Aux_arr(3,:),size(Z_0));

h_surf = surf(h_axes,X+position(1),Y+position(2),Z+position(3));
set(h_surf,'edgecolor','none','facecolor',color,'facealpha','0.5');

if not(hold_state)
    hold off;
end

end

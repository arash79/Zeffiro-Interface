function zef_parcellation_roi_plot(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_roi_plot — Zef parcellation roi plot.
%
% Purpose:
%   Zef parcellation roi plot.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   See function signature and code below.
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.parcellation_roi_center (read)
%   zef.parcellation_roi_color (read)
%   zef.parcellation_roi_radius (read)
%
% Calls (project):
%   zef_parcellation_roi_plot
%
% Side effects:
%   - filesystem I/O
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `zef_parcellation_roi_plot(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


[s_x,s_y,s_z] = sphere(100);
h_axes1 = zef.h_axes1;
hold(h_axes1,'on');
h_parcellation_roi_sphere = findobj(h_axes1,'Tag','additional: parcellation roi');
delete(h_parcellation_roi_sphere);
for i = 1 : size(zef.parcellation_roi_center,1)
s_x_2 = zef.parcellation_roi_radius(i)*s_x + zef.parcellation_roi_center(i,1);
s_y_2 = zef.parcellation_roi_radius(i)*s_y + zef.parcellation_roi_center(i,2);
s_z_2 = zef.parcellation_roi_radius(i)*s_z + zef.parcellation_roi_center(i,3);
h_plot = surf(h_axes1,s_x_2,s_y_2,s_z_2);
set(h_plot,'facealpha',1,'edgecolor','none','facecolor',zef.parcellation_roi_color(i,:),'tag','additional: parcellation roi');
end

drawnow;
hold(h_axes1,'off');

end

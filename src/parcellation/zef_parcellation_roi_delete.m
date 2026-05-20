function zef = zef_parcellation_roi_delete(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_roi_delete — Zef parcellation roi delete.
%
% Purpose:
%   Zef parcellation roi delete.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.parcellation_roi_center (read, write)
%   zef.parcellation_roi_color (read, write)
%   zef.parcellation_roi_name (read, write)
%   zef.parcellation_roi_radius (read, write)
%   zef.parcellation_roi_selected (read, write)
%
% Calls (project):
%   zef_parcellation_roi_delete
%   zef_update_parcellation
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: `[zef] = zef_parcellation_roi_delete(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


I = [1 : size(zef.parcellation_roi_center,1)];
I = setdiff(I,zef.parcellation_roi_selected);
if not(isempty(I))
zef.parcellation_roi_center = zef.parcellation_roi_center(I,:);
zef.parcellation_roi_color = zef.parcellation_roi_color(I,:);
zef.parcellation_roi_radius = zef.parcellation_roi_radius(I);
zef.parcellation_roi_name = zef.parcellation_roi_name(I);
else
zef.parcellation_roi_center = [0 0 0];
zef.parcellation_roi_radius = [10];
zef.parcellation_roi_color = [0.56078 0.91373 1];
zef.parcellation_roi_name = [{'Used-defined ROI'}];
end
zef.parcellation_roi_selected = 1;
zef = zef_update_parcellation(zef);

end

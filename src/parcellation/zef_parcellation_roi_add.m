function zef = zef_parcellation_roi_add(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_roi_add — Zef parcellation roi add.
%
% Purpose:
%   Zef parcellation roi add.
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
%   zef_parcellation_roi_add
%   zef_update_parcellation
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_parcellation_roi_add(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef.parcellation_roi_selected = 1;
zef.parcellation_roi_center = [0 0 0; zef.parcellation_roi_center];
zef.parcellation_roi_radius = [10 zef.parcellation_roi_radius];
zef.parcellation_roi_color = [0.56078 0.91373 1; zef.parcellation_roi_color];
zef.parcellation_roi_name = [{'Used-defined ROI'} zef.parcellation_roi_name];
zef = zef_update_parcellation(zef);

end

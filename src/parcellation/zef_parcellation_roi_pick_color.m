function zef = zef_parcellation_roi_pick_color(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_roi_pick_color — Zef parcellation roi pick color.
%
% Purpose:
%   Zef parcellation roi pick color.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_parcellation_roi_color (read)
%   zef.parcellation_roi_color (read)
%   zef.parcellation_roi_selected (read)
%
% Calls (project):
%   zef_parcellation_roi_pick_color
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_parcellation_roi_pick_color(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


color_vec = uisetcolor;
if not(isequal(color_vec,0))
    color_str = num2str(color_vec);
    zef.h_parcellation_roi_color.String = color_str;
    zef.h_parcellation_roi_color.BackgroundColor = color_vec;
    zef.parcellation_roi_color(zef.parcellation_roi_selected,:) = color_vec;
end

end

function zef = zef_parcellation_roi_pick_center(zef)
% --- Zeffiro documentation header ---
% zef_parcellation_roi_pick_center — Zef parcellation roi pick center.
%
% Purpose:
%   Zef parcellation roi pick center.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_axes1 (read)
%   zef.h_datatip (read, write)
%   zef.h_parcellation_roi_center (read)
%   zef.parcellation_roi_center (read)
%   zef.parcellation_roi_selected (read)
%
% Calls (project):
%   zef_parcellation_roi_pick_center
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_parcellation_roi_pick_center(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if isempty(findobj(allchild(zef.h_axes1),'Type','DataTip'))~=1
    zef.h_datatip = findobj(allchild(zef.h_axes1),'Type','DataTip');
    zef.parcellation_roi_center(zef.parcellation_roi_selected,:) = [h_datatip(1).X h_datatip(1).Y h_datatip(1).Z];
    zef.h_parcellation_roi_center.String = num2str(zef.parcellation_roi_center(zef.parcellation_roi_selected,:));
end

end

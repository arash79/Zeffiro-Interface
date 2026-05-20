function zef = zef_DBS_strip_struct_update(zef)
% --- Zeffiro documentation header ---
% zef_DBS_strip_struct_update — Zef DBS strip struct update.
%
% Purpose:
%   Zef DBS strip struct update.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.strip_struct (read)
%
% Calls (project):
%   zef_Abbott_infinity_strip_multiple_probe
%   zef_DBS_strip_struct_update
%   zef_electrode_strip_multiple_probe
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_DBS_strip_struct_update(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    if zef.strip_struct.strip_type == 1
        zef = zef_electrode_strip_multiple_probe(zef);
    elseif zef.strip_struct.strip_type == 2
        zef = zef_Abbott_infinity_strip_multiple_probe(zef);
    end
end

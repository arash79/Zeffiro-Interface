function zef = zef_DBS_update_electrodes(zef)
% --- Zeffiro documentation header ---
% zef_DBS_update_electrodes — Zef DBS update electrodes.
%
% Purpose:
%   Zef DBS update electrodes.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_DBS_attach_electrodes
%   zef_DBS_update_electrodes
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_DBS_update_electrodes(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header

zef=zef_DBS_attach_electrodes(zef);
end

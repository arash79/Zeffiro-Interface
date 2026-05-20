function zef = zef_GMModel_open(zef)
% --- Zeffiro documentation header ---
% zef_GMModel_open — Zef GMModel open.
%
% Purpose:
%   Zef GMModel open.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Calls (project):
%   zef_GMModel_open
%   zef_GMModel_window
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_GMModel_open(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef = zef_GMModel_window(zef);
zef_GMModel_init;

end

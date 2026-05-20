function p_vec = zef_wireframe_permittivity_vec(f_vec,p_val)
% --- Zeffiro documentation header ---
% zef_wireframe_permittivity_vec — Zef wireframe permittivity vec.
%
% Purpose:
%   Zef wireframe permittivity vec.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   f_vec
%   p_val
%
% Outputs:
%   p_vec
%
% Calls (project):
%   zef_wireframe_permittivity_vec
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[p_vec] = zef_wireframe_permittivity_vec(f_vec, p_val)` with project root and `src` on the path.
% --- End Zeffiro documentation header


p_vec = (2.*f_vec.*(p_val - 1) + p_val + 2)./(2 + p_val - f_vec.*(p_val - 1));

end

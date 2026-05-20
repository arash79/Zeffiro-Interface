function [filling_vec] = zef_wireframe_filling_vec(eps_vec_1, eps_vec_2)
% --- Zeffiro documentation header ---
% zef_wireframe_filling_vec — Zef wireframe filling vec.
%
% Purpose:
%   Zef wireframe filling vec.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   eps_vec_1
%   eps_vec_2
%
% Outputs:
%   filling_vec
%
% Calls (project):
%   zef_wireframe_filling_vec
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[filling_vec] = zef_wireframe_filling_vec(eps_vec_1, eps_vec_2)` with project root and `src` on the path.
% --- End Zeffiro documentation header


filling_vec = - (real(eps_vec_2) - real(eps_vec_1).*(real(eps_vec_2) + 2) + 2)./(2.*real(eps_vec_2) + real(eps_vec_1).*(real(eps_vec_2) - 1) - 2);

end

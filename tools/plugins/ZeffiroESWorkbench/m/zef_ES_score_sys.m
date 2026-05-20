function [current_score] = zef_ES_score_sys(y, rwnnz)
% --- Zeffiro documentation header ---
% zef_ES_score_sys — Zef ES score sys.
%
% Purpose:
%   Zef ES score sys.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   y
%   rwnnz
%
% Outputs:
%   current_score
%
% Calls (project):
%   zef_ES_score_sys
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[current_score] = zef_ES_score_sys(y, rwnnz)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if istable(y)
    y = table2array(y);
end
sorted_y = cumsum(sort(abs(y),'descend'));
y = sorted_y/norm(y,1);
current_score = find(y >= rwnnz,1);
end

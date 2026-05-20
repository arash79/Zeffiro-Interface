% --- Zeffiro documentation header ---
% zef_git_push(zef.h_github_pat.Value,'message',[zef.h_github_author.Value  ': ' char(join(string(zef.h_github_message — Zef git push(zef.h github pat.Value,'message',[zef.h github author.Value  ': ' char(join(string(zef.h github message.
%
% Purpose:
%   Zef git push(zef.h github pat.Value,'message',[zef.h github author.Value  ': ' char(join(string(zef.h github message.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_git_push(zef.h_github_pat.Value,'message',[zef.h_github_author.Value  ': ' char(join(string(zef.h_github_message` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef_git_push(zef.h_github_pat.Value,'message',[zef.h_github_author.Value  ': ' char(join(string(zef.h_github_message.Value)))]);

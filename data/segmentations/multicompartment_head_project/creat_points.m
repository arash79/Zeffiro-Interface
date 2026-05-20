% --- Zeffiro documentation header ---
% a = load ('lh.all_aparc — A = load ('lh.all aparc.
%
% Purpose:
%   A = load ('lh.all aparc.
%   Folder: Bundled sample projects, segmentations, and runtime data roots referenced by examples and default startup.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `a = load ('lh.all_aparc` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

a = load ('lh.all_aparc.2009s');
c = a([3:end],[1:4]);
save lh_point.dat c

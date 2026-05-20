% --- Zeffiro documentation header ---
% a = load ('lh_labels_76 — A = load ('lh labels 76.
%
% Purpose:
%   A = load ('lh labels 76.
%   Folder: Bundled sample projects, segmentations, and runtime data roots referenced by examples and default startup.
%
% Side effects:
%   - filesystem I/O
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `a = load ('lh_labels_76` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

a = load ('lh_labels_76.asc');
c = a([3:end],[1:4]);
save lh_point_76.dat c
b = load ('rh_labels_76.asc');
d = b([3:end],[1:4]);
save rh_point_76.dat d
e = load ('lh_labels_36.asc');
f = e([3:end],[1:4]);
save lh_point_36.dat f
g = load ('lh_labels_36.asc');
h = g([3:end],[1:4]);
save lh_point_36.dat h
i = load ('rh_labels_36.asc');
j = i([3:end],[1:4]);
save lh_point_36.dat j

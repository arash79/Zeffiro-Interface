% --- Zeffiro documentation header ---
% lh.aparc.a2009s — Lh.aparc.a2009s.
%
% Purpose:
%   Lh.aparc.a2009s.
%   Folder: Bundled sample projects, segmentations, and runtime data roots referenced by examples and default startup.
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `lh.aparc.a2009s` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[vertices,label,colortable]=read_annotation([dir_name '/label/lh.aparc.a2009s.annot']);
save color_table_lh_76.mat colortable label vertices;
[vertices,label,colortable]=read_annotation([dir_name '/label/rh.aparc.a2009s.annot']);
save color_table_rh_76.mat colortable label vertices;
[vertices,label,colortable]=read_annotation([dir_name '/label/lh.aparc.annot']);
save color_table_lh_36.mat colortable label vertices;
[vertices,label,colortable]=read_annotation([dir_name '/label/rh.aparc.annot']);
save color_table_rh_36.mat colortable label vertices;

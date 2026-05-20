% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Interactive UI: App Designer exports, menu tools, callbacks, plot refresh, and `zef_update_*` sync from widgets to `zef`.
%
% Zef fields (observed):
%   zef.L_original_field (read, write)
%   zef.L_source_interpolation_ind_original_field (read, write)
%   zef.source_directions_original_field (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

zef.source_positions_original_field =[];
zef.source_directions_original_field = [];
zef.L_original_field = [];
zef.L_source_interpolation_ind_original_field = [];

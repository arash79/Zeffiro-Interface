%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef — Zef.
%
% Purpose:
%   Zef.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Zef fields (observed):
%   zef.parcellation_merge (read, write)
%   zef.parcellation_points (read, write)
%   zef.parcellation_selected (read, write)
%   zef.use_parcellation (read, write)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header



zef.parcellation_colortable = cell(0);
zef.parcellation_points = cell(0);
zef.parcellation_merge = 1;
zef.use_parcellation = 0;
zef.parcellation_selected = [];
zef_update_parcellation;

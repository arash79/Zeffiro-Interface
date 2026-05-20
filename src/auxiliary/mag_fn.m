function mag = mag_fn(La, Lfem)
% --- Zeffiro documentation header ---
% mag_fn — Mag fn.
%
% Purpose:
%   Mag fn.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   La
%   Lfem
%
% Outputs:
%   mag
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[mag] = mag_fn(La, Lfem)` with project root and `src` on the path.
% --- End Zeffiro documentation header

mag = 1 - sqrt(sum(Lfem.^2))' ./ sqrt(sum(La.^2))';
end

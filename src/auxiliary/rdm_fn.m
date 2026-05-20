function rdm = rdm_fn(La, Lfem)
% --- Zeffiro documentation header ---
% rdm_fn — Rdm fn.
%
% Purpose:
%   Rdm fn.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   La
%   Lfem
%
% Outputs:
%   rdm
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[rdm] = rdm_fn(La, Lfem)` with project root and `src` on the path.
% --- End Zeffiro documentation header

arguments
    La double
    Lfem double
end

scaled_Lfem = Lfem ./ repmat(sqrt(sum(Lfem.^2)), size(Lfem, 1), 1);
scaled_La = La ./ repmat(sqrt(sum(La.^2)), size(La, 1), 1);

diffs = scaled_Lfem - scaled_La;

rdm = sqrt(sum(diffs.^2))';

end

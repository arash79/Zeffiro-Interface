function weighting = zef_barycentric_weighting(weighting_type)
% --- Zeffiro documentation header ---
% zef_barycentric_weighting — Zef barycentric weighting.
%
% Purpose:
%   Zef barycentric weighting.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   weighting_type
%
% Outputs:
%   weighting
%
% Calls (project):
%   zef_barycentric_weighting
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[weighting] = zef_barycentric_weighting(weighting_type)` with project root and `src` on the path.
% --- End Zeffiro documentation header

switch weighting_type

    case 'FF'
        weighting = [1/10 1/20];
    case 'GG'
        weighting = [1];
    case 'FG'
        weighting = [1/4];
    case 'uFG'
        weighting = [1/10 1/20];
    case 'surface_FF'
        weighting = [1/6 1/12];
    case 'surface_FG'
        weighting = [1/3];
end

end

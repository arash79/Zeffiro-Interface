function [tetra, domain_labels] = zef_unique_tetra(tetra, domain_labels)
% --- Zeffiro documentation header ---
% zef_unique_tetra — Zef unique tetra.
%
% Purpose:
%   Zef unique tetra.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   tetra
%   domain_labels
%
% Outputs:
%   tetra
%   domain_labels
%
% Calls (project):
%   zef_unique_tetra
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[tetra, domain_labels]] = zef_unique_tetra(tetra, domain_labels)` with project root and `src` on the path.
% --- End Zeffiro documentation header


[~, I] = unique(sort(tetra,2),'rows');
tetra = tetra(I,:);
domain_labels = domain_labels(I,:);

end

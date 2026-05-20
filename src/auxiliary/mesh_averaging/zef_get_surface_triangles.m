function [surface_triangles] = zef_get_surface_triangles(tetra,labels,compartment_ind)
% --- Zeffiro documentation header ---
% zef_get_surface_triangles — Zef get surface triangles.
%
% Purpose:
%   Zef get surface triangles.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   tetra
%   labels
%   compartment_ind
%
% Outputs:
%   surface_triangles
%
% Calls (project):
%   zef_get_surface_triangles
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[surface_triangles] = zef_get_surface_triangles(tetra, labels, compartment_ind)` with project root and `src` on the path.
% --- End Zeffiro documentation header


I = find(labels==compartment_ind);
tetra = tetra(I,:);

ind_m = [ 2 4 3 ;
    1 3 4 ;
    1 4 2 ;
    1 2 3 ];

tetra_sort = [tetra(:,[2 4 3]) ones(size(tetra,1),1) [1:size(tetra,1)]';
    tetra(:,[1 3 4]) 2*ones(size(tetra,1),1) [1:size(tetra,1)]';
    tetra(:,[1 4 2]) 3*ones(size(tetra,1),1) [1:size(tetra,1)]';
    tetra(:,[1 2 3]) 4*ones(size(tetra,1),1) [1:size(tetra,1)]';];
tetra_sort(:,1:3) = sort(tetra_sort(:,1:3),2);
tetra_sort = sortrows(tetra_sort,[1 2 3]);
tetra_ind = zeros(size(tetra_sort,1),1);
I = find(sum(abs(tetra_sort(2:end,1:3)-tetra_sort(1:end-1,1:3)),2)==0);
tetra_ind(I) = 1;
tetra_ind(I+1) = 1;
I = find(tetra_ind == 0);
tetra_ind = sub2ind(size(tetra),repmat(tetra_sort(I,5),1,3),ind_m(tetra_sort(I,4),:));
surface_triangles = tetra(tetra_ind);

end

function [surface_triangles] = zef_get_surface_triangles(tetra,labels,compartment_ind)
%ZEF_GET_SURFACE_TRIANGLES  Faces of tetrahedra with labels==compartment_ind.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   surface_triangles = zef_get_surface_triangles(tetra, labels, compartment_ind)
%
%   Keeps tets where labels==compartment_ind. Faces that appear once
%   (sorted vertex triples) are the surface. Used by zef_find_distance_to_mesh
%   with zef.sigma(:,2) as labels.
%
%   See also zef_plot_surface_triangles, zef_surface_mesh.

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

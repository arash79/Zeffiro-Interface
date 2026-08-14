

function [boundary_triangles, boundary_tetra_ind] = free_boundary(tetra)
%FREE_BOUNDARY  Unique exterior triangles of a tetrahedral mesh.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   Faces that appear once (not shared) are the free boundary.
%
%   [boundary_triangles, boundary_tetra_ind] = free_boundary(tetra)
%
%   tetra may include a 5th domain-label column; only columns 1:4 are faces.
%
%   See also create_system, tetra_in_compartment.




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
boundary_triangles = tetra(tetra_ind);
boundary_tetra_ind = tetra_sort(I,5);

end

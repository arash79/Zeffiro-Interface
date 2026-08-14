

function [nodes,tetra,interp_vec] = refine_mesh(nodes,tetra)
%REFINE_MESH  Split every tetra into 8 by inserting edge midpoints.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   Unique edges become new nodes; interp_vec maps each child tet back to
%   its parent (length 8*n_tet). Domain label column 5 is copied. Called
%   n_refinement times from create_system.
%
%   [nodes, tetra, interp_vec] = refine_mesh(nodes, tetra)
%
%   See also create_system.




tetra_sort = [tetra(:,[1 2]);
    tetra(:,[2 3]);
    tetra(:,[3 1]);
    tetra(:,[1 4]);
    tetra(:,[2 4]);
    tetra(:,[3 4]);
    ];

tetra_sort = sort(tetra_sort,2);
[edges,edges_ind_1,edges_ind_2] = unique(tetra_sort,'rows');
edges_ind = reshape(edges_ind_2,size(edges_ind_2,1)/6,6);

edges_ind = edges_ind + size(nodes,1);
nodes = [nodes ; 0.5*(nodes(edges(:,1),:) + nodes(edges(:,2),:))];

interp_vec = repmat([1:size(tetra,1)]',8,1);

tetra  = [tetra(:,1) edges_ind(:,1) edges_ind(:,3) edges_ind(:,4) tetra(:,5) ;
    edges_ind(:,1)  tetra(:,2) edges_ind(:,2) edges_ind(:,5) tetra(:,5) ;
    edges_ind(:,3) edges_ind(:,2) tetra(:,3) edges_ind(:,6) tetra(:,5) ;
    edges_ind(:,4) edges_ind(:,5) edges_ind(:,6) tetra(:,4) tetra(:,5);
    edges_ind(:,3) edges_ind(:,4) edges_ind(:,1) edges_ind(:,6) tetra(:,5);
    edges_ind(:,6) edges_ind(:,5) edges_ind(:,1) edges_ind(:,2) tetra(:,5);
    edges_ind(:,4) edges_ind(:,1) edges_ind(:,6) edges_ind(:,5) tetra(:,5);
    edges_ind(:,3) edges_ind(:,1) edges_ind(:,2) edges_ind(:,6) tetra(:,5)
    ];

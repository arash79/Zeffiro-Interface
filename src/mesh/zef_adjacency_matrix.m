function [A, I, J] = zef_adjacency_matrix(nodes, tetra)
%ZEF_ADJACENCY_MATRIX  Sparse node–node adjacency of a tetrahedral mesh.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   [A, I, J] = zef_adjacency_matrix(nodes, tetra)
%
%   A(p,q) is nonzero when nodes p and q share a tet edge (spones of the
%   six edge pairs, symmetrized). I,J are the row/column index vectors
%   used to build A. St. Venant interpolation uses A(:,centre) as the
%   neighbour stencil. Waitbar with onCleanup.
%
%   See also zef_st_venant_interpolation.
arguments
    nodes (:,3) double {mustBeNonNan}
    tetra (:,4) double {mustBeInteger, mustBePositive}
end

% Initialization.

n_of_nodes = size(nodes,1);
A = spalloc(n_of_nodes,n_of_nodes,0);

% zef_waitbar and its cleanup object, which closes the zef_waitbar in case of
% termination.

wbtitle = 'Adjacency matrix';
wb = zef_waitbar(0,1, wbtitle);

cleanupfn = @(h) close(h);
cleanupobj = onCleanup(@() cleanupfn(wb));

% Begin iteration.

n_of_iters = 3 + 2 + 1;

for i = 1 : 4

    for j = i + 1 : 4

        ind = i + j - 1;
        progress_num = ind / n_of_iters;
        progress_str = [wbtitle, ': neighbours ', num2str(ind), ' / ', num2str(n_of_iters)];

        zef_waitbar(ind,n_of_iters, wb, progress_str);

        A = A + sparse(            ...
            tetra(:,i),            ...
            tetra(:,j),            ...
            ones(size(tetra,1),1), ...
            n_of_nodes,            ...
            n_of_nodes             ...
            );

    end
end

% Stensils are symmetric, as they describe an undirected graph.

zef_waitbar(0,1, wb, strcat(wbtitle, ': take care of symmetricity'));

A = A + A';

zef_waitbar(1,1, wb);

% Take care of the diagonal.

init_progress_str = strcat(wbtitle, ': the diagonal ');
zef_waitbar(0,1, wb, progress_str);

n_of_iters = 4;

for i = 1 : 4

    progress_num = i / n_of_iters;
    progress_str = [init_progress_str, ' ', num2str(i), ' / ', num2str(n_of_iters)];
    zef_waitbar(i,n_of_iters, wb, progress_str);

    A = A + sparse(            ...
        tetra(:,i),            ...
        tetra(:,i),            ...
        ones(size(tetra,1),1), ...
        n_of_nodes,            ...
        n_of_nodes             ...
        );

end

% Find indices and values of nonzero elements and force them into ones.

[I,J,K] = find(A);

K = ones(size(K));

A = sparse(I,J,K);

end

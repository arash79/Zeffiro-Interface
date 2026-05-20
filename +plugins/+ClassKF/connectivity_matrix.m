function [A] = connectivity_matrix(source_positions, K, weighted_avg)
%CONNECTIVITY_MATRIX Build spatial smoothing matrix from K nearest neighbors.
%
%   A = CONNECTIVITY_MATRIX(SOURCE_POSITIONS, K) constructs a sparse matrix A
%   such that each source point is connected to its K nearest spatial neighbors
%   with equal weights 1/K. Used for Kalman filter state transition and spatial
%   regularization in source reconstruction.
%
%   Inputs:
%     SOURCE_POSITIONS - N-by-3 matrix of source positions (x,y,z)
%     K                - Number of nearest neighbors per point
%     WEIGHTED_AVG     - (Optional) If true, use distance-weighted averaging.
%                        Default: false. Reserved for future implementation.
%
%   Output:
%     A - (3*N)-by-(3*N) sparse matrix. Source vector z is indexed as
%         [x_1,y_1,z_1, x_2,y_2,z_2, ...]; kron(A_1d, eye(3)) expands
%         the connectivity to x,y,z components.
%
%   See also KDTreeSearcher, knnsearch.

if nargin < 3
    weighted_avg = false;  % Reserved: distance-weighted averaging not yet implemented
end

% Find K nearest neighbors for each source point
MdlKDT = KDTreeSearcher(source_positions);
[IDX, ~] = knnsearch(MdlKDT, source_positions, 'K', K);

% Build sparse connectivity matrix with uniform weights 1/K
A = sparse(size(source_positions,1), size(source_positions,1));
row_idx = 1:size(A,1);

for n_neighbor = 1:K
    n_neighbor_ind = IDX(:,n_neighbor);
    idx = sub2ind(size(A), row_idx', n_neighbor_ind);
    A(idx) = 1/K;
end

% Expand to 3D: each source has (x,y,z) components
A = kron(A, eye(3));
end

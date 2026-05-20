function prec = jacobi ( A )
% jacobi — Jacobi (diagonal) preconditioner for a linear system.
%
% Builds the Jacobi preconditioner for the system A*x = b. The preconditioner
% is the inverse of the diagonal of A, so that prec = D^{-1} where D = diag(A).
% Applying the preconditioner is equivalent to scaling each equation by the
% inverse of its diagonal entry; it is cheap and often improves convergence
% when A is diagonally dominant.
%
% Input:
%   A (:,:) double — Square matrix of the linear system (real or complex).
%
% Output:
%   prec (:,:) — Preconditioner matrix such that the preconditioned system
%       is (prec*A)*x = prec*b. In practice, prec is applied as a linear
%       operator (e.g. in iterative solvers) rather than formed explicitly.
%
% Note:
%   If any diagonal entry of A is zero, the result will contain Inf or NaN.
%
% See also: core.preconditioners.ssor, diag.

    arguments
        A (:,:)
    end

    % M = D^{-1} with D = diag(A); stored as left factor for (D \ I).
    prec = diag ( diag ( A ) ) \ eye ( size ( A ) ) ;

end % function

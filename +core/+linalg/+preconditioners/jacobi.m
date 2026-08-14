function prec = jacobi ( A )
%JACOBI  Jacobi (diagonal) preconditioner matrix M = D^{-1}.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Builds the dense inverse-diagonal of A as (diag(diag(A)) \ I). Intended
%   for left-preconditioned iterative solvers. Lead-field PCG in src/forward
%   still uses its own SSOR/ichol path; this package helper is not yet wired
%   there.
%
%   prec = core.linalg.preconditioners.jacobi(A)
%
%   Input
%     A  - square matrix (sparse or dense).
%
%   Output
%     prec  - D^{-1} with D = diag(A), same size as A.
%
%   See also core.linalg.preconditioners.ssor.

    arguments
        A (:,:)
    end

    % M = D^{-1} with D = diag(A); stored as left factor for (D \ I).
    prec = diag ( diag ( A ) ) \ eye ( size ( A ) ) ;

end % function

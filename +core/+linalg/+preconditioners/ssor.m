function prec = ssor ( A, kwargs )
%SSOR  Symmetric successive over-relaxation preconditioner matrix.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   M = (D + ω L) D^{-1} (D + ω U) with L = tril(A), U = triu(A),
%   D = diag(A), and ω = kwargs.coeff in [0, 2] (default 1, which is SSOR
%   with unit relaxation / symmetric Gauss–Seidel). Not yet wired into
%   src/forward lead-field PCG.
%
%   prec = core.linalg.preconditioners.ssor(A)
%   prec = core.linalg.preconditioners.ssor(A, "coeff", 1)
%
%   See also core.linalg.preconditioners.jacobi.

    arguments
        A (:,:)
        kwargs.coeff (1,1) double { mustBeInRange(kwargs.coeff, 0, 2) } = 1
    end

    L = tril ( A ) ;
    U = triu ( A ) ;
    D = diag ( diag ( A ) ) ;
    invD = D \ eye ( size ( D ) ) ;
    coeff = kwargs.coeff ;

    % M = (D + coeff*L) * D^{-1} * (D + coeff*U)
    prec = ( D + coeff * L ) * invD * ( D + coeff * U ) ;

end % function

function prec = ssor ( A, kwargs )
% ssor — Symmetric successive over-relaxation (SSOR) preconditioner.
%
% Builds the SSOR preconditioner for the system A*x = b. With A = D + L + U
% (diagonal, strict lower, strict upper), the preconditioner is
%
%   M = (D/omega + L) * (D/omega)^{-1} * (D/omega + U)
%
% where omega is the relaxation coefficient (here named coeff). For coeff = 1,
% this reduces to the symmetric Gauss–Seidel preconditioner. The coefficient
% must lie in (0, 2) for theoretical convergence; typical values are in
% (1, 2) for over-relaxation.
%
% Input:
%   A (:,:) — Square matrix of the linear system.
%
% Optional name-value (kwargs):
%   coeff (1,1) double — Relaxation coefficient in (0, 2). Default 1
%       (Gauss–Seidel). Over-relaxation: coeff > 1.
%
% Output:
%   prec (:,:) — Preconditioner matrix. The preconditioned system is
%       (prec*A)*x = prec*b.
%
% See also: core.preconditioners.jacobi, tril, triu.

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

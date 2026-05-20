function prec = ssor ( A, kwargs )
% --- Zeffiro documentation header ---
% core.linalg.preconditioners.ssor — Ssor.
%
% Purpose:
%   Ssor.
%   Folder: Builds Jacobi and SSOR preconditioner matrices for sparse systems; not yet wired into legacy lead-field PCG loops.
%
% Inputs:
%   A
%   kwargs
%
% Outputs:
%   prec
%
% Calls (project):
%   core.linalg.preconditioners.ssor
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[prec] = core.linalg.preconditioners.ssor(A, kwargs)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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

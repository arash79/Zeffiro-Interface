function prec = jacobi ( A )
% --- Zeffiro documentation header ---
% core.linalg.preconditioners.jacobi — Jacobi.
%
% Purpose:
%   Jacobi.
%   Folder: Builds Jacobi and SSOR preconditioner matrices for sparse systems; not yet wired into legacy lead-field PCG loops.
%
% Inputs:
%   A
%
% Outputs:
%   prec
%
% Calls (project):
%   core.linalg.preconditioners.jacobi
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[prec] = core.linalg.preconditioners.jacobi(A)` with project root and `src` on the path.
% --- End Zeffiro documentation header

    arguments
        A (:,:)
    end

    % M = D^{-1} with D = diag(A); stored as left factor for (D \ I).
    prec = diag ( diag ( A ) ) \ eye ( size ( A ) ) ;

end % function

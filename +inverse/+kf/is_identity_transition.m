function tf = is_identity_transition(A)
%IS_IDENTITY_TRANSITION  True iff A is diagonal with ones on the diagonal.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   tf = inverse.kf.is_identity_transition(A)
%
%   The historical test was
%
%       isdiag(A) && all(diag(A) - 1) < eps
%
%   MATLAB parses that as (all(diag(A)-1)) < eps. all(...) is a scalar
%   logical, so the comparison is true whenever any diagonal entry is
%   exactly 1 (all() is false) and false when every entry differs from 1.
%   A mixed diagonal such as diag([1, 0.9, 1]) therefore took the identity
%   shortcut and dropped A from the predict/RTS step.
%
%   This helper is the intended test: every diagonal entry is 1.

    arguments
        A {mustBeA(A, ["double", "single", "gpuArray"])}
    end

    if isempty(A) || size(A, 1) ~= size(A, 2)
        tf = false;
        return
    end
    d = full(diag(A));
    if isa(d, "gpuArray")
        cls = classUnderlying(d);
    else
        cls = class(d);
    end
    tf = isdiag(A) && all(abs(d - 1) < eps(cls));
end

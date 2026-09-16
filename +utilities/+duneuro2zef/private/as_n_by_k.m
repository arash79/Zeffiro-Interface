function A = as_n_by_k(A, k, name)
%AS_N_BY_K  Orient a numeric array as N×k (rows are items).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    if ~isnumeric(A)
        error('duneuro2zef:InvalidInput', '%s must be numeric.', name);
    end
    A = double(A);
    if size(A, 2) == k
        return
    end
    if size(A, 1) == k && size(A, 2) ~= k
        A = A.';
        return
    end
    error('duneuro2zef:InvalidInput', '%s must be N×%d or %d×N, got %s.', ...
        name, k, k, mat2str(size(A)));
end

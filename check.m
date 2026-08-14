%CHECK  One-off timeit of a 10000×10000 rand matrix multiply.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Does not use zef, the project path, or any Zeffiro function.
%   Allocates A and B as rand(10000,10000) and prints timeit(@() A*B).
%   Lab micro-benchmark; not part of the session API.
%

m = 10000;
n = 10000;
p = 10000;

A = rand(m,n);
B = rand(n,p);

f = @() A * B;
t = timeit(f);

fprintf("Time: %.6f seconds\n", t)
;

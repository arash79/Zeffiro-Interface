function [x, function_val, flag_val] = zef_cvx_semidefprog(z, y, A,b,Aeq,beq,lb,ub,varargin)
%ZEF_CVX_SEMIDEFPROG  CVX wrapper for ES search_method 2 (L1L2 / SDP setup).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_ES_optimize_current case 2 (not search_method 5).
%   Minimizes ||z.*x|| + y'*x with the same A x <= b bounds as the LP
%   wrapper.
%
%   [x, fval, flag] = zef_cvx_semidefprog(z, y, A, b, Aeq, beq, lb, ub, opts)
%
%   See also zef_ES_optimize_current, zef_cvx_linprog.
%

opts = [];

max_1_norm = []; %#ok<*NASGU>
max_infty_norm = [];
function_val = [];
solver_package = 'sdpt3';

if not(isempty(varargin))
        opts = varargin{1};
end

flag_val = -2;
n = size(A,2);

if isfield(opts,'Solver')
    solver_package = opts.Solver;
end

try
cvx_solver(solver_package)
end

if isfield(opts,'TolVal')
    cvx_precision(opts.TolVal)
end

if isequal(opts.Display,'off')

cvx_begin quiet
variable x(n)
minimize(norm(z.*x) + sum(y.*x))
subject to: 

A*x - b <= 0; %#ok<*VUNUS>
if not(isempty(lb))
x >= lb;
end
if not(isempty(ub))
x <= ub;
end
if not(isempty(Aeq))
Aeq*x == beq;
end

cvx_end

else
   cvx_begin quiet
variable x(n)
minimize(norm(z.*x) + sum(y.*x))
subject to: 

A*x - b <= 0; %#ok<*VUNUS>
if not(isempty(lb))
x >= lb;
end
if not(isempty(ub))
x <= ub;
end
if not(isempty(Aeq))
Aeq*x == beq;
end

cvx_end
end

if isequal(cvx_status,'Solved')
    flag_val = 1; 
    function_val = norm(A*x-b,1);
    
end
end

function [x, function_val, flag_val] = zef_cvx_linprog(z,A,b,Aeq,beq,lb,ub,varargin)
%ZEF_CVX_LINPROG  CVX linear program used when ES_opt_solver is SDPT3 or SeDuMi (LP).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_ES_optimize_current search_method 1 when the solver
%   package is 'sdpt3' or 'sedumi' (ES_opt_solver_list entries 2–3). linprog
%   signature: minimize z'*x s.t. A x <= b, Aeq x = beq, lb <= x <= ub.
%   Optional last argument is an opts struct (solver, TolFun, Display).
%   flag_val = 1 if cvx_status is Solved.
%
%   [x, fval, flag] = zef_cvx_linprog(z, A, b, Aeq, beq, lb, ub, opts)
%
%   See also zef_ES_optimize_current, zef_cvx_quadprog.
%

opts = [];
solver_package = 'sdpt3';

max_1_norm = []; %#ok<*NASGU>
max_infty_norm = [];
function_val = [];

if not(isempty(varargin))
        opts = varargin{1};
end

flag_val = -2;
n = size(A,2);

if isfield(opts,'solver')
    solver_package = opts.solver;
end

try
cvx_solver(solver_package)
end

if isfield(opts,'TolFun')
    cvx_precision(opts.TolFun)
end

if isequal(opts.Display,'off')
cvx_begin quiet
variable x(n)
minimize sum(z.*x)
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
   cvx_begin 
variable x(n)
minimize sum(z.*x)
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

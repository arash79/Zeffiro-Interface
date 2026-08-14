function [x,fval,exitflag] = zef_gurobi_linprog(f,A,b,Aeq,beq,lb,ub,options)
%ZEF_GUROBI_LINPROG  Gurobi linprog-compatible wrapper for ES LP.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Called from zef_ES_optimize_current search_method 1 when
%   ES_opt_solver_list{ES_opt_solver} is 'Gurobi'. Maps Algorithm
%   interior-point/dual-simplex/primal-simplex onto Gurobi Method 2/1/0.
%   exitflag 1 = OPTIMAL (linprog-style).
%
%   [x, fval, exitflag] = zef_gurobi_linprog(f, A, b, Aeq, beq, lb, ub, options)
%
%   See also zef_ES_optimize_current, zef_mosek_linprog.
%

if nargin < 4
    Aeq = [];
end

if nargin < 5
    beq = [];
end

model.obj   = f;
model.A     = [sparse(A); Aeq];
model.sense = [repmat('<',size(A,1),1); repmat('=',size(Aeq,1),1)];
model.rhs   = [b; beq];

if nargin > 5
    if not(isempty(lb))
        model.lb = lb;
    else
        model.lb = -Inf*ones(size(A,2),1);
    end
end

if nargin > 6
    if not(isempty(ub))
        model.ub = ub;
    else
        model.ub = Inf*ones(size(A,2),1);
    end
end

params.TimeLimit        = options.MaxTime;
params.BarIterLimit     = options.MaxIter;
params.IterationLimit   = options.MaxIter;

if      isequal(lower(options.Algorithm),'interior-point')
    params.Method = 2;
elseif  isequal(lower(options.Algorithm),'dual-simplex')
    params.Method = 1;
elseif  isequal(lower(options.Algorithm),'primal-simplex')
    params.Method = 0;
end

if isequal(options.Display,'off')
    params.OutputFlag = 0;
else
    params.OutputFlag = 1;
end

params.Crossover = 0;
params.BarConvTol = options.TolFun;
params.OptimalityTol = options.TolFun;

result = gurobi(model,params);

try
    x = result.x;
catch
    x = 0;
end

fval = [];

if isfield(result,'objval')
    fval = result.objval;
end

if     strcmp(result.status,'OPTIMAL')
    exitflag = 1;
elseif strcmp(result.status,'UNBOUNDED')
    exitflag = -3;
elseif strcmp(result.status,'ITERATION_LIMIT')
    exitflag = 0;
else
    exitflag = -2;
end

end

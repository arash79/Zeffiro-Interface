function [x,fval,exitflag] = zef_gurobi_linprog(f,A,b,Aeq,beq,lb,ub,options)
% --- Zeffiro documentation header ---
% zef_gurobi_linprog — Zef gurobi linprog.
%
% Purpose:
%   Zef gurobi linprog.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   f
%   A
%   b
%   Aeq
%   beq
%   lb
%   ub
%   options
%
% Outputs:
%   x
%   fval
%   exitflag
%
% Calls (project):
%   zef_gurobi_linprog
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[x, fval, exitflag]] = zef_gurobi_linprog(f, A, b, Aeq, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header


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

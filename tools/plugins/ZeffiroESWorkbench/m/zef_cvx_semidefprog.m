function [x, function_val, flag_val] = zef_cvx_linprog(z, y, A,b,Aeq,beq,lb,ub,varargin)
% --- Zeffiro documentation header ---
% zef_cvx_linprog — Zef cvx linprog.
%
% Purpose:
%   Zef cvx linprog.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   z
%   y
%   A
%   b
%   Aeq
%   beq
%   lb
%   ub
%   varargin
%
% Outputs:
%   x
%   function_val
%   flag_val
%
% Calls (project):
%   zef_cvx_linprog
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[x, function_val, flag_val]] = zef_cvx_linprog(z, y, A, b, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

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

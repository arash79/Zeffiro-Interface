function x = zef_l2_l1_optimizer(L, y, reg_param, options)
% --- Zeffiro documentation header ---
% zef_l2_l1_optimizer — Zef l2 l1 optimizer.
%
% Purpose:
%   Zef l2 l1 optimizer.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   L
%   y
%   reg_param
%   options
%
% Outputs:
%   x
%
% Calls (project):
%   zef_l2_l1_optimizer
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[x] = zef_l2_l1_optimizer(L, y, reg_param, options)` with project root and `src` on the path.
% --- End Zeffiro documentation header


H = [ L'*L zeros(size(L,2), size(L,2)) ; zeros(size(L,2), 2*size(L,2)) ];
f = [ - L'*y ; reg_param ];

A = [ eye(size(L,2)) -eye(size(L,2)); -eye(size(L,2)) eye(size(L,2)); zeros(size(L,2)) -eye(size(L,2))];
b = [ zeros(3*size(L,2),1) ];

x = quadprog(H, f, A, b, [], [], [], [], [], options);
x = x(1:size(L,2));

end

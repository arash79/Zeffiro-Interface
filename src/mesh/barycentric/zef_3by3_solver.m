function [x,y,z,D] = zef_3by3_solver(a,b,c,d,D)
% --- Zeffiro documentation header ---
% zef_3by3_solver — Zef 3by3 solver.
%
% Purpose:
%   Zef 3by3 solver.
%   Folder: FEM mesh generation, surface processing, refinement, and barycentric operators.
%
% Inputs:
%   a
%   b
%   c
%   d
%   D
%
% Outputs:
%   x
%   y
%   z
%   D
%
% Calls (project):
%   zef_3by3_solver
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[x, y, z]] = zef_3by3_solver(a, b, c, d, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

x = [];
y = [];
z = [];

if nargin < 5

    D = a(:,1).*(b(:,2).*c(:,3) - b(:,3).*c(:,2));
    D = D - b(:,1).*(a(:,2).*c(:,3) - a(:,3).*c(:,2));
    D = D + c(:,1).*(a(:,2).*b(:,3) - a(:,3).*b(:,2));

end

if nargin > 3

    D_x =  d(:,1).*(b(:,2).*c(:,3) - b(:,3).*c(:,2));
    D_x = D_x   - b(:,1).*(d(:,2).*c(:,3) - d(:,3).*c(:,2));
    D_x = D_x   + c(:,1).*(d(:,2).*b(:,3) - d(:,3).*b(:,2));

    D_y = a(:,1).*(d(:,2).*c(:,3) - d(:,3).*c(:,2));
    D_y = D_y - d(:,1).*(a(:,2).*c(:,3) - a(:,3).*c(:,2));
    D_y = D_y + c(:,1).*(a(:,2).*d(:,3) - a(:,3).*d(:,2));

    D_z = a(:,1).*(b(:,2).*d(:,3) - b(:,3).*d(:,2));
    D_z = D_z - b(:,1).*(a(:,2).*d(:,3) - a(:,3).*d(:,2));
    D_z = D_z + d(:,1).*(a(:,2).*b(:,3) - a(:,3).*b(:,2));

    x = D_x./D;
    y = D_y./D;
    z = D_z./D;

end

end

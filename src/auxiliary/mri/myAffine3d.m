function [point] = myAffine3d(point, matrix)
% --- Zeffiro documentation header ---
% myAffine3d — My Affine3d.
%
% Purpose:
%   My Affine3d.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Inputs:
%   point
%   matrix
%
% Outputs:
%   point
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[point] = myAffine3d(point, matrix)` with project root and `src` on the path.
% --- End Zeffiro documentation header

[N, ~]=size(point);

point=point';
point=vertcat(point, ones(1,N));

point=matrix*point;

point=point(1:3,:);

point=point';

end

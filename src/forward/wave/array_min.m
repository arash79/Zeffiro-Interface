%Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%See: https://github.com/sampsapursiainen/GPU-Torre-3D

function [min_ind] = array_min(i, xq, yq, zq, nodes_aux)
% --- Zeffiro documentation header ---
% array_min — Array min.
%
% Purpose:
%   Array min.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   i
%   xq
%   yq
%   zq
%   nodes_aux
%
% Outputs:
%   min_ind
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[min_ind] = array_min(i, xq, yq, zq, …)` with project root and `src` on the path.
% --- End Zeffiro documentation header

aux_pos = [xq(i),yq(i),zq(i)];
[min_val,min_ind] = min(sqrt(sum((nodes_aux - aux_pos(ones(size(nodes_aux,1),1),:)).^2,2)));
min_ind = gather(min_ind);
end

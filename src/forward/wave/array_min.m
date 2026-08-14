
function [min_ind] = array_min(i, xq, yq, zq, nodes_aux)
%ARRAY_MIN  Index of the nearest nodes_aux row to query (xq(i), yq(i), zq(i)).
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   min_ind = array_min(i, xq, yq, zq, nodes_aux)
%
%   See also make_interp_mat.



aux_pos = [xq(i),yq(i),zq(i)];
[min_val,min_ind] = min(sqrt(sum((nodes_aux - aux_pos(ones(size(nodes_aux,1),1),:)).^2,2)));
min_ind = gather(min_ind);
end

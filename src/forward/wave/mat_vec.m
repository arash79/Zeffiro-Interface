%Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%See: https://github.com/sampsapursiainen/GPU-Torre-3D


function [y] = mat_vec(R,x,gpu_extended_memory)
% --- Zeffiro documentation header ---
% mat_vec — Mat vec.
%
% Purpose:
%   Mat vec.
%   Folder: Forward modeling: lead-field FEM assembly, DTI conductivity, NSE, wave models, and PCG solvers.
%
% Inputs:
%   R
%   x
%   gpu_extended_memory
%
% Outputs:
%   y
%
% Side effects:
%   - GPU
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[y] = mat_vec(R, x, gpu_extended_memory)` with project root and `src` on the path.
% --- End Zeffiro documentation header


R = gpuArray(R);
x = gpuArray(double(x));
y = R*x;

if (ismember(gpu_extended_memory,[0 2]))
    y = gather(y);
end

end

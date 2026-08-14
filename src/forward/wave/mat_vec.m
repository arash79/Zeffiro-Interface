

function [y] = mat_vec(R,x,gpu_extended_memory)
%MAT_VEC  Sparse y = R*x, with optional gather when gpu_extended_memory ∈ [0 2].
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   Damping/mass product in the leap-frog loop. R is the sparse matrix from
%   create_system; x is the current field.
%
%   y = mat_vec(R, x, gpu_extended_memory)
%
%   See also compute_data_gpu, pcg_iteration_gpu.




R = gpuArray(R);
x = gpuArray(double(x));
y = R*x;

if (ismember(gpu_extended_memory,[0 2]))
    y = gather(y);
end

end

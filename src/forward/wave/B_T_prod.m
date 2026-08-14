

function [div_u] = B_T_prod(p_1, p_2, p_3, div_vec, n, t, gpu_extended_memory)
%B_T_PROD  Discrete divergence B' of (p1,p2,p3) plus boundary injection div_vec.
%
%   Zeffiro Interface (GPU-ToRRe-3D wave module).
%   Copyright © 2021- Sampsa Pursiainen & GPU-ToRRe-3D Development Team
%   See: https://github.com/sampsapursiainen/GPU-Torre-3D
%
%   Adjoint of B_prod in the leap-frog pair: updates the E-like unknown
%   from the three H components. div_vec carries the orbit/AST boundary
%   source. gpu_extended_memory as in B_prod.
%
%   div_u = B_T_prod(p_1, p_2, p_3, div_vec, n, t, gpu_extended_memory)
%
%   See also B_prod, compute_data_gpu.




n = gpuArray(n);
t = gpuArray(t);

div_u = gpuArray(zeros(size(n,1),3));
div_vec = gpuArray(div_vec);

v_ind = [ 1 2 3 4; 2 3 1 4; 3 4 1 2; 4 1 3 2];
size_n = [size(n,1) 1];

for i = 1 : 4

    aux_vec = n(t(:,v_ind(i,2)),:);
    v1 = n(t(:,v_ind(i,4)),:);
    v1 = v1 - aux_vec;
    v2 = n(t(:,v_ind(i,3)),:);
    v2 = v2 - aux_vec;

    for k = 1 : 3

        p_aux = gpuArray(p_1(:,k));
        if k == 1
            p_aux = p_aux - div_vec;
        end
        aux_vec = p_aux.*v1(:,2).*v2(:,3);
        aux_vec = aux_vec - p_aux.*v1(:,3).*v2(:,2);

        p_aux = gpuArray(p_2(:,k));
        if k == 2
            p_aux = p_aux - div_vec;
        end
        aux_vec = aux_vec - p_aux.*v1(:,1).*v2(:,3);
        aux_vec = aux_vec + p_aux.*v1(:,3).*v2(:,1);

        p_aux = gpuArray(p_3(:,k));
        if k == 3
            p_aux = p_aux - div_vec;
        end
        aux_vec = aux_vec + p_aux.*v1(:,1).*v2(:,2);
        aux_vec = aux_vec - p_aux.*v1(:,2).*v2(:,1);

        clear p_aux;

        if i == 1

            div_u(:,k) = accumarray(t(:,i),aux_vec,size_n);

        else

            div_u(:,k) = div_u(:,k) + accumarray(t(:,i),aux_vec,size_n);

        end

    end

end

div_u = div_u/6;

if ismember(gpu_extended_memory,[0 2])
    div_u = gather(div_u);
end

end
